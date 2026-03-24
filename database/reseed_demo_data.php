<?php
declare(strict_types=1);

date_default_timezone_set('America/Caracas');

require_once __DIR__ . '/../config/global.php';

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$db = new mysqli(DB_HOST, DB_USERNAME, DB_PASSWORD, DB_NAME);
$db->set_charset('utf8mb4');

function run(mysqli $db, string $sql): void
{
    $db->query($sql);
}

function fetchAllAssoc(mysqli $db, string $sql): array
{
    $rows = array();
    $result = $db->query($sql);
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
    }
    $result->free();
    return $rows;
}

function fetchOneAssoc(mysqli $db, string $sql): ?array
{
    $result = $db->query($sql);
    $row = $result->fetch_assoc();
    $result->free();
    return $row ?: null;
}

function fetchValue(mysqli $db, string $sql)
{
    $row = fetchOneAssoc($db, $sql);
    if ($row === null) {
        return null;
    }

    $values = array_values($row);
    return $values[0] ?? null;
}

function sqlValue(mysqli $db, $value): string
{
    if ($value === null) {
        return 'NULL';
    }

    if (is_bool($value)) {
        return $value ? '1' : '0';
    }

    if (is_int($value) || is_float($value)) {
        return (string) $value;
    }

    return "'" . $db->real_escape_string((string) $value) . "'";
}

function insertRow(mysqli $db, string $table, array $data): void
{
    $columns = array();
    $values = array();

    foreach ($data as $column => $value) {
        $columns[] = "`$column`";
        $values[] = sqlValue($db, $value);
    }

    $sql = "INSERT INTO `$table` (" . implode(', ', $columns) . ") VALUES (" . implode(', ', $values) . ")";
    run($db, $sql);
}

function updateRowById(mysqli $db, string $table, string $pk, int $id, array $data): void
{
    $sets = array();
    foreach ($data as $column => $value) {
        $sets[] = "`$column` = " . sqlValue($db, $value);
    }

    $sql = "UPDATE `$table` SET " . implode(', ', $sets) . " WHERE `$pk` = " . (int) $id;
    run($db, $sql);
}

function fetchPairs(mysqli $db, string $sql, string $keyColumn, string $valueColumn): array
{
    $pairs = array();
    foreach (fetchAllAssoc($db, $sql) as $row) {
        $pairs[(string) $row[$keyColumn]] = (int) $row[$valueColumn];
    }
    return $pairs;
}

function ensureDirectory(string $path): void
{
    if (!is_dir($path) && !mkdir($path, 0777, true) && !is_dir($path)) {
        throw new RuntimeException('No se pudo crear el directorio: ' . $path);
    }
}

