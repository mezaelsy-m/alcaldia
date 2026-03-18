<?php
session_start();

require_once "../modelos/Beneficiarios.php";
require_once "../modelos/Ayudasocial.php";
require_once "../modelos/Serviciospublicos.php";
require_once "../modelos/Serviciosemergencia.php";
require_once "../config/Conexion.php";

$beneficiario = new Beneficiario();
$ayudasocial = new Ayudasocial();
$serviciospubli = new Servicios();
$serviciosemer = new Seguridad_emergencia();

switch ($_GET["op"]) {
    case "estadisticas":
        $estadisticas = array(
            "total_beneficiarios" => 0,
            "total_ayudas" => 0,
            "total_servicios" => 0,
            "total_seguridad" => 0,
            "total_traslados" => 0,
            "total_usuarios" => 0
        );

        try {
            $rspta_beneficiarios = $beneficiario->listar();
            while ($rspta_beneficiarios && $rspta_beneficiarios->fetch_object()) {
                $estadisticas["total_beneficiarios"]++;
            }

            $rspta_ayudas = $ayudasocial->listar();
            while ($rspta_ayudas && $rspta_ayudas->fetch_object()) {
                $estadisticas["total_ayudas"]++;
            }

            $rspta_servicios = $serviciospubli->listar();
            while ($rspta_servicios && $rspta_servicios->fetch_object()) {
                $estadisticas["total_servicios"]++;
            }

            $rspta_seguridad = $serviciosemer->listar();
            while ($rspta_seguridad && $rspta_seguridad->fetch_object()) {
                $estadisticas["total_seguridad"]++;
            }

            $rspta_traslados = ejecutarConsultaSimpleFila("SELECT COUNT(*) AS total FROM reportes_traslado");
            if ($rspta_traslados && isset($rspta_traslados["total"])) {
                $estadisticas["total_traslados"] = (int)$rspta_traslados["total"];
            }

            $rspta_usuarios = ejecutarConsultaSimpleFila("SELECT COUNT(*) AS total FROM usuarios WHERE estado='1'");
            if ($rspta_usuarios && isset($rspta_usuarios["total"])) {
                $estadisticas["total_usuarios"] = (int)$rspta_usuarios["total"];
            }
        } catch (Exception $e) {
            $estadisticas["error"] = $e->getMessage();
        }

        header("Content-Type: application/json");
        echo json_encode($estadisticas);
        break;

    default:
        header("Content-Type: application/json");
        echo json_encode(array("error" => "Operacion no soportada"));
        break;
}
?>
