<?php
require "global.php";

if (!isset($conexion) || !($conexion instanceof mysqli)) {
    $dbHost = DB_HOST;

    // En Windows, "localhost" puede usar named pipes y sumar latencia.
    if (strtoupper(substr(PHP_OS, 0, 3)) === "WIN" && $dbHost === "localhost") {
        $dbHost = "127.0.0.1";
    }

    $conexion = new mysqli($dbHost, DB_USERNAME, DB_PASSWORD, DB_NAME);
    mysqli_query($conexion, 'SET NAMES "' . DB_ENCODE . '"');

    if ($conexion->connect_errno) {
        printf("Fallo conexion a la base de datos: %s\n", $conexion->connect_error);
        exit();
    }
}

if (!function_exists("ejecutarConsulta")) {
    function ejecutarConsulta($sql)
    {
        global $conexion;
        $query = $conexion->query($sql);
        return $query;
    }

    function ejecutarConsultaSimpleFila($sql)
    {
        global $conexion;
        $query = $conexion->query($sql);
        $row = $query ? $query->fetch_assoc() : null;
        return $row;
    }

    function ejecutarConsulta_retornarID($sql)
    {
        global $conexion;
        $conexion->query($sql);
        return $conexion->insert_id;
    }

    function limpiarCadena($str)
    {
        global $conexion;
        $str = mysqli_real_escape_string($conexion, trim($str));
        return htmlspecialchars($str, ENT_QUOTES, "UTF-8");
    }
}
?>
