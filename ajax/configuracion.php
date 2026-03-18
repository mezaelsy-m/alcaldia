<?php
session_start();
require_once "../modelos/Configuracion.php";

$configuracion = new Configuracion();

function responderJsonConfiguracion($ok, $msg, $data = null)
{
    header("Content-Type: application/json; charset=utf-8");
    echo json_encode(array("ok" => (bool) $ok, "msg" => $msg, "data" => $data));
    exit;
}

function limpiarPayloadConfiguracion($source)
{
    $payload = array();

    foreach ($source as $key => $value) {
        if (!is_scalar($value)) {
            continue;
        }

        $payload[$key] = limpiarCadena((string) $value);
    }

    return $payload;
}

function registrarBitacoraConfiguracion($idUsuario, $detalle)
{
    if ((int) $idUsuario <= 0 || trim((string) $detalle) === "") {
        return;
    }

    require_once "../modelos/Bitacora.php";
    $bitacora = new Bitacora();
    $bitacora->insertar($idUsuario, $detalle);
}

function tienePermisoConfiguracionSesion($permiso)
{
    return isset($_SESSION[$permiso]) && (int) $_SESSION[$permiso] === 1;
}

if (!isset($_SESSION["nombre"])) {
    responderJsonConfiguracion(false, "La sesion ha expirado. Inicie sesion nuevamente.");
}

if (!tienePermisoConfiguracionSesion("Concepto") && !tienePermisoConfiguracionSesion("Usuarios")) {
    responderJsonConfiguracion(false, "No tiene permisos para acceder a configuracion.");
}

$request = array_merge($_GET, $_POST);
$catalogo = isset($request["catalogo"]) ? limpiarCadena($request["catalogo"]) : "";
$idRegistro = isset($request["id_registro"]) ? (int) limpiarCadena($request["id_registro"]) : 0;
$idUsuario = isset($_SESSION["idusuario"]) ? (int) $_SESSION["idusuario"] : 0;
$op = isset($_GET["op"]) ? $_GET["op"] : "";
$puedeCatalogos = tienePermisoConfiguracionSesion("Concepto");
$puedeUsuarios = tienePermisoConfiguracionSesion("Usuarios");
$puedeEmpleados = $puedeCatalogos || $puedeUsuarios;
$puedeSmtp = $puedeCatalogos || $puedeUsuarios;

