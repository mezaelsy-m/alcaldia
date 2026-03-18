<?php 
session_start();
require "../config/Conexion.php";
require_once "../modelos/Bitacora.php";

$bitacora = new Bitacora();
$op = isset($_GET["op"]) ? (string) $_GET["op"] : "";
$tienePermisoBitacora = isset($_SESSION["Tribunal"]) && (int) $_SESSION["Tribunal"] === 1;

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

        $rspta = $bitacora->listar();
        $data = Array();
        
        while ($reg = $rspta->fetch_object()){
            $data[] = array(
                "0" => $reg->id_bitacora,
                "1" => "Usuario ID: " . $reg->id_usuario,
                "2" => $reg->resumen,
                "3" => $reg->detalle,
                "4" => $reg->moment,
                "5" => $_SERVER['REMOTE_ADDR'] ?? 'Desconocida'
            );
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
