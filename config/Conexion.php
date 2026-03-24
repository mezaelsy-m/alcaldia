<?php
require "global.php";
require_once "SystemLogger.php";

bootstrapSystemLogger();

if (!isset($conexion) || !($conexion instanceof mysqli)) {
    $dbHost = DB_HOST;

    // En Windows, "localhost" puede usar named pipes y sumar latencia.
    if (strtoupper(substr(PHP_OS, 0, 3)) === "WIN" && $dbHost === "localhost") {
        $dbHost = "127.0.0.1";
    }

    $conexion = new mysqli($dbHost, DB_USERNAME, DB_PASSWORD, DB_NAME);
    mysqli_query($conexion, 'SET NAMES "' . DB_ENCODE . '"');

    if ($conexion->connect_errno) {
        registrarFallaSistema("DB_CONNECT", "Fallo conexion a la base de datos.", array(
            "host" => $dbHost,
            "database" => DB_NAME,
            "error" => $conexion->connect_error,
            "errno" => $conexion->connect_errno
        ));
        printf("Fallo conexion a la base de datos: %s\n", $conexion->connect_error);
        exit();
    }
}

if (!function_exists("ejecutarConsulta")) {
    function ejecutarConsulta($sql)
    {
        global $conexion;
        $query = $conexion->query($sql);
        if ($query === false) {
            registrarFallaSistema("DB_QUERY", "Error al ejecutar consulta SQL.", array(
                "error" => $conexion->error,
                "errno" => $conexion->errno,
                "sql" => resumirConsultaSistema($sql)
            ));
        }
        return $query;
    }

    function ejecutarConsultaSimpleFila($sql)
    {
        global $conexion;
        $query = $conexion->query($sql);
        if ($query === false) {
            registrarFallaSistema("DB_QUERY", "Error al ejecutar consulta simple SQL.", array(
                "error" => $conexion->error,
                "errno" => $conexion->errno,
                "sql" => resumirConsultaSistema($sql)
            ));
            return null;
        }
        $row = $query ? $query->fetch_assoc() : null;
        if ($query instanceof mysqli_result) {
            $query->free();
        }
        return $row;
    }

    function ejecutarConsulta_retornarID($sql)
    {
        global $conexion;
        $resultado = $conexion->query($sql);
        if ($resultado === false) {
            registrarFallaSistema("DB_QUERY", "Error al ejecutar consulta con retorno de ID.", array(
                "error" => $conexion->error,
                "errno" => $conexion->errno,
                "sql" => resumirConsultaSistema($sql)
            ));
            return 0;
        }
        return $conexion->insert_id;
    }

    function limpiarResultadosPendientesConexion()
    {
        global $conexion;
        if (!($conexion instanceof mysqli)) {
            return;
        }

        while ($conexion->more_results()) {
            if (!$conexion->next_result()) {
                break;
            }

            $extra = $conexion->store_result();
            if ($extra instanceof mysqli_result) {
                $extra->free();
            }
        }
    }

    function ejecutarProcedimientoNoResultado($sql)
    {
        global $conexion;
        $resultado = $conexion->query($sql);

        if ($resultado === false) {
            registrarFallaSistema("DB_PROC", "Error al ejecutar procedimiento almacenado.", array(
                "error" => $conexion->error,
                "errno" => $conexion->errno,
                "sql" => resumirConsultaSistema($sql)
            ));
            return false;
        }

        if ($resultado instanceof mysqli_result) {
            $resultado->free();
        }

        limpiarResultadosPendientesConexion();

        return true;
    }

    function ejecutarProcedimientoSimpleFila($sql)
    {
        global $conexion;
        $resultado = $conexion->query($sql);

        if ($resultado === false) {
            registrarFallaSistema("DB_PROC", "Error al ejecutar procedimiento almacenado con retorno simple.", array(
                "error" => $conexion->error,
                "errno" => $conexion->errno,
                "sql" => resumirConsultaSistema($sql)
            ));
            return null;
        }

        $fila = null;
        if ($resultado instanceof mysqli_result) {
            $fila = $resultado->fetch_assoc();
            $resultado->free();
        }

        limpiarResultadosPendientesConexion();

        return $fila;
    }

    function ejecutarProcedimientoLista($sql)
    {
        global $conexion;
        $resultado = $conexion->query($sql);

        if ($resultado === false) {
            registrarFallaSistema("DB_PROC", "Error al ejecutar procedimiento almacenado con listado.", array(
                "error" => $conexion->error,
                "errno" => $conexion->errno,
                "sql" => resumirConsultaSistema($sql)
            ));
            return array();
        }

        $items = array();
        if ($resultado instanceof mysqli_result) {
            while ($fila = $resultado->fetch_assoc()) {
                $items[] = $fila;
            }
            $resultado->free();
        }

        limpiarResultadosPendientesConexion();

        return $items;
    }

    function limpiarCadena($str)
    {
        global $conexion;
        $str = mysqli_real_escape_string($conexion, trim($str));
        return htmlspecialchars($str, ENT_QUOTES, "UTF-8");
    }
}
?>
