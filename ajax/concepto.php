<?php
session_start();

require_once "../modelos/Beneficiarios.php";
require_once "../modelos/Ayudasocial.php";
require_once "../modelos/Serviciospublicos.php";
require_once "../modelos/Serviciosemergencia.php";
require_once "../config/Conexion.php";

function jsonResponseConcepto($data, $status = 200)
{
    if (function_exists("http_response_code")) {
        http_response_code((int) $status);
    }

    header("Content-Type: application/json; charset=utf-8");
    echo json_encode($data);
    exit;
}

function intValueConcepto($row, $key)
{
    if (!is_array($row) || !isset($row[$key])) {
        return 0;
    }

    return (int) $row[$key];
}

function safeCountConcepto($sql, $field = "total")
{
    $row = ejecutarConsultaSimpleFila($sql);
    if (!is_array($row) || !isset($row[$field])) {
        return 0;
    }

    return (int) $row[$field];
}

function safeProcedureRowConcepto($sql)
{
    $row = ejecutarProcedimientoSimpleFila($sql);
    return is_array($row) ? $row : array();
}

function totalMesConcepto($table, $dateField)
{
    if (!preg_match('/^[a-zA-Z0-9_]+$/', (string) $table) || !preg_match('/^[a-zA-Z0-9_]+$/', (string) $dateField)) {
        return 0;
    }

    $sql = "SELECT COUNT(*) AS total
            FROM `$table`
            WHERE IFNULL(estado, 1) = 1
              AND `$dateField` IS NOT NULL
              AND YEAR(`$dateField`) = YEAR(CURDATE())
              AND MONTH(`$dateField`) = MONTH(CURDATE())";

    return safeCountConcepto($sql);
}

function ultimosCasosConcepto($limit = 6)
{
    $limit = max(1, min(12, (int) $limit));
    $sql = "SELECT modulo,
                   ticket_interno,
                   beneficiario,
                   tipo_registro,
                   estado_solicitud,
                   fecha_evento_formateada
            FROM vw_solicitudes_ciudadanas
            WHERE IFNULL(estado, 1) = 1
            ORDER BY fecha_evento DESC, id_registro DESC
            LIMIT " . $limit;

    $rspta = ejecutarConsulta($sql);
    $items = array();

    if ($rspta) {
        while ($row = $rspta->fetch_assoc()) {
            $items[] = array(
                "modulo" => isset($row["modulo"]) ? (string) $row["modulo"] : "",
                "ticket_interno" => isset($row["ticket_interno"]) ? (string) $row["ticket_interno"] : "",
                "beneficiario" => isset($row["beneficiario"]) ? (string) $row["beneficiario"] : "",
                "tipo_registro" => isset($row["tipo_registro"]) ? (string) $row["tipo_registro"] : "",
                "estado_solicitud" => isset($row["estado_solicitud"]) ? (string) $row["estado_solicitud"] : "",
                "fecha_evento_formateada" => isset($row["fecha_evento_formateada"]) ? (string) $row["fecha_evento_formateada"] : ""
            );
        }
    }

    return $items;
}

if (!isset($_SESSION["nombre"])) {
    jsonResponseConcepto(
        array(
            "ok" => false,
            "msg" => "Sesion no valida."
        ),
        401
    );
}

if (!isset($_SESSION["Concepto"]) || (int) $_SESSION["Concepto"] !== 1) {
    jsonResponseConcepto(
        array(
            "ok" => false,
            "msg" => "No autorizado para consultar esta informacion."
        ),
        403
    );
}

$beneficiario = new Beneficiario();
$ayudasocial = new Ayudasocial();
$serviciosPublicos = new Serviciospublicos();
$seguridadEmergencia = new Seguridad_emergencia();

$op = isset($_GET["op"]) ? (string) $_GET["op"] : "";