function pickFirstMatch(string $directory, string $pattern): ?string
{
    $matches = glob(rtrim($directory, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . $pattern);
    if (!$matches) {
        return null;
    }

    sort($matches);
    return $matches[0];
}

function ensureEmployee(mysqli $db, array $data): int
{
    $cedula = (int) $data['cedula'];
    $row = fetchOneAssoc($db, "SELECT id_empleado FROM empleados WHERE cedula = $cedula LIMIT 1");

    if ($row) {
        $id = (int) $row['id_empleado'];
        updateRowById($db, 'empleados', 'id_empleado', $id, $data);
        return $id;
    }

    insertRow($db, 'empleados', $data);
    return (int) fetchValue($db, "SELECT id_empleado FROM empleados WHERE cedula = $cedula LIMIT 1");
}

function ensureUser(mysqli $db, array $data): int
{
    $usuario = $db->real_escape_string((string) $data['usuario']);
    $row = fetchOneAssoc($db, "SELECT id_usuario FROM usuarios WHERE usuario = '$usuario' LIMIT 1");

    if ($row) {
        $id = (int) $row['id_usuario'];
        updateRowById($db, 'usuarios', 'id_usuario', $id, $data);
        return $id;
    }

    insertRow($db, 'usuarios', $data);
    return (int) fetchValue($db, "SELECT id_usuario FROM usuarios WHERE usuario = '$usuario' LIMIT 1");
}

function ensureUserAccess(mysqli $db, int $userId, array $data): void
{
    $row = fetchOneAssoc($db, "SELECT id_usuario FROM usuarios_seguridad_acceso WHERE id_usuario = $userId LIMIT 1");

    if ($row) {
        updateRowById($db, 'usuarios_seguridad_acceso', 'id_usuario', $userId, $data);
        return;
    }

    insertRow($db, 'usuarios_seguridad_acceso', array_merge(array('id_usuario' => $userId), $data));
}

function syncUserPermissions(mysqli $db, int $userId, array $permissionIds): void
{
    $wanted = array();
    foreach ($permissionIds as $permissionId) {
        $wanted[(int) $permissionId] = true;
    }

    $rows = fetchAllAssoc(
        $db,
        "SELECT id_usuario_permiso, id_permiso
         FROM usuario_permisos
         WHERE id_usuario = $userId
         ORDER BY id_usuario_permiso ASC"
    );

    $grouped = array();
    foreach ($rows as $row) {
        $grouped[(int) $row['id_permiso']][] = (int) $row['id_usuario_permiso'];
    }

    foreach ($grouped as $permissionId => $ids) {
        $state = isset($wanted[$permissionId]) ? 1 : 0;
        foreach ($ids as $userPermissionId) {
            updateRowById($db, 'usuario_permisos', 'id_usuario_permiso', $userPermissionId, array('estado' => $state));
        }
    }

    foreach (array_keys($wanted) as $permissionId) {
        if (isset($grouped[$permissionId])) {
            continue;
        }

        insertRow($db, 'usuario_permisos', array(
            'id_usuario' => $userId,
            'id_permiso' => $permissionId,
            'estado' => 1,
        ));
    }
}

function ensureDriver(mysqli $db, array $data): int
{
    $employeeId = (int) $data['id_empleado'];
    $row = fetchOneAssoc($db, "SELECT id_chofer_ambulancia FROM choferes_ambulancia WHERE id_empleado = $employeeId LIMIT 1");

    if ($row) {
        $id = (int) $row['id_chofer_ambulancia'];
        updateRowById($db, 'choferes_ambulancia', 'id_chofer_ambulancia', $id, $data);
        return $id;
    }

    insertRow($db, 'choferes_ambulancia', $data);
    return (int) fetchValue($db, "SELECT id_chofer_ambulancia FROM choferes_ambulancia WHERE id_empleado = $employeeId LIMIT 1");
}

function ensureUnit(mysqli $db, array $data): int
{
    $code = $db->real_escape_string((string) $data['codigo_unidad']);
    $row = fetchOneAssoc($db, "SELECT id_unidad FROM unidades WHERE codigo_unidad = '$code' LIMIT 1");

    if ($row) {
        $id = (int) $row['id_unidad'];
        updateRowById($db, 'unidades', 'id_unidad', $id, $data);
        return $id;
    }

    insertRow($db, 'unidades', $data);
    return (int) fetchValue($db, "SELECT id_unidad FROM unidades WHERE codigo_unidad = '$code' LIMIT 1");
}

function buildTicket(string $prefix, string $date, int $id): string
{
    return $prefix . '-' . str_replace('-', '', substr($date, 0, 10)) . '-' . str_pad((string) $id, 6, '0', STR_PAD_LEFT);
}

function insertFollowUp(mysqli $db, string $module, int $referenceId, int $stateId, int $userId, string $dateTime, string $observation): void
{
    insertRow($db, 'seguimientos_solicitudes', array(
        'modulo' => $module,
        'id_referencia' => $referenceId,
        'id_estado_solicitud' => $stateId,
        'id_usuario' => $userId,
        'fecha_gestion' => $dateTime,
        'observacion' => $observation,
        'estado' => 1,
    ));
}

function callAuthenticationLog(mysqli $db, int $userId, string $username, string $action, string $detail, string $ip): void
{
    $sql = sprintf(
        "CALL sp_bitacora_registrar_autenticacion(%d, %s, %s, %s, %s)",
        $userId,
        sqlValue($db, $username),
        sqlValue($db, $action),
        sqlValue($db, $detail),
        sqlValue($db, $ip)
    );
    run($db, $sql);

    while ($db->more_results()) {
        $db->next_result();
        $extra = $db->store_result();
        if ($extra instanceof mysqli_result) {
            $extra->free();
        }
    }
}

function copySupportFile(string $source, string $destination): void
{
    if (!copy($source, $destination)) {
        throw new RuntimeException('No se pudo copiar el soporte ' . basename($destination));
    }
}

echo "Preparando carga demo..." . PHP_EOL;

$communityRows = fetchAllAssoc($db, "SELECT id_comunidad, nombre_comunidad FROM comunidades WHERE estado = 1 ORDER BY id_comunidad ASC");
$communityMap = array();
foreach ($communityRows as $row) {
    $communityMap[(int) $row['id_comunidad']] = (string) $row['nombre_comunidad'];
}

$stateIds = fetchPairs(
    $db,
    "SELECT codigo_estado, id_estado_solicitud FROM estados_solicitudes WHERE estado = 1",
    'codigo_estado',
    'id_estado_solicitud'
);
$requestIds = fetchPairs(
    $db,
    "SELECT codigo_solicitud, id_solicitud_general FROM solicitudes_generales WHERE estado = 1",
    'codigo_solicitud',
    'id_solicitud_general'
);
$requestNames = array();
foreach (fetchAllAssoc($db, "SELECT codigo_solicitud, nombre_solicitud FROM solicitudes_generales WHERE estado = 1") as $row) {
    $requestNames[(string) $row['codigo_solicitud']] = (string) $row['nombre_solicitud'];
}
$aidTypeIds = fetchPairs(
    $db,
    "SELECT nombre_tipo_ayuda, id_tipo_ayuda_social FROM tipos_ayuda_social WHERE estado = 1",
    'nombre_tipo_ayuda',
    'id_tipo_ayuda_social'
);
$securityTypeIds = fetchPairs(
    $db,
    "SELECT nombre_tipo, id_tipo_seguridad FROM tipos_seguridad_emergencia WHERE estado = 1",
    'nombre_tipo',
    'id_tipo_seguridad'
);
$serviceTypeIds = fetchPairs(
    $db,
    "SELECT codigo_tipo_servicio_publico, id_tipo_servicio_publico FROM tipos_servicios_publicos WHERE estado = 1",
    'codigo_tipo_servicio_publico',
    'id_tipo_servicio_publico'
);
$serviceTypeNames = array();
foreach (fetchAllAssoc($db, "SELECT codigo_tipo_servicio_publico, nombre_tipo_servicio FROM tipos_servicios_publicos WHERE estado = 1") as $row) {
    $serviceTypeNames[(string) $row['codigo_tipo_servicio_publico']] = (string) $row['nombre_tipo_servicio'];
}
$permissionIds = fetchPairs(
    $db,
    "SELECT nombre_permiso, id_permiso FROM permisos WHERE estado = 1",
    'nombre_permiso',
    'id_permiso'
);

if (!$communityMap || !$stateIds || !$requestIds || !$aidTypeIds || !$securityTypeIds || !$serviceTypeIds || !$permissionIds) {
    throw new RuntimeException('Faltan catalogos base requeridos para construir la demo.');
}

$supportDirSolicitudes = __DIR__ . '/../uploads/reportes_solicitudes_ambulancia';
$supportDirTraslado = __DIR__ . '/../uploads/reportes_traslado';
ensureDirectory($supportDirSolicitudes);
ensureDirectory($supportDirTraslado);

$registrationTemplate = pickFirstMatch($supportDirSolicitudes, '*registro*.pdf');
$closureTemplate = pickFirstMatch($supportDirSolicitudes, '*cierre*.pdf');
$imageTemplate = pickFirstMatch($supportDirTraslado, '*.jpg');
if ($imageTemplate === null) {
    $imageTemplate = pickFirstMatch($supportDirTraslado, '*.png');
}

if ($registrationTemplate === null || $closureTemplate === null || $imageTemplate === null) {
    throw new RuntimeException('No se encontraron archivos base suficientes para reportes demo.');
}

echo "Vaciando tablas operativas..." . PHP_EOL;

run($db, "SET FOREIGN_KEY_CHECKS = 0");
foreach (array(
    'reportes_traslado',
    'reportes_solicitudes_ambulancia',
    'despachos_unidades',
    'seguimientos_solicitudes',
    'ayuda_social',
    'servicios_publicos',
    'seguridad',
    'asignaciones_unidades_choferes',
    'choferes_ambulancia',
    'unidades',
    'beneficiarios',
    'bitacora',
) as $table) {
    run($db, "TRUNCATE TABLE `$table`");
}
run($db, "SET FOREIGN_KEY_CHECKS = 1");

echo "Ajustando empleados y usuarios demo..." . PHP_EOL;

$demoPassword = 'DemoSala2026!';
$demoPasswordHash = hash('sha256', $demoPassword);

$employeeIds = array();
foreach (array(
    array(30124567, 'Jose Gregorio', 'Carrasco', 4, '0412-5503412', 'jose.carrasco@situacional.demo', 'Tocuyito, sector centro'),
    array(28455102, 'Maria Alejandra', 'Perez', 2, '0414-5503413', 'maria.perez@situacional.demo', 'Tocuyito, casco central'),
    array(26789012, 'Luis Alberto', 'Romero', 7, '0424-5503414', 'luis.romero@situacional.demo', 'Parroquia Independencia'),
    array(19654321, 'Carmen Elena', 'Vargas', 4, '0416-5503415', 'carmen.vargas@situacional.demo', 'Barrio El Oasis'),
    array(21567890, 'Pedro Antonio', 'Rivas', 2, '0412-5503416', 'pedro.rivas@situacional.demo', 'Urbanizacion La Esperanza'),
    array(18345678, 'Ana Beatriz', 'Salazar', 4, '0414-5503417', 'ana.salazar@situacional.demo', 'Santa Eduviges'),
    array(25432109, 'Ramon Eduardo', 'Suarez', 3, '0424-5503418', 'ramon.suarez@situacional.demo', 'Comunidad Bicentenario'),
) as $seed) {
    $employeeIds[(int) $seed[0]] = ensureEmployee($db, array(
        'cedula' => (int) $seed[0],
        'nombre' => $seed[1],
        'apellido' => $seed[2],
        'id_dependencia' => (int) $seed[3],
        'telefono' => $seed[4],
        'correo' => $seed[5],
        'direccion' => $seed[6],
        'estado' => 1,
    ));
}

$adminUserId = (int) fetchValue($db, "SELECT id_usuario FROM usuarios WHERE usuario = 'admin' LIMIT 1");
if ($adminUserId <= 0) {
    throw new RuntimeException('No se encontro el usuario admin actual.');
}

$userIds = array('admin' => $adminUserId);
$userSeed = array(
    array('operador.sala', $employeeIds[30124567], 'OPERADOR', array('Escritorio', 'Concepto', 'Ayuda', 'Emergencia', 'Publicos', 'Tribunal', 'Chofer'), '2026-03-20 08:00:00', 0),
    array('atencion.ciudadana', $employeeIds[28455102], 'OPERADOR', array('Escritorio', 'Ayuda', 'Publicos'), '2026-03-20 08:05:00', 0),
    array('consulta.tribunal', $employeeIds[26789012], 'CONSULTOR', array('Concepto', 'Tribunal'), '2026-03-21 10:00:00', 1),
);

foreach ($userSeed as $seed) {
    $userId = ensureUser($db, array(
        'id_empleado' => $seed[1],
        'usuario' => $seed[0],
        'password' => $demoPasswordHash,
        'rol' => $seed[2],
        'estado' => 1,
    ));

    ensureUserAccess($db, $userId, array(
        'intentos_fallidos' => (int) $seed[5],
        'bloqueado' => 0,
        'fecha_bloqueo' => null,
        'password_temporal' => 0,
        'fecha_password_temporal' => null,
        'fecha_actualizacion' => $seed[4],
    ));

    $permissionList = array();
    foreach ($seed[3] as $permissionName) {
        $permissionList[] = $permissionIds[$permissionName];
    }
    syncUserPermissions($db, $userId, $permissionList);
    $userIds[$seed[0]] = $userId;
}

echo "Insertando beneficiarios demo..." . PHP_EOL;

$communityIds = array_slice(array_keys($communityMap), 0, min(24, count($communityMap)));
$beneficiaryNames = array(
    'Maria Fernanda Rojas', 'Jose Gregorio Navas', 'Carmen Elena Perez', 'Luis Alberto Romero',
    'Ana Karina Salcedo', 'Pedro Antonio Marquez', 'Yelitza Carolina Gil', 'Ramon Eduardo Suarez',
    'Andreina del Valle Medina', 'Carlos Andres Sequera', 'Beatriz Elena Farias', 'Juan Pablo Ortega',
    'Norelys Alexandra Pino', 'Daniel Enrique Salazar', 'Gledys Carolina Rivas', 'Victor Manuel Carvajal',
    'Yusmary del Carmen Flores', 'Julio Cesar Mendez', 'Adriana Paola Infante', 'Wilmer Antonio Silva',
    'Lisbeth Coromoto Barrios', 'Hector Jose Villarroel', 'Damaris Elena Cabrera', 'Franklin Javier Lozada',
    'Marisela Josefina Quero', 'Nelson David Zambrano', 'Rosangelica Soto', 'Reinaldo Antonio Acosta',
    'Marianela Torres', 'Edgar Rafael Villalobos', 'Yajaira Perez', 'Alvaro Jose Pacheco',
    'Mireya del Carmen Ochoa', 'Henry Alexander Briceno', 'Marlenis Tovar', 'Jesus Alberto Moreno',
);

$beneficiaryIds = array();
foreach ($beneficiaryNames as $index => $name) {
    $communityId = $communityIds[$index % count($communityIds)];
    $date = new DateTime('2026-02-15 08:00:00');
    $date->modify('+' . $index . ' day');
    $phonePrefixes = array('0412', '0414', '0424', '0426');
    $cedula = 15234000 + ($index * 431);

    insertRow($db, 'beneficiarios', array(
        'nacionalidad' => $index % 9 === 0 ? 'E' : 'V',
        'cedula' => $cedula,
        'nombre_beneficiario' => $name,
        'telefono' => $phonePrefixes[$index % 4] . '-' . str_pad((string) (5100000 + ($index * 137)), 7, '0', STR_PAD_LEFT),
        'id_comunidad' => $communityId,
        'comunidad' => $communityMap[$communityId],
        'fecha_registro' => $date->format('Y-m-d H:i:s'),
        'estado' => 1,
    ));

    $beneficiaryIds[] = (int) fetchValue($db, "SELECT id_beneficiario FROM beneficiarios WHERE cedula = $cedula LIMIT 1");
}

echo "Insertando ayudas sociales..." . PHP_EOL;

$aidRecords = array(
    array('Medicas', 'SOL-ATC', 'ATENDIDA', 'Apoyo con medicamentos antihipertensivos para adulto mayor en control regular.'),
    array('Tecnicas', 'SOL-1X10', 'EN_GESTION', 'Solicitud de silla de ruedas para paciente con movilidad reducida.'),
    array('Sociales', 'SOL-RDS', 'REGISTRADA', 'Apoyo alimentario temporal para nucleo familiar afectado por perdida de empleo.'),
    array('Traslado', 'SOL-ATC', 'ATENDIDA', 'Coordinacion de traslado programado para consulta especializada en Valencia.'),
    array('Atencion prehospitalaria', 'SOL-1X10', 'EN_GESTION', 'Seguimiento para paciente cronico con necesidad de evaluacion domiciliaria.'),
    array('Reubicacion de insectos', 'SOL-RDS', 'ATENDIDA', 'Atencion por enjambre detectado en vivienda cercana a escuela basica.'),
    array('Medicas', 'SOL-ATC', 'NO_ATENDIDA', 'Solicitud de tensiometro digital sin disponibilidad inmediata en inventario.'),
    array('Tecnicas', 'SOL-1X10', 'ATENDIDA', 'Entrega de colchon antiescaras para adulto mayor encamado.'),
    array('Sociales', 'SOL-RDS', 'EN_GESTION', 'Evaluacion socioeconomica para apoyo con canastilla y articulos de primera necesidad.'),
    array('Traslado', 'SOL-ATC', 'ATENDIDA', 'Solicitud de traslado para paciente oncologico a jornada de quimioterapia.'),
    array('Medicas', 'SOL-1X10', 'REGISTRADA', 'Requerimiento de nebulizador y medicinas para control respiratorio.'),
    array('Tecnicas', 'SOL-RDS', 'ATENDIDA', 'Suministro de muletas para joven lesionado en accidente domestico.'),
    array('Sociales', 'SOL-ATC', 'ATENDIDA', 'Canalizacion de apoyo para familia afectada por incendio parcial de vivienda.'),
    array('Atencion prehospitalaria', 'SOL-1X10', 'NO_ATENDIDA', 'Caso referido a red regional por requerir cobertura externa al municipio.'),
    array('Reubicacion de insectos', 'SOL-RDS', 'EN_GESTION', 'Reporte de colmena en techo de casa de cuidado infantil.'),
    array('Medicas', 'SOL-ATC', 'ATENDIDA', 'Entrega de kit de curas para paciente con ulceras por presion.'),
    array('Tecnicas', 'SOL-1X10', 'REGISTRADA', 'Solicitud de baston de cuatro puntas para persona adulta mayor.'),
    array('Sociales', 'SOL-RDS', 'ATENDIDA', 'Apoyo con alimentos y agua potable a familia afectada por colapso de tuberia.'),
);

foreach ($aidRecords as $index => $aid) {
    $id = $index + 1;
    $users = array($userIds['admin'], $userIds['operador.sala'], $userIds['atencion.ciudadana']);
    $userId = $users[$index % 3];
    $date = new DateTime('2026-02-18');
    $date->modify('+' . ($index * 2) . ' day');
    $dateString = $date->format('Y-m-d');

    insertRow($db, 'ayuda_social', array(
        'ticket_interno' => buildTicket('AYU', $dateString, $id),
        'id_beneficiario' => $beneficiaryIds[$index % count($beneficiaryIds)],
        'id_usuario' => $userId,
        'id_tipo_ayuda_social' => $aidTypeIds[$aid[0]],
        'id_solicitud_ayuda_social' => $requestIds[$aid[1]],
        'id_estado_solicitud' => $stateIds[$aid[2]],
        'tipo_ayuda' => $aid[0],
        'solicitud_ayuda' => $requestNames[$aid[1]],
        'fecha_ayuda' => $dateString,
        'descripcion' => $aid[3],
        'estado' => 1,
    ));

    insertFollowUp($db, 'AYUDA_SOCIAL', $id, $stateIds['REGISTRADA'], $userId, $dateString . ' 08:00:00', 'Solicitud registrada en ayuda social.');

    if ($aid[2] === 'EN_GESTION') {
        insertFollowUp($db, 'AYUDA_SOCIAL', $id, $stateIds['EN_GESTION'], $userId, $dateString . ' 11:30:00', 'Caso canalizado a la dependencia social para seguimiento.');
    } elseif ($aid[2] === 'ATENDIDA') {
        insertFollowUp($db, 'AYUDA_SOCIAL', $id, $stateIds['ATENDIDA'], $userId, (new DateTime($dateString . ' 14:00:00'))->modify('+2 day')->format('Y-m-d H:i:s'), 'Solicitud resuelta y apoyo entregado al beneficiario.');
    } elseif ($aid[2] === 'NO_ATENDIDA') {
        insertFollowUp($db, 'AYUDA_SOCIAL', $id, $stateIds['NO_ATENDIDA'], $userId, (new DateTime($dateString . ' 16:00:00'))->modify('+3 day')->format('Y-m-d H:i:s'), 'Solicitud cerrada sin disponibilidad operativa inmediata.');
    }
}

echo "Insertando servicios publicos..." . PHP_EOL;

$serviceRecords = array(
    array('SP-AGU', 'SOL-ATC', 'ATENDIDA', 'Fuga de agua blanca en tuberia principal cercana a la escuela del sector.'),
    array('SP-AGN', 'SOL-RDS', 'EN_GESTION', 'Desborde de aguas negras en calle ciega con afectacion de varias viviendas.'),
    array('SP-ALU', 'SOL-1X10', 'ATENDIDA', 'Luminarias apagadas en corredor peatonal de alta circulacion nocturna.'),
    array('SP-AMB', 'SOL-ATC', 'REGISTRADA', 'Acumulacion de desechos vegetales en espacio comunal.'),
    array('SP-ASF', 'SOL-RDS', 'EN_GESTION', 'Bache de gran tamano en vialidad principal con riesgo para motorizados.'),
    array('SP-CAN', 'SOL-1X10', 'ATENDIDA', 'Limpieza y desobstruccion de cano lateral antes del periodo de lluvias.'),
    array('SP-ENE', 'SOL-ATC', 'NO_ATENDIDA', 'Variacion de voltaje reportada en manzana con transformador sobrecargado.'),
    array('SP-INF', 'SOL-RDS', 'ATENDIDA', 'Reparacion de filtracion en techo de modulo comunal.'),
    array('SP-PYP', 'SOL-1X10', 'EN_GESTION', 'Ramas sobre tendido electrico con riesgo de caida por vientos.'),
    array('SP-VIA', 'SOL-ATC', 'ATENDIDA', 'Se requiere demarcacion y reparacion parcial de paso peatonal.'),
    array('SP-AGU', 'SOL-RDS', 'REGISTRADA', 'Baja presion de agua en zona alta de la comunidad durante la tarde.'),
    array('SP-ALU', 'SOL-1X10', 'ATENDIDA', 'Reposicion de reflector en cancha multiple para jornada nocturna.'),
    array('SP-ASF', 'SOL-ATC', 'ATENDIDA', 'Hundimiento de calzada cerca de parada de transporte publico.'),
    array('SP-INF', 'SOL-RDS', 'NO_ATENDIDA', 'Solicitud de rehabilitacion integral de plaza sin presupuesto asignado.'),
    array('SP-PYP', 'SOL-1X10', 'ATENDIDA', 'Poda preventiva de arboles frente a preescolar municipal.'),
    array('SP-CAN', 'SOL-ATC', 'EN_GESTION', 'Sedimentacion en embaulamiento con necesidad de maquinaria liviana.'),
    array('SP-ENE', 'SOL-RDS', 'ATENDIDA', 'Reposicion de fusible y chequeo de acometida en sector residencial.'),
    array('SP-VIA', 'SOL-1X10', 'REGISTRADA', 'Solicitud de reductores de velocidad frente a centro educativo.'),
);

foreach ($serviceRecords as $index => $service) {
    $id = $index + 1;
    $users = array($userIds['operador.sala'], $userIds['atencion.ciudadana'], $userIds['admin']);
    $userId = $users[$index % 3];
    $date = new DateTime('2026-02-19');
    $date->modify('+' . ($index * 2) . ' day');
    $dateString = $date->format('Y-m-d');

    insertRow($db, 'servicios_publicos', array(
        'ticket_interno' => buildTicket('SPU', $dateString, $id),
        'id_beneficiario' => $beneficiaryIds[($index + 5) % count($beneficiaryIds)],
        'id_usuario' => $userId,
        'id_tipo_servicio_publico' => $serviceTypeIds[$service[0]],
        'id_solicitud_servicio_publico' => $requestIds[$service[1]],
        'id_estado_solicitud' => $stateIds[$service[2]],
        'tipo_servicio' => $serviceTypeNames[$service[0]],
        'solicitud_servicio' => $requestNames[$service[1]],
        'fecha_servicio' => $dateString,
        'descripcion' => $service[3],
        'estado' => 1,
    ));

    insertFollowUp($db, 'SERVICIOS_PUBLICOS', $id, $stateIds['REGISTRADA'], $userId, $dateString . ' 08:30:00', 'Solicitud registrada en servicios publicos.');

    if ($service[2] === 'EN_GESTION') {
        insertFollowUp($db, 'SERVICIOS_PUBLICOS', $id, $stateIds['EN_GESTION'], $userId, $dateString . ' 10:45:00', 'Solicitud remitida a cuadrilla operativa para programacion.');
    } elseif ($service[2] === 'ATENDIDA') {
        insertFollowUp($db, 'SERVICIOS_PUBLICOS', $id, $stateIds['ATENDIDA'], $userId, (new DateTime($dateString . ' 15:15:00'))->modify('+1 day')->format('Y-m-d H:i:s'), 'Solicitud atendida y gestion cerrada en sitio.');
    } elseif ($service[2] === 'NO_ATENDIDA') {
        insertFollowUp($db, 'SERVICIOS_PUBLICOS', $id, $stateIds['NO_ATENDIDA'], $userId, (new DateTime($dateString . ' 17:00:00'))->modify('+3 day')->format('Y-m-d H:i:s'), 'Solicitud cerrada por falta de disponibilidad presupuestaria.');
    }
}

echo "Insertando flota operativa..." . PHP_EOL;

$unitIds = array();
foreach (array(
    array('AMB-001', 'Ambulancia Ford Transit', 'AB7C21D', 'EN_SERVICIO', 'Hospital de Tocuyito', 'Area de urgencias', 1, '2026-03-22 20:22:00'),
    array('AMB-002', 'Ambulancia Toyota Hiace', 'AC4G91M', 'EN_SERVICIO', 'Urbanizacion Jose Rafael Pocaterra', 'Frente al modulo policial', 2, '2026-03-23 14:50:00'),
    array('AMB-003', 'Ambulancia Iveco Daily', 'AD2L44R', 'DISPONIBLE', 'Base central', 'Patio operacional', 3, '2026-03-21 09:40:00'),
    array('AMB-004', 'Ambulancia Mercedes Sprinter', 'AE6J12K', 'DISPONIBLE', 'CDI El Oasis', 'Area de espera', 4, '2026-03-20 16:30:00'),
    array('AMB-005', 'Ambulancia Chevrolet Express', 'AF8P33T', 'DISPONIBLE', 'Parroquia Independencia', 'Puesto sanitario movil', 5, '2026-03-18 11:20:00'),
    array('AMB-006', 'Unidad de respuesta rapida', 'AG1N58Q', 'FUERA_SERVICIO', 'Taller municipal', 'Revision de frenos', 6, '2026-03-17 08:10:00'),
) as $unit) {
    $unitIds[$unit[0]] = ensureUnit($db, array(
        'codigo_unidad' => $unit[0],
        'descripcion' => $unit[1],
        'placa' => $unit[2],
        'estado' => 1,
        'estado_operativo' => $unit[3],
        'ubicacion_actual' => $unit[4],
        'referencia_actual' => $unit[5],
        'prioridad_despacho' => $unit[6],
        'fecha_actualizacion_operativa' => $unit[7],
    ));
}

$driverIds = array();
foreach (array(
    array(1, 'LIC-14382513', '5to grado', '2030-08-14', 'Andres Aguilar', '0412-7001122', 'Chofer principal de guardia nocturna.', '2026-02-14 07:10:00', '2026-03-22 20:22:00'),
    array(2, 'LIC-24329534', '5to grado', '2031-04-09', 'Maria Franco', '0424-7012233', 'Disponible para turnos rotativos y traslados largos.', '2026-02-14 07:20:00', '2026-03-23 14:50:00'),
    array($employeeIds[19654321], 'LIC-19654321', '5to grado', '2032-01-18', 'Julio Vargas', '0416-7023344', 'Resguardo de unidad para operativos especiales.', '2026-02-15 08:00:00', '2026-03-21 09:40:00'),
    array($employeeIds[21567890], 'LIC-21567890', '4to grado', '2031-11-02', 'Laura Rivas', '0412-7034455', 'Apoyo en guardias diurnas y relevo de ambulancias.', '2026-02-15 08:15:00', '2026-03-20 16:30:00'),
    array($employeeIds[18345678], 'LIC-18345678', '4to grado', '2030-09-27', 'Jose Salazar', '0414-7045566', 'Conductora asignada a guardias comunitarias.', '2026-02-16 09:00:00', '2026-03-18 11:20:00'),
    array($employeeIds[25432109], 'LIC-25432109', '4to grado', '2031-06-30', 'Nelly Suarez', '0424-7056677', 'Chofer de reserva para unidades en mantenimiento.', '2026-02-16 09:20:00', '2026-03-17 08:10:00'),
) as $driver) {
    $driverIds[$driver[0]] = ensureDriver($db, array(
        'id_empleado' => $driver[0],
        'numero_licencia' => $driver[1],
        'categoria_licencia' => $driver[2],
        'vencimiento_licencia' => $driver[3],
        'contacto_emergencia' => $driver[4],
        'telefono_contacto_emergencia' => $driver[5],
        'observaciones' => $driver[6],
        'estado' => 1,
        'fecha_registro' => $driver[7],
        'fecha_actualizacion' => $driver[8],
    ));
}

echo "Insertando asignaciones operativas..." . PHP_EOL;

foreach (array(
    array($unitIds['AMB-001'], $driverIds[1], '2026-02-25 07:00:00', null, 'Guardia activa en hospital de referencia.', 1, '2026-02-25 07:00:00', '2026-03-22 20:22:00'),
    array($unitIds['AMB-002'], $driverIds[2], '2026-02-25 07:15:00', null, 'Guardia activa en eje Pocaterra.', 1, '2026-02-25 07:15:00', '2026-03-23 14:50:00'),
    array($unitIds['AMB-003'], $driverIds[$employeeIds[19654321]], '2026-02-26 07:00:00', null, 'Guardia diurna en base central.', 1, '2026-02-26 07:00:00', '2026-03-21 09:40:00'),
    array($unitIds['AMB-004'], $driverIds[$employeeIds[21567890]], '2026-02-26 07:10:00', null, 'Guardia mixta para cobertura comunitaria.', 1, '2026-02-26 07:10:00', '2026-03-20 16:30:00'),
    array($unitIds['AMB-005'], $driverIds[$employeeIds[18345678]], '2026-02-26 07:20:00', null, 'Cobertura preventiva en parroquia Independencia.', 1, '2026-02-26 07:20:00', '2026-03-18 11:20:00'),
    array($unitIds['AMB-006'], $driverIds[$employeeIds[25432109]], '2026-02-20 08:00:00', '2026-03-01 17:30:00', 'Unidad retirada temporalmente por mantenimiento preventivo.', 0, '2026-02-20 08:00:00', '2026-03-01 17:30:00'),
    array($unitIds['AMB-003'], $driverIds[$employeeIds[25432109]], '2026-02-18 07:30:00', '2026-02-24 18:00:00', 'Asignacion previa cerrada por relevo operativo.', 0, '2026-02-18 07:30:00', '2026-02-24 18:00:00'),
) as $assignment) {
    insertRow($db, 'asignaciones_unidades_choferes', array(
        'id_unidad' => $assignment[0],
        'id_chofer_ambulancia' => $assignment[1],
        'fecha_inicio' => $assignment[2],
        'fecha_fin' => $assignment[3],
        'observaciones' => $assignment[4],
        'estado' => $assignment[5],
        'fecha_registro' => $assignment[6],
        'fecha_actualizacion' => $assignment[7],
    ));
}

echo "Insertando seguridad y emergencia..." . PHP_EOL;

$driverInfoById = array();
foreach (fetchAllAssoc(
    $db,
    "SELECT ca.id_chofer_ambulancia, ca.id_empleado, e.correo
     FROM choferes_ambulancia ca
     INNER JOIN empleados e ON e.id_empleado = ca.id_empleado"
) as $row) {
    $driverInfoById[(int) $row['id_chofer_ambulancia']] = array(
        'id_empleado' => (int) $row['id_empleado'],
        'correo' => (string) $row['correo'],
    );
}

$securityCases = array(
    array(0, $userIds['operador.sala'], 'Atencion prehospitalaria', 'SOL-ATC', '2026-03-03 08:20:00', 'Paciente femenina de 67 anos con crisis hipertensiva y mareos persistentes.', 'Sector 12 de Octubre, calle principal', 'Frente al ambulatorio popular', 'FINALIZADO', 'ATENDIDA', array('AMB-003', $employeeIds[19654321], $userIds['operador.sala'], 'AUTO', '2026-03-03 08:28:00', '2026-03-03 10:10:00', 'Base central', 'Hospital de Tocuyito', 'Traslado estabilizado sin novedades durante el recorrido.', 'Paciente estabilizada y entregada en urgencias con signos vitales compensados.', 24120, 24138, 'jpg')),
    array(5, $userIds['admin'], 'Atencion prehospitalaria', 'SOL-1X10', '2026-03-05 18:05:00', 'Adulto masculino lesionado por caida de moto con dolor en hombro y escoriaciones.', 'Avenida principal de La Honda', 'Cerca del puente peatonal', 'FINALIZADO', 'ATENDIDA', array('AMB-004', $employeeIds[21567890], $userIds['admin'], 'MANUAL', '2026-03-05 18:12:00', '2026-03-05 19:32:00', 'CDI El Oasis', 'Hospital de Tocuyito', 'Atencion primaria en sitio y posterior traslado preventivo.', 'Traumatismo leve en hombro derecho, paciente referido para rayos X.', 18344, 18360, 'png')),
    array(8, $userIds['operador.sala'], 'Atencion prehospitalaria', 'SOL-RDS', '2026-03-07 06:45:00', 'Nino con dificultad respiratoria y antecedentes de asma bronquial.', 'Comunidad Nueva Villa', 'Casa azul junto a la bodega', 'FINALIZADO', 'ATENDIDA', array('AMB-005', $employeeIds[18345678], $userIds['operador.sala'], 'AUTO', '2026-03-07 06:51:00', '2026-03-07 08:05:00', 'Parroquia Independencia', 'Hospital de Tocuyito', 'Se administro oxigeno de apoyo durante el recorrido.', 'Crisis asmatica controlada con respuesta favorable a nebulizacion inicial.', 19872, 19888, 'jpg')),
    array(12, $userIds['admin'], 'Atencion prehospitalaria', 'SOL-ATC', '2026-03-10 11:30:00', 'Gestante con contracciones regulares y dolor abdominal en fase activa.', 'Urbanizacion Villa Jardin', 'Edificio 3, planta baja', 'FINALIZADO', 'ATENDIDA', array('AMB-001', 1, $userIds['admin'], 'MANUAL', '2026-03-10 11:37:00', '2026-03-10 12:42:00', 'Hospital de Tocuyito', 'Maternidad municipal', 'Ingreso rapido y sin complicaciones durante el traslado.', 'Paciente entregada en sala de parto con signos estables.', 24138, 24149, 'png')),
    array(14, $userIds['operador.sala'], 'Atencion prehospitalaria', 'SOL-1X10', '2026-03-22 20:15:00', 'Adulto mayor con dolor toracico y dificultad para caminar.', 'Casco Comercial de Tocuyito', 'Frente a la farmacia principal', 'DESPACHADO', 'EN_GESTION', array('AMB-001', 1, $userIds['operador.sala'], 'AUTO', '2026-03-22 20:22:00', null, 'Hospital de Tocuyito', null, 'Unidad en ruta al sitio con prioridad uno.', null, null, null, 'jpg')),
    array(17, $userIds['admin'], 'Atencion prehospitalaria', 'SOL-RDS', '2026-03-23 14:40:00', 'Paciente con hipoglucemia reportada por familiares y mareo intenso.', 'Urbanizacion Jose Rafael Pocaterra', 'Casa 14, calle A', 'DESPACHADO', 'EN_GESTION', array('AMB-002', 2, $userIds['admin'], 'AUTO', '2026-03-23 14:50:00', null, 'Urbanizacion Jose Rafael Pocaterra', null, 'Unidad en atencion activa con reporte telefonico abierto.', null, null, null, 'png')),
    array(20, $userIds['operador.sala'], 'Atencion prehospitalaria', 'SOL-ATC', '2026-03-23 07:10:00', 'Adulto mayor con sospecha de deshidratacion mientras se libera una unidad.', 'Barrio El Oasis', 'Cancha techada', 'PENDIENTE_UNIDAD', 'EN_GESTION', null),
    array(22, $userIds['consulta.tribunal'], 'Hurto', 'SOL-ATC', '2026-03-12 09:00:00', 'Denuncia de hurto de cableado residencial con afectacion de servicio domestico.', 'Santa Eduviges', 'Detras de la casa comunal', 'FINALIZADO', 'ATENDIDA', null),
    array(23, $userIds['consulta.tribunal'], 'Robo de vehiculo', 'SOL-1X10', '2026-03-13 22:10:00', 'Reporte de robo de motocicleta al salir de jornada laboral nocturna.', 'Zanjon Dulce', 'Cerca de la parada de autobuses', 'REGISTRADO', 'REGISTRADA', null),
    array(24, $userIds['operador.sala'], 'Riesgo de vias publicas', 'SOL-RDS', '2026-03-15 17:35:00', 'Arbol inclinado sobre vialidad con riesgo de caida sobre peatones.', 'Los Mangos', 'Frente a la escuela tecnica', 'FINALIZADO', 'ATENDIDA', null),
    array(25, $userIds['operador.sala'], 'Reubicacion de insectos', 'SOL-ATC', '2026-03-16 13:25:00', 'Avispero activo en techo de vivienda multifamiliar.', 'Urbanizacion La Esperanza', 'Casa esquinera color beige', 'FINALIZADO', 'ATENDIDA', null),
    array(26, $userIds['consulta.tribunal'], 'Maltrato domestico', 'SOL-RDS', '2026-03-18 19:10:00', 'Vecinos reportan presunta situacion de violencia intrafamiliar.', 'Colinas del Rosario', 'Pasillo 4 del conjunto residencial', 'REGISTRADO', 'REGISTRADA', null),
    array(27, $userIds['admin'], 'Guardia y seguridad', 'SOL-1X10', '2026-03-19 06:30:00', 'Solicitud de apoyo preventivo por evento comunitario con alta asistencia.', 'Comunidad Bicentenario', 'Plaza central', 'FINALIZADO', 'ATENDIDA', null),
    array(28, $userIds['consulta.tribunal'], 'Robo de inmueble', 'SOL-ATC', '2026-03-20 03:50:00', 'Reporte de intrusion nocturna en vivienda desocupada parcialmente.', 'Banco Obrero Las Palmas', 'Casa 8, vereda final', 'REGISTRADO', 'REGISTRADA', null),
);

foreach ($securityCases as $index => $case) {
    $id = $index + 1;
    insertRow($db, 'seguridad', array(
        'ticket_interno' => buildTicket('SEG', substr($case[4], 0, 10), $id),
        'id_beneficiario' => $beneficiaryIds[$case[0]],
        'id_usuario' => $case[1],
        'id_tipo_seguridad' => $securityTypeIds[$case[2]],
        'id_solicitud_seguridad' => $requestIds[$case[3]],
        'id_estado_solicitud' => $stateIds[$case[9]],
        'tipo_seguridad' => $case[2],
        'tipo_solicitud' => $requestNames[$case[3]],
        'fecha_seguridad' => $case[4],
        'descripcion' => $case[5],
        'estado_atencion' => $case[8],
        'ubicacion_evento' => $case[6],
        'referencia_evento' => $case[7],
        'estado' => 1,
    ));

    insertFollowUp($db, 'SEGURIDAD', $id, $stateIds['REGISTRADA'], $case[1], $case[4], 'Solicitud registrada en seguridad y emergencia.');

    if ($case[8] === 'PENDIENTE_UNIDAD') {
        insertFollowUp($db, 'SEGURIDAD', $id, $stateIds['EN_GESTION'], $case[1], (new DateTime($case[4]))->modify('+10 minutes')->format('Y-m-d H:i:s'), 'Caso en espera de unidad operativa disponible.');
        continue;
    }

    if ($case[10] === null) {
        if ($case[8] === 'FINALIZADO') {
            insertFollowUp($db, 'SEGURIDAD', $id, $stateIds['ATENDIDA'], $case[1], (new DateTime($case[4]))->modify('+2 hours')->format('Y-m-d H:i:s'), 'Gestion cerrada por el equipo operativo correspondiente.');
        }
        continue;
    }

    $dispatch = $case[10];
    $unitId = $unitIds[$dispatch[0]];
    $driverId = $driverIds[$dispatch[1]];
    $dispatchState = $dispatch[5] ? 'CERRADO' : 'ACTIVO';

    insertRow($db, 'despachos_unidades', array(
        'id_seguridad' => $id,
        'id_unidad' => $unitId,
        'id_chofer_ambulancia' => $driverId,
        'id_usuario_asigna' => $dispatch[2],
        'modo_asignacion' => $dispatch[3],
        'estado_despacho' => $dispatchState,
        'fecha_asignacion' => $dispatch[4],
        'fecha_cierre' => $dispatch[5],
        'ubicacion_salida' => $dispatch[6],
        'ubicacion_evento' => $case[6],
        'ubicacion_cierre' => $dispatch[7],
        'observaciones' => $dispatch[8],
        'fecha_registro' => $dispatch[4],
        'fecha_actualizacion' => $dispatch[5] ?: $dispatch[4],
    ));

    $dispatchId = (int) fetchValue($db, "SELECT id_despacho_unidad FROM despachos_unidades WHERE id_seguridad = $id AND id_unidad = $unitId ORDER BY id_despacho_unidad DESC LIMIT 1");
    $ticket = buildTicket('SEG', substr($case[4], 0, 10), $id);
    $driverInfo = $driverInfoById[$driverId];

    insertFollowUp($db, 'SEGURIDAD', $id, $stateIds['EN_GESTION'], $dispatch[2], $dispatch[4], 'Solicitud en gestion operativa con unidad y chofer asignados.');

    $registrationFile = sprintf('%s_registro_%s_%04d.pdf', $ticket, date('Ymd_His', strtotime($dispatch[4])), $id);
    copySupportFile($registrationTemplate, $supportDirSolicitudes . DIRECTORY_SEPARATOR . $registrationFile);
    insertRow($db, 'reportes_solicitudes_ambulancia', array(
        'id_seguridad' => $id,
        'id_despacho_unidad' => $dispatchId,
        'tipo_reporte' => 'REGISTRO',
        'nombre_archivo' => $registrationFile,
        'ruta_archivo' => 'uploads/reportes_solicitudes_ambulancia/' . $registrationFile,
        'estado_envio' => 'ENVIADO',
        'correo_destino' => $driverInfo['correo'],
        'fecha_envio' => (new DateTime($dispatch[4]))->modify('+2 minutes')->format('Y-m-d H:i:s'),
        'detalle_envio' => 'Reporte de salida enviado correctamente al correo del chofer.',
        'id_usuario_genera' => $dispatch[2],
        'fecha_generacion' => $dispatch[4],
        'estado' => 1,
    ));

    if ($dispatch[5] === null) {
        continue;
    }

    insertFollowUp($db, 'SEGURIDAD', $id, $stateIds['ATENDIDA'], $dispatch[2], $dispatch[5], 'Solicitud finalizada con cierre operativo y traslado documentado.');

    $closureFile = sprintf('%s_cierre_%s_%04d.pdf', $ticket, date('Ymd_His', strtotime($dispatch[5])), $id);
    copySupportFile($closureTemplate, $supportDirSolicitudes . DIRECTORY_SEPARATOR . $closureFile);
    insertRow($db, 'reportes_solicitudes_ambulancia', array(
        'id_seguridad' => $id,
        'id_despacho_unidad' => $dispatchId,
        'tipo_reporte' => 'CIERRE',
        'nombre_archivo' => $closureFile,
        'ruta_archivo' => 'uploads/reportes_solicitudes_ambulancia/' . $closureFile,
        'estado_envio' => 'ENVIADO',
        'correo_destino' => $driverInfo['correo'],
        'fecha_envio' => (new DateTime($dispatch[5]))->modify('+4 minutes')->format('Y-m-d H:i:s'),
        'detalle_envio' => 'Reporte de cierre enviado correctamente al correo del chofer.',
        'id_usuario_genera' => $dispatch[2],
        'fecha_generacion' => $dispatch[5],
        'estado' => 1,
    ));

    $imageFile = sprintf(
        'seguridad_%s_%04d.%s',
        date('Ymd_His', strtotime($dispatch[5])),
        $id,
        strtolower($dispatch[12]) === 'png' ? 'png' : 'jpg'
    );
    copySupportFile($imageTemplate, $supportDirTraslado . DIRECTORY_SEPARATOR . $imageFile);
    insertRow($db, 'reportes_traslado', array(
        'id_ayuda' => null,
        'id_seguridad' => $id,
        'id_despacho_unidad' => $dispatchId,
        'id_usuario_operador' => $dispatch[2],
        'id_empleado_chofer' => $driverInfo['id_empleado'],
        'id_unidad' => $unitId,
        'ticket_interno' => $ticket,
        'fecha_hora' => $dispatch[5],
        'diagnostico_paciente' => $dispatch[9],
        'foto_evidencia' => 'uploads/reportes_traslado/' . $imageFile,
        'km_salida' => $dispatch[10],
        'km_llegada' => $dispatch[11],
        'estado' => 1,
    ));
}

echo "Registrando eventos de autenticacion demo..." . PHP_EOL;

callAuthenticationLog($db, $userIds['admin'], 'admin', 'LOGIN_OK', 'Inicio de sesion administrativo para revision de tableros.', '127.0.0.1');
callAuthenticationLog($db, $userIds['operador.sala'], 'operador.sala', 'LOGIN_OK', 'Ingreso del operador de sala para coordinacion operativa.', '127.0.0.1');
callAuthenticationLog($db, $userIds['atencion.ciudadana'], 'atencion.ciudadana', 'LOGIN_OK', 'Ingreso para carga de solicitudes ciudadanas.', '127.0.0.1');
callAuthenticationLog($db, $userIds['consulta.tribunal'], 'consulta.tribunal', 'LOGIN_FAIL', 'Intento previo con clave vencida antes de la autenticacion correcta.', '127.0.0.1');
callAuthenticationLog($db, $userIds['consulta.tribunal'], 'consulta.tribunal', 'LOGIN_OK', 'Ingreso de consulta para revision de bitacora institucional.', '127.0.0.1');

echo PHP_EOL . "Resumen de carga:" . PHP_EOL;
foreach (array(
    'empleados',
    'usuarios',
    'usuarios_seguridad_acceso',
    'usuario_permisos',
    'beneficiarios',
    'ayuda_social',
    'servicios_publicos',
    'seguridad',
    'seguimientos_solicitudes',
    'unidades',
    'choferes_ambulancia',
    'asignaciones_unidades_choferes',
    'despachos_unidades',
    'reportes_solicitudes_ambulancia',
    'reportes_traslado',
    'bitacora',
) as $table) {
    echo str_pad($table, 34, ' ') . (int) fetchValue($db, "SELECT COUNT(*) FROM `$table`") . PHP_EOL;
}

echo PHP_EOL . "Usuarios demo creados o actualizados:" . PHP_EOL;
echo " - operador.sala / " . $demoPassword . PHP_EOL;
echo " - atencion.ciudadana / " . $demoPassword . PHP_EOL;
echo " - consulta.tribunal / " . $demoPassword . PHP_EOL;
echo PHP_EOL . "Carga demo completada correctamente." . PHP_EOL;
