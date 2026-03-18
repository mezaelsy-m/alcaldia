<?php
require_once "../config/Conexion.php";
require_once __DIR__ . "/EstadoSolicitud.php";

class Seguridad_emergencia
{
    private $estadoSolicitud;
    private $tablaReportesSolicitudesAmbulanciaExiste;
    private $columnasTablaCache;

    public function __construct()
    {
        $this->estadoSolicitud = new EstadoSolicitud();
        $this->tablaReportesSolicitudesAmbulanciaExiste = null;
        $this->columnasTablaCache = array();
    }

    private function db()
    {
        global $conexion;
        return $conexion;
    }

    private function esc($valor)
    {
        return mysqli_real_escape_string($this->db(), (string) $valor);
    }

    private function obtenerColumnasTabla($tabla)
    {
        $tabla = trim((string) $tabla);
        if ($tabla === "") {
            return array();
        }

        if (isset($this->columnasTablaCache[$tabla])) {
            return $this->columnasTablaCache[$tabla];
        }

        $sql = "SELECT COLUMN_NAME
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = '" . $this->esc($tabla) . "'
                ORDER BY ORDINAL_POSITION ASC";
        $rspta = ejecutarConsulta($sql);
        $columnas = array();

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $nombre = isset($row["COLUMN_NAME"]) ? trim((string) $row["COLUMN_NAME"]) : "";
                if ($nombre !== "") {
                    $columnas[] = $nombre;
                }
            }
        }

        $this->columnasTablaCache[$tabla] = $columnas;
        return $columnas;
    }

    private function obtenerListaColumnasSelect($tabla, $alias = "")
    {
        $columnas = $this->obtenerColumnasTabla($tabla);
        if (empty($columnas)) {
            return "";
        }

        $prefijo = trim((string) $alias);
        if ($prefijo !== "") {
            $prefijo = "`" . $prefijo . "`.";
        }

        $items = array();
        foreach ($columnas as $columna) {
            $items[] = $prefijo . "`" . $columna . "`";
        }

        return implode(",\n                   ", $items);
    }

    private function licenciaEstaVencida($fecha)
    {
        $fecha = trim((string) $fecha);
        if ($fecha === "") {
            return true;
        }

        return $fecha < date("Y-m-d");
    }

    private function ultimoDespachoSubquery()
    {
        $columnas = $this->obtenerListaColumnasSelect("despachos_unidades", "d1");
        return "(
            SELECT " . $columnas . "
            FROM despachos_unidades AS d1
            INNER JOIN (
                SELECT id_seguridad, MAX(id_despacho_unidad) AS max_id
                FROM despachos_unidades
                GROUP BY id_seguridad
            ) AS dm
                ON dm.max_id = d1.id_despacho_unidad
        )";
    }

    private function asignacionActivaSubquery()
    {
        $columnas = $this->obtenerListaColumnasSelect("asignaciones_unidades_choferes", "a1");
        return "(
            SELECT " . $columnas . "
            FROM asignaciones_unidades_choferes AS a1
            INNER JOIN (
                SELECT id_unidad, MAX(id_asignacion_unidad_chofer) AS max_id
                FROM asignaciones_unidades_choferes
                WHERE estado = 1
                  AND fecha_fin IS NULL
                GROUP BY id_unidad
            ) AS am
                ON am.max_id = a1.id_asignacion_unidad_chofer
        )";
    }

    private function asignacionActivaChoferSubquery()
    {
        $columnas = $this->obtenerListaColumnasSelect("asignaciones_unidades_choferes", "a1");
        return "(
            SELECT " . $columnas . "
            FROM asignaciones_unidades_choferes AS a1
            INNER JOIN (
                SELECT id_chofer_ambulancia, MAX(id_asignacion_unidad_chofer) AS max_id
                FROM asignaciones_unidades_choferes
                WHERE estado = 1
                  AND fecha_fin IS NULL
                GROUP BY id_chofer_ambulancia
            ) AS ac
                ON ac.max_id = a1.id_asignacion_unidad_chofer
        )";
    }

    private function existeTabla($nombreTabla)
    {
        $nombreTabla = trim((string) $nombreTabla);
        if ($nombreTabla === "") {
            return false;
        }

        $sql = "SELECT COUNT(*) AS total
                FROM information_schema.TABLES
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = '" . $this->esc($nombreTabla) . "'";
        $fila = ejecutarConsultaSimpleFila($sql);
        return $fila && isset($fila["total"]) && (int) $fila["total"] > 0;
    }

    private function tieneTablaReportesSolicitudesAmbulancia()
    {
        if ($this->tablaReportesSolicitudesAmbulanciaExiste === null) {
            $this->tablaReportesSolicitudesAmbulanciaExiste = $this->existeTabla("reportes_solicitudes_ambulancia");
        }

        return (bool) $this->tablaReportesSolicitudesAmbulanciaExiste;
    }

    private function ultimoReporteSolicitudSubquery()
    {
        $columnas = $this->obtenerListaColumnasSelect("reportes_solicitudes_ambulancia", "r1");
        return "(
            SELECT " . $columnas . "
            FROM reportes_solicitudes_ambulancia AS r1
            INNER JOIN (
                SELECT id_seguridad,
                       MAX(CASE WHEN tipo_reporte = 'CIERRE' THEN id_reporte_solicitud ELSE 0 END) AS max_cierre,
                       MAX(id_reporte_solicitud) AS max_id
                FROM reportes_solicitudes_ambulancia
                WHERE estado = 1
                GROUP BY id_seguridad
            ) AS rm
                ON rm.id_seguridad = r1.id_seguridad
               AND r1.id_reporte_solicitud = CASE WHEN rm.max_cierre > 0 THEN rm.max_cierre ELSE rm.max_id END
        )";
    }

    private function ultimoReporteTrasladoSubquery()
    {
        $columnas = $this->obtenerListaColumnasSelect("reportes_traslado", "r1");
        return "(
            SELECT " . $columnas . "
            FROM reportes_traslado AS r1
            INNER JOIN (
                SELECT id_despacho_unidad, MAX(id_reporte) AS max_id
                FROM reportes_traslado
                WHERE estado = 1
                  AND id_despacho_unidad IS NOT NULL
                GROUP BY id_despacho_unidad
            ) AS rm
                ON rm.max_id = r1.id_reporte
        )";
    }

    private function liberarAsignacionActivaUnidad($idUnidad, $motivo, $forUpdate = false)
    {
        $idUnidad = (int) $idUnidad;
        $motivo = $this->esc($motivo);

        $sqlBuscar = "SELECT au.id_asignacion_unidad_chofer,
                             au.id_chofer_ambulancia,
                             CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer
                      FROM asignaciones_unidades_choferes AS au
                      LEFT JOIN choferes_ambulancia AS ca
                        ON ca.id_chofer_ambulancia = au.id_chofer_ambulancia
                      LEFT JOIN empleados AS e
                        ON e.id_empleado = ca.id_empleado
                      WHERE au.id_unidad = '$idUnidad'
                        AND au.estado = 1
                        AND au.fecha_fin IS NULL
                      LIMIT 1";

        if ($forUpdate) {
            $sqlBuscar .= " FOR UPDATE";
        }

        $asignacion = ejecutarConsultaSimpleFila($sqlBuscar);
        if (!$asignacion) {
            return array(
                "ok" => true,
                "liberada" => false,
                "id_chofer_ambulancia" => 0,
                "nombre_chofer" => ""
            );
        }

        $idAsignacion = (int) $asignacion["id_asignacion_unidad_chofer"];
        $sqlCerrar = "UPDATE asignaciones_unidades_choferes
                      SET estado = 0,
                          fecha_fin = NOW(),
                          observaciones = CONCAT(COALESCE(observaciones, ''), CASE WHEN COALESCE(observaciones, '') = '' THEN '' ELSE ' | ' END, '$motivo')
                      WHERE id_asignacion_unidad_chofer = '$idAsignacion'";

        if (!ejecutarConsulta($sqlCerrar)) {
            return array(
                "ok" => false,
                "liberada" => false,
                "id_chofer_ambulancia" => isset($asignacion["id_chofer_ambulancia"]) ? (int) $asignacion["id_chofer_ambulancia"] : 0,
                "nombre_chofer" => isset($asignacion["nombre_chofer"]) ? (string) $asignacion["nombre_chofer"] : ""
            );
        }

        return array(
            "ok" => true,
            "liberada" => true,
            "id_chofer_ambulancia" => isset($asignacion["id_chofer_ambulancia"]) ? (int) $asignacion["id_chofer_ambulancia"] : 0,
            "nombre_chofer" => isset($asignacion["nombre_chofer"]) ? (string) $asignacion["nombre_chofer"] : ""
        );
    }

    private function guardarAsignacionOperativaInterna($idUnidad, $idChoferAmbulancia, $fechaInicio, $ubicacionActual, $referenciaActual, $prioridadDespacho, $observaciones)
    {
        $idUnidad = (int) $idUnidad;
        $idChoferAmbulancia = (int) $idChoferAmbulancia;
        $fechaInicio = $this->esc($fechaInicio);
        $ubicacionActual = trim((string) $ubicacionActual);
        $referenciaActual = trim((string) $referenciaActual);
        $prioridadDespacho = (int) $prioridadDespacho;
        $observaciones = $this->esc($observaciones);

        $unidad = ejecutarConsultaSimpleFila("SELECT id_unidad,
                                                     estado,
                                                     estado_operativo,
                                                     ubicacion_actual,
                                                     referencia_actual,
                                                     prioridad_despacho
                                              FROM unidades
                                              WHERE id_unidad = '$idUnidad'
                                              LIMIT 1
                                              FOR UPDATE");
        if (!$unidad || (int) $unidad["estado"] !== 1) {
            return array("ok" => false, "msg" => "Debe seleccionar una unidad activa.");
        }

        if ($unidad["estado_operativo"] === "EN_SERVICIO") {
            return array("ok" => false, "msg" => "La unidad se encuentra en servicio y no puede reasignarse.");
        }

        if ($unidad["estado_operativo"] === "FUERA_SERVICIO") {
            return array("ok" => false, "msg" => "La unidad seleccionada se encuentra fuera de servicio.");
        }

        $chofer = ejecutarConsultaSimpleFila("SELECT id_chofer_ambulancia,
                                                     estado,
                                                     vencimiento_licencia
                                              FROM choferes_ambulancia
                                              WHERE id_chofer_ambulancia = '$idChoferAmbulancia'
                                              LIMIT 1
                                              FOR UPDATE");
        if (!$chofer || (int) $chofer["estado"] !== 1) {
            return array("ok" => false, "msg" => "Debe seleccionar un chofer operativo activo.");
        }

        if ($this->licenciaEstaVencida($chofer["vencimiento_licencia"])) {
            return array("ok" => false, "msg" => "La licencia del chofer se encuentra vencida. Actualice la fecha de vencimiento antes de asignar una unidad.");
        }

        $asignacionChoferActiva = ejecutarConsultaSimpleFila("SELECT id_asignacion_unidad_chofer,
                                                                     id_unidad
                                                              FROM asignaciones_unidades_choferes
                                                              WHERE id_chofer_ambulancia = '$idChoferAmbulancia'
                                                                AND estado = 1
                                                                AND fecha_fin IS NULL
                                                              LIMIT 1
                                                              FOR UPDATE");
        if ($asignacionChoferActiva) {
            if ((int) $asignacionChoferActiva["id_unidad"] === $idUnidad) {
                return array("ok" => true, "msg" => "La unidad ya estaba asignada a este chofer.", "sin_cambios" => true);
            }

            return array("ok" => false, "msg" => "El chofer seleccionado ya tiene una unidad asignada. Debe liberarla antes de conectarlo con otra ambulancia.");
        }

        $asignacionUnidadActiva = ejecutarConsultaSimpleFila("SELECT au.id_asignacion_unidad_chofer,
                                                                     au.id_chofer_ambulancia,
                                                                     CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer_actual
                                                              FROM asignaciones_unidades_choferes AS au
                                                              LEFT JOIN choferes_ambulancia AS ca
                                                                ON ca.id_chofer_ambulancia = au.id_chofer_ambulancia
                                                              LEFT JOIN empleados AS e
                                                                ON e.id_empleado = ca.id_empleado
                                                              WHERE au.id_unidad = '$idUnidad'
                                                                AND au.estado = 1
                                                                AND au.fecha_fin IS NULL
                                                              LIMIT 1
                                                              FOR UPDATE");
        if ($asignacionUnidadActiva) {
            return array("ok" => false, "msg" => "La unidad seleccionada ya cuenta con un chofer asignado.");
        }

        if ($ubicacionActual === "") {
            $ubicacionActual = (string) $unidad["ubicacion_actual"];
        }
        if ($referenciaActual === "") {
            $referenciaActual = (string) $unidad["referencia_actual"];
        }
        if ($prioridadDespacho <= 0) {
            $prioridadDespacho = (int) $unidad["prioridad_despacho"];
        }
        if ($prioridadDespacho <= 0) {
            $prioridadDespacho = 1;
        }

        $ubicacionActual = $this->esc($ubicacionActual);
        $referenciaActual = $this->esc($referenciaActual);

        $sqlAsignar = "INSERT INTO asignaciones_unidades_choferes (
                            id_unidad,
                            id_chofer_ambulancia,
                            fecha_inicio,
                            fecha_fin,
                            observaciones,
                            estado
                       ) VALUES (
                            '$idUnidad',
                            '$idChoferAmbulancia',
                            '$fechaInicio',
                            NULL,
                            '$observaciones',
                            1
                       )";

        if (!ejecutarConsulta($sqlAsignar)) {
            return array("ok" => false, "msg" => "No se pudo registrar la asignacion operativa.");
        }

        $sqlUnidad = "UPDATE unidades
                      SET estado_operativo = 'DISPONIBLE',
                          ubicacion_actual = '$ubicacionActual',
                          referencia_actual = '$referenciaActual',
                          prioridad_despacho = '$prioridadDespacho',
                          fecha_actualizacion_operativa = NOW()
                      WHERE id_unidad = '$idUnidad'";

        if (!ejecutarConsulta($sqlUnidad)) {
            return array("ok" => false, "msg" => "No se pudo actualizar la unidad.");
        }

        return array("ok" => true, "msg" => "Asignacion operativa guardada correctamente.", "sin_cambios" => false);
    }

    private function generarTicketInterno($idSeguridad, $fechaSeguridad)
    {
        $timestamp = strtotime((string) $fechaSeguridad);
        if ($timestamp === false) {
            $timestamp = time();
        }

        return "SEG-" . date("Ymd", $timestamp) . "-" . str_pad((string) $idSeguridad, 6, "0", STR_PAD_LEFT);
    }

    private function obtenerIdEstadoSolicitudPorCodigo($codigoEstado)
    {
        return $this->estadoSolicitud->obtenerIdPorCodigo($codigoEstado);
    }

    private function obtenerUltimoSeguimientoEstado($idSeguridad)
    {
        return $this->estadoSolicitud->obtenerUltimoSeguimiento("SEGURIDAD", $idSeguridad);
    }

    private function registrarSeguimientoEstado($idSeguridad, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)
    {
        return $this->estadoSolicitud->registrarSeguimiento(
            "SEGURIDAD",
            $idSeguridad,
            $idEstadoSolicitud,
            $idUsuario,
            $fechaGestion,
            $observacion
        );
    }

    private function mapearEstadoAtencionACodigo($estadoAtencion)
    {
        switch ((string) $estadoAtencion) {
            case "DESPACHADO":
            case "PENDIENTE_UNIDAD":
                return "EN_GESTION";
            case "FINALIZADO":
                return "ATENDIDA";
            case "NO_ATENDIDA":
                return "NO_ATENDIDA";
            default:
                return "REGISTRADA";
        }
    }

    private function sincronizarEstadoSolicitud($idSeguridad, $codigoEstado, $idUsuario, $fechaGestion, $observacion)
    {
        $idSeguridad = (int) $idSeguridad;
        $idUsuario = (int) $idUsuario;
        $codigoEstado = strtoupper(trim((string) $codigoEstado));
        $observacion = trim((string) $observacion);

        $idEstadoSolicitud = $this->obtenerIdEstadoSolicitudPorCodigo($codigoEstado);
        if ($idSeguridad <= 0 || $idEstadoSolicitud <= 0) {
            return false;
        }

        $actual = ejecutarConsultaSimpleFila("SELECT id_estado_solicitud FROM seguridad WHERE id_seguridad = '$idSeguridad' LIMIT 1");
        $idEstadoActual = $actual ? (int) $actual["id_estado_solicitud"] : 0;

        if (!ejecutarConsulta("UPDATE seguridad SET id_estado_solicitud = '$idEstadoSolicitud' WHERE id_seguridad = '$idSeguridad'")) {
            return false;
        }

        $ultimoSeguimiento = $this->obtenerUltimoSeguimientoEstado($idSeguridad);
        $debeRegistrarSeguimiento = $idEstadoActual !== $idEstadoSolicitud || !$ultimoSeguimiento || $observacion !== "";
        if (!$debeRegistrarSeguimiento) {
            return true;
        }

        return $this->registrarSeguimientoEstado($idSeguridad, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion);
    }

    public function listarEstadosSolicitud()
    {
        return $this->estadoSolicitud->listarActivos();
    }

    private function obtenerTipoSeguridad($idTipoSeguridad)
    {
        $idTipoSeguridad = (int) $idTipoSeguridad;
        $sql = "SELECT id_tipo_ayuda_social AS id_tipo_seguridad,
                       nombre_tipo_ayuda AS nombre_tipo,
                       COALESCE(requiere_ambulancia, 0) AS requiere_ambulancia,
                       estado
                FROM tipos_ayuda_social
                WHERE id_tipo_ayuda_social = '$idTipoSeguridad'
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    private function obtenerSolicitudSeguridad($idSolicitudSeguridad)
    {
        $idSolicitudSeguridad = (int) $idSolicitudSeguridad;
        $sql = "SELECT id_solicitud_general AS id_solicitud_seguridad,
                       nombre_solicitud,
                       estado
                FROM solicitudes_generales
                WHERE id_solicitud_general = '$idSolicitudSeguridad'
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    private function obtenerSeguridadPorId($idSeguridad, $forUpdate = false)
    {
        $idSeguridad = (int) $idSeguridad;
        $columnas = $this->obtenerListaColumnasSelect("seguridad", "s");
        $sql = "SELECT " . $columnas . ",
                       COALESCE(tas.requiere_ambulancia, 0) AS requiere_ambulancia
                FROM seguridad AS s
                LEFT JOIN tipos_ayuda_social AS tas
                    ON tas.id_tipo_ayuda_social = s.id_tipo_seguridad
                WHERE s.id_seguridad = '$idSeguridad'
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    private function obtenerDespachoActivoFila($idSeguridad, $forUpdate = false)
    {
        $idSeguridad = (int) $idSeguridad;
        $columnas = $this->obtenerListaColumnasSelect("despachos_unidades", "du");
        $sql = "SELECT " . $columnas . "
                FROM despachos_unidades AS du
                WHERE du.id_seguridad = '$idSeguridad'
                  AND du.estado_despacho = 'ACTIVO'
                ORDER BY du.id_despacho_unidad DESC
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    private function buscarAsignacionDisponible($forUpdate = false)
    {
        $sql = "SELECT au.id_asignacion_unidad_chofer,
                       au.id_unidad,
                       au.id_chofer_ambulancia,
                       u.codigo_unidad,
                       u.descripcion AS descripcion_unidad,
                       u.placa,
                       u.estado_operativo,
                       u.ubicacion_actual,
                       u.referencia_actual,
                       u.prioridad_despacho,
                       ca.numero_licencia,
                       ca.categoria_licencia,
                       ca.vencimiento_licencia,
                       e.id_empleado,
                       e.cedula AS cedula_chofer,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer,
                       e.telefono AS telefono_chofer
                FROM asignaciones_unidades_choferes AS au
                INNER JOIN unidades AS u
                    ON u.id_unidad = au.id_unidad
                INNER JOIN choferes_ambulancia AS ca
                    ON ca.id_chofer_ambulancia = au.id_chofer_ambulancia
                INNER JOIN empleados AS e
                    ON e.id_empleado = ca.id_empleado
                WHERE au.estado = 1
                  AND au.fecha_fin IS NULL
                  AND u.estado = 1
                  AND u.estado_operativo = 'DISPONIBLE'
                  AND ca.estado = 1
                  AND ca.vencimiento_licencia >= CURDATE()
                  AND e.estado = 1
                ORDER BY u.prioridad_despacho ASC, u.id_unidad ASC
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    private function buscarAsignacionDisponiblePorId($idAsignacion, $forUpdate = false)
    {
        $idAsignacion = (int) $idAsignacion;
        $sql = "SELECT au.id_asignacion_unidad_chofer,
                       au.id_unidad,
                       au.id_chofer_ambulancia,
                       u.codigo_unidad,
                       u.descripcion AS descripcion_unidad,
                       u.placa,
                       u.estado_operativo,
                       u.ubicacion_actual,
                       u.referencia_actual,
                       u.prioridad_despacho,
                       ca.numero_licencia,
                       ca.categoria_licencia,
                       ca.vencimiento_licencia,
                       e.id_empleado,
                       e.cedula AS cedula_chofer,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer,
                       e.telefono AS telefono_chofer
                FROM asignaciones_unidades_choferes AS au
                INNER JOIN unidades AS u
                    ON u.id_unidad = au.id_unidad
                INNER JOIN choferes_ambulancia AS ca
                    ON ca.id_chofer_ambulancia = au.id_chofer_ambulancia
                INNER JOIN empleados AS e
                    ON e.id_empleado = ca.id_empleado
                WHERE au.id_asignacion_unidad_chofer = '$idAsignacion'
                  AND au.estado = 1
                  AND au.fecha_fin IS NULL
                  AND u.estado = 1
                  AND u.estado_operativo = 'DISPONIBLE'
                  AND ca.estado = 1
                  AND ca.vencimiento_licencia >= CURDATE()
                  AND e.estado = 1
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    private function obtenerAsignacionesDisponiblesColeccion()
    {
        $items = array();
        $rspta = $this->listarAsignacionesDisponibles();
        if (!$rspta) {
            return $items;
        }

        while ($reg = $rspta->fetch_assoc()) {
            $items[] = $reg;
        }

        return $items;
    }

    private function actualizarUnidadComoEnServicio($idUnidad)
    {
        $idUnidad = (int) $idUnidad;
        $sql = "UPDATE unidades
                SET estado_operativo = 'EN_SERVICIO',
                    fecha_actualizacion_operativa = NOW()
                WHERE id_unidad = '$idUnidad'
                  AND estado = 1
                  AND estado_operativo = 'DISPONIBLE'";

        $resultado = ejecutarConsulta($sql);
        if (!$resultado) {
            return false;
        }

        return $this->db()->affected_rows > 0;
    }

    private function crearDespacho($idSeguridad, $idUsuario, $asignacion, $modoAsignacion, $ubicacionEvento, $observaciones)
    {
        $idSeguridad = (int) $idSeguridad;
        $idUsuario = (int) $idUsuario;
        $idUnidad = (int) $asignacion["id_unidad"];
        $idChofer = (int) $asignacion["id_chofer_ambulancia"];
        $modoAsignacion = $this->esc($modoAsignacion);
        $ubicacionSalida = $this->esc($asignacion["ubicacion_actual"]);
        $ubicacionEvento = $this->esc($ubicacionEvento);
        $observaciones = $this->esc($observaciones);

        $sql = "INSERT INTO despachos_unidades (
                    id_seguridad,
                    id_unidad,
                    id_chofer_ambulancia,
                    id_usuario_asigna,
                    modo_asignacion,
                    estado_despacho,
                    fecha_asignacion,
                    ubicacion_salida,
                    ubicacion_evento,
                    observaciones
                ) VALUES (
                    '$idSeguridad',
                    '$idUnidad',
                    '$idChofer',
                    '$idUsuario',
                    '$modoAsignacion',
                    'ACTIVO',
                    NOW(),
                    '$ubicacionSalida',
                    '$ubicacionEvento',
                    '$observaciones'
                )";

        return ejecutarConsulta_retornarID($sql);
    }

    private function formatearResultadoAsignacion($asignacion)
    {
        if (!$asignacion) {
            return null;
        }

        return array(
            "id_unidad" => (int) $asignacion["id_unidad"],
            "codigo_unidad" => $asignacion["codigo_unidad"],
            "placa" => $asignacion["placa"],
            "descripcion_unidad" => $asignacion["descripcion_unidad"],
            "ubicacion_actual" => $asignacion["ubicacion_actual"],
            "referencia_actual" => $asignacion["referencia_actual"],
            "prioridad_despacho" => isset($asignacion["prioridad_despacho"]) ? (int) $asignacion["prioridad_despacho"] : 0
        );
    }

    private function formatearResultadoChofer($asignacion)
    {
        if (!$asignacion || !is_array($asignacion)) {
            return null;
        }

        return array(
            "id_chofer_ambulancia" => isset($asignacion["id_chofer_ambulancia"]) ? (int) $asignacion["id_chofer_ambulancia"] : 0,
            "id_empleado" => isset($asignacion["id_empleado"]) ? (int) $asignacion["id_empleado"] : 0,
            "nombre_chofer" => isset($asignacion["nombre_chofer"]) ? $asignacion["nombre_chofer"] : "",
            "cedula_chofer" => isset($asignacion["cedula_chofer"]) ? $asignacion["cedula_chofer"] : "",
            "telefono_chofer" => array_key_exists("telefono_chofer", $asignacion) ? $asignacion["telefono_chofer"] : null,
            "correo_chofer" => array_key_exists("correo_chofer", $asignacion) ? $asignacion["correo_chofer"] : null,
            "numero_licencia" => isset($asignacion["numero_licencia"]) ? $asignacion["numero_licencia"] : "",
            "categoria_licencia" => isset($asignacion["categoria_licencia"]) ? $asignacion["categoria_licencia"] : "",
            "vencimiento_licencia" => array_key_exists("vencimiento_licencia", $asignacion) ? $asignacion["vencimiento_licencia"] : null
        );
    }

    private function formatearSugerenciaOperativa($asignacion)
    {
        if (!$asignacion) {
            return null;
        }

        return array(
            "id_asignacion_unidad_chofer" => isset($asignacion["id_asignacion_unidad_chofer"]) ? (int) $asignacion["id_asignacion_unidad_chofer"] : 0,
            "unidad" => $this->formatearResultadoAsignacion($asignacion),
            "chofer" => $this->formatearResultadoChofer($asignacion)
        );
    }

    private function valorHtml($valor)
    {
        return htmlspecialchars((string) $valor, ENT_QUOTES, "UTF-8");
    }

    private function esCorreoValido($correo)
    {
        $correo = trim((string) $correo);
        return $correo !== "" && filter_var($correo, FILTER_VALIDATE_EMAIL);
    }

    private function formatearFechaHoraReporte($valor)
    {
        $valor = trim((string) $valor);
        if ($valor === "" || $valor === "0000-00-00 00:00:00") {
            return "";
        }

        $timestamp = strtotime($valor);
        if ($timestamp === false) {
            return $valor;
        }

        return date("d/m/Y h:i A", $timestamp);
    }

    private function obtenerDirectorioReportesSolicitudes()
    {
        $relativo = "uploads/reportes_solicitudes_ambulancia/";
        $absoluto = dirname(__DIR__) . DIRECTORY_SEPARATOR . "uploads" . DIRECTORY_SEPARATOR . "reportes_solicitudes_ambulancia" . DIRECTORY_SEPARATOR;
        return array("relativo" => $relativo, "absoluto" => $absoluto);
    }

    private function asegurarDirectorio($rutaAbsoluta)
    {
        if (is_dir($rutaAbsoluta)) {
            return true;
        }

        return @mkdir($rutaAbsoluta, 0777, true);
    }

    private function sanitizarNombreArchivo($valor)
    {
        $valor = strtoupper(trim((string) $valor));
        $valor = str_replace(array(" ", "/", "\\", ":"), "_", $valor);
        $valor = preg_replace('/[^A-Z0-9_\-]/', "", $valor);
        $valor = preg_replace('/_+/', "_", (string) $valor);
        $valor = trim((string) $valor, "_");
        if ($valor === "") {
            $valor = "REPORTE";
        }

        return $valor;
    }

    private function obtenerResumenReporteSolicitud($idSeguridad, $idDespachoUnidad = 0)
    {
        $idSeguridad = (int) $idSeguridad;
        $idDespachoUnidad = (int) $idDespachoUnidad;
        $joinDespacho = $idDespachoUnidad > 0
            ? "LEFT JOIN despachos_unidades AS du
                ON du.id_despacho_unidad = '$idDespachoUnidad'"
            : "LEFT JOIN " . $this->ultimoDespachoSubquery() . " AS du
                ON du.id_seguridad = s.id_seguridad";

        $sql = "SELECT s.id_seguridad,
                       s.ticket_interno,
                       s.estado_atencion,
                       s.descripcion,
                       s.fecha_seguridad,
                       DATE_FORMAT(s.fecha_seguridad, '%d/%m/%Y %h:%i %p') AS fecha_seguridad_formateada,
                       COALESCE(tas.nombre_tipo_ayuda, s.tipo_seguridad) AS tipo_seguridad,
                       COALESCE(sg.nombre_solicitud, s.tipo_solicitud) AS tipo_solicitud,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono AS telefono_beneficiario,
                       s.ubicacion_evento,
                       s.referencia_evento,
                       du.id_despacho_unidad,
                       du.estado_despacho,
                       du.fecha_asignacion,
                       DATE_FORMAT(du.fecha_asignacion, '%d/%m/%Y %h:%i %p') AS fecha_asignacion_formateada,
                       du.fecha_cierre,
                       DATE_FORMAT(du.fecha_cierre, '%d/%m/%Y %h:%i %p') AS fecha_cierre_despacho_formateada,
                       du.ubicacion_salida,
                       du.ubicacion_evento AS ubicacion_evento_despacho,
                       du.ubicacion_cierre,
                       du.observaciones AS observaciones_despacho,
                       u.id_unidad,
                       u.codigo_unidad,
                       u.descripcion AS descripcion_unidad,
                       u.placa,
                       u.ubicacion_actual,
                       u.referencia_actual,
                       ca.id_chofer_ambulancia,
                       ca.numero_licencia,
                       ca.categoria_licencia,
                       ca.vencimiento_licencia,
                       e.id_empleado,
                       e.cedula AS cedula_chofer,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer,
                       e.telefono AS telefono_chofer,
                       e.correo AS correo_chofer,
                       rt.id_reporte AS id_reporte_traslado,
                       rt.fecha_hora AS fecha_hora_reporte_traslado,
                       DATE_FORMAT(rt.fecha_hora, '%d/%m/%Y %h:%i %p') AS fecha_hora_reporte_traslado_formateada,
                       rt.diagnostico_paciente,
                       rt.foto_evidencia,
                       rt.km_salida,
                       rt.km_llegada
                FROM seguridad AS s
                LEFT JOIN tipos_ayuda_social AS tas
                    ON tas.id_tipo_ayuda_social = s.id_tipo_seguridad
                LEFT JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = s.id_solicitud_seguridad
                LEFT JOIN beneficiarios AS b
                    ON b.id_beneficiario = s.id_beneficiario
                $joinDespacho
                LEFT JOIN unidades AS u
                    ON u.id_unidad = du.id_unidad
                LEFT JOIN choferes_ambulancia AS ca
                    ON ca.id_chofer_ambulancia = du.id_chofer_ambulancia
                LEFT JOIN empleados AS e
                    ON e.id_empleado = ca.id_empleado
                LEFT JOIN " . $this->ultimoReporteTrasladoSubquery() . " AS rt
                    ON rt.id_despacho_unidad = du.id_despacho_unidad
                WHERE s.id_seguridad = '$idSeguridad'
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    private function renderizarPdfConDompdf($html, $rutaAbsoluta)
    {
        try {
            $autoloadDompdf = dirname(__DIR__) . DIRECTORY_SEPARATOR . "lib" . DIRECTORY_SEPARATOR . "dompdf" . DIRECTORY_SEPARATOR . "autoload.inc.php";
            if (!is_file($autoloadDompdf)) {
                return array("ok" => false, "msg" => "No se encontro la libreria Dompdf en la carpeta lib.");
            }

            require_once $autoloadDompdf;
            if (!class_exists("\\Dompdf\\Dompdf") || !class_exists("\\Dompdf\\Options")) {
                return array("ok" => false, "msg" => "No fue posible cargar Dompdf correctamente.");
            }

            $options = new \Dompdf\Options();
            $options->set("isHtml5ParserEnabled", true);
            $options->set("isRemoteEnabled", false);
            $options->set("isPhpEnabled", false);
            $options->set("chroot", dirname(__DIR__));
            $tmpDir = sys_get_temp_dir();
            if (is_string($tmpDir) && $tmpDir !== "" && is_dir($tmpDir)) {
                $options->set("tempDir", $tmpDir);
            }

            $dompdf = new \Dompdf\Dompdf($options);
            $dompdf->loadHtml((string) $html, "UTF-8");
            $dompdf->setPaper("A4", "portrait");
            $dompdf->render();

            $pdfBytes = $dompdf->output();
            if (@file_put_contents($rutaAbsoluta, $pdfBytes) === false) {
                return array("ok" => false, "msg" => "No se pudo guardar el archivo PDF del reporte.");
            }

            return array("ok" => true);
        } catch (Exception $exception) {
            return array("ok" => false, "msg" => "Fallo la generacion PDF: " . $exception->getMessage());
        }
    }

    private function construirHtmlReporteSolicitudAmbulancia($datos, $tipoReporte)
    {
        $tipoReporte = strtoupper(trim((string) $tipoReporte)) === "CIERRE" ? "CIERRE" : "REGISTRO";
        $tituloPrincipal = $tipoReporte === "CIERRE"
            ? "REPORTE DE CIERRE DE DESPACHO DE AMBULANCIA"
            : "REPORTE DE SOLICITUD DE AMBULANCIA";

        $nombreSistema = defined("PRO_NOMBRE") && trim((string) PRO_NOMBRE) !== ""
            ? trim((string) PRO_NOMBRE)
            : "Sala Situacional";

        $ticket = isset($datos["ticket_interno"]) ? (string) $datos["ticket_interno"] : "";
        $beneficiario = trim((string) (isset($datos["nacionalidad"]) ? $datos["nacionalidad"] : "") . "-" . (isset($datos["cedula"]) ? $datos["cedula"] : "") . " " . (isset($datos["nombre_beneficiario"]) ? $datos["nombre_beneficiario"] : ""));
        $chofer = isset($datos["nombre_chofer"]) ? (string) $datos["nombre_chofer"] : "";
        $correoChofer = isset($datos["correo_chofer"]) ? (string) $datos["correo_chofer"] : "";
        $fechaEmision = date("d/m/Y h:i A");
        $fechaSolicitud = $this->formatearFechaHoraReporte(isset($datos["fecha_seguridad"]) ? $datos["fecha_seguridad"] : "");
        $fechaDespacho = $this->formatearFechaHoraReporte(isset($datos["fecha_asignacion"]) ? $datos["fecha_asignacion"] : "");
        $fechaCierre = $this->formatearFechaHoraReporte(
            isset($datos["fecha_hora_reporte_traslado"]) && trim((string) $datos["fecha_hora_reporte_traslado"]) !== ""
                ? $datos["fecha_hora_reporte_traslado"]
                : (isset($datos["fecha_cierre"]) ? $datos["fecha_cierre"] : "")
        );

        $html = '<!doctype html><html lang="es"><head><meta charset="utf-8">';
        $html .= '<meta name="viewport" content="width=device-width, initial-scale=1">';
        $html .= '<title>' . $this->valorHtml($tituloPrincipal . " - " . $ticket) . '</title>';
        $html .= '<style>';
        $html .= 'body{margin:0;padding:24px;background:#eef2f7;font-family:Arial,Helvetica,sans-serif;color:#1f2d3d;}';
        $html .= '.sheet{max-width:900px;margin:0 auto;background:#fff;border-radius:14px;border:1px solid #d8e0ea;overflow:hidden;box-shadow:0 12px 30px rgba(16,45,69,.12);}';
        $html .= '.head{padding:22px 24px;border-bottom:1px solid #dbe4ee;background:linear-gradient(180deg,#f8fbfe 0%,#eef4fa 100%);}';
        $html .= '.head h1{margin:0 0 8px;font-size:1.08rem;letter-spacing:.04em;color:#0f3556;}';
        $html .= '.head p{margin:2px 0;font-size:.92rem;color:#4c6278;}';
        $html .= '.content{padding:20px 24px 26px;}';
        $html .= '.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;}';
        $html .= '.card{border:1px solid #dce5ef;border-radius:10px;padding:12px;background:#fbfdff;}';
        $html .= '.label{display:block;font-size:.74rem;text-transform:uppercase;letter-spacing:.05em;color:#6a7f94;margin-bottom:4px;}';
        $html .= '.value{display:block;font-size:.92rem;color:#162f47;font-weight:600;line-height:1.35;}';
        $html .= '.section-title{margin:20px 0 10px;font-size:.86rem;letter-spacing:.06em;text-transform:uppercase;color:#274966;}';
        $html .= '.full{grid-column:1/-1;}';
        $html .= '.foot{padding:12px 24px;border-top:1px solid #dbe4ee;background:#f7f9fc;color:#61758a;font-size:.78rem;}';
        $html .= '@media(max-width:720px){body{padding:12px}.sheet{border-radius:10px}.content{padding:16px}.grid{grid-template-columns:1fr}.head{padding:16px}.foot{padding:12px 16px}}';
        $html .= '@media print{body{background:#fff;padding:0}.sheet{box-shadow:none;border:0;max-width:none}}';
        $html .= '</style></head><body>';
        $html .= '<article class="sheet"><header class="head">';
        $html .= '<h1>' . $this->valorHtml($tituloPrincipal) . '</h1>';
        $html .= '<p><strong>Institucion:</strong> ' . $this->valorHtml($nombreSistema) . '</p>';
        $html .= '<p><strong>Ticket:</strong> ' . $this->valorHtml($ticket !== "" ? $ticket : "Sin ticket") . ' | <strong>Fecha de emision:</strong> ' . $this->valorHtml($fechaEmision) . '</p>';
        $html .= '</header><section class="content">';
        $html .= '<div class="section-title">Datos de la solicitud</div><div class="grid">';
        $html .= '<div class="card"><span class="label">Tipo de ayuda</span><span class="value">' . $this->valorHtml(isset($datos["tipo_seguridad"]) ? $datos["tipo_seguridad"] : "") . '</span></div>';
        $html .= '<div class="card"><span class="label">Tipo de solicitud</span><span class="value">' . $this->valorHtml(isset($datos["tipo_solicitud"]) ? $datos["tipo_solicitud"] : "") . '</span></div>';
        $html .= '<div class="card"><span class="label">Fecha de solicitud</span><span class="value">' . $this->valorHtml($fechaSolicitud !== "" ? $fechaSolicitud : "No disponible") . '</span></div>';
        $html .= '<div class="card"><span class="label">Estado operativo</span><span class="value">' . $this->valorHtml(isset($datos["estado_atencion"]) ? $datos["estado_atencion"] : "") . '</span></div>';
        $html .= '<div class="card full"><span class="label">Descripcion de la incidencia</span><span class="value">' . $this->valorHtml(isset($datos["descripcion"]) ? $datos["descripcion"] : "Sin descripcion") . '</span></div>';
        $html .= '<div class="card"><span class="label">Ubicacion</span><span class="value">' . $this->valorHtml(isset($datos["ubicacion_evento"]) ? $datos["ubicacion_evento"] : "") . '</span></div>';
        $html .= '<div class="card"><span class="label">Referencia</span><span class="value">' . $this->valorHtml(isset($datos["referencia_evento"]) ? $datos["referencia_evento"] : "Sin referencia") . '</span></div></div>';
        $html .= '<div class="section-title">Beneficiario</div><div class="grid">';
        $html .= '<div class="card"><span class="label">Identificacion</span><span class="value">' . $this->valorHtml($beneficiario !== "-" ? $beneficiario : "No disponible") . '</span></div>';
        $html .= '<div class="card"><span class="label">Telefono</span><span class="value">' . $this->valorHtml(isset($datos["telefono_beneficiario"]) ? $datos["telefono_beneficiario"] : "Sin telefono") . '</span></div></div>';
        $html .= '<div class="section-title">Despacho de ambulancia</div><div class="grid">';
        $html .= '<div class="card"><span class="label">Unidad</span><span class="value">' . $this->valorHtml(isset($datos["codigo_unidad"]) ? $datos["codigo_unidad"] : "Sin unidad") . ' / ' . $this->valorHtml(isset($datos["placa"]) ? $datos["placa"] : "--") . '</span></div>';
        $html .= '<div class="card"><span class="label">Descripcion unidad</span><span class="value">' . $this->valorHtml(isset($datos["descripcion_unidad"]) ? $datos["descripcion_unidad"] : "No disponible") . '</span></div>';
        $html .= '<div class="card"><span class="label">Chofer</span><span class="value">' . $this->valorHtml($chofer !== "" ? $chofer : "Sin chofer asignado") . '</span></div>';
        $html .= '<div class="card"><span class="label">Correo chofer</span><span class="value">' . $this->valorHtml($correoChofer !== "" ? $correoChofer : "No registrado") . '</span></div>';
        $html .= '<div class="card"><span class="label">Licencia</span><span class="value">' . $this->valorHtml(isset($datos["numero_licencia"]) ? $datos["numero_licencia"] : "--") . ' (' . $this->valorHtml(isset($datos["categoria_licencia"]) ? $datos["categoria_licencia"] : "--") . ')</span></div>';
        $html .= '<div class="card"><span class="label">Fecha despacho</span><span class="value">' . $this->valorHtml($fechaDespacho !== "" ? $fechaDespacho : "Pendiente") . '</span></div></div>';

        if ($tipoReporte === "CIERRE") {
            $html .= '<div class="section-title">Cierre del despacho</div><div class="grid">';
            $html .= '<div class="card"><span class="label">Fecha de cierre</span><span class="value">' . $this->valorHtml($fechaCierre !== "" ? $fechaCierre : "No registrada") . '</span></div>';
            $html .= '<div class="card"><span class="label">Ubicacion final</span><span class="value">' . $this->valorHtml(isset($datos["ubicacion_cierre"]) ? $datos["ubicacion_cierre"] : "No disponible") . '</span></div>';
            $html .= '<div class="card"><span class="label">Km salida</span><span class="value">' . $this->valorHtml(isset($datos["km_salida"]) ? $datos["km_salida"] : "--") . '</span></div>';
            $html .= '<div class="card"><span class="label">Km llegada</span><span class="value">' . $this->valorHtml(isset($datos["km_llegada"]) ? $datos["km_llegada"] : "--") . '</span></div>';
            $html .= '<div class="card full"><span class="label">Resultado / diagnostico</span><span class="value">' . $this->valorHtml(isset($datos["diagnostico_paciente"]) ? $datos["diagnostico_paciente"] : "Sin novedad registrada") . '</span></div></div>';
        }

        $html .= '</section><footer class="foot">Documento generado automaticamente por el sistema. ID solicitud: ' . $this->valorHtml(isset($datos["id_seguridad"]) ? $datos["id_seguridad"] : 0) . '.</footer></article></body></html>';
        return $html;
    }

    private function generarArchivoReporteSolicitudAmbulancia($datos, $tipoReporte)
    {
        $directorios = $this->obtenerDirectorioReportesSolicitudes();
        if (!$this->asegurarDirectorio($directorios["absoluto"])) {
            return array("ok" => false, "msg" => "No se pudo crear el directorio de reportes.");
        }

        $tipoSlug = strtoupper(trim((string) $tipoReporte)) === "CIERRE" ? "cierre" : "registro";
        $ticket = isset($datos["ticket_interno"]) ? trim((string) $datos["ticket_interno"]) : "";
        $base = $this->sanitizarNombreArchivo($ticket !== "" ? $ticket : "solicitud_" . (int) $datos["id_seguridad"]);
        $nombreArchivo = $base . "_" . $tipoSlug . "_" . date("Ymd_His") . "_" . mt_rand(1000, 9999) . ".pdf";
        $rutaRelativa = $directorios["relativo"] . $nombreArchivo;
        $rutaAbsoluta = $directorios["absoluto"] . $nombreArchivo;
        $html = $this->construirHtmlReporteSolicitudAmbulancia($datos, $tipoReporte);
        $resultadoPdf = $this->renderizarPdfConDompdf($html, $rutaAbsoluta);
        if (!$resultadoPdf["ok"]) {
            return $resultadoPdf;
        }

        return array(
            "ok" => true,
            "nombre_archivo" => $nombreArchivo,
            "ruta_relativa" => $rutaRelativa,
            "ruta_absoluta" => $rutaAbsoluta
        );
    }

    private function registrarReporteSolicitudAmbulancia($idSeguridad, $idDespachoUnidad, $tipoReporte, $nombreArchivo, $rutaArchivo, $idUsuarioGenera, $envioReporte)
    {
        if (!$this->tieneTablaReportesSolicitudesAmbulancia()) {
            return 0;
        }

        $idSeguridad = (int) $idSeguridad;
        $idDespachoUnidad = (int) $idDespachoUnidad;
        $idUsuarioGenera = (int) $idUsuarioGenera;
        $tipoReporte = strtoupper(trim((string) $tipoReporte)) === "CIERRE" ? "CIERRE" : "REGISTRO";
        $estadoEnvio = isset($envioReporte["estado"]) ? strtoupper(trim((string) $envioReporte["estado"])) : "NO_APLICA";
        if (!in_array($estadoEnvio, array("NO_APLICA", "PENDIENTE", "ENVIADO", "ERROR"), true)) {
            $estadoEnvio = "NO_APLICA";
        }

        $correoDestino = isset($envioReporte["correo_destino"]) ? trim((string) $envioReporte["correo_destino"]) : "";
        $detalleEnvio = isset($envioReporte["detalle"]) ? trim((string) $envioReporte["detalle"]) : "";
        $fechaEnvio = isset($envioReporte["fecha_envio"]) ? trim((string) $envioReporte["fecha_envio"]) : "";

        $sql = "INSERT INTO reportes_solicitudes_ambulancia (
                            id_seguridad,
                            id_despacho_unidad,
                            tipo_reporte,
                            nombre_archivo,
                            ruta_archivo,
                            estado_envio,
                            correo_destino,
                            fecha_envio,
                            detalle_envio,
                            id_usuario_genera,
                            estado
                        ) VALUES (
                            '$idSeguridad',
                            " . ($idDespachoUnidad > 0 ? "'$idDespachoUnidad'" : "NULL") . ",
                            '" . $this->esc($tipoReporte) . "',
                            '" . $this->esc($nombreArchivo) . "',
                            '" . $this->esc($rutaArchivo) . "',
                            '" . $this->esc($estadoEnvio) . "',
                            " . ($correoDestino !== "" ? "'" . $this->esc($correoDestino) . "'" : "NULL") . ",
                            " . ($fechaEnvio !== "" ? "'" . $this->esc($fechaEnvio) . "'" : "NULL") . ",
                            " . ($detalleEnvio !== "" ? "'" . $this->esc($detalleEnvio) . "'" : "NULL") . ",
                            " . ($idUsuarioGenera > 0 ? "'$idUsuarioGenera'" : "NULL") . ",
                            1
                        )";

        return (int) ejecutarConsulta_retornarID($sql);
    }

    private function obtenerConfiguracionSmtpActiva()
    {
        if (!$this->existeTabla("configuracion_smtp")) {
            return null;
        }

        $sql = "SELECT host,
                       puerto,
                       usuario,
                       clave,
                       correo_remitente,
                       nombre_remitente,
                       IFNULL(usar_tls, 1) AS usar_tls
                FROM configuracion_smtp
                WHERE IFNULL(estado, 1) = 1
                ORDER BY id_configuracion_smtp DESC
                LIMIT 1";
        return ejecutarConsultaSimpleFila($sql);
    }

    private function smtpLeerRespuesta($socket)
    {
        $respuesta = "";
        while (!feof($socket)) {
            $linea = fgets($socket, 1024);
            if ($linea === false) {
                break;
            }

            $respuesta .= $linea;
            if (strlen($linea) < 4 || substr($linea, 3, 1) === " ") {
                break;
            }
        }

        return trim((string) $respuesta);
    }

    private function smtpEnviarComando($socket, $comando, $codigosEsperados)
    {
        if ($comando !== null) {
            if (@fwrite($socket, $comando . "\r\n") === false) {
                throw new Exception("No se pudo enviar un comando al servidor SMTP.");
            }
        }

        $respuesta = $this->smtpLeerRespuesta($socket);
        if (!preg_match('/^(\d{3})/', $respuesta, $match)) {
            throw new Exception("Respuesta SMTP invalida: " . $respuesta);
        }

        $codigo = (int) $match[1];
        if (!in_array($codigo, $codigosEsperados, true)) {
            throw new Exception("Error SMTP " . $codigo . ": " . $respuesta);
        }

        return $respuesta;
    }

    private function enviarCorreoSmtpHtml($config, $destinatario, $asunto, $mensajeHtml, $adjunto = null)
    {
        $host = trim((string) (isset($config["host"]) ? $config["host"] : ""));
        $puerto = isset($config["puerto"]) ? (int) $config["puerto"] : 0;
        $usuario = trim((string) (isset($config["usuario"]) ? $config["usuario"] : ""));
        $clave = (string) (isset($config["clave"]) ? $config["clave"] : "");
        $correoRemitente = trim((string) (isset($config["correo_remitente"]) ? $config["correo_remitente"] : ""));
        $nombreRemitente = trim((string) (isset($config["nombre_remitente"]) ? $config["nombre_remitente"] : ""));
        $usarTls = isset($config["usar_tls"]) && (int) $config["usar_tls"] === 1;
        $usarAdjunto = is_array($adjunto) && isset($adjunto["ruta_absoluta"]) && trim((string) $adjunto["ruta_absoluta"]) !== "";
        $rutaAdjunto = "";
        $nombreAdjunto = "";
        $mimeAdjunto = "application/octet-stream";

        if ($usarAdjunto) {
            $rutaAdjunto = trim((string) $adjunto["ruta_absoluta"]);
            if (!is_file($rutaAdjunto)) {
                throw new Exception("No se encontro el archivo adjunto del reporte.");
            }

            $nombreAdjunto = isset($adjunto["nombre_archivo"]) ? trim((string) $adjunto["nombre_archivo"]) : "";
            if ($nombreAdjunto === "") {
                $nombreAdjunto = basename($rutaAdjunto);
            }
            $nombreAdjunto = preg_replace('/[^A-Za-z0-9_\.\-]/', "_", $nombreAdjunto);
            if ($nombreAdjunto === "") {
                $nombreAdjunto = "reporte_solicitud_ambulancia.html";
            }

            $mimeAdjuntoData = isset($adjunto["mime"]) ? trim((string) $adjunto["mime"]) : "";
            if ($mimeAdjuntoData !== "") {
                $mimeAdjunto = $mimeAdjuntoData;
            } else {
                if (function_exists("finfo_open")) {
                    $finfo = @finfo_open(FILEINFO_MIME_TYPE);
                    if ($finfo) {
                        $mimeDetectado = @finfo_file($finfo, $rutaAdjunto);
                        @finfo_close($finfo);
                        if (is_string($mimeDetectado) && trim($mimeDetectado) !== "") {
                            $mimeAdjunto = trim($mimeDetectado);
                        }
                    }
                }
            }
        }

        if ($host === "" || $puerto <= 0 || $usuario === "" || trim($clave) === "" || !$this->esCorreoValido($correoRemitente)) {
            throw new Exception("La configuracion SMTP esta incompleta.");
        }

        $contexto = stream_context_create(array(
            "ssl" => array(
                "verify_peer" => false,
                "verify_peer_name" => false,
                "allow_self_signed" => true
            )
        ));

        $socket = @stream_socket_client(
            $host . ":" . $puerto,
            $errno,
            $error,
            20,
            STREAM_CLIENT_CONNECT,
            $contexto
        );

        if (!$socket) {
            throw new Exception("No se pudo conectar al servidor SMTP: " . $error);
        }

        stream_set_timeout($socket, 20);

        try {
            $this->smtpEnviarComando($socket, null, array(220));

            $heloHost = isset($_SERVER["SERVER_NAME"]) ? preg_replace('/[^A-Za-z0-9\.\-]/', '', (string) $_SERVER["SERVER_NAME"]) : "localhost";
            if (trim((string) $heloHost) === "") {
                $heloHost = "localhost";
            }

            $this->smtpEnviarComando($socket, "EHLO " . $heloHost, array(250));

            if ($usarTls) {
                $this->smtpEnviarComando($socket, "STARTTLS", array(220));
                $crypto = @stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT);
                if ($crypto !== true) {
                    throw new Exception("No se pudo habilitar STARTTLS con el servidor SMTP.");
                }
                $this->smtpEnviarComando($socket, "EHLO " . $heloHost, array(250));
            }

            $this->smtpEnviarComando($socket, "AUTH LOGIN", array(334));
            $this->smtpEnviarComando($socket, base64_encode($usuario), array(334));
            $this->smtpEnviarComando($socket, base64_encode($clave), array(235));
            $this->smtpEnviarComando($socket, "MAIL FROM:<" . $correoRemitente . ">", array(250));
            $this->smtpEnviarComando($socket, "RCPT TO:<" . $destinatario . ">", array(250, 251));
            $this->smtpEnviarComando($socket, "DATA", array(354));

            $asuntoCodificado = "=?UTF-8?B?" . base64_encode((string) $asunto) . "?=";
            $remitenteHeader = $correoRemitente;
            if ($nombreRemitente !== "") {
                $remitenteHeader = "=?UTF-8?B?" . base64_encode($nombreRemitente) . "?= <" . $correoRemitente . ">";
            }

            $cuerpoNormalizado = str_replace(array("\r\n", "\r"), "\n", (string) $mensajeHtml);
            $cuerpoNormalizado = str_replace("\n", "\r\n", $cuerpoNormalizado);
            $lineas = explode("\r\n", $cuerpoNormalizado);
            foreach ($lineas as &$linea) {
                if (isset($linea[0]) && $linea[0] === ".") {
                    $linea = "." . $linea;
                }
            }
            unset($linea);
            $cuerpoNormalizado = implode("\r\n", $lineas);

            $headers = array(
                "Date: " . date("r"),
                "From: " . $remitenteHeader,
                "To: <" . $destinatario . ">",
                "Subject: " . $asuntoCodificado,
                "MIME-Version: 1.0"
            );

            $cuerpoMime = "";
            if ($usarAdjunto) {
                $contenidoAdjunto = @file_get_contents($rutaAdjunto);
                if ($contenidoAdjunto === false) {
                    throw new Exception("No se pudo leer el archivo adjunto del reporte.");
                }

                $boundary = "=_Part_" . md5(uniqid((string) mt_rand(), true));
                $headers[] = "Content-Type: multipart/mixed; boundary=\"" . $boundary . "\"";

                $cuerpoMime .= "--" . $boundary . "\r\n";
                $cuerpoMime .= "Content-Type: text/html; charset=UTF-8\r\n";
                $cuerpoMime .= "Content-Transfer-Encoding: 8bit\r\n\r\n";
                $cuerpoMime .= $cuerpoNormalizado . "\r\n";

                $cuerpoMime .= "--" . $boundary . "\r\n";
                $cuerpoMime .= "Content-Type: " . $mimeAdjunto . "; name=\"" . $nombreAdjunto . "\"\r\n";
                $cuerpoMime .= "Content-Transfer-Encoding: base64\r\n";
                $cuerpoMime .= "Content-Disposition: attachment; filename=\"" . $nombreAdjunto . "\"\r\n\r\n";
                $cuerpoMime .= chunk_split(base64_encode($contenidoAdjunto), 76, "\r\n");
                $cuerpoMime .= "\r\n--" . $boundary . "--";
            } else {
                $headers[] = "Content-Type: text/html; charset=UTF-8";
                $headers[] = "Content-Transfer-Encoding: 8bit";
                $cuerpoMime = $cuerpoNormalizado;
            }

            $contenidoData = implode("\r\n", $headers) . "\r\n\r\n" . $cuerpoMime;
            $contenidoData = str_replace(array("\r\n", "\r"), "\n", $contenidoData);
            $contenidoData = str_replace("\n", "\r\n", $contenidoData);
            $lineasData = explode("\r\n", $contenidoData);
            foreach ($lineasData as &$lineaData) {
                if (isset($lineaData[0]) && $lineaData[0] === ".") {
                    $lineaData = "." . $lineaData;
                }
            }
            unset($lineaData);
            $contenidoData = implode("\r\n", $lineasData) . "\r\n.";
            if (@fwrite($socket, $contenidoData . "\r\n") === false) {
                throw new Exception("No se pudo enviar el contenido del correo al servidor SMTP.");
            }

            $this->smtpEnviarComando($socket, null, array(250));
            $this->smtpEnviarComando($socket, "QUIT", array(221, 250));
        } finally {
            fclose($socket);
        }
    }

    private function obtenerBaseUrlSistema()
    {
        $host = isset($_SERVER["HTTP_HOST"]) ? trim((string) $_SERVER["HTTP_HOST"]) : "";
        if ($host === "") {
            return "";
        }

        $esHttps = isset($_SERVER["HTTPS"]) && strtolower((string) $_SERVER["HTTPS"]) !== "off" && (string) $_SERVER["HTTPS"] !== "0";
        $protocolo = $esHttps ? "https" : "http";
        $scriptName = isset($_SERVER["SCRIPT_NAME"]) ? str_replace("\\", "/", (string) $_SERVER["SCRIPT_NAME"]) : "";
        $base = trim((string) dirname(dirname($scriptName)));
        $base = str_replace("\\", "/", $base);
        if ($base === "/" || $base === "\\") {
            $base = "";
        }

        return $protocolo . "://" . $host . rtrim($base, "/");
    }

    private function enviarReporteSolicitudAlChofer($correoChofer, $rutaRelativa, $datosReporte, $tipoReporte)
    {
        $correoChofer = trim((string) $correoChofer);
        if (!$this->esCorreoValido($correoChofer)) {
            return array(
                "ok" => false,
                "estado" => "ERROR",
                "correo_destino" => $correoChofer,
                "detalle" => "El chofer no tiene un correo valido registrado."
            );
        }

        $configSmtp = $this->obtenerConfiguracionSmtpActiva();
        if (!$configSmtp) {
            return array(
                "ok" => false,
                "estado" => "ERROR",
                "correo_destino" => $correoChofer,
                "detalle" => "No hay configuracion SMTP activa para realizar el envio."
            );
        }

        $rutaRelativa = ltrim(str_replace("\\", "/", (string) $rutaRelativa), "/");
        if ($rutaRelativa === "") {
            return array(
                "ok" => false,
                "estado" => "ERROR",
                "correo_destino" => $correoChofer,
                "detalle" => "No se encontro la ruta del reporte para adjuntar."
            );
        }

        $rutaAbsoluta = dirname(__DIR__) . DIRECTORY_SEPARATOR . str_replace("/", DIRECTORY_SEPARATOR, $rutaRelativa);
        if (!is_file($rutaAbsoluta)) {
            return array(
                "ok" => false,
                "estado" => "ERROR",
                "correo_destino" => $correoChofer,
                "detalle" => "No se encontro el archivo del reporte para adjuntar."
            );
        }

        $nombreAdjunto = basename($rutaAbsoluta);
        $baseUrl = $this->obtenerBaseUrlSistema();
        $urlArchivo = $baseUrl !== ""
            ? $baseUrl . "/" . $rutaRelativa
            : $rutaRelativa;
        $idSeguridad = isset($datosReporte["id_seguridad"]) ? (int) $datosReporte["id_seguridad"] : 0;
        $urlVista = $baseUrl !== ""
            ? $baseUrl . "/ajax/serviciosemergencia.php?op=verreporte&id_seguridad=" . $idSeguridad
            : "ajax/serviciosemergencia.php?op=verreporte&id_seguridad=" . $idSeguridad;
        $tipoTexto = strtoupper(trim((string) $tipoReporte)) === "CIERRE" ? "cierre de despacho" : "registro de solicitud";
        $ticket = isset($datosReporte["ticket_interno"]) ? (string) $datosReporte["ticket_interno"] : "Sin ticket";
        $asunto = "Reporte de ambulancia - Ticket " . $ticket;
        $mensaje = "<h3>Reporte de solicitud de ambulancia</h3>"
            . "<p>Se genero el reporte de <strong>" . $this->valorHtml($tipoTexto) . "</strong> para el ticket <strong>" . $this->valorHtml($ticket) . "</strong>.</p>"
            . "<p>El reporte va adjunto en este correo.</p>"
            . "<p><a href='" . $this->valorHtml($urlVista) . "' target='_blank'>Ver reporte con boton de descarga</a></p>"
            . "<p><a href='" . $this->valorHtml($urlArchivo) . "' target='_blank'>Abrir archivo del reporte</a></p>"
            . "<p>Fecha: " . $this->valorHtml(date("d/m/Y h:i A")) . "</p>";

        try {
            $this->enviarCorreoSmtpHtml($configSmtp, $correoChofer, $asunto, $mensaje, array(
                "ruta_absoluta" => $rutaAbsoluta,
                "nombre_archivo" => $nombreAdjunto,
                "mime" => "application/pdf"
            ));
            return array(
                "ok" => true,
                "estado" => "ENVIADO",
                "correo_destino" => $correoChofer,
                "detalle" => "Reporte enviado correctamente al correo del chofer con archivo adjunto.",
                "fecha_envio" => date("Y-m-d H:i:s")
            );
        } catch (Exception $exception) {
            return array(
                "ok" => false,
                "estado" => "ERROR",
                "correo_destino" => $correoChofer,
                "detalle" => "No se pudo enviar el reporte: " . $exception->getMessage()
            );
        }
    }

    private function generarYRegistrarReporteSolicitudAmbulancia($idSeguridad, $idDespachoUnidad, $tipoReporte, $idUsuarioGenera, $solicitaEnvioChofer)
    {
        if (!$this->tieneTablaReportesSolicitudesAmbulancia()) {
            return array("ok" => false, "msg" => "Falta la tabla reportes_solicitudes_ambulancia. Ejecute la migracion correspondiente.");
        }

        $datos = $this->obtenerResumenReporteSolicitud($idSeguridad, $idDespachoUnidad);
        if (!$datos) {
            return array("ok" => false, "msg" => "No se encontraron datos para generar el reporte.");
        }

        $archivo = $this->generarArchivoReporteSolicitudAmbulancia($datos, $tipoReporte);
        if (!$archivo["ok"]) {
            return $archivo;
        }

        $envio = array(
            "ok" => false,
            "estado" => "NO_APLICA",
            "correo_destino" => "",
            "detalle" => "Envio no solicitado."
        );

        if ($solicitaEnvioChofer) {
            $envio = $this->enviarReporteSolicitudAlChofer(
                isset($datos["correo_chofer"]) ? $datos["correo_chofer"] : "",
                $archivo["ruta_relativa"],
                $datos,
                $tipoReporte
            );
        }

        $idReporteSolicitud = $this->registrarReporteSolicitudAmbulancia(
            $idSeguridad,
            $idDespachoUnidad,
            $tipoReporte,
            $archivo["nombre_archivo"],
            $archivo["ruta_relativa"],
            $idUsuarioGenera,
            $envio
        );

        if ($idReporteSolicitud <= 0) {
            return array("ok" => false, "msg" => "No se pudo registrar la metadata del reporte.");
        }

        return array(
            "ok" => true,
            "id_reporte_solicitud" => $idReporteSolicitud,
            "tipo_reporte" => strtoupper(trim((string) $tipoReporte)) === "CIERRE" ? "CIERRE" : "REGISTRO",
            "ruta_reporte" => $archivo["ruta_relativa"],
            "nombre_reporte" => $archivo["nombre_archivo"],
            "envio_reporte" => $envio
        );
    }

    private function obtenerReporteSolicitudRow($idSeguridad, $idReporteSolicitud = 0)
    {
        if (!$this->tieneTablaReportesSolicitudesAmbulancia()) {
            return null;
        }

        $idSeguridad = (int) $idSeguridad;
        $idReporteSolicitud = (int) $idReporteSolicitud;
        $filtroReporte = $idReporteSolicitud > 0
            ? "AND rsa.id_reporte_solicitud = '$idReporteSolicitud'"
            : "";

        $sql = "SELECT rsa.id_reporte_solicitud,
                       rsa.id_seguridad,
                       rsa.id_despacho_unidad,
                       rsa.tipo_reporte,
                       rsa.nombre_archivo,
                       rsa.ruta_archivo,
                       rsa.estado_envio,
                       rsa.correo_destino,
                       rsa.fecha_envio,
                       rsa.fecha_generacion
                FROM reportes_solicitudes_ambulancia AS rsa
                WHERE rsa.estado = 1
                  AND rsa.id_seguridad = '$idSeguridad'
                  $filtroReporte
                ORDER BY CASE WHEN rsa.tipo_reporte = 'CIERRE' THEN 0 ELSE 1 END, rsa.id_reporte_solicitud DESC
                LIMIT 1";
        return ejecutarConsultaSimpleFila($sql);
    }

    public function obtenerReporteSolicitud($idSeguridad, $idReporteSolicitud = 0)
    {
        if (!$this->tieneTablaReportesSolicitudesAmbulancia()) {
            return array("ok" => false, "msg" => "Falta la tabla de reportes de solicitudes de ambulancia.");
        }

        $row = $this->obtenerReporteSolicitudRow($idSeguridad, $idReporteSolicitud);
        if (!$row) {
            return array("ok" => false, "msg" => "No existe un reporte disponible para esta solicitud.");
        }

        $extensionOriginal = strtolower((string) pathinfo(isset($row["nombre_archivo"]) ? $row["nombre_archivo"] : "", PATHINFO_EXTENSION));
        if ($extensionOriginal === "html" || $extensionOriginal === "htm") {
            $rutaRelativaHtml = trim((string) $row["ruta_archivo"]);
            if ($rutaRelativaHtml !== "") {
                $rutaNormalizadaHtml = str_replace(array("/", "\\"), DIRECTORY_SEPARATOR, $rutaRelativaHtml);
                $rutaAbsolutaHtml = dirname(__DIR__) . DIRECTORY_SEPARATOR . $rutaNormalizadaHtml;
                if (is_file($rutaAbsolutaHtml)) {
                    $htmlContenido = @file_get_contents($rutaAbsolutaHtml);
                    if ($htmlContenido !== false) {
                        $nombrePdf = preg_replace('/\.(html|htm)$/i', '.pdf', (string) $row["nombre_archivo"]);
                        $rutaRelativaPdf = preg_replace('/\.(html|htm)$/i', '.pdf', $rutaRelativaHtml);
                        if (!is_string($rutaRelativaPdf) || trim($rutaRelativaPdf) === "") {
                            $rutaRelativaPdf = $rutaRelativaHtml . ".pdf";
                        }

                        $rutaAbsolutaPdf = dirname(__DIR__) . DIRECTORY_SEPARATOR . str_replace(array("/", "\\"), DIRECTORY_SEPARATOR, $rutaRelativaPdf);
                        if (!is_file($rutaAbsolutaPdf)) {
                            $resultadoPdf = $this->renderizarPdfConDompdf($htmlContenido, $rutaAbsolutaPdf);
                            if (!$resultadoPdf["ok"]) {
                                return array("ok" => false, "msg" => $resultadoPdf["msg"]);
                            }
                        }

                        $idReporteActual = (int) $row["id_reporte_solicitud"];
                        $sqlActualizar = "UPDATE reportes_solicitudes_ambulancia
                                          SET nombre_archivo = '" . $this->esc($nombrePdf) . "',
                                              ruta_archivo = '" . $this->esc($rutaRelativaPdf) . "'
                                          WHERE id_reporte_solicitud = '$idReporteActual'
                                          LIMIT 1";
                        ejecutarConsulta($sqlActualizar);

                        $row["nombre_archivo"] = $nombrePdf;
                        $row["ruta_archivo"] = $rutaRelativaPdf;
                        @unlink($rutaAbsolutaHtml);
                    }
                }
            }
        }

        $rutaRelativa = trim((string) $row["ruta_archivo"]);
        if ($rutaRelativa === "") {
            return array("ok" => false, "msg" => "El reporte no tiene una ruta de archivo valida.");
        }

        $rutaNormalizada = str_replace(array("/", "\\"), DIRECTORY_SEPARATOR, $rutaRelativa);
        $rutaAbsoluta = dirname(__DIR__) . DIRECTORY_SEPARATOR . $rutaNormalizada;
        if (!is_file($rutaAbsoluta)) {
            return array("ok" => false, "msg" => "El archivo del reporte no se encuentra disponible.");
        }

        return array(
            "ok" => true,
            "msg" => "Reporte cargado correctamente.",
            "item" => array(
                "id_reporte_solicitud" => (int) $row["id_reporte_solicitud"],
                "id_seguridad" => (int) $row["id_seguridad"],
                "tipo_reporte" => (string) $row["tipo_reporte"],
                "nombre_archivo" => (string) $row["nombre_archivo"],
                "ruta_relativa" => $rutaRelativa,
                "ruta_absoluta" => $rutaAbsoluta,
                "estado_envio" => isset($row["estado_envio"]) ? (string) $row["estado_envio"] : "NO_APLICA",
                "correo_destino" => isset($row["correo_destino"]) ? (string) $row["correo_destino"] : "",
                "fecha_envio" => isset($row["fecha_envio"]) ? (string) $row["fecha_envio"] : "",
                "fecha_generacion" => isset($row["fecha_generacion"]) ? (string) $row["fecha_generacion"] : ""
            )
        );
    }

    public function reenviarReporteSolicitudChofer($idSeguridad, $idReporteSolicitud = 0)
    {
        if (!$this->tieneTablaReportesSolicitudesAmbulancia()) {
            return array("ok" => false, "msg" => "Falta la tabla de reportes de solicitudes de ambulancia.");
        }

        $idSeguridad = (int) $idSeguridad;
        $idReporteSolicitud = (int) $idReporteSolicitud;
        $row = $this->obtenerReporteSolicitudRow($idSeguridad, $idReporteSolicitud);
        if (!$row) {
            return array("ok" => false, "msg" => "No existe un reporte registrado para esta solicitud.");
        }

        $idReporteSolicitud = (int) $row["id_reporte_solicitud"];
        $idDespachoUnidad = isset($row["id_despacho_unidad"]) ? (int) $row["id_despacho_unidad"] : 0;
        $tipoReporte = isset($row["tipo_reporte"]) ? (string) $row["tipo_reporte"] : "REGISTRO";
        $rutaRelativa = isset($row["ruta_archivo"]) ? (string) $row["ruta_archivo"] : "";

        $datos = $this->obtenerResumenReporteSolicitud($idSeguridad, $idDespachoUnidad);
        if (!$datos) {
            return array("ok" => false, "msg" => "No se encontraron datos de la solicitud para enviar el reporte.");
        }

        $envio = $this->enviarReporteSolicitudAlChofer(
            isset($datos["correo_chofer"]) ? $datos["correo_chofer"] : "",
            $rutaRelativa,
            $datos,
            $tipoReporte
        );

        $estadoEnvio = isset($envio["estado"]) ? strtoupper(trim((string) $envio["estado"])) : ($envio["ok"] ? "ENVIADO" : "ERROR");
        if (!in_array($estadoEnvio, array("NO_APLICA", "PENDIENTE", "ENVIADO", "ERROR"), true)) {
            $estadoEnvio = $envio["ok"] ? "ENVIADO" : "ERROR";
        }

        $correoDestino = isset($envio["correo_destino"]) ? trim((string) $envio["correo_destino"]) : "";
        $detalleEnvio = isset($envio["detalle"]) ? trim((string) $envio["detalle"]) : "";
        $fechaEnvio = isset($envio["fecha_envio"]) ? trim((string) $envio["fecha_envio"]) : "";

        $sql = "UPDATE reportes_solicitudes_ambulancia
                SET estado_envio = '" . $this->esc($estadoEnvio) . "',
                    correo_destino = " . ($correoDestino !== "" ? "'" . $this->esc($correoDestino) . "'" : "NULL") . ",
                    fecha_envio = " . ($fechaEnvio !== "" ? "'" . $this->esc($fechaEnvio) . "'" : "NULL") . ",
                    detalle_envio = " . ($detalleEnvio !== "" ? "'" . $this->esc($detalleEnvio) . "'" : "NULL") . "
                WHERE id_reporte_solicitud = '$idReporteSolicitud'
                LIMIT 1";
        ejecutarConsulta($sql);

        return array(
            "ok" => $envio["ok"] ? true : false,
            "msg" => $envio["ok"]
                ? "Reporte enviado correctamente al correo del chofer."
                : ($detalleEnvio !== "" ? $detalleEnvio : "No se pudo enviar el reporte al chofer."),
            "id_reporte_solicitud" => $idReporteSolicitud,
            "envio_reporte" => $envio
        );
    }

    private function guardarSolicitudBase($idSeguridad, $idBeneficiario, $idUsuario, $tipo, $solicitud, $fechaSeguridad, $descripcion, $ubicacionEvento, $referenciaEvento)
    {
        $idSeguridad = (int) $idSeguridad;
        $idBeneficiario = (int) $idBeneficiario;
        $idUsuario = (int) $idUsuario;
        $fechaSeguridad = $this->esc($fechaSeguridad);
        $descripcion = $this->esc($descripcion);
        $ubicacionEvento = $this->esc($ubicacionEvento);
        $referenciaEvento = $this->esc($referenciaEvento);
        $nombreTipo = $this->esc($tipo["nombre_tipo"]);
        $nombreSolicitud = $this->esc($solicitud["nombre_solicitud"]);
        $idTipoSeguridad = (int) $tipo["id_tipo_seguridad"];
        $idSolicitudSeguridad = (int) $solicitud["id_solicitud_seguridad"];

        if ($idSeguridad > 0) {
            $sql = "UPDATE seguridad
                    SET id_beneficiario = '$idBeneficiario',
                        id_usuario = '$idUsuario',
                        id_tipo_seguridad = '$idTipoSeguridad',
                        id_solicitud_seguridad = '$idSolicitudSeguridad',
                        tipo_seguridad = '$nombreTipo',
                        tipo_solicitud = '$nombreSolicitud',
                        fecha_seguridad = '$fechaSeguridad',
                        descripcion = '$descripcion',
                        ubicacion_evento = '$ubicacionEvento',
                        referencia_evento = '$referenciaEvento'
                    WHERE id_seguridad = '$idSeguridad'";

            return ejecutarConsulta($sql) ? $idSeguridad : 0;
        }

        $sql = "INSERT INTO seguridad (
                    ticket_interno,
                    id_beneficiario,
                    id_usuario,
                    id_tipo_seguridad,
                    id_solicitud_seguridad,
                    id_estado_solicitud,
                    tipo_seguridad,
                    tipo_solicitud,
                    fecha_seguridad,
                    descripcion,
                    estado_atencion,
                    ubicacion_evento,
                    referencia_evento,
                    estado
                ) VALUES (
                    '',
                    '$idBeneficiario',
                    '$idUsuario',
                    '$idTipoSeguridad',
                    '$idSolicitudSeguridad',
                    (SELECT id_estado_solicitud FROM estados_solicitudes WHERE codigo_estado = 'REGISTRADA' AND estado = 1 LIMIT 1),
                    '$nombreTipo',
                    '$nombreSolicitud',
                    '$fechaSeguridad',
                    '$descripcion',
                    'REGISTRADO',
                    '$ubicacionEvento',
                    '$referenciaEvento',
                    1
                )";

        return ejecutarConsulta_retornarID($sql);
    }

    private function actualizarTicketSiHaceFalta($idSeguridad)
    {
        $registro = $this->obtenerSeguridadPorId($idSeguridad, false);
        if (!$registro) {
            return false;
        }

        $ticket = trim((string) $registro["ticket_interno"]);
        if ($ticket !== "") {
            return $ticket;
        }

        $ticket = $this->generarTicketInterno($idSeguridad, $registro["fecha_seguridad"]);
        $ticketEscapado = $this->esc($ticket);
        $idSeguridad = (int) $idSeguridad;

        ejecutarConsulta("UPDATE seguridad SET ticket_interno = '$ticketEscapado' WHERE id_seguridad = '$idSeguridad'");
        return $ticket;
    }

    public function guardarSolicitud($idSeguridad, $idBeneficiario, $idUsuario, $idTipoSeguridad, $idSolicitudSeguridad, $fechaSeguridad, $descripcion, $ubicacionEvento, $referenciaEvento, $idAsignacionPreferida = 0, $enviarReporteChofer = 0)
    {
        $conexion = $this->db();
        $idSeguridad = (int) $idSeguridad;
        $idBeneficiario = (int) $idBeneficiario;
        $idUsuario = (int) $idUsuario;
        $idTipoSeguridad = (int) $idTipoSeguridad;
        $idSolicitudSeguridad = (int) $idSolicitudSeguridad;
        $idAsignacionPreferida = (int) $idAsignacionPreferida;
        $enviarReporteChofer = (int) $enviarReporteChofer === 1;

        $tipo = $this->obtenerTipoSeguridad($idTipoSeguridad);
        if (!$tipo || (int) $tipo["estado"] !== 1) {
            return array("ok" => false, "msg" => "Debe seleccionar un tipo de ayuda valido.");
        }

        $solicitud = $this->obtenerSolicitudSeguridad($idSolicitudSeguridad);
        if (!$solicitud || (int) $solicitud["estado"] !== 1) {
            return array("ok" => false, "msg" => "Debe seleccionar un tipo de solicitud valido.");
        }

        $requiereAmbulancia = (int) $tipo["requiere_ambulancia"] === 1;
        $conexion->begin_transaction();

        try {
            $registroAnterior = null;
            if ($idSeguridad > 0) {
                $registroAnterior = $this->obtenerSeguridadPorId($idSeguridad, true);
                if (!$registroAnterior) {
                    throw new Exception("No se encontro la solicitud a editar.");
                }
            }

            $idGuardado = $this->guardarSolicitudBase(
                $idSeguridad,
                $idBeneficiario,
                $idUsuario,
                $tipo,
                $solicitud,
                $fechaSeguridad,
                $descripcion,
                $ubicacionEvento,
                $referenciaEvento
            );

            if ((int) $idGuardado <= 0) {
                throw new Exception("No se pudo guardar la solicitud.");
            }

            $ticket = $this->actualizarTicketSiHaceFalta($idGuardado);
            if (!$ticket) {
                throw new Exception("No se pudo generar el ticket interno.");
            }

            $despachoActivo = $this->obtenerDespachoActivoFila($idGuardado, true);
            if ($despachoActivo && !$requiereAmbulancia) {
                throw new Exception("No puede cambiar a un tipo sin ambulancia mientras exista un despacho activo.");
            }

            $estadoFinal = "REGISTRADO";
            $asignacion = null;
            $unidad = null;
            $chofer = null;
            $autoAsignado = false;
            $pendienteAsignacionManual = false;
            $idDespachoReporte = 0;
            $resultadoReporte = null;

            if ($despachoActivo) {
                $estadoFinal = "DESPACHADO";
                $sqlDespacho = "SELECT du.id_despacho_unidad,
                                       u.id_unidad,
                                       u.codigo_unidad,
                                       u.descripcion AS descripcion_unidad,
                                       u.placa,
                                       u.ubicacion_actual,
                                       u.referencia_actual,
                                       u.prioridad_despacho,
                                       ca.id_chofer_ambulancia,
                                       ca.numero_licencia,
                                       ca.categoria_licencia,
                                       ca.vencimiento_licencia,
                                       e.id_empleado,
                                       e.cedula AS cedula_chofer,
                                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer,
                                       e.telefono AS telefono_chofer,
                                       e.correo AS correo_chofer
                                FROM despachos_unidades AS du
                                INNER JOIN unidades AS u
                                    ON u.id_unidad = du.id_unidad
                                INNER JOIN choferes_ambulancia AS ca
                                    ON ca.id_chofer_ambulancia = du.id_chofer_ambulancia
                                INNER JOIN empleados AS e
                                    ON e.id_empleado = ca.id_empleado
                                WHERE du.id_despacho_unidad = '" . (int) $despachoActivo["id_despacho_unidad"] . "'
                                LIMIT 1";
                $asignacionActual = ejecutarConsultaSimpleFila($sqlDespacho);
                $unidad = $this->formatearResultadoAsignacion($asignacionActual);
                $chofer = $this->formatearResultadoChofer($asignacionActual);
                $idDespachoReporte = (int) $despachoActivo["id_despacho_unidad"];
            } elseif ($requiereAmbulancia) {
                $asignacion = null;

                if ($idAsignacionPreferida > 0) {
                    $asignacion = $this->buscarAsignacionDisponiblePorId($idAsignacionPreferida, true);
                }

                if (!$asignacion) {
                    $asignacion = $this->buscarAsignacionDisponible(true);
                }

                if ($asignacion) {
                    if (!$this->actualizarUnidadComoEnServicio($asignacion["id_unidad"])) {
                        throw new Exception("La ambulancia sugerida dejo de estar disponible. Intente nuevamente.");
                    }

                    $idDespacho = $this->crearDespacho(
                        $idGuardado,
                        $idUsuario,
                        $asignacion,
                        "AUTO",
                        $ubicacionEvento,
                        "Asignacion automatica al guardar la solicitud."
                    );

                    if ((int) $idDespacho <= 0) {
                        throw new Exception("No se pudo registrar el despacho automatico.");
                    }

                    $estadoFinal = "DESPACHADO";
                    $unidad = $this->formatearResultadoAsignacion($asignacion);
                    $chofer = $this->formatearResultadoChofer($asignacion);
                    $autoAsignado = true;
                    $idDespachoReporte = (int) $idDespacho;
                } else {
                    $estadoFinal = "PENDIENTE_UNIDAD";
                    $pendienteAsignacionManual = true;
                }
            } elseif ($registroAnterior && $registroAnterior["estado_atencion"] === "FINALIZADO") {
                $estadoFinal = "FINALIZADO";
            }

            $estadoAtencionEscapado = $this->esc($estadoFinal);
            $sqlEstado = "UPDATE seguridad
                          SET estado = 1,
                              estado_atencion = '$estadoAtencionEscapado'
                          WHERE id_seguridad = '" . (int) $idGuardado . "'";

            if (!ejecutarConsulta($sqlEstado)) {
                throw new Exception("No se pudo actualizar el estado de la solicitud.");
            }

            $observacionEstado = "Solicitud registrada.";
            if ($estadoFinal === "DESPACHADO") {
                $observacionEstado = "Solicitud en gestion operativa con unidad y chofer asignados.";
            } elseif ($estadoFinal === "PENDIENTE_UNIDAD") {
                $observacionEstado = "Solicitud en gestion, pendiente por asignacion de unidad.";
            } elseif ($estadoFinal === "FINALIZADO") {
                $observacionEstado = "Solicitud atendida y finalizada.";
            }

            if (!$this->sincronizarEstadoSolicitud(
                $idGuardado,
                $this->mapearEstadoAtencionACodigo($estadoFinal),
                $idUsuario,
                $fechaSeguridad,
                $observacionEstado
            )) {
                throw new Exception("No se pudo sincronizar el estado general de la solicitud.");
            }

            if ($requiereAmbulancia) {
                $resultadoReporte = $this->generarYRegistrarReporteSolicitudAmbulancia(
                    $idGuardado,
                    $idDespachoReporte,
                    "REGISTRO",
                    $idUsuario,
                    $enviarReporteChofer
                );
                if (!$resultadoReporte["ok"]) {
                    throw new Exception($resultadoReporte["msg"]);
                }
            }

            $conexion->commit();

            return array(
                "ok" => true,
                "msg" => $idSeguridad > 0
                    ? "Solicitud actualizada correctamente."
                    : "Solicitud registrada correctamente.",
                "id_seguridad" => (int) $idGuardado,
                "ticket_interno" => $ticket,
                "requiere_ambulancia" => $requiereAmbulancia,
                "auto_asignado" => $autoAsignado,
                "pendiente_asignacion_manual" => $pendienteAsignacionManual,
                "estado_atencion" => $estadoFinal,
                "unidad" => $unidad,
                "chofer" => $chofer,
                "id_asignacion_unidad_chofer" => $asignacion ? (int) $asignacion["id_asignacion_unidad_chofer"] : 0,
                "reporte_generado" => $resultadoReporte ? true : false,
                "id_reporte_solicitud" => $resultadoReporte ? (int) $resultadoReporte["id_reporte_solicitud"] : 0,
                "ruta_reporte" => $resultadoReporte ? (string) $resultadoReporte["ruta_reporte"] : "",
                "envio_reporte" => $resultadoReporte ? $resultadoReporte["envio_reporte"] : null
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function anularSolicitud($idSeguridad)
    {
        $conexion = $this->db();
        $idSeguridad = (int) $idSeguridad;
        $conexion->begin_transaction();

        try {
            $registro = $this->obtenerSeguridadPorId($idSeguridad, true);
            if (!$registro) {
                throw new Exception("No se encontro la solicitud.");
            }

            $despachoActivo = $this->obtenerDespachoActivoFila($idSeguridad, true);
            if ($despachoActivo) {
                throw new Exception("No puede anular la solicitud mientras exista un despacho activo.");
            }

            $sql = "UPDATE seguridad
                    SET estado = 0
                    WHERE id_seguridad = '$idSeguridad'";

            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo eliminar la solicitud.");
            }

            $conexion->commit();
            return array("ok" => true, "msg" => "Solicitud eliminada correctamente.");
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function reactivarSolicitud($idSeguridad, $idUsuario)
    {
        $conexion = $this->db();
        $idSeguridad = (int) $idSeguridad;
        $idUsuario = (int) $idUsuario;
        $conexion->begin_transaction();

        try {
            $registro = $this->obtenerSeguridadPorId($idSeguridad, true);
            if (!$registro) {
                throw new Exception("No se encontro la solicitud.");
            }

            $estadoFinal = "REGISTRADO";
            $autoAsignado = false;
            $pendienteAsignacionManual = false;
            $unidad = null;
            $chofer = null;

            if ((int) $registro["requiere_ambulancia"] === 1) {
                $asignacion = $this->buscarAsignacionDisponible(true);
                if ($asignacion) {
                    if (!$this->actualizarUnidadComoEnServicio($asignacion["id_unidad"])) {
                        throw new Exception("La unidad sugerida dejo de estar disponible.");
                    }

                    $idDespacho = $this->crearDespacho(
                        $idSeguridad,
                        $idUsuario,
                        $asignacion,
                        "AUTO",
                        $registro["ubicacion_evento"],
                        "Asignacion automatica al reactivar la solicitud."
                    );

                    if ((int) $idDespacho <= 0) {
                        throw new Exception("No se pudo generar el despacho automatico.");
                    }

                    $estadoFinal = "DESPACHADO";
                    $autoAsignado = true;
                    $unidad = $this->formatearResultadoAsignacion($asignacion);
                    $chofer = $this->formatearResultadoChofer($asignacion);
                } else {
                    $estadoFinal = "PENDIENTE_UNIDAD";
                    $pendienteAsignacionManual = true;
                }
            } elseif ($registro["estado_atencion"] === "FINALIZADO") {
                $estadoFinal = "FINALIZADO";
            }

            $sql = "UPDATE seguridad
                    SET estado = 1,
                        estado_atencion = '" . $this->esc($estadoFinal) . "'
                    WHERE id_seguridad = '$idSeguridad'";

            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo reactivar la solicitud.");
            }

            if (!$this->sincronizarEstadoSolicitud(
                $idSeguridad,
                $this->mapearEstadoAtencionACodigo($estadoFinal),
                $idUsuario,
                date("Y-m-d H:i:s"),
                "Solicitud reactivada para continuar su gestion."
            )) {
                throw new Exception("No se pudo sincronizar el estado general de la solicitud.");
            }

            $ticket = $this->actualizarTicketSiHaceFalta($idSeguridad);
            $conexion->commit();

            return array(
                "ok" => true,
                "msg" => "Solicitud reactivada correctamente.",
                "ticket_interno" => $ticket,
                "estado_atencion" => $estadoFinal,
                "auto_asignado" => $autoAsignado,
                "pendiente_asignacion_manual" => $pendienteAsignacionManual,
                "unidad" => $unidad,
                "chofer" => $chofer
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function finalizarSolicitud($idSeguridad)
    {
        return array(
            "ok" => false,
            "msg" => "Esta accion fue deshabilitada. Gestione el estado desde 'Gestionar estado de solicitud'."
        );
    }

    public function actualizarEstadoSolicitudManual($idSeguridad, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)
    {
        $conexion = $this->db();
        $idSeguridad = (int) $idSeguridad;
        $idEstadoSolicitud = (int) $idEstadoSolicitud;
        $idUsuario = (int) $idUsuario;
        $fechaGestion = trim((string) $fechaGestion);
        $observacion = trim((string) $observacion);
        $conexion->begin_transaction();

        try {
            $registro = $this->obtenerSeguridadPorId($idSeguridad, true);
            if (!$registro || (int) $registro["estado"] !== 1) {
                throw new Exception("La solicitud no esta disponible para actualizarse.");
            }

            $estadoSolicitud = $this->estadoSolicitud->obtener($idEstadoSolicitud);
            if (!$estadoSolicitud) {
                throw new Exception("Debe seleccionar un estado de solicitud valido.");
            }

            $despachoActivo = $this->obtenerDespachoActivoFila($idSeguridad, true);
            $codigoEstado = (string) $estadoSolicitud["codigo_estado"];
            $estadoAtencionNuevo = (string) $registro["estado_atencion"];

            if ($despachoActivo && $codigoEstado !== "EN_GESTION") {
                throw new Exception("La solicitud tiene un despacho activo. Debe cerrarlo antes de cambiar este estado.");
            }

            if ((int) $registro["requiere_ambulancia"] === 1 && ($codigoEstado === "ATENDIDA" || $codigoEstado === "NO_ATENDIDA")) {
                throw new Exception("Las solicitudes con ambulancia se cierran exclusivamente desde Cerrar despacho.");
            }

            if ($codigoEstado === "ATENDIDA" || $codigoEstado === "NO_ATENDIDA") {
                $estadoAtencionNuevo = "FINALIZADO";
            } elseif ($codigoEstado === "EN_GESTION") {
                if ($despachoActivo) {
                    $estadoAtencionNuevo = "DESPACHADO";
                } elseif ((int) $registro["requiere_ambulancia"] === 1) {
                    $estadoAtencionNuevo = "PENDIENTE_UNIDAD";
                } else {
                    $estadoAtencionNuevo = "REGISTRADO";
                }
            } else {
                $estadoAtencionNuevo = "REGISTRADO";
            }

            $sql = "UPDATE seguridad
                    SET id_estado_solicitud = '$idEstadoSolicitud',
                        estado_atencion = '" . $this->esc($estadoAtencionNuevo) . "'
                    WHERE id_seguridad = '$idSeguridad'";
            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo actualizar el estado de la solicitud.");
            }

            if (!$this->registrarSeguimientoEstado($idSeguridad, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)) {
                throw new Exception("No se pudo registrar el seguimiento de la solicitud.");
            }

            $conexion->commit();
            return array(
                "ok" => true,
                "msg" => "Estado de la solicitud actualizado correctamente.",
                "estado_atencion" => $estadoAtencionNuevo,
                "estado_solicitud" => $estadoSolicitud["nombre_estado"],
                "codigo_estado_solicitud" => $estadoSolicitud["codigo_estado"],
                "clase_badge_estado_solicitud" => $estadoSolicitud["clase_badge"],
                "es_atendida" => (int) $estadoSolicitud["es_atendida"]
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function sugerirDespacho($idTipoSeguridad)
    {
        $tipo = $this->obtenerTipoSeguridad($idTipoSeguridad);
        if (!$tipo || (int) $tipo["estado"] !== 1) {
            return array("ok" => false, "msg" => "Tipo de servicio no valido.");
        }

        if ((int) $tipo["requiere_ambulancia"] !== 1) {
            return array(
                "ok" => true,
                "requiere_ambulancia" => false,
                "disponible" => false,
                "total_disponibles" => 0,
                "sugerencias" => array(),
                "unidad" => null,
                "chofer" => null
            );
        }

        $asignaciones = $this->obtenerAsignacionesDisponiblesColeccion();
        $asignacion = count($asignaciones) > 0 ? $asignaciones[0] : null;
        $sugerencias = array();

        foreach ($asignaciones as $item) {
            $sugerencia = $this->formatearSugerenciaOperativa($item);
            if ($sugerencia) {
                $sugerencias[] = $sugerencia;
            }
        }

        return array(
            "ok" => true,
            "requiere_ambulancia" => true,
            "disponible" => $asignacion ? true : false,
            "total_disponibles" => count($sugerencias),
            "sugerencias" => $sugerencias,
            "id_asignacion_unidad_chofer" => $asignacion ? (int) $asignacion["id_asignacion_unidad_chofer"] : 0,
            "unidad" => $this->formatearResultadoAsignacion($asignacion),
            "chofer" => $this->formatearResultadoChofer($asignacion)
        );
    }

    public function asignarManual($idSeguridad, $idAsignacion, $idUsuario, $observaciones = "")
    {
        $conexion = $this->db();
        $idSeguridad = (int) $idSeguridad;
        $idAsignacion = (int) $idAsignacion;
        $idUsuario = (int) $idUsuario;
        $observaciones = trim((string) $observaciones);
        $conexion->begin_transaction();

        try {
            $registro = $this->obtenerSeguridadPorId($idSeguridad, true);
            if (!$registro) {
                throw new Exception("No se encontro la solicitud.");
            }

            if ((int) $registro["estado"] !== 1) {
                throw new Exception("La solicitud esta anulada.");
            }

            if ((int) $registro["requiere_ambulancia"] !== 1) {
                throw new Exception("Esta solicitud no requiere ambulancia.");
            }

            $despachoActivo = $this->obtenerDespachoActivoFila($idSeguridad, true);
            if ($despachoActivo) {
                throw new Exception("La solicitud ya tiene un despacho activo.");
            }

            $asignacion = $this->buscarAsignacionDisponiblePorId($idAsignacion, true);
            if (!$asignacion) {
                throw new Exception("La unidad o el chofer seleccionados ya no estan disponibles.");
            }

            if (!$this->actualizarUnidadComoEnServicio($asignacion["id_unidad"])) {
                throw new Exception("La unidad seleccionada dejo de estar disponible.");
            }

            $idDespacho = $this->crearDespacho(
                $idSeguridad,
                $idUsuario,
                $asignacion,
                "MANUAL",
                $registro["ubicacion_evento"],
                $observaciones !== "" ? $observaciones : "Asignacion manual desde la vista operativa."
            );

            if ((int) $idDespacho <= 0) {
                throw new Exception("No se pudo registrar el despacho manual.");
            }

            $sql = "UPDATE seguridad
                    SET estado = 1,
                        estado_atencion = 'DESPACHADO'
                    WHERE id_seguridad = '$idSeguridad'";

            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo actualizar el estado de la solicitud.");
            }

            if (!$this->sincronizarEstadoSolicitud(
                $idSeguridad,
                "EN_GESTION",
                $idUsuario,
                date("Y-m-d H:i:s"),
                $observaciones !== "" ? $observaciones : "Solicitud en gestion operativa con asignacion manual."
            )) {
                throw new Exception("No se pudo sincronizar el estado general de la solicitud.");
            }

            $ticket = $this->actualizarTicketSiHaceFalta($idSeguridad);
            $conexion->commit();

            return array(
                "ok" => true,
                "msg" => "Despacho asignado correctamente.",
                "ticket_interno" => $ticket,
                "estado_atencion" => "DESPACHADO",
                "unidad" => $this->formatearResultadoAsignacion($asignacion),
                "chofer" => $this->formatearResultadoChofer($asignacion)
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function cerrarDespacho($idSeguridad, $idUsuarioOperador, $fechaHora, $diagnostico, $fotoEvidencia, $kmSalida, $kmLlegada, $estadoUnidadFinal, $ubicacionCierre, $referenciaCierre, $enviarReporteChofer = 0)
    {
        $conexion = $this->db();
        $idSeguridad = (int) $idSeguridad;
        $idUsuarioOperador = (int) $idUsuarioOperador;
        $enviarReporteChofer = (int) $enviarReporteChofer === 1;
        $fechaHora = $this->esc($fechaHora);
        $diagnostico = $this->esc($diagnostico);
        $fotoEvidencia = $this->esc($fotoEvidencia);
        $kmSalida = (int) $kmSalida;
        $kmLlegada = (int) $kmLlegada;
        $estadoUnidadFinal = strtoupper(trim((string) $estadoUnidadFinal));
        $ubicacionCierre = $this->esc($ubicacionCierre);
        $referenciaCierre = $this->esc($referenciaCierre);
        $mensajeResultado = "Despacho cerrado correctamente.";
        $resultadoReporte = null;

        if ($estadoUnidadFinal !== "FUERA_SERVICIO") {
            $estadoUnidadFinal = "DISPONIBLE";
        }

        $conexion->begin_transaction();

        try {
            $registro = $this->obtenerSeguridadPorId($idSeguridad, true);
            if (!$registro) {
                throw new Exception("No se encontro la solicitud.");
            }

            $despachoActivo = $this->obtenerDespachoActivoFila($idSeguridad, true);
            if (!$despachoActivo) {
                throw new Exception("No existe un despacho activo para cerrar.");
            }

            $idUnidad = (int) $despachoActivo["id_unidad"];
            $idChofer = (int) $despachoActivo["id_chofer_ambulancia"];
            $ticket = $this->actualizarTicketSiHaceFalta($idSeguridad);

            $sqlReporte = "INSERT INTO reportes_traslado (
                                id_ayuda,
                                id_seguridad,
                                id_despacho_unidad,
                                id_usuario_operador,
                                id_empleado_chofer,
                                id_unidad,
                                ticket_interno,
                                fecha_hora,
                                diagnostico_paciente,
                                foto_evidencia,
                                km_salida,
                                km_llegada,
                                estado
                           )
                           SELECT
                                NULL,
                                '$idSeguridad',
                                '" . (int) $despachoActivo["id_despacho_unidad"] . "',
                                '$idUsuarioOperador',
                                ca.id_empleado,
                                '$idUnidad',
                                '" . $this->esc($ticket) . "',
                                '$fechaHora',
                                '$diagnostico',
                                '$fotoEvidencia',
                                '$kmSalida',
                                '$kmLlegada',
                                1
                           FROM choferes_ambulancia AS ca
                           WHERE ca.id_chofer_ambulancia = '$idChofer'
                           LIMIT 1";

            $idReporteTraslado = (int) ejecutarConsulta_retornarID($sqlReporte);
            if ($idReporteTraslado <= 0) {
                throw new Exception("No se pudo registrar el reporte del despacho.");
            }

            $observacionesCierre = $this->esc("Cierre de despacho desde seguridad y emergencia.");
            $sqlDespacho = "UPDATE despachos_unidades
                            SET estado_despacho = 'CERRADO',
                                fecha_cierre = '$fechaHora',
                                ubicacion_cierre = '$ubicacionCierre',
                                observaciones = CONCAT(COALESCE(observaciones, ''), CASE WHEN COALESCE(observaciones, '') = '' THEN '' ELSE ' | ' END, '$observacionesCierre')
                            WHERE id_despacho_unidad = '" . (int) $despachoActivo["id_despacho_unidad"] . "'";

            if (!ejecutarConsulta($sqlDespacho)) {
                throw new Exception("No se pudo cerrar el despacho.");
            }

            $sqlUnidad = "UPDATE unidades
                          SET estado_operativo = '" . $this->esc($estadoUnidadFinal) . "',
                              ubicacion_actual = '$ubicacionCierre',
                              referencia_actual = '$referenciaCierre',
                              fecha_actualizacion_operativa = NOW()
                          WHERE id_unidad = '$idUnidad'";

            if (!ejecutarConsulta($sqlUnidad)) {
                throw new Exception("No se pudo actualizar la unidad.");
            }

            if ($estadoUnidadFinal === "FUERA_SERVICIO") {
                $liberacion = $this->liberarAsignacionActivaUnidad($idUnidad, "Unidad marcada fuera de servicio al cerrar el despacho.", true);
                if (!$liberacion["ok"]) {
                    throw new Exception("El despacho se cerro, pero no se pudo liberar el chofer operativo de la unidad.");
                }

                if ($liberacion["liberada"]) {
                    $mensajeResultado = "Despacho cerrado correctamente. La unidad quedo fuera de servicio y el chofer operativo fue liberado.";
                }
            }

            $sqlSolicitud = "UPDATE seguridad
                             SET estado = 1,
                                 estado_atencion = 'FINALIZADO'
                             WHERE id_seguridad = '$idSeguridad'";

            if (!ejecutarConsulta($sqlSolicitud)) {
                throw new Exception("No se pudo actualizar la solicitud.");
            }

            if (!$this->sincronizarEstadoSolicitud(
                $idSeguridad,
                "ATENDIDA",
                $idUsuarioOperador,
                $fechaHora,
                "Solicitud atendida y cerrada desde el reporte de despacho."
            )) {
                throw new Exception("No se pudo sincronizar el estado general de la solicitud.");
            }

            $resultadoReporte = $this->generarYRegistrarReporteSolicitudAmbulancia(
                $idSeguridad,
                (int) $despachoActivo["id_despacho_unidad"],
                "CIERRE",
                $idUsuarioOperador,
                $enviarReporteChofer
            );
            if (!$resultadoReporte["ok"]) {
                throw new Exception($resultadoReporte["msg"]);
            }

            $conexion->commit();
            return array(
                "ok" => true,
                "msg" => $mensajeResultado,
                "estado_atencion" => "FINALIZADO",
                "reporte_generado" => $resultadoReporte ? true : false,
                "id_reporte_solicitud" => $resultadoReporte ? (int) $resultadoReporte["id_reporte_solicitud"] : 0,
                "ruta_reporte" => $resultadoReporte ? (string) $resultadoReporte["ruta_reporte"] : "",
                "envio_reporte" => $resultadoReporte ? $resultadoReporte["envio_reporte"] : null
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function guardarChoferAmbulancia($idEmpleado, $numeroLicencia, $categoriaLicencia, $vencimientoLicencia, $contactoEmergencia, $telefonoContactoEmergencia, $observaciones, $idUnidadAsignada = 0)
    {
        $conexion = $this->db();
        $idEmpleado = (int) $idEmpleado;
        $idUnidadAsignada = (int) $idUnidadAsignada;
        $numeroLicencia = $this->esc($numeroLicencia);
        $categoriaLicencia = $this->esc($categoriaLicencia);
        $vencimientoLicencia = $this->esc($vencimientoLicencia);
        $contactoEmergencia = $this->esc($contactoEmergencia);
        $telefonoContactoEmergencia = $this->esc($telefonoContactoEmergencia);
        $observaciones = $this->esc($observaciones);

        if ($this->licenciaEstaVencida($vencimientoLicencia)) {
            return array("ok" => false, "msg" => "La licencia del chofer ya se encuentra vencida. Debe registrar una fecha de vencimiento vigente.");
        }

        $conexion->begin_transaction();

        try {
            $empleado = ejecutarConsultaSimpleFila("SELECT id_empleado, estado
                                                    FROM empleados
                                                    WHERE id_empleado = '$idEmpleado'
                                                    LIMIT 1
                                                    FOR UPDATE");
            if (!$empleado || (int) $empleado["estado"] !== 1) {
                throw new Exception("Debe seleccionar un empleado activo.");
            }

            $existente = ejecutarConsultaSimpleFila("SELECT id_chofer_ambulancia, estado
                                                     FROM choferes_ambulancia
                                                     WHERE id_empleado = '$idEmpleado'
                                                     LIMIT 1
                                                     FOR UPDATE");

            $mensajeResultado = "Chofer registrado correctamente.";
            $idChoferAmbulancia = 0;

            if ($existente) {
                $idChoferAmbulancia = (int) $existente["id_chofer_ambulancia"];
                $sql = "UPDATE choferes_ambulancia
                        SET numero_licencia = '$numeroLicencia',
                            categoria_licencia = '$categoriaLicencia',
                            vencimiento_licencia = '$vencimientoLicencia',
                            contacto_emergencia = '$contactoEmergencia',
                            telefono_contacto_emergencia = '$telefonoContactoEmergencia',
                            observaciones = '$observaciones',
                            estado = 1
                        WHERE id_chofer_ambulancia = '$idChoferAmbulancia'";

                if (!ejecutarConsulta($sql)) {
                    throw new Exception("No se pudo actualizar el perfil del chofer.");
                }

                if ((int) $existente["estado"] !== 1) {
                    $mensajeResultado = "Chofer reactivado y actualizado correctamente.";
                } else {
                    $mensajeResultado = "Perfil del chofer actualizado correctamente.";
                }
            } else {
                $sql = "INSERT INTO choferes_ambulancia (
                            id_empleado,
                            numero_licencia,
                            categoria_licencia,
                            vencimiento_licencia,
                            contacto_emergencia,
                            telefono_contacto_emergencia,
                            observaciones,
                            estado
                        ) VALUES (
                            '$idEmpleado',
                            '$numeroLicencia',
                            '$categoriaLicencia',
                            '$vencimientoLicencia',
                            '$contactoEmergencia',
                            '$telefonoContactoEmergencia',
                            '$observaciones',
                            1
                        )";

                $idChoferAmbulancia = (int) ejecutarConsulta_retornarID($sql);
                if ($idChoferAmbulancia <= 0) {
                    throw new Exception("No se pudo registrar el chofer.");
                }
            }

            if ($idUnidadAsignada > 0) {
                $resultadoAsignacion = $this->guardarAsignacionOperativaInterna(
                    $idUnidadAsignada,
                    $idChoferAmbulancia,
                    date("Y-m-d H:i:s"),
                    "",
                    "",
                    0,
                    "Asignacion directa desde el formulario de chofer operativo."
                );

                if (!$resultadoAsignacion["ok"]) {
                    throw new Exception($resultadoAsignacion["msg"]);
                }

                if (!empty($resultadoAsignacion["sin_cambios"])) {
                    $mensajeResultado .= " La unidad seleccionada ya estaba vinculada a este chofer.";
                } else {
                    $mensajeResultado .= " Unidad asignada correctamente.";
                }
            }

            $conexion->commit();
            return array(
                "ok" => true,
                "msg" => $mensajeResultado,
                "id_chofer_ambulancia" => $idChoferAmbulancia
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function desactivarChoferAmbulancia($idChoferAmbulancia)
    {
        $conexion = $this->db();
        $idChoferAmbulancia = (int) $idChoferAmbulancia;
        $conexion->begin_transaction();

        try {
            $chofer = ejecutarConsultaSimpleFila("SELECT id_chofer_ambulancia, estado
                                                  FROM choferes_ambulancia
                                                  WHERE id_chofer_ambulancia = '$idChoferAmbulancia'
                                                  LIMIT 1
                                                  FOR UPDATE");
            if (!$chofer || (int) $chofer["estado"] !== 1) {
                throw new Exception("El chofer no esta disponible para desactivarse.");
            }

            $despachoActivo = ejecutarConsultaSimpleFila("SELECT id_despacho_unidad
                                                          FROM despachos_unidades
                                                          WHERE id_chofer_ambulancia = '$idChoferAmbulancia'
                                                            AND estado_despacho = 'ACTIVO'
                                                          LIMIT 1
                                                          FOR UPDATE");
            if ($despachoActivo) {
                throw new Exception("No puede desactivar un chofer con despacho activo.");
            }

            $sqlCerrarAsignaciones = "UPDATE asignaciones_unidades_choferes
                                      SET estado = 0,
                                          fecha_fin = NOW(),
                                          observaciones = CONCAT(COALESCE(observaciones, ''), CASE WHEN COALESCE(observaciones, '') = '' THEN '' ELSE ' | ' END, 'Cierre automatico por desactivacion del chofer.')
                                      WHERE id_chofer_ambulancia = '$idChoferAmbulancia'
                                        AND estado = 1
                                        AND fecha_fin IS NULL";
            if (!ejecutarConsulta($sqlCerrarAsignaciones)) {
                throw new Exception("No se pudo liberar la asignacion del chofer.");
            }

            $sql = "UPDATE choferes_ambulancia
                    SET estado = 0
                    WHERE id_chofer_ambulancia = '$idChoferAmbulancia'";
            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo desactivar el chofer.");
            }

            $conexion->commit();
            return array("ok" => true, "msg" => "Chofer desactivado correctamente.");
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function guardarAsignacionOperativa($idUnidad, $idChoferAmbulancia, $fechaInicio, $ubicacionActual, $referenciaActual, $prioridadDespacho, $estadoOperativo, $observaciones)
    {
        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $resultado = $this->guardarAsignacionOperativaInterna(
                $idUnidad,
                $idChoferAmbulancia,
                $fechaInicio,
                $ubicacionActual,
                $referenciaActual,
                $prioridadDespacho,
                $observaciones
            );

            if (!$resultado["ok"]) {
                throw new Exception($resultado["msg"]);
            }

            $conexion->commit();
            return array("ok" => true, "msg" => $resultado["msg"]);
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function guardarUnidadOperativa($idUnidad, $codigoUnidad, $descripcion, $placa, $estadoOperativo, $ubicacionActual, $referenciaActual, $prioridadDespacho)
    {
        $conexion = $this->db();
        $idUnidad = (int) $idUnidad;
        $codigoUnidad = trim((string) $codigoUnidad);
        $descripcion = trim((string) $descripcion);
        $placa = trim((string) $placa);
        $estadoOperativo = strtoupper(trim((string) $estadoOperativo));
        $ubicacionActual = trim((string) $ubicacionActual);
        $referenciaActual = trim((string) $referenciaActual);
        $prioridadDespacho = (int) $prioridadDespacho;

        if ($estadoOperativo !== "FUERA_SERVICIO") {
            $estadoOperativo = "DISPONIBLE";
        }
        if ($prioridadDespacho <= 0) {
            $prioridadDespacho = 1;
        }

        $codigoUnidadEsc = $this->esc($codigoUnidad);
        $descripcionEsc = $this->esc($descripcion);
        $placaEsc = $this->esc($placa);
        $ubicacionActualEsc = $this->esc($ubicacionActual);
        $referenciaActualEsc = $this->esc($referenciaActual);

        $conexion->begin_transaction();

        try {
            $sqlCodigo = "SELECT id_unidad FROM unidades WHERE codigo_unidad = '$codigoUnidadEsc'";
            $sqlPlaca = "SELECT id_unidad FROM unidades WHERE placa = '$placaEsc'";
            if ($idUnidad > 0) {
                $sqlCodigo .= " AND id_unidad <> '$idUnidad'";
                $sqlPlaca .= " AND id_unidad <> '$idUnidad'";
            }
            $sqlCodigo .= " LIMIT 1";
            $sqlPlaca .= " LIMIT 1";

            if (ejecutarConsultaSimpleFila($sqlCodigo)) {
                throw new Exception("Ya existe otra unidad con ese codigo.");
            }
            if (ejecutarConsultaSimpleFila($sqlPlaca)) {
                throw new Exception("Ya existe otra unidad con esa placa.");
            }

            $mensajeResultado = "Unidad registrada correctamente.";

            if ($idUnidad > 0) {
                $unidad = ejecutarConsultaSimpleFila("SELECT id_unidad, estado
                                                      FROM unidades
                                                      WHERE id_unidad = '$idUnidad'
                                                      LIMIT 1
                                                      FOR UPDATE");
                if (!$unidad || (int) $unidad["estado"] !== 1) {
                    throw new Exception("Debe seleccionar una unidad activa.");
                }

                $despachoActivo = ejecutarConsultaSimpleFila("SELECT id_despacho_unidad
                                                              FROM despachos_unidades
                                                              WHERE id_unidad = '$idUnidad'
                                                                AND estado_despacho = 'ACTIVO'
                                                              LIMIT 1
                                                              FOR UPDATE");
                if ($despachoActivo) {
                    throw new Exception("No puede modificar una unidad con despacho activo.");
                }

                $sqlActualizar = "UPDATE unidades
                                  SET codigo_unidad = '$codigoUnidadEsc',
                                      descripcion = '$descripcionEsc',
                                      placa = '$placaEsc',
                                      estado_operativo = '" . $this->esc($estadoOperativo) . "',
                                      ubicacion_actual = '$ubicacionActualEsc',
                                      referencia_actual = '$referenciaActualEsc',
                                      prioridad_despacho = '$prioridadDespacho',
                                      fecha_actualizacion_operativa = NOW()
                                  WHERE id_unidad = '$idUnidad'";

                if (!ejecutarConsulta($sqlActualizar)) {
                    throw new Exception("No se pudo guardar la unidad.");
                }

                $mensajeResultado = "Unidad actualizada correctamente.";
                if ($estadoOperativo === "FUERA_SERVICIO") {
                    $liberacion = $this->liberarAsignacionActivaUnidad($idUnidad, "Unidad marcada fuera de servicio desde el modulo de unidades.", true);
                    if (!$liberacion["ok"]) {
                        throw new Exception("La unidad quedo fuera de servicio, pero no se pudo liberar el chofer asignado.");
                    }

                    if ($liberacion["liberada"]) {
                        $mensajeResultado .= " El chofer asignado quedo disponible para otra unidad.";
                    }
                }
            } else {
                $sqlInsertar = "INSERT INTO unidades (
                                    codigo_unidad,
                                    descripcion,
                                    placa,
                                    estado,
                                    estado_operativo,
                                    ubicacion_actual,
                                    referencia_actual,
                                    prioridad_despacho,
                                    fecha_actualizacion_operativa
                                ) VALUES (
                                    '$codigoUnidadEsc',
                                    '$descripcionEsc',
                                    '$placaEsc',
                                    1,
                                    '" . $this->esc($estadoOperativo) . "',
                                    '$ubicacionActualEsc',
                                    '$referenciaActualEsc',
                                    '$prioridadDespacho',
                                    NOW()
                                )";

                $idUnidad = (int) ejecutarConsulta_retornarID($sqlInsertar);
                if ($idUnidad <= 0) {
                    throw new Exception("No se pudo registrar la unidad.");
                }
            }

            $conexion->commit();
            return array("ok" => true, "msg" => $mensajeResultado, "id_unidad" => $idUnidad);
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function actualizarUnidadOperativa($idUnidad, $estadoOperativo, $ubicacionActual, $referenciaActual, $prioridadDespacho)
    {
        $conexion = $this->db();
        $idUnidad = (int) $idUnidad;
        $estadoOperativo = strtoupper(trim((string) $estadoOperativo));
        $ubicacionActual = $this->esc($ubicacionActual);
        $referenciaActual = $this->esc($referenciaActual);
        $prioridadDespacho = (int) $prioridadDespacho;
        $mensajeResultado = "Unidad actualizada correctamente.";

        if ($estadoOperativo !== "FUERA_SERVICIO") {
            $estadoOperativo = "DISPONIBLE";
        }

        $conexion->begin_transaction();

        try {
            $unidad = ejecutarConsultaSimpleFila("SELECT id_unidad, estado FROM unidades WHERE id_unidad = '$idUnidad' LIMIT 1 FOR UPDATE");
            if (!$unidad || (int) $unidad["estado"] !== 1) {
                throw new Exception("Debe seleccionar una unidad activa.");
            }

            $despachoActivo = ejecutarConsultaSimpleFila("SELECT id_despacho_unidad
                                                          FROM despachos_unidades
                                                          WHERE id_unidad = '$idUnidad'
                                                            AND estado_despacho = 'ACTIVO'
                                                          LIMIT 1
                                                          FOR UPDATE");
            if ($despachoActivo) {
                throw new Exception("No puede cambiar el estado de una unidad con despacho activo.");
            }

            $sql = "UPDATE unidades
                    SET estado_operativo = '" . $this->esc($estadoOperativo) . "',
                        ubicacion_actual = '$ubicacionActual',
                        referencia_actual = '$referenciaActual',
                        prioridad_despacho = '$prioridadDespacho',
                        fecha_actualizacion_operativa = NOW()
                    WHERE id_unidad = '$idUnidad'";

            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo actualizar la unidad operativa.");
            }

            if ($estadoOperativo === "FUERA_SERVICIO") {
                $liberacion = $this->liberarAsignacionActivaUnidad($idUnidad, "Unidad marcada fuera de servicio desde el control operativo.", true);
                if (!$liberacion["ok"]) {
                    throw new Exception("La unidad paso a fuera de servicio, pero no se pudo liberar el chofer asignado.");
                }

                if ($liberacion["liberada"]) {
                    $mensajeResultado = "Unidad actualizada correctamente. El chofer asignado quedo disponible para otra unidad.";
                }
            }

            $conexion->commit();
            return array("ok" => true, "msg" => $mensajeResultado);
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function mostrar($idSeguridad)
    {
        $idSeguridad = (int) $idSeguridad;
        $selectReporte = "";
        $joinReporte = "";
        if ($this->tieneTablaReportesSolicitudesAmbulancia()) {
            $selectReporte = ",
                       COALESCE(rsa.id_reporte_solicitud, 0) AS id_reporte_solicitud,
                       COALESCE(rsa.tipo_reporte, '') AS tipo_reporte_solicitud,
                       COALESCE(rsa.ruta_archivo, '') AS ruta_reporte_solicitud,
                       COALESCE(rsa.estado_envio, 'NO_APLICA') AS estado_envio_reporte,
                       COALESCE(rsa.detalle_envio, '') AS detalle_envio_reporte,
                       COALESCE(rsa.correo_destino, '') AS correo_destino_reporte,
                       COALESCE(DATE_FORMAT(rsa.fecha_envio, '%Y-%m-%d %H:%i:%s'), '') AS fecha_envio_reporte";
            $joinReporte = "
                LEFT JOIN " . $this->ultimoReporteSolicitudSubquery() . " AS rsa
                    ON rsa.id_seguridad = s.id_seguridad";
        }

        $sql = "SELECT s.id_seguridad,
                       s.ticket_interno,
                       s.id_beneficiario,
                       s.id_usuario,
                       s.id_tipo_seguridad,
                       s.id_solicitud_seguridad,
                       s.id_estado_solicitud,
                       COALESCE(tas.nombre_tipo_ayuda, s.tipo_seguridad) AS tipo_seguridad,
                       COALESCE(sg.nombre_solicitud, s.tipo_solicitud) AS tipo_solicitud,
                       COALESCE(es.nombre_estado, 'Registrada') AS estado_solicitud,
                       COALESCE(es.codigo_estado, 'REGISTRADA') AS codigo_estado_solicitud,
                       COALESCE(es.clase_badge, 'draft') AS clase_badge_estado_solicitud,
                       COALESCE(es.es_atendida, 0) AS es_atendida,
                       COALESCE(tas.requiere_ambulancia, 0) AS requiere_ambulancia,
                       s.fecha_seguridad,
                       DATE_FORMAT(s.fecha_seguridad, '%Y-%m-%dT%H:%i') AS fecha_seguridad_input,
                       DATE_FORMAT(s.fecha_seguridad, '%d/%m/%Y %h:%i %p') AS fecha_seguridad_formateada,
                       s.descripcion,
                       s.estado,
                       s.estado_atencion,
                       s.ubicacion_evento,
                       s.referencia_evento,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono,
                       CONCAT(b.nacionalidad, '-', b.cedula, ' ', b.nombre_beneficiario) AS beneficiario,
                       du.id_despacho_unidad,
                       du.estado_despacho,
                       du.fecha_asignacion,
                       u.id_unidad,
                       u.codigo_unidad,
                       u.descripcion AS descripcion_unidad,
                       u.placa,
                       u.ubicacion_actual,
                       u.referencia_actual,
                       ca.id_chofer_ambulancia,
                       ca.numero_licencia,
                       ca.categoria_licencia,
                       ca.vencimiento_licencia,
                       e.id_empleado,
                       e.cedula AS cedula_chofer,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer,
                       e.telefono AS telefono_chofer,
                       e.correo AS correo_chofer
                       $selectReporte
                FROM seguridad AS s
                LEFT JOIN tipos_ayuda_social AS tas
                    ON tas.id_tipo_ayuda_social = s.id_tipo_seguridad
                LEFT JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = s.id_solicitud_seguridad
                LEFT JOIN estados_solicitudes AS es
                    ON es.id_estado_solicitud = s.id_estado_solicitud
                LEFT JOIN beneficiarios AS b
                    ON b.id_beneficiario = s.id_beneficiario
                LEFT JOIN " . $this->ultimoDespachoSubquery() . " AS du
                    ON du.id_seguridad = s.id_seguridad
                LEFT JOIN unidades AS u
                    ON u.id_unidad = du.id_unidad
                LEFT JOIN choferes_ambulancia AS ca
                    ON ca.id_chofer_ambulancia = du.id_chofer_ambulancia
                LEFT JOIN empleados AS e
                    ON e.id_empleado = ca.id_empleado
                $joinReporte
                WHERE s.id_seguridad = '$idSeguridad'
                LIMIT 1";

        $registro = ejecutarConsultaSimpleFila($sql);
        if ($registro) {
            $ultimoSeguimiento = $this->obtenerUltimoSeguimientoEstado($idSeguridad);
            if ($ultimoSeguimiento) {
                $registro["fecha_estado_solicitud"] = $ultimoSeguimiento["fecha_gestion_formateada"];
                $registro["fecha_estado_solicitud_input"] = $ultimoSeguimiento["fecha_gestion_input"];
                $registro["observacion_estado_solicitud"] = $ultimoSeguimiento["observacion"];
            } else {
                $registro["fecha_estado_solicitud"] = "";
                $registro["fecha_estado_solicitud_input"] = "";
                $registro["observacion_estado_solicitud"] = "";
            }
        }

        return $registro;
    }

    public function listar()
    {
        $selectReporte = "";
        $joinReporte = "";
        if ($this->tieneTablaReportesSolicitudesAmbulancia()) {
            $selectReporte = ",
                       COALESCE(rsa.id_reporte_solicitud, 0) AS id_reporte_solicitud,
                       COALESCE(rsa.tipo_reporte, '') AS tipo_reporte_solicitud,
                       COALESCE(rsa.ruta_archivo, '') AS ruta_reporte_solicitud,
                       COALESCE(rsa.estado_envio, 'NO_APLICA') AS estado_envio_reporte,
                       COALESCE(rsa.detalle_envio, '') AS detalle_envio_reporte,
                       COALESCE(rsa.correo_destino, '') AS correo_destino_reporte,
                       COALESCE(DATE_FORMAT(rsa.fecha_envio, '%Y-%m-%d %H:%i:%s'), '') AS fecha_envio_reporte";
            $joinReporte = "
                LEFT JOIN " . $this->ultimoReporteSolicitudSubquery() . " AS rsa
                    ON rsa.id_seguridad = s.id_seguridad";
        }

        $sql = "SELECT s.id_seguridad,
                       s.ticket_interno,
                       s.id_beneficiario,
                       s.estado,
                       s.estado_atencion,
                       s.id_estado_solicitud,
                       COALESCE(tas.nombre_tipo_ayuda, s.tipo_seguridad) AS tipo_seguridad,
                       COALESCE(tas.requiere_ambulancia, 0) AS requiere_ambulancia,
                       COALESCE(sg.nombre_solicitud, s.tipo_solicitud) AS tipo_solicitud,
                       COALESCE(es.nombre_estado, 'Registrada') AS estado_solicitud,
                       COALESCE(es.codigo_estado, 'REGISTRADA') AS codigo_estado_solicitud,
                       COALESCE(es.clase_badge, 'draft') AS clase_badge_estado_solicitud,
                       COALESCE(es.es_atendida, 0) AS es_atendida,
                       s.fecha_seguridad,
                       DATE_FORMAT(s.fecha_seguridad, '%d/%m/%Y %h:%i %p') AS fecha_seguridad_formateada,
                       s.descripcion,
                       s.ubicacion_evento,
                       s.referencia_evento,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono,
                       du.id_despacho_unidad,
                       du.estado_despacho,
                       du.modo_asignacion,
                       du.fecha_asignacion,
                       u.codigo_unidad,
                       u.descripcion AS descripcion_unidad,
                       u.placa,
                       u.ubicacion_actual,
                       u.referencia_actual,
                       ca.numero_licencia,
                       e.cedula AS cedula_chofer,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer
                       $selectReporte
                FROM seguridad AS s
                LEFT JOIN tipos_ayuda_social AS tas
                    ON tas.id_tipo_ayuda_social = s.id_tipo_seguridad
                LEFT JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = s.id_solicitud_seguridad
                LEFT JOIN estados_solicitudes AS es
                    ON es.id_estado_solicitud = s.id_estado_solicitud
                LEFT JOIN beneficiarios AS b
                    ON b.id_beneficiario = s.id_beneficiario
                LEFT JOIN " . $this->ultimoDespachoSubquery() . " AS du
                    ON du.id_seguridad = s.id_seguridad
                LEFT JOIN unidades AS u
                    ON u.id_unidad = du.id_unidad
                LEFT JOIN choferes_ambulancia AS ca
                    ON ca.id_chofer_ambulancia = du.id_chofer_ambulancia
                LEFT JOIN empleados AS e
                    ON e.id_empleado = ca.id_empleado
                $joinReporte
                WHERE s.estado = 1
                ORDER BY s.id_seguridad DESC";

        return ejecutarConsulta($sql);
    }

    public function resumen()
    {
        $sql = "SELECT COUNT(*) AS total,
                       SUM(CASE WHEN s.estado_atencion = 'PENDIENTE_UNIDAD' THEN 1 ELSE 0 END) AS pendientes_unidad,
                       SUM(CASE WHEN s.estado_atencion = 'DESPACHADO' THEN 1 ELSE 0 END) AS despachados,
                       SUM(CASE WHEN s.estado_atencion = 'FINALIZADO' THEN 1 ELSE 0 END) AS finalizadas,
                       SUM(CASE WHEN s.estado_atencion = 'REGISTRADO' THEN 1 ELSE 0 END) AS registrados,
                       (SELECT COUNT(*)
                        FROM unidades
                        WHERE estado = 1
                          AND estado_operativo = 'DISPONIBLE') AS unidades_disponibles
                FROM seguridad AS s
                WHERE s.estado = 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    public function listarBeneficiarios($termino = "")
    {
        $termino = trim((string) $termino);
        $filtro = "";
        if ($termino !== "") {
            $terminoEscapado = $this->esc($termino);
            $filtro = "AND (
                b.nacionalidad LIKE '%$terminoEscapado%'
                OR b.cedula LIKE '%$terminoEscapado%'
                OR b.nombre_beneficiario LIKE '%$terminoEscapado%'
                OR CONCAT(b.nacionalidad, '-', b.cedula, ' ', b.nombre_beneficiario) LIKE '%$terminoEscapado%'
            )";
        }

        $sql = "SELECT b.id_beneficiario,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono
                FROM beneficiarios AS b
                WHERE b.estado = 1
                $filtro
                ORDER BY b.nombre_beneficiario ASC
                LIMIT 150";

        return ejecutarConsulta($sql);
    }

    public function listarTiposSeguridad()
    {
        $sql = "SELECT id_tipo_ayuda_social AS id_tipo_seguridad,
                       nombre_tipo_ayuda AS nombre_tipo,
                       COALESCE(requiere_ambulancia, 0) AS requiere_ambulancia
                FROM tipos_ayuda_social
                WHERE estado = 1
                ORDER BY nombre_tipo_ayuda ASC";

        return ejecutarConsulta($sql);
    }

    public function listarSolicitudesSeguridad()
    {
        $sql = "SELECT id_solicitud_general AS id_solicitud_seguridad,
                       nombre_solicitud
                FROM solicitudes_generales
                WHERE estado = 1
                ORDER BY nombre_solicitud ASC";

        return ejecutarConsulta($sql);
    }

    public function listarEmpleadosOperativos($termino = "")
    {
        $termino = trim((string) $termino);
        $filtro = "";
        if ($termino !== "") {
            $terminoEscapado = $this->esc($termino);
            $filtro = "AND (
                e.cedula LIKE '%$terminoEscapado%'
                OR e.nombre LIKE '%$terminoEscapado%'
                OR e.apellido LIKE '%$terminoEscapado%'
                OR CONCAT(e.nombre, ' ', e.apellido) LIKE '%$terminoEscapado%'
            )";
        }

        $sql = "SELECT e.id_empleado,
                       e.cedula,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo,
                       d.nombre_dependencia,
                       ca.id_chofer_ambulancia,
                       ca.estado AS estado_chofer,
                       ca.numero_licencia,
                       ca.categoria_licencia,
                       ca.vencimiento_licencia,
                       ca.contacto_emergencia,
                       ca.telefono_contacto_emergencia,
                       ca.observaciones
                FROM empleados AS e
                LEFT JOIN dependencias AS d
                    ON d.id_dependencia = e.id_dependencia
                LEFT JOIN choferes_ambulancia AS ca
                    ON ca.id_empleado = e.id_empleado
                WHERE e.estado = 1
                $filtro
                ORDER BY e.nombre ASC, e.apellido ASC
                LIMIT 200";

        return ejecutarConsulta($sql);
    }

    public function listarChoferesAmbulancia($soloDisponibles = false)
    {
        $filtroDisponibles = $soloDisponibles ? "AND au.id_asignacion_unidad_chofer IS NULL" : "";
        $sql = "SELECT ca.id_chofer_ambulancia,
                       ca.id_empleado,
                       ca.numero_licencia,
                       ca.categoria_licencia,
                       ca.vencimiento_licencia,
                       ca.contacto_emergencia,
                       ca.telefono_contacto_emergencia,
                       ca.observaciones,
                       ca.estado,
                       e.cedula,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer,
                       au.id_asignacion_unidad_chofer,
                       u.id_unidad,
                       u.codigo_unidad,
                       u.placa,
                       u.estado_operativo AS estado_unidad,
                       ds.id_despacho_unidad,
                       ds.estado_despacho,
                       s.ticket_interno
                FROM choferes_ambulancia AS ca
                INNER JOIN empleados AS e
                    ON e.id_empleado = ca.id_empleado
                LEFT JOIN " . $this->asignacionActivaChoferSubquery() . " AS au
                    ON au.id_chofer_ambulancia = ca.id_chofer_ambulancia
                LEFT JOIN unidades AS u
                    ON u.id_unidad = au.id_unidad
                LEFT JOIN despachos_unidades AS ds
                    ON ds.id_unidad = u.id_unidad
                   AND ds.estado_despacho = 'ACTIVO'
                LEFT JOIN seguridad AS s
                    ON s.id_seguridad = ds.id_seguridad
                WHERE e.estado = 1
                  AND ca.estado = 1
                  $filtroDisponibles
                ORDER BY e.nombre ASC, e.apellido ASC";

        return ejecutarConsulta($sql);
    }

    public function listarUnidades()
    {
        $sql = "SELECT id_unidad,
                       codigo_unidad,
                       descripcion,
                       placa,
                       estado_operativo,
                       ubicacion_actual,
                       referencia_actual,
                       prioridad_despacho
                FROM unidades
                WHERE estado = 1
                ORDER BY prioridad_despacho ASC, codigo_unidad ASC";

        return ejecutarConsulta($sql);
    }

    public function listarAsignacionesDisponibles()
    {
        $sql = "SELECT au.id_asignacion_unidad_chofer,
                       u.id_unidad,
                       u.codigo_unidad,
                       u.descripcion AS descripcion_unidad,
                       u.placa,
                       u.ubicacion_actual,
                       u.referencia_actual,
                       u.prioridad_despacho,
                       ca.id_chofer_ambulancia,
                       ca.numero_licencia,
                       ca.categoria_licencia,
                       ca.vencimiento_licencia,
                       e.id_empleado,
                       e.cedula AS cedula_chofer,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer,
                       e.telefono AS telefono_chofer
                FROM asignaciones_unidades_choferes AS au
                INNER JOIN unidades AS u
                    ON u.id_unidad = au.id_unidad
                INNER JOIN choferes_ambulancia AS ca
                    ON ca.id_chofer_ambulancia = au.id_chofer_ambulancia
                INNER JOIN empleados AS e
                    ON e.id_empleado = ca.id_empleado
                WHERE au.estado = 1
                  AND au.fecha_fin IS NULL
                  AND u.estado = 1
                  AND u.estado_operativo = 'DISPONIBLE'
                  AND ca.estado = 1
                  AND ca.vencimiento_licencia >= CURDATE()
                  AND e.estado = 1
                ORDER BY u.prioridad_despacho ASC, u.id_unidad ASC";

        return ejecutarConsulta($sql);
    }

    public function listarOperativoUnidades()
    {
        $sql = "SELECT u.id_unidad,
                       u.codigo_unidad,
                       u.descripcion,
                       u.placa,
                       u.estado_operativo,
                       u.ubicacion_actual,
                       u.referencia_actual,
                       u.prioridad_despacho,
                       au.id_asignacion_unidad_chofer,
                       ca.id_chofer_ambulancia,
                       ca.numero_licencia,
                       ca.categoria_licencia,
                       ca.vencimiento_licencia,
                       e.id_empleado,
                       e.cedula AS cedula_chofer,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer,
                       e.telefono AS telefono_chofer,
                       ds.id_despacho_unidad,
                       ds.estado_despacho,
                       ds.fecha_asignacion,
                       s.ticket_interno
                FROM unidades AS u
                LEFT JOIN " . $this->asignacionActivaSubquery() . " AS au
                    ON au.id_unidad = u.id_unidad
                LEFT JOIN choferes_ambulancia AS ca
                    ON ca.id_chofer_ambulancia = au.id_chofer_ambulancia
                LEFT JOIN empleados AS e
                    ON e.id_empleado = ca.id_empleado
                LEFT JOIN despachos_unidades AS ds
                    ON ds.id_unidad = u.id_unidad
                   AND ds.estado_despacho = 'ACTIVO'
                LEFT JOIN seguridad AS s
                    ON s.id_seguridad = ds.id_seguridad
                WHERE u.estado = 1
                ORDER BY u.prioridad_despacho ASC, u.id_unidad ASC";

        return ejecutarConsulta($sql);
    }

    public function obtenerDespachoActivo($idSeguridad)
    {
        $idSeguridad = (int) $idSeguridad;
        $sql = "SELECT du.id_despacho_unidad,
                       du.id_seguridad,
                       du.id_unidad,
                       du.id_chofer_ambulancia,
                       du.modo_asignacion,
                       du.estado_despacho,
                       du.fecha_asignacion,
                       du.ubicacion_salida,
                       du.ubicacion_evento,
                       du.observaciones,
                       s.ticket_interno,
                       s.estado_atencion,
                       u.codigo_unidad,
                       u.descripcion AS descripcion_unidad,
                       u.placa,
                       u.ubicacion_actual,
                       u.referencia_actual,
                       ca.numero_licencia,
                       ca.categoria_licencia,
                       ca.vencimiento_licencia,
                       e.cedula AS cedula_chofer,
                       CONCAT(e.nombre, ' ', e.apellido) AS nombre_chofer
                FROM despachos_unidades AS du
                INNER JOIN seguridad AS s
                    ON s.id_seguridad = du.id_seguridad
                INNER JOIN unidades AS u
                    ON u.id_unidad = du.id_unidad
                INNER JOIN choferes_ambulancia AS ca
                    ON ca.id_chofer_ambulancia = du.id_chofer_ambulancia
                INNER JOIN empleados AS e
                    ON e.id_empleado = ca.id_empleado
                WHERE du.id_seguridad = '$idSeguridad'
                  AND du.estado_despacho = 'ACTIVO'
                ORDER BY du.id_despacho_unidad DESC
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }
}
?>