switch ($op) {
    case "metadata":
        if (!$puedeCatalogos) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar tablas maestras.");
        }
        responderJsonConfiguracion(true, "Metadatos cargados correctamente.", $configuracion->obtenerMetadatosUI());
    break;

    case "listar":
        if (!$puedeCatalogos) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar tablas maestras.");
        }
        if ($catalogo === "") {
            responderJsonConfiguracion(false, "Debe indicar el catalogo a consultar.");
        }

        $estado = isset($request["estado"]) ? limpiarCadena($request["estado"]) : "activos";
        $resultado = $configuracion->listar($catalogo, $estado);

        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "items" => isset($resultado["items"]) ? $resultado["items"] : array(),
                    "resumen" => isset($resultado["resumen"]) ? $resultado["resumen"] : array()
                )
                : null
        );
    break;

    case "mostrar":
        if (!$puedeCatalogos) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar tablas maestras.");
        }
        if ($catalogo === "" || $idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el catalogo y el registro a consultar.");
        }

        $resultado = $configuracion->mostrar($catalogo, $idRegistro);
        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "item" => isset($resultado["item"]) ? $resultado["item"] : null,
                    "locks" => isset($resultado["locks"]) ? $resultado["locks"] : array(),
                    "notice" => isset($resultado["notice"]) ? $resultado["notice"] : ""
                )
                : null
        );
    break;

    case "guardaryeditar":
        if (!$puedeCatalogos) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar tablas maestras.");
        }
        if ($catalogo === "") {
            responderJsonConfiguracion(false, "Debe indicar el catalogo a gestionar.");
        }

        $payload = limpiarPayloadConfiguracion($_POST);
        unset($payload["catalogo"], $payload["id_registro"]);

        $resultado = $configuracion->guardaryeditar($catalogo, $idRegistro, $payload);
        if (!empty($resultado["ok"])) {
            $accion = $idRegistro > 0 ? "ACTUALIZAR" : (!empty($resultado["reactivado"]) ? "REACTIVAR" : "CREAR");
            $detalle = "CONFIGURACION " . $accion . " - Catalogo: " . $catalogo . " - Registro: " . (int) $resultado["id_registro"];
            registrarBitacoraConfiguracion($idUsuario, $detalle);
        }

        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "id_registro" => isset($resultado["id_registro"]) ? (int) $resultado["id_registro"] : 0,
                    "reactivado" => !empty($resultado["reactivado"])
                )
                : null
        );
    break;

    case "desactivar":
        if (!$puedeCatalogos) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar tablas maestras.");
        }
        if ($catalogo === "" || $idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el catalogo y el registro a desactivar.");
        }

        $resultado = $configuracion->desactivar($catalogo, $idRegistro);
        if (!empty($resultado["ok"])) {
            registrarBitacoraConfiguracion($idUsuario, "CONFIGURACION DESACTIVAR - Catalogo: " . $catalogo . " - Registro: " . $idRegistro);
        }

        responderJsonConfiguracion(!empty($resultado["ok"]), isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.");
    break;

    case "reactivar":
        if (!$puedeCatalogos) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar tablas maestras.");
        }
        if ($catalogo === "" || $idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el catalogo y el registro a reactivar.");
        }

        $resultado = $configuracion->reactivar($catalogo, $idRegistro);
        if (!empty($resultado["ok"])) {
            registrarBitacoraConfiguracion($idUsuario, "CONFIGURACION REACTIVAR - Catalogo: " . $catalogo . " - Registro: " . $idRegistro);
        }

        responderJsonConfiguracion(!empty($resultado["ok"]), isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.");
    break;

    case "metadatausuarios":
        if (!$puedeUsuarios) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar usuarios del sistema.");
        }

        responderJsonConfiguracion(true, "Metadatos de usuarios cargados correctamente.", $configuracion->obtenerMetadatosUsuariosUI($idUsuario));
    break;

    case "listarusuarios":
        if (!$puedeUsuarios) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar usuarios del sistema.");
        }

        $estado = isset($request["estado"]) ? limpiarCadena($request["estado"]) : "activos";
        $resultado = $configuracion->listarUsuariosSistema($estado, $idUsuario);
        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "items" => isset($resultado["items"]) ? $resultado["items"] : array(),
                    "resumen" => isset($resultado["resumen"]) ? $resultado["resumen"] : array()
                )
                : null
        );
    break;

    case "mostrarusuario":
        if (!$puedeUsuarios) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar usuarios del sistema.");
        }

        if ($idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el usuario a consultar.");
        }

        $resultado = $configuracion->mostrarUsuarioSistema($idRegistro, $idUsuario);
        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "item" => isset($resultado["item"]) ? $resultado["item"] : null,
                    "notice" => isset($resultado["notice"]) ? $resultado["notice"] : ""
                )
                : null
        );
    break;

    case "guardaryeditarusuario":
        if (!$puedeUsuarios) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar usuarios del sistema.");
        }

        $payloadUsuario = array(
            "id_empleado" => isset($_POST["id_empleado"]) ? (int) $_POST["id_empleado"] : 0,
            "usuario" => isset($_POST["usuario"]) ? trim((string) $_POST["usuario"]) : "",
            "rol" => isset($_POST["rol"]) ? trim((string) $_POST["rol"]) : "",
            "password" => isset($_POST["password"]) ? (string) $_POST["password"] : "",
            "confirmar_password" => isset($_POST["confirmar_password"]) ? (string) $_POST["confirmar_password"] : "",
            "id_permisos" => isset($_POST["id_permisos"]) ? (array) $_POST["id_permisos"] : array()
        );

        $resultado = $configuracion->guardaryeditarUsuarioSistema($idRegistro, $payloadUsuario, $idUsuario);
        if (!empty($resultado["ok"])) {
            $accion = $idRegistro > 0 ? "ACTUALIZAR" : (!empty($resultado["reactivado"]) ? "REACTIVAR" : "CREAR");
            registrarBitacoraConfiguracion($idUsuario, "USUARIOS " . $accion . " - Usuario ID " . (int) $resultado["id_registro"]);
        }

        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "id_registro" => isset($resultado["id_registro"]) ? (int) $resultado["id_registro"] : 0,
                    "reactivado" => !empty($resultado["reactivado"])
                )
                : null
        );
    break;

    case "desactivarusuario":
        if (!$puedeUsuarios) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar usuarios del sistema.");
        }

        if ($idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el usuario a desactivar.");
        }

        $resultado = $configuracion->cambiarEstadoUsuarioSistema($idRegistro, false, $idUsuario);
        if (!empty($resultado["ok"])) {
            registrarBitacoraConfiguracion($idUsuario, "USUARIOS SOFTDELETE - Usuario ID " . $idRegistro);
        }

        responderJsonConfiguracion(!empty($resultado["ok"]), isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.");
    break;

    case "reactivarusuario":
        if (!$puedeUsuarios) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar usuarios del sistema.");
        }

        if ($idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el usuario a reactivar.");
        }

        $resultado = $configuracion->cambiarEstadoUsuarioSistema($idRegistro, true, $idUsuario);
        if (!empty($resultado["ok"])) {
            registrarBitacoraConfiguracion($idUsuario, "USUARIOS REACTIVAR - Usuario ID " . $idRegistro);
        }

        responderJsonConfiguracion(!empty($resultado["ok"]), isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.");
    break;

    case "accesototalusuario":
        if (!$puedeUsuarios) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar usuarios del sistema.");
        }

        if ($idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el usuario a gestionar.");
        }

        $otorgar = isset($_POST["otorgar"]) && (string) $_POST["otorgar"] === "1";
        $resultado = $configuracion->cambiarAccesoTotalUsuario($idRegistro, $otorgar, $idUsuario);
        if (!empty($resultado["ok"])) {
            registrarBitacoraConfiguracion(
                $idUsuario,
                "USUARIOS " . ($otorgar ? "OTORGAR" : "RETIRAR") . " ACCESO TOTAL - Usuario ID " . $idRegistro
            );
        }

        responderJsonConfiguracion(!empty($resultado["ok"]), isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.");
    break;

    case "metadataempleados":
        if (!$puedeEmpleados) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar empleados del sistema.");
        }

        responderJsonConfiguracion(true, "Metadatos de empleados cargados correctamente.", $configuracion->obtenerMetadatosEmpleadosUI());
    break;

    case "listarempleados":
        if (!$puedeEmpleados) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar empleados del sistema.");
        }

        $estado = isset($request["estado"]) ? limpiarCadena($request["estado"]) : "activos";
        $resultado = $configuracion->listarEmpleadosSistema($estado);
        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "items" => isset($resultado["items"]) ? $resultado["items"] : array(),
                    "resumen" => isset($resultado["resumen"]) ? $resultado["resumen"] : array()
                )
                : null
        );
    break;

    case "mostrarempleado":
        if (!$puedeEmpleados) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar empleados del sistema.");
        }

        if ($idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el empleado a consultar.");
        }

        $resultado = $configuracion->mostrarEmpleadoSistema($idRegistro);
        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "item" => isset($resultado["item"]) ? $resultado["item"] : null,
                    "notice" => isset($resultado["notice"]) ? $resultado["notice"] : ""
                )
                : null
        );
    break;

    case "guardaryeditarempleado":
        if (!$puedeEmpleados) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar empleados del sistema.");
        }

        $payloadEmpleado = array(
            "cedula" => isset($_POST["cedula"]) ? (int) $_POST["cedula"] : 0,
            "nombre" => isset($_POST["nombre"]) ? trim((string) $_POST["nombre"]) : "",
            "apellido" => isset($_POST["apellido"]) ? trim((string) $_POST["apellido"]) : "",
            "id_dependencia" => isset($_POST["id_dependencia"]) ? (int) $_POST["id_dependencia"] : 0,
            "telefono" => isset($_POST["telefono"]) ? trim((string) $_POST["telefono"]) : "",
            "correo" => isset($_POST["correo"]) ? trim((string) $_POST["correo"]) : "",
            "direccion" => isset($_POST["direccion"]) ? trim((string) $_POST["direccion"]) : ""
        );

        $resultado = $configuracion->guardaryeditarEmpleadoSistema($idRegistro, $payloadEmpleado, $idUsuario);
        if (!empty($resultado["ok"])) {
            $accion = $idRegistro > 0 ? "ACTUALIZAR" : (!empty($resultado["reactivado"]) ? "REACTIVAR" : "CREAR");
            registrarBitacoraConfiguracion($idUsuario, "EMPLEADOS " . $accion . " - Empleado ID " . (int) $resultado["id_registro"]);
        }

        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "id_registro" => isset($resultado["id_registro"]) ? (int) $resultado["id_registro"] : 0,
                    "reactivado" => !empty($resultado["reactivado"])
                )
                : null
        );
    break;

    case "desactivarempleado":
        if (!$puedeEmpleados) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar empleados del sistema.");
        }

        if ($idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el empleado a desactivar.");
        }

        $resultado = $configuracion->cambiarEstadoEmpleadoSistema($idRegistro, false);
        if (!empty($resultado["ok"])) {
            registrarBitacoraConfiguracion($idUsuario, "EMPLEADOS DESACTIVAR - Empleado ID " . $idRegistro);
        }

        responderJsonConfiguracion(!empty($resultado["ok"]), isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.");
    break;

    case "reactivarempleado":
        if (!$puedeEmpleados) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar empleados del sistema.");
        }

        if ($idRegistro <= 0) {
            responderJsonConfiguracion(false, "Debe indicar el empleado a reactivar.");
        }

        $resultado = $configuracion->cambiarEstadoEmpleadoSistema($idRegistro, true);
        if (!empty($resultado["ok"])) {
            registrarBitacoraConfiguracion($idUsuario, "EMPLEADOS REACTIVAR - Empleado ID " . $idRegistro);
        }

        responderJsonConfiguracion(!empty($resultado["ok"]), isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.");
    break;

    case "metadatasmtp":
        if (!$puedeSmtp) {
            responderJsonConfiguracion(false, "No tiene permisos para consultar la configuracion SMTP.");
        }

        $resultado = $configuracion->obtenerConfiguracionSmtp();
        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "item" => isset($resultado["item"]) ? $resultado["item"] : null
                )
                : null
        );
    break;

    case "guardarsmtp":
        if (!$puedeSmtp) {
            responderJsonConfiguracion(false, "No tiene permisos para gestionar la configuracion SMTP.");
        }

        $payloadSmtp = array(
            "host" => isset($_POST["host"]) ? trim((string) $_POST["host"]) : "",
            "puerto" => isset($_POST["puerto"]) ? (int) $_POST["puerto"] : 0,
            "usuario" => isset($_POST["usuario"]) ? trim((string) $_POST["usuario"]) : "",
            "clave" => isset($_POST["clave"]) ? (string) $_POST["clave"] : "",
            "correo_remitente" => isset($_POST["correo_remitente"]) ? trim((string) $_POST["correo_remitente"]) : "",
            "nombre_remitente" => isset($_POST["nombre_remitente"]) ? trim((string) $_POST["nombre_remitente"]) : "",
            "usar_tls" => isset($_POST["usar_tls"]) ? (int) $_POST["usar_tls"] : 1
        );

        $resultado = $configuracion->guardarConfiguracionSmtp($payloadSmtp, $idUsuario);
        if (!empty($resultado["ok"])) {
            registrarBitacoraConfiguracion($idUsuario, "SMTP ACTUALIZAR CONFIGURACION");
        }

        responderJsonConfiguracion(
            !empty($resultado["ok"]),
            isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.",
            !empty($resultado["ok"])
                ? array(
                    "id_registro" => isset($resultado["id_registro"]) ? (int) $resultado["id_registro"] : 0
                )
                : null
        );
    break;

    case "enviarsmtptest":
        if (!$puedeSmtp) {
            responderJsonConfiguracion(false, "No tiene permisos para enviar pruebas SMTP.");
        }

        $destinatario = isset($_POST["destinatario"]) ? trim((string) $_POST["destinatario"]) : "";
        $resultado = $configuracion->enviarPruebaSmtp($destinatario, $idUsuario);
        if (!empty($resultado["ok"])) {
            registrarBitacoraConfiguracion($idUsuario, "SMTP ENVIO PRUEBA - Destino: " . $destinatario);
        }

        responderJsonConfiguracion(!empty($resultado["ok"]), isset($resultado["msg"]) ? $resultado["msg"] : "Operacion finalizada.");
    break;

    default:
        responderJsonConfiguracion(false, "Operacion no soportada.");
    break;
}
?>
