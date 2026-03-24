<?php
session_start();
require_once "../modelos/Usuarios.php";

$usuarios = new Usuarios();

function responderUsuarios($data)
{
    header("Content-Type: application/json; charset=utf-8");
    echo json_encode($data);
    exit;
}

$op = isset($_GET["op"]) ? (string) $_GET["op"] : "";

switch ($op) {
    case "estadoinicial":
        $estadoInicial = $usuarios->obtenerEstadoInicialAcceso();
        responderUsuarios($estadoInicial);
        break;

    case "registrarprimerusuario":
        $payloadPrimerUsuario = array(
            "usuario" => isset($_POST["usuario"]) ? trim((string) $_POST["usuario"]) : "",
            "password" => isset($_POST["password"]) ? (string) $_POST["password"] : "",
            "password_confirm" => isset($_POST["password_confirm"]) ? (string) $_POST["password_confirm"] : "",
            "cedula" => isset($_POST["cedula"]) ? trim((string) $_POST["cedula"]) : "",
            "nombre" => isset($_POST["nombre"]) ? trim((string) $_POST["nombre"]) : "",
            "apellido" => isset($_POST["apellido"]) ? trim((string) $_POST["apellido"]) : "",
            "correo" => isset($_POST["correo"]) ? trim((string) $_POST["correo"]) : "",
            "dependencia" => isset($_POST["dependencia"]) ? trim((string) $_POST["dependencia"]) : ""
        );

        $resultadoPrimerUsuario = $usuarios->registrarPrimerUsuarioInicial($payloadPrimerUsuario);
        if (!isset($resultadoPrimerUsuario["ok"]) || $resultadoPrimerUsuario["ok"] !== true || !isset($resultadoPrimerUsuario["usuario"])) {
            responderUsuarios($resultadoPrimerUsuario);
        }

        $sesion = $resultadoPrimerUsuario["usuario"];
        $_SESSION["idusuario"] = (int) $sesion["id_usuario"];
        $_SESSION["nombre"] = (string) $sesion["usuario"];
        $_SESSION["usuario"] = (string) $sesion["usuario"];
        $_SESSION["rol"] = (string) $sesion["rol"];
        $_SESSION["nombre_empleado"] = isset($sesion["nombre_empleado"]) ? (string) $sesion["nombre_empleado"] : (string) $sesion["usuario"];
        $_SESSION["idBitacora"] = (int) $sesion["id_usuario"];
        $_SESSION["password_temporal"] = isset($sesion["password_temporal"]) ? (int) $sesion["password_temporal"] : 0;

        $permisosSesion = $usuarios->obtenerPermisosSesion((int) $sesion["id_usuario"], (string) $sesion["rol"]);
        foreach ($permisosSesion as $permiso => $valor) {
            $_SESSION[$permiso] = (int) $valor;
        }

        responderUsuarios(array(
            "ok" => true,
            "msg" => isset($resultadoPrimerUsuario["msg"]) ? (string) $resultadoPrimerUsuario["msg"] : "Primer usuario administrador creado.",
            "id_usuario" => (int) $sesion["id_usuario"],
            "usuario" => (string) $sesion["usuario"],
            "rol" => (string) $sesion["rol"],
            "nombre_empleado" => isset($sesion["nombre_empleado"]) ? (string) $sesion["nombre_empleado"] : (string) $sesion["usuario"],
            "password_temporal" => isset($sesion["password_temporal"]) ? (int) $sesion["password_temporal"] : 0
        ));
        break;

    case "verificar":
        $usuario = isset($_POST["logina"]) ? trim((string) $_POST["logina"]) : "";
        $password = isset($_POST["clavea"]) ? (string) $_POST["clavea"] : "";

        $resultado = $usuarios->verificarAcceso($usuario, $password);
        if (!isset($resultado["ok"]) || $resultado["ok"] !== true || !isset($resultado["usuario"])) {
            responderUsuarios($resultado);
        }

        $sesion = $resultado["usuario"];
        $_SESSION["idusuario"] = (int) $sesion["id_usuario"];
        $_SESSION["nombre"] = (string) $sesion["usuario"];
        $_SESSION["usuario"] = (string) $sesion["usuario"];
        $_SESSION["rol"] = (string) $sesion["rol"];
        $_SESSION["nombre_empleado"] = isset($sesion["nombre_empleado"]) ? (string) $sesion["nombre_empleado"] : (string) $sesion["usuario"];
        $_SESSION["idBitacora"] = (int) $sesion["id_usuario"];
        $_SESSION["password_temporal"] = isset($sesion["password_temporal"]) ? (int) $sesion["password_temporal"] : 0;

        $permisosSesion = $usuarios->obtenerPermisosSesion((int) $sesion["id_usuario"], (string) $sesion["rol"]);
        foreach ($permisosSesion as $permiso => $valor) {
            $_SESSION[$permiso] = (int) $valor;
        }

        responderUsuarios(array(
            "ok" => true,
            "msg" => isset($resultado["msg"]) ? (string) $resultado["msg"] : "Acceso autorizado.",
            "id_usuario" => (int) $sesion["id_usuario"],
            "usuario" => (string) $sesion["usuario"],
            "rol" => (string) $sesion["rol"],
            "nombre_empleado" => isset($sesion["nombre_empleado"]) ? (string) $sesion["nombre_empleado"] : (string) $sesion["usuario"],
            "password_temporal" => isset($sesion["password_temporal"]) ? (int) $sesion["password_temporal"] : 0
        ));
        break;

    case "recuperarclave":
        $usuarioRecuperacion = isset($_POST["usuario_recuperacion"])
            ? trim((string) $_POST["usuario_recuperacion"])
            : (isset($_POST["usuario"]) ? trim((string) $_POST["usuario"]) : "");
        $cedulaRecuperacion = isset($_POST["cedula_recuperacion"])
            ? trim((string) $_POST["cedula_recuperacion"])
            : (isset($_POST["cedula"]) ? trim((string) $_POST["cedula"]) : "");

        $resultado = $usuarios->solicitarRecuperacionClave($usuarioRecuperacion, $cedulaRecuperacion);
        responderUsuarios($resultado);
        break;

    case "salir":
        $idUsuarioSesion = isset($_SESSION["idusuario"]) ? (int) $_SESSION["idusuario"] : 0;
        $usuarioSesion = isset($_SESSION["usuario"]) ? (string) $_SESSION["usuario"] : "";
        if ($idUsuarioSesion > 0) {
            $usuarios->registrarCierreSesion($idUsuarioSesion, $usuarioSesion);
        }
        session_unset();
        session_destroy();
        header("Location: ../index.php");
        break;

    default:
        responderUsuarios(array(
            "ok" => false,
            "codigo" => "OPERACION_NO_SOPORTADA",
            "msg" => "Operacion no soportada."
        ));
        break;
}
?>