switch ($op) {
    case "estadisticas":
        $estadisticas = array(
            "ok" => true,
            "total_beneficiarios" => 0,
            "total_ayudas" => 0,
            "total_servicios" => 0,
            "total_seguridad" => 0,
            "ayudas_atendidas" => 0,
            "ayudas_pendientes" => 0,
            "servicios_atendidos" => 0,
            "servicios_pendientes" => 0,
            "seguridad_pendientes" => 0,
            "seguridad_finalizadas" => 0,
            "total_atendidos" => 0,
            "total_pendientes" => 0,
            "total_traslados" => 0,
            "total_usuarios_activos" => 0,
            "unidades_disponibles" => 0,
            "beneficiarios_mes" => 0,
            "ayudas_mes" => 0,
            "servicios_mes" => 0,
            "seguridad_mes" => 0,
            "total_registros_mes" => 0,
            "porcentaje_atencion" => 0,
            "total_usuarios_bloqueados" => 0,
            "ultimos_casos" => array(),
            "bitacora_respaldo_total" => 0,
            "bitacora_respaldo_eventos_criticos" => 0,
            "bitacora_respaldo_ultimo" => "",
            "bitacora_respaldo_estado" => "SIN_DATOS",
            "actualizado_en" => date("Y-m-d H:i:s")
        );

        try {
            $resumenDashboard = safeProcedureRowConcepto("CALL sp_dashboard_resumen_general()");
            $resumenRespaldo = safeProcedureRowConcepto("CALL sala_situacional_respaldo_bitacora.sp_respaldo_bitacora_resumen()");
            $resumenBeneficiarios = $beneficiario->resumen();
            $resumenAyudas = $ayudasocial->resumen();
            $resumenServicios = $serviciosPublicos->resumen();
            $resumenSeguridad = $seguridadEmergencia->resumen();

            $estadisticas["total_beneficiarios"] = isset($resumenDashboard["total_beneficiarios"])
                ? (int) $resumenDashboard["total_beneficiarios"]
                : intValueConcepto($resumenBeneficiarios, "activos");
            $estadisticas["total_ayudas"] = isset($resumenDashboard["total_ayudas"])
                ? (int) $resumenDashboard["total_ayudas"]
                : intValueConcepto($resumenAyudas, "total");
            $estadisticas["total_servicios"] = isset($resumenDashboard["total_servicios"])
                ? (int) $resumenDashboard["total_servicios"]
                : intValueConcepto($resumenServicios, "total");
            $estadisticas["total_seguridad"] = isset($resumenDashboard["total_seguridad"])
                ? (int) $resumenDashboard["total_seguridad"]
                : intValueConcepto($resumenSeguridad, "total");

            $estadisticas["ayudas_atendidas"] = intValueConcepto($resumenAyudas, "atendidas");
            $estadisticas["ayudas_pendientes"] = intValueConcepto($resumenAyudas, "no_atendidas");
            $estadisticas["servicios_atendidos"] = intValueConcepto($resumenServicios, "atendidas");
            $estadisticas["servicios_pendientes"] = intValueConcepto($resumenServicios, "pendientes");

            $seguridadPendientesUnidad = intValueConcepto($resumenSeguridad, "pendientes_unidad");
            $seguridadRegistradas = intValueConcepto($resumenSeguridad, "registrados");
            $estadisticas["seguridad_pendientes"] = $seguridadPendientesUnidad + $seguridadRegistradas;
            $estadisticas["seguridad_finalizadas"] = intValueConcepto($resumenSeguridad, "finalizadas");
            $estadisticas["unidades_disponibles"] = intValueConcepto($resumenSeguridad, "unidades_disponibles");

            $estadisticas["total_atendidos"] = $estadisticas["ayudas_atendidas"]
                + $estadisticas["servicios_atendidos"]
                + $estadisticas["seguridad_finalizadas"];

            $estadisticas["total_pendientes"] = $estadisticas["ayudas_pendientes"]
                + $estadisticas["servicios_pendientes"]
                + $estadisticas["seguridad_pendientes"];

            $totalCasosGestion = $estadisticas["total_ayudas"]
                + $estadisticas["total_servicios"]
                + $estadisticas["total_seguridad"];

            if ($totalCasosGestion > 0) {
                $estadisticas["porcentaje_atencion"] = round(($estadisticas["total_atendidos"] * 100) / $totalCasosGestion, 1);
            }

            $estadisticas["total_traslados"] = safeCountConcepto("SELECT COUNT(*) AS total FROM reportes_traslado");
            $estadisticas["total_usuarios_activos"] = isset($resumenDashboard["total_usuarios_activos"])
                ? (int) $resumenDashboard["total_usuarios_activos"]
                : safeCountConcepto("SELECT COUNT(*) AS total FROM usuarios WHERE IFNULL(estado, 1) = 1");
            $estadisticas["total_usuarios_bloqueados"] = isset($resumenDashboard["total_usuarios_bloqueados"])
                ? (int) $resumenDashboard["total_usuarios_bloqueados"]
                : safeCountConcepto("SELECT COUNT(*) AS total FROM usuarios_seguridad_acceso WHERE IFNULL(bloqueado, 0) = 1");
            $estadisticas["unidades_disponibles"] = isset($resumenDashboard["total_unidades_disponibles"])
                ? (int) $resumenDashboard["total_unidades_disponibles"]
                : $estadisticas["unidades_disponibles"];

            $estadisticas["beneficiarios_mes"] = totalMesConcepto("beneficiarios", "fecha_registro");
            $estadisticas["ayudas_mes"] = totalMesConcepto("ayuda_social", "fecha_ayuda");
            $estadisticas["servicios_mes"] = totalMesConcepto("servicios_publicos", "fecha_servicio");
            $estadisticas["seguridad_mes"] = totalMesConcepto("seguridad", "fecha_seguridad");

            $estadisticas["total_registros_mes"] = $estadisticas["beneficiarios_mes"]
                + $estadisticas["ayudas_mes"]
                + $estadisticas["servicios_mes"]
                + $estadisticas["seguridad_mes"];
            $estadisticas["ultimos_casos"] = ultimosCasosConcepto(6);
            $estadisticas["bitacora_respaldo_total"] = isset($resumenRespaldo["total_registros"]) ? (int) $resumenRespaldo["total_registros"] : 0;
            $estadisticas["bitacora_respaldo_eventos_criticos"] = isset($resumenRespaldo["eventos_criticos"]) ? (int) $resumenRespaldo["eventos_criticos"] : 0;
            $estadisticas["bitacora_respaldo_ultimo"] = isset($resumenRespaldo["ultimo_respaldo"]) ? (string) $resumenRespaldo["ultimo_respaldo"] : "";
            $estadisticas["bitacora_respaldo_estado"] = isset($resumenRespaldo["estado_respaldo"]) ? (string) $resumenRespaldo["estado_respaldo"] : "SIN_DATOS";
        } catch (Exception $e) {
            $estadisticas["ok"] = false;
            $estadisticas["msg"] = "No se pudo cargar el resumen general.";
            $estadisticas["error"] = $e->getMessage();
        }

        jsonResponseConcepto($estadisticas);
        break;

    default:
        jsonResponseConcepto(
            array(
                "ok" => false,
                "msg" => "Operacion no soportada."
            ),
            400
        );
        break;
}
?>
