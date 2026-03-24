<?php 
session_start();
require "../config/Conexion.php";
require_once "../modelos/Bitacora.php";

$bitacora = new Bitacora();
$op = isset($_GET["op"]) ? (string) $_GET["op"] : "";
$tienePermisoBitacora = isset($_SESSION["Tribunal"]) && (int) $_SESSION["Tribunal"] === 1;

function valorFilaBitacora($row, $campo, $default = "")
{
    if (is_array($row) && array_key_exists($campo, $row)) {
        return $row[$campo];
    }

    if (is_object($row) && isset($row->$campo)) {
        return $row->$campo;
    }

    return $default;
}

function construirFilaBitacoraListado($row)
{
    $idUsuario = (int) valorFilaBitacora($row, "id_usuario", 0);
    $usuarioMostrar = trim((string) valorFilaBitacora($row, "usuario_mostrar", ""));
    if ($usuarioMostrar === "") {
        $usuarioMostrar = $idUsuario > 0 ? "Usuario ID: " . $idUsuario : "Sistema";
    }

    $resumenMostrar = trim((string) valorFilaBitacora($row, "origen_evento", ""));
    $resumen = trim((string) valorFilaBitacora($row, "resumen", ""));
    if ($resumen !== "") {
        $resumenMostrar = $resumenMostrar !== ""
            ? $resumenMostrar . " | " . $resumen
            : $resumen;
    }

    return array(
        "0" => valorFilaBitacora($row, "id_bitacora"),
        "1" => $usuarioMostrar,
        "2" => $resumenMostrar,
        "3" => valorFilaBitacora($row, "detalle"),
        "4" => valorFilaBitacora($row, "fecha_evento_formateada", valorFilaBitacora($row, "fecha_evento")),
        "5" => valorFilaBitacora($row, "ipaddr", "Desconocida")
    );
}

switch ($op){
    case 'listar':
        if (!$tienePermisoBitacora) {
            echo json_encode(array(
                "sEcho" => 1,
                "iTotalRecords" => 0,
                "iTotalDisplayRecords" => 0,
                "aaData" => array()
            ));
            break;
        }

        $data = Array();
        $scope = isset($_GET["scope"]) ? strtolower(trim((string) $_GET["scope"])) : "sistema";

        if ($scope === "autenticacion") {
            $rows = $bitacora->listarAutenticacion(
                isset($_GET["fecha_desde"]) ? limpiarCadena($_GET["fecha_desde"]) : "",
                isset($_GET["fecha_hasta"]) ? limpiarCadena($_GET["fecha_hasta"]) : "",
                isset($_GET["usuario"]) ? limpiarCadena($_GET["usuario"]) : "",
                isset($_GET["accion"]) ? limpiarCadena($_GET["accion"]) : ""
            );

            foreach ($rows as $row) {
                $data[] = construirFilaBitacoraListado($row);
            }
        } else {
            $rspta = $bitacora->listar();

            while ($reg = $rspta->fetch_object()){
                $data[] = construirFilaBitacoraListado($reg);
            }
        }
        
        $results = array(
            "sEcho" => 1,
            "iTotalRecords" => count($data),
            "iTotalDisplayRecords" => count($data),
            "aaData" => $data
        );
        
        echo json_encode($results);
    break;
    
    case 'mostrar':
        if (!$tienePermisoBitacora) {
            echo json_encode(array("ok" => false, "msg" => "No tiene permisos para consultar la bitacora."));
            break;
        }

        $id_bitacora = isset($_POST["id_bitacora"]) ? limpiarCadena($_POST["id_bitacora"]) : "";
        $rspta = $bitacora->mostrar($id_bitacora);
        echo json_encode($rspta);
    break;
    
    case 'salir':
        // Limpiar sesión
        session_unset();
        session_destroy();
        header("Location: ../index.php");
    break;
}
?>
