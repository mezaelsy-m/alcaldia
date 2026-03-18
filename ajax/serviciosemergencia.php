<?php
session_start();
require_once "../modelos/Serviciosemergencia.php";

$serviciosemer = new Seguridad_emergencia();

$idSeguridad = isset($_POST["id_seguridad"])
    ? limpiarCadena($_POST["id_seguridad"])
    : (isset($_GET["id_seguridad"]) ? limpiarCadena($_GET["id_seguridad"]) : "");
$idBeneficiario = isset($_POST["id_beneficiario"]) ? limpiarCadena($_POST["id_beneficiario"]) : "";
$idTipoSeguridad = isset($_POST["id_tipo_seguridad"]) ? limpiarCadena($_POST["id_tipo_seguridad"]) : "";
$idSolicitudSeguridad = isset($_POST["id_solicitud_seguridad"]) ? limpiarCadena($_POST["id_solicitud_seguridad"]) : "";
$idReporteSolicitud = isset($_REQUEST["id_reporte_solicitud"]) ? limpiarCadena($_REQUEST["id_reporte_solicitud"]) : "";
$fechaSeguridad = isset($_POST["fecha_seguridad"]) ? limpiarCadena($_POST["fecha_seguridad"]) : "";
$descripcion = isset($_POST["descripcion"]) ? limpiarCadena($_POST["descripcion"]) : "";
$ubicacionEvento = isset($_POST["ubicacion_evento"]) ? limpiarCadena($_POST["ubicacion_evento"]) : "";
$referenciaEvento = isset($_POST["referencia_evento"]) ? limpiarCadena($_POST["referencia_evento"]) : "";
$enviarReporteChofer = isset($_POST["enviar_reporte_chofer"]) ? $_POST["enviar_reporte_chofer"] : "0";
$idEstadoSolicitud = isset($_POST["id_estado_solicitud"]) ? limpiarCadena($_POST["id_estado_solicitud"]) : "";
$fechaEstadoSolicitud = isset($_POST["fecha_estado_solicitud"]) ? limpiarCadena($_POST["fecha_estado_solicitud"]) : "";
$observacionEstadoSolicitud = isset($_POST["observacion_estado_solicitud"]) ? limpiarCadena($_POST["observacion_estado_solicitud"]) : "";
$idUsuario = isset($_SESSION["idusuario"]) ? (int) $_SESSION["idusuario"] : 0;

function responderJson($ok, $msg, $data = null)
{
    header("Content-Type: application/json; charset=utf-8");
    echo json_encode(array("ok" => $ok, "msg" => $msg, "data" => $data));
    exit;
}

function normalizarBooleanoPost($valor)
{
    $valor = strtolower(trim((string) $valor));
    return in_array($valor, array("1", "true", "on", "si", "yes"), true) ? "1" : "0";
}

function normalizarFechaHora($valor)
{
    $valor = trim((string) $valor);
    if ($valor === "") {
        return "";
    }

    $valor = str_replace("T", " ", $valor);
    if (preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/', $valor)) {
        $valor .= ":00";
    }

    return $valor;
}

$enviarReporteChofer = normalizarBooleanoPost($enviarReporteChofer);

function registrarBitacoraOperacion($idUsuario, $detalle)
{
    if ((int) $idUsuario <= 0) {
        return;
    }

    require_once "../modelos/Bitacora.php";
    $bitacora = new Bitacora();
    $bitacora->insertar($idUsuario, $detalle);
}

function detalleOperacionSeguridad($estadoAtencion)
{
    if ($estadoAtencion === "PENDIENTE_UNIDAD") {
        return "Pendiente de unidad";
    }
    if ($estadoAtencion === "DESPACHADO") {
        return "Despachado";
    }
    if ($estadoAtencion === "FINALIZADO") {
        return "Cierre operativo";
    }

    return "Registro operativo";
}

function badgeEstadoSolicitud($nombreEstado, $claseBadge, $estadoAtencion)
{
    $claseBadge = preg_replace('/[^a-z0-9_-]/i', '', (string) $claseBadge);
    if ($claseBadge === "") {
        $claseBadge = "draft";
    }

    $html = '<span class="status-pill ' . $claseBadge . '">' . htmlspecialchars((string) $nombreEstado, ENT_QUOTES, "UTF-8") . '</span>';
    $detalle = detalleOperacionSeguridad($estadoAtencion);
    if ($detalle !== "") {
        $html .= '<div class="small text-muted mt-1">' . htmlspecialchars($detalle, ENT_QUOTES, "UTF-8") . '</div>';
    }

    return $html;
}

function construirTelefonoHtml($telefono)
{
    $telefono = trim((string) $telefono);
    if ($telefono === "") {
        return '<span class="text-muted">Sin telefono</span>';
    }

    $telefonoWhatsapp = normalizarTelefonoWhatsapp($telefono);
    if ($telefonoWhatsapp === "") {
        return '<span class="text-muted">Telefono invalido</span>';
    }

    $mensaje = urlencode("Hola, su solicitud de seguridad y emergencia esta siendo gestionada.");
    return '<a href="https://wa.me/' . $telefonoWhatsapp . '?text=' . $mensaje . '" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-outline-success"><i class="fab fa-whatsapp"></i> ' . htmlspecialchars($telefono, ENT_QUOTES, "UTF-8") . '</a>';
}

function normalizarTelefonoWhatsapp($telefono)
{
    $telefono = preg_replace('/[^0-9]/', '', (string) $telefono);
    if ($telefono === "") {
        return "";
    }

    if (strpos($telefono, "58") !== 0) {
        $telefono = "58" . ltrim($telefono, "0");
    }

    return $telefono;
}

function obtenerNombreSistemaWhatsapp()
{
    return defined("PRO_NOMBRE") && trim((string) PRO_NOMBRE) !== ""
        ? trim((string) PRO_NOMBRE)
        : "Sala Situacional";
}

function obtenerEscenarioWhatsapp($escenario)
{
    $escenario = strtoupper(trim((string) $escenario));
    switch ($escenario) {
        case "REGISTRO_AMBULANCIA":
            return array(
                "titulo" => "Notificar registro de ambulancia",
                "resumen" => "Su solicitud fue registrada y se encuentra en revision operativa."
            );
        case "REGISTRO_PENDIENTE_UNIDAD":
            return array(
                "titulo" => "Notificar solicitud en revision",
                "resumen" => "Su solicitud fue registrada y esta en revision. Aun no hay unidad disponible."
            );
        case "AMBULANCIA_DESPACHADA":
            return array(
                "titulo" => "Notificar ambulancia en camino",
                "resumen" => "Su ambulancia fue despachada y va en camino."
            );
        case "SOLICITUD_EN_REVISION":
            return array(
                "titulo" => "Notificar solicitud en revision",
                "resumen" => "Su solicitud se encuentra en revision."
            );
        case "SOLICITUD_ATENDIDA":
            return array(
                "titulo" => "Notificar solicitud atendida",
                "resumen" => "Su solicitud fue atendida satisfactoriamente."
            );
        case "SOLICITUD_FINALIZADA":
            return array(
                "titulo" => "Notificar cierre de solicitud",
                "resumen" => "Su solicitud fue finalizada y el despacho se cerro correctamente."
            );
        case "SOLICITUD_NO_ATENDIDA":
            return array(
                "titulo" => "Notificar cierre sin atencion",
                "resumen" => "Su solicitud fue cerrada sin atencion satisfactoria."
            );
        default:
            return array(
                "titulo" => "Notificar actualizacion de solicitud",
                "resumen" => "Hay una actualizacion sobre su solicitud."
            );
    }
}

function construirMensajeWhatsappPlantilla($datos, $escenario)
{
    $infoEscenario = obtenerEscenarioWhatsapp($escenario);
    $beneficiario = isset($datos["beneficiario"]) ? trim((string) $datos["beneficiario"]) : "";
    if ($beneficiario === "") {
        $beneficiario = trim((string) (isset($datos["nacionalidad"]) ? $datos["nacionalidad"] : "") . "-" . (isset($datos["cedula"]) ? $datos["cedula"] : "") . " " . (isset($datos["nombre_beneficiario"]) ? $datos["nombre_beneficiario"] : ""));
    }
    if ($beneficiario === "" || $beneficiario === "-") {
        $beneficiario = "Beneficiario";
    }

    $ticket = isset($datos["ticket_interno"]) ? trim((string) $datos["ticket_interno"]) : "";
    $tipoSeguridad = isset($datos["tipo_seguridad"]) ? trim((string) $datos["tipo_seguridad"]) : "";
    $tipoSolicitud = isset($datos["tipo_solicitud"]) ? trim((string) $datos["tipo_solicitud"]) : "";
    $estadoSolicitud = isset($datos["estado_solicitud"]) ? trim((string) $datos["estado_solicitud"]) : "";
    $estadoAtencion = isset($datos["estado_atencion"]) ? trim((string) $datos["estado_atencion"]) : "";
    $ubicacion = isset($datos["ubicacion_evento"]) ? trim((string) $datos["ubicacion_evento"]) : "";
    $unidad = isset($datos["codigo_unidad"]) ? trim((string) $datos["codigo_unidad"]) : "";
    $placa = isset($datos["placa"]) ? trim((string) $datos["placa"]) : "";
    $chofer = isset($datos["nombre_chofer"]) ? trim((string) $datos["nombre_chofer"]) : "";
    $cedulaChofer = isset($datos["cedula_chofer"]) ? trim((string) $datos["cedula_chofer"]) : "";
    $licencia = isset($datos["numero_licencia"]) ? trim((string) $datos["numero_licencia"]) : "";

    $lineas = array();
    $lineas[] = "*Notificacion de Seguridad y Emergencia*";
    $lineas[] = "Estimado(a) *" . $beneficiario . "*:";
    $lineas[] = "";
    $lineas[] = $infoEscenario["resumen"];
    $lineas[] = "";
    $lineas[] = "*Resumen de la solicitud*";
    $lineas[] = "- Ticket: *" . ($ticket !== "" ? $ticket : "Sin ticket") . "*";
    if ($tipoSeguridad !== "") {
        $lineas[] = "- Tipo de ayuda: " . $tipoSeguridad;
    }
    if ($tipoSolicitud !== "") {
        $lineas[] = "- Tipo de solicitud: " . $tipoSolicitud;
    }
    if ($estadoSolicitud !== "") {
        $lineas[] = "- Estado de solicitud: *" . $estadoSolicitud . "*";
    }
    if ($estadoAtencion !== "") {
        $lineas[] = "- Estado operativo: " . $estadoAtencion;
    }
    if ($ubicacion !== "") {
        $lineas[] = "- Ubicacion: " . $ubicacion;
    }

    if ($unidad !== "" || $placa !== "" || $chofer !== "") {
        $lineas[] = "";
        $lineas[] = "*Datos de la ambulancia*";
        if ($unidad !== "" || $placa !== "") {
            $lineas[] = "- Unidad: *" . trim($unidad . ($placa !== "" ? " (" . $placa . ")" : "")) . "*";
        }
        if ($chofer !== "") {
            $detalleChofer = "*" . $chofer . "*";
            if ($cedulaChofer !== "") {
                $detalleChofer .= " | CI: " . $cedulaChofer;
            }
            if ($licencia !== "") {
                $detalleChofer .= " | Licencia: " . $licencia;
            }
            $lineas[] = "- Chofer: " . $detalleChofer;
        }
    }

    $lineas[] = "";
    $lineas[] = "Mensaje enviado por *" . obtenerNombreSistemaWhatsapp() . "*.";
    return implode("\n", $lineas);
}

function construirPayloadWhatsappManualDesdeDatos($datos, $escenario, $motivoSinTelefono = "")
{
    if (!is_array($datos)) {
        return array(
            "disponible" => false,
            "escenario" => $escenario,
            "motivo" => "No se pudo cargar la informacion de la solicitud para WhatsApp."
        );
    }

    $telefonoWhatsapp = normalizarTelefonoWhatsapp(isset($datos["telefono"]) ? $datos["telefono"] : "");
    if ($telefonoWhatsapp === "") {
        return array(
            "disponible" => false,
            "escenario" => $escenario,
            "motivo" => $motivoSinTelefono !== "" ? $motivoSinTelefono : "El beneficiario no tiene un telefono valido para WhatsApp."
        );
    }

    $infoEscenario = obtenerEscenarioWhatsapp($escenario);
    $texto = construirMensajeWhatsappPlantilla($datos, $escenario);
    return array(
        "disponible" => true,
        "escenario" => $escenario,
        "titulo" => $infoEscenario["titulo"],
        "telefono" => $telefonoWhatsapp,
        "texto" => $texto,
        "url" => "https://wa.me/" . $telefonoWhatsapp . "?text=" . rawurlencode($texto)
    );
}

function construirPayloadWhatsappManualDesdeSolicitud($serviciosemer, $idSeguridad, $escenario)
{
    $idSeguridad = (int) $idSeguridad;
    if ($idSeguridad <= 0) {
        return null;
    }

    $registro = $serviciosemer->mostrar($idSeguridad);
    if (!$registro || !is_array($registro)) {
        return array(
            "disponible" => false,
            "escenario" => $escenario,
            "motivo" => "No se pudo cargar el detalle de la solicitud para notificar por WhatsApp."
        );
    }

    return construirPayloadWhatsappManualDesdeDatos($registro, $escenario);
}

function guardarArchivoEvidencia($campo)
{
    if (!isset($_FILES[$campo]) || (int) $_FILES[$campo]["error"] !== 0) {
        return "";
    }

    $archivo = $_FILES[$campo];
    $extension = pathinfo($archivo["name"], PATHINFO_EXTENSION);
    $nombreArchivo = "seguridad_" . date("Ymd_His") . "_" . mt_rand(1000, 9999);
    if ($extension !== "") {
        $nombreArchivo .= "." . preg_replace('/[^a-zA-Z0-9]/', '', $extension);
    }

    $directorioRelativo = "uploads/reportes_traslado/";
    $directorioAbsoluto = dirname(__DIR__) . DIRECTORY_SEPARATOR . "uploads" . DIRECTORY_SEPARATOR . "reportes_traslado" . DIRECTORY_SEPARATOR;

    if (!is_dir($directorioAbsoluto)) {
        mkdir($directorioAbsoluto, 0777, true);
    }

    $rutaDestino = $directorioAbsoluto . $nombreArchivo;
    if (!move_uploaded_file($archivo["tmp_name"], $rutaDestino)) {
        return "";
    }

    return $directorioRelativo . $nombreArchivo;
}

function escaparHtmlReporte($valor)
{
    return htmlspecialchars((string) $valor, ENT_QUOTES, "UTF-8");
}

function obtenerBaseUrlSistemaReporte()
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

function renderizarVistaReporteSolicitud($item)
{
    $idSeguridad = isset($item["id_seguridad"]) ? (int) $item["id_seguridad"] : 0;
    $idReporte = isset($item["id_reporte_solicitud"]) ? (int) $item["id_reporte_solicitud"] : 0;
    $tipoReporte = isset($item["tipo_reporte"]) ? (string) $item["tipo_reporte"] : "REGISTRO";
    $rutaRelativa = isset($item["ruta_relativa"]) ? (string) $item["ruta_relativa"] : "";
    $nombreArchivo = isset($item["nombre_archivo"]) ? (string) $item["nombre_archivo"] : "reporte.pdf";
    $extensionArchivo = strtolower((string) pathinfo($nombreArchivo, PATHINFO_EXTENSION));
    $esPdf = $extensionArchivo === "pdf";
    $baseUrl = obtenerBaseUrlSistemaReporte();
    $rutaRelativa = ltrim(str_replace("\\", "/", $rutaRelativa), "/");
    $srcReporte = $baseUrl !== "" ? $baseUrl . "/" . $rutaRelativa : "../" . $rutaRelativa;
    $srcIframe = $esPdf ? $srcReporte . "#toolbar=1&navpanes=0&scrollbar=1" : $srcReporte;
    $urlDescarga = $baseUrl !== ""
        ? $baseUrl . "/ajax/serviciosemergencia.php?op=descargarreporte&id_seguridad=" . $idSeguridad . "&id_reporte_solicitud=" . $idReporte
        : "../ajax/serviciosemergencia.php?op=descargarreporte&id_seguridad=" . $idSeguridad . "&id_reporte_solicitud=" . $idReporte;
    $urlVista = $baseUrl !== ""
        ? $baseUrl . "/ajax/serviciosemergencia.php?op=verreporte&id_seguridad=" . $idSeguridad . "&id_reporte_solicitud=" . $idReporte
        : "../ajax/serviciosemergencia.php?op=verreporte&id_seguridad=" . $idSeguridad . "&id_reporte_solicitud=" . $idReporte;

    header("Content-Type: text/html; charset=utf-8");
    echo "<!doctype html>
<html lang='es'>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>Reporte de solicitud de ambulancia</title>
    <style>
        body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#eef3f8;color:#213447}
        .toolbar{display:flex;gap:8px;align-items:center;justify-content:space-between;flex-wrap:wrap;padding:10px 14px;border-bottom:1px solid #d2dbe5;background:#fff}
        .badge{display:inline-block;padding:4px 10px;border-radius:999px;background:#dceeff;color:#14517f;font-size:.8rem;font-weight:700}
        .btn{display:inline-block;padding:8px 12px;border-radius:8px;text-decoration:none;font-size:.86rem;font-weight:700;border:1px solid #2a6ea3;background:#2a6ea3;color:#fff}
        .btn-outline{background:#fff;color:#2a6ea3}
        .meta{font-size:.85rem;color:#5a6f83}
        .url{margin-top:4px;font-size:.78rem;color:#4a6177;word-break:break-all}
        .frame-wrap{padding:10px}
        iframe{width:100%;height:calc(100vh - 86px);border:1px solid #d3dde8;border-radius:10px;background:#fff}
    </style>
</head>
<body>
    <div class='toolbar'>
        <div>
            <div><strong>Reporte de solicitud ambulancia</strong></div>
            <div class='meta'>Archivo: " . escaparHtmlReporte($nombreArchivo) . " | Ticket ID solicitud: " . escaparHtmlReporte($idSeguridad) . " | <span class='badge'>" . escaparHtmlReporte($tipoReporte) . "</span></div>
            <div class='url'>URL: <a href='" . escaparHtmlReporte($urlVista) . "' target='_blank' rel='noopener noreferrer'>" . escaparHtmlReporte($urlVista) . "</a></div>
        </div>
        <div>
            <a class='btn btn-outline' href='" . escaparHtmlReporte($srcReporte) . "' target='_blank' rel='noopener noreferrer'>" . ($esPdf ? "Abrir PDF" : "Abrir archivo") . "</a>
            <a class='btn' href='" . escaparHtmlReporte($urlDescarga) . "'>" . ($esPdf ? "Descargar PDF" : "Descargar") . "</a>
        </div>
    </div>
    <div class='frame-wrap'>
        <iframe src='" . escaparHtmlReporte($srcIframe) . "' title='Reporte solicitud ambulancia'></iframe>
    </div>
</body>
</html>";
    exit;
}

$op = isset($_GET["op"]) ? $_GET["op"] : "";

switch ($op) {
    case "guardaryeditar":
        if ($idBeneficiario === "" || $idTipoSeguridad === "" || $idSolicitudSeguridad === "" || $fechaSeguridad === "" || $ubicacionEvento === "") {
            responderJson(false, "Debe completar los campos obligatorios.");
        }

        $fechaSeguridad = normalizarFechaHora($fechaSeguridad);

        $resultado = $serviciosemer->guardarSolicitud(
            $idSeguridad,
            $idBeneficiario,
            $idUsuario,
            $idTipoSeguridad,
            $idSolicitudSeguridad,
            $fechaSeguridad,
            $descripcion,
            $ubicacionEvento,
            $referenciaEvento,
            isset($_POST["id_asignacion_preferida"]) ? limpiarCadena($_POST["id_asignacion_preferida"]) : 0,
            $enviarReporteChofer
        );

        if ($resultado["ok"]) {
            $detalle = ($idSeguridad === "" ? "INSERTAR" : "ACTUALIZAR") .
                " Seguridad y Emergencia - Ticket: " . $resultado["ticket_interno"] .
                " - Estado: " . $resultado["estado_atencion"];
            registrarBitacoraOperacion($idUsuario, $detalle);

            $idSeguridadNotificacion = isset($resultado["id_seguridad"]) ? (int) $resultado["id_seguridad"] : (int) $idSeguridad;
            $escenarioWhatsapp = "";
            if (isset($resultado["requiere_ambulancia"]) && (int) $resultado["requiere_ambulancia"] === 1) {
                $estadoOperacion = isset($resultado["estado_atencion"]) ? strtoupper(trim((string) $resultado["estado_atencion"])) : "";
                if ($estadoOperacion === "DESPACHADO") {
                    $escenarioWhatsapp = "AMBULANCIA_DESPACHADA";
                } elseif ($estadoOperacion === "PENDIENTE_UNIDAD") {
                    $escenarioWhatsapp = "REGISTRO_PENDIENTE_UNIDAD";
                } else {
                    $escenarioWhatsapp = "REGISTRO_AMBULANCIA";
                }
            }

            if ($escenarioWhatsapp !== "" && $idSeguridadNotificacion > 0) {
                $resultado["whatsapp"] = construirPayloadWhatsappManualDesdeSolicitud($serviciosemer, $idSeguridadNotificacion, $escenarioWhatsapp);
            }
        }

        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "mostrar":
        if ($idSeguridad === "") {
            responderJson(false, "Solicitud no especificada.");
        }

        $registro = $serviciosemer->mostrar($idSeguridad);
        if (!$registro) {
            responderJson(false, "No se encontro la solicitud.");
        }

        responderJson(true, "Registro cargado.", $registro);
    break;

    case "listar":
        $rspta = $serviciosemer->listar();
        $data = array();

        while ($reg = $rspta->fetch_object()) {
            $id = (int) $reg->id_seguridad;
            $estado = (int) $reg->estado;
            $estadoAtencion = (string) $reg->estado_atencion;
            $requiereAmbulancia = (int) $reg->requiere_ambulancia === 1;
            $idReporteSolicitud = isset($reg->id_reporte_solicitud) ? (int) $reg->id_reporte_solicitud : 0;
            $tipoReporteSolicitud = isset($reg->tipo_reporte_solicitud) ? (string) $reg->tipo_reporte_solicitud : "";
            $estadoEnvioReporte = isset($reg->estado_envio_reporte) ? strtoupper(trim((string) $reg->estado_envio_reporte)) : "NO_APLICA";

            $acciones = array();
            $acciones[] = '<button type="button" class="btn btn-sm btn-outline-primary js-editar" data-id="' . $id . '" title="Editar"><i class="fas fa-pen"></i></button>';
            if (!$requiereAmbulancia) {
                $acciones[] = '<button type="button" class="btn btn-sm btn-outline-success js-gestionar-estado" data-id="' . $id . '" title="Gestionar estado de solicitud"><i class="fas fa-clipboard-check"></i></button>';
            }

            if ($requiereAmbulancia && $estadoAtencion === "PENDIENTE_UNIDAD") {
                $acciones[] = '<button type="button" class="btn btn-sm btn-outline-warning js-asignar" data-id="' . $id . '" title="Asignar ambulancia"><i class="fas fa-ambulance"></i></button>';
            }

            if ($estadoAtencion === "DESPACHADO") {
                $acciones[] = '<button type="button" class="btn btn-sm btn-outline-success js-cerrar" data-id="' . $id . '" title="Cerrar despacho"><i class="fas fa-clipboard-check"></i></button>';
            }

            if ($idReporteSolicitud > 0) {
                $esReporteCierre = strtoupper($tipoReporteSolicitud) === "CIERRE";
                $tipoReporteSeguro = htmlspecialchars($esReporteCierre ? "CIERRE" : "REGISTRO", ENT_QUOTES, "UTF-8");
                $estadoEnvioSeguro = htmlspecialchars($estadoEnvioReporte, ENT_QUOTES, "UTF-8");
                $tituloReporte = $esReporteCierre ? "Ver reporte de cierre" : "Ver reporte de solicitud";
                $acciones[] = '<button type="button" class="btn btn-sm btn-outline-info js-ver-reporte" data-id="' . $id . '" data-reporte="' . $idReporteSolicitud . '" title="' . htmlspecialchars($tituloReporte, ENT_QUOTES, "UTF-8") . '"><i class="fas fa-file-alt"></i></button>';

                $esEnviado = $estadoEnvioReporte === "ENVIADO";
                $tituloReenvio = $esEnviado
                    ? ($esReporteCierre ? "Reenviar correo del reporte de cierre al chofer" : "Reenviar correo del reporte de solicitud al chofer")
                    : ($esReporteCierre ? "Enviar correo del reporte de cierre al chofer" : "Enviar correo del reporte de solicitud al chofer");
                $claseReenvio = $esEnviado ? "btn-outline-primary" : "btn-outline-warning";
                $iconoReenvio = $esEnviado ? "fas fa-paper-plane" : "fas fa-envelope";
                $acciones[] = '<button type="button" class="btn btn-sm ' . $claseReenvio . ' js-reenviar-reporte" data-id="' . $id . '" data-reporte="' . $idReporteSolicitud . '" data-tipo="' . $tipoReporteSeguro . '" data-estado-envio="' . $estadoEnvioSeguro . '" title="' . htmlspecialchars($tituloReenvio, ENT_QUOTES, "UTF-8") . '"><i class="' . $iconoReenvio . '"></i></button>';
            }

            $escenarioFilaWhatsapp = "";
            if ($requiereAmbulancia && $estadoAtencion === "DESPACHADO") {
                $escenarioFilaWhatsapp = "AMBULANCIA_DESPACHADA";
            } elseif ($requiereAmbulancia && $estadoAtencion === "PENDIENTE_UNIDAD") {
                $escenarioFilaWhatsapp = "REGISTRO_PENDIENTE_UNIDAD";
            } elseif ($requiereAmbulancia && $estadoAtencion === "FINALIZADO") {
                $escenarioFilaWhatsapp = "SOLICITUD_FINALIZADA";
            }

            if ($escenarioFilaWhatsapp !== "") {
                $payloadWhatsappFila = construirPayloadWhatsappManualDesdeDatos(array(
                    "nacionalidad" => isset($reg->nacionalidad) ? $reg->nacionalidad : "",
                    "cedula" => isset($reg->cedula) ? $reg->cedula : "",
                    "nombre_beneficiario" => isset($reg->nombre_beneficiario) ? $reg->nombre_beneficiario : "",
                    "beneficiario" => trim((string) $reg->nacionalidad . "-" . $reg->cedula . " " . $reg->nombre_beneficiario),
                    "telefono" => isset($reg->telefono) ? $reg->telefono : "",
                    "ticket_interno" => isset($reg->ticket_interno) ? $reg->ticket_interno : "",
                    "tipo_seguridad" => isset($reg->tipo_seguridad) ? $reg->tipo_seguridad : "",
                    "tipo_solicitud" => isset($reg->tipo_solicitud) ? $reg->tipo_solicitud : "",
                    "estado_solicitud" => isset($reg->estado_solicitud) ? $reg->estado_solicitud : "",
                    "estado_atencion" => $estadoAtencion,
                    "ubicacion_evento" => isset($reg->ubicacion_evento) ? $reg->ubicacion_evento : "",
                    "codigo_unidad" => isset($reg->codigo_unidad) ? $reg->codigo_unidad : "",
                    "placa" => isset($reg->placa) ? $reg->placa : "",
                    "nombre_chofer" => isset($reg->nombre_chofer) ? $reg->nombre_chofer : "",
                    "cedula_chofer" => isset($reg->cedula_chofer) ? $reg->cedula_chofer : "",
                    "numero_licencia" => isset($reg->numero_licencia) ? $reg->numero_licencia : ""
                ), $escenarioFilaWhatsapp);

                if ($payloadWhatsappFila && isset($payloadWhatsappFila["disponible"]) && $payloadWhatsappFila["disponible"] === true) {
                    $acciones[] = '<button type="button" class="btn btn-sm btn-outline-success js-notificar-whatsapp" data-url="' . htmlspecialchars($payloadWhatsappFila["url"], ENT_QUOTES, "UTF-8") . '" title="Notificar beneficiario por WhatsApp (manual)"><i class="fab fa-whatsapp"></i></button>';
                }
            }

            if ($estadoAtencion !== "DESPACHADO") {
                $acciones[] = '<button type="button" class="btn btn-sm btn-outline-danger js-eliminar" data-id="' . $id . '" title="Eliminar"><i class="fas fa-trash-alt"></i></button>';
            }

            $beneficiario = trim((string) $reg->nacionalidad . "-" . $reg->cedula . " " . $reg->nombre_beneficiario);
            $beneficiario = htmlspecialchars($beneficiario !== "-" ? $beneficiario : "Beneficiario no disponible", ENT_QUOTES, "UTF-8");

            $ambulancia = "No aplica";
            if ($requiereAmbulancia && trim((string) $reg->codigo_unidad) !== "") {
                $ambulancia = htmlspecialchars($reg->codigo_unidad . " / " . $reg->placa, ENT_QUOTES, "UTF-8");
            } elseif ($requiereAmbulancia) {
                $ambulancia = '<span class="text-warning">Pendiente por asignar</span>';
            }

            $chofer = "No aplica";
            if ($requiereAmbulancia && trim((string) $reg->nombre_chofer) !== "") {
                $chofer = htmlspecialchars($reg->nombre_chofer . " / Lic. " . $reg->numero_licencia, ENT_QUOTES, "UTF-8");
            } elseif ($requiereAmbulancia) {
                $chofer = '<span class="text-muted">Sin chofer asignado</span>';
            }

            $ubicacion = htmlspecialchars((string) $reg->ubicacion_evento, ENT_QUOTES, "UTF-8");
            if ($ubicacion === "") {
                $ubicacion = '<span class="text-muted">Sin ubicacion</span>';
            }

            $data[] = array(
                "beneficiario" => $beneficiario,
                "tipo_seguridad" => htmlspecialchars((string) $reg->tipo_seguridad, ENT_QUOTES, "UTF-8"),
                "tipo_solicitud" => htmlspecialchars((string) $reg->tipo_solicitud, ENT_QUOTES, "UTF-8"),
                "fecha_seguridad" => htmlspecialchars((string) $reg->fecha_seguridad_formateada, ENT_QUOTES, "UTF-8"),
                "ticket_interno" => htmlspecialchars((string) $reg->ticket_interno, ENT_QUOTES, "UTF-8"),
                "ambulancia" => $ambulancia,
                "chofer" => $chofer,
                "ubicacion_evento" => $ubicacion,
                "telefono" => construirTelefonoHtml($reg->telefono),
                "estado_solicitud" => badgeEstadoSolicitud($reg->estado_solicitud, $reg->clase_badge_estado_solicitud, $estadoAtencion),
                "acciones" => '<div class="d-flex justify-content-end flex-nowrap emergency-actions">' . implode("", $acciones) . '</div>'
            );
        }

        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array(
            "sEcho" => 1,
            "iTotalRecords" => count($data),
            "iTotalDisplayRecords" => count($data),
            "aaData" => $data
        ));
    break;

    case "resumen":
        $resumen = $serviciosemer->resumen();
        responderJson(true, "Resumen cargado.", array(
            "total" => isset($resumen["total"]) ? (int) $resumen["total"] : 0,
            "pendientes_unidad" => isset($resumen["pendientes_unidad"]) ? (int) $resumen["pendientes_unidad"] : 0,
            "despachados" => isset($resumen["despachados"]) ? (int) $resumen["despachados"] : 0,
            "finalizadas" => isset($resumen["finalizadas"]) ? (int) $resumen["finalizadas"] : 0,
            "registrados" => isset($resumen["registrados"]) ? (int) $resumen["registrados"] : 0,
            "unidades_disponibles" => isset($resumen["unidades_disponibles"]) ? (int) $resumen["unidades_disponibles"] : 0
        ));
    break;

    case "actualizarestadosolicitud":
        if ($idSeguridad === "" || $idEstadoSolicitud === "") {
            responderJson(false, "Debe indicar la solicitud y el estado a registrar.");
        }

        $resultado = $serviciosemer->actualizarEstadoSolicitudManual(
            $idSeguridad,
            $idEstadoSolicitud,
            $idUsuario,
            $fechaEstadoSolicitud,
            $observacionEstadoSolicitud
        );
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "GESTIONAR estado de solicitud de seguridad ID $idSeguridad");

            $codigoEstadoSolicitud = isset($resultado["codigo_estado_solicitud"]) ? strtoupper(trim((string) $resultado["codigo_estado_solicitud"])) : "";
            $escenarioWhatsapp = "";
            if ($codigoEstadoSolicitud === "EN_GESTION") {
                $escenarioWhatsapp = "SOLICITUD_EN_REVISION";
            } elseif ($codigoEstadoSolicitud === "ATENDIDA") {
                $escenarioWhatsapp = "SOLICITUD_ATENDIDA";
            } elseif ($codigoEstadoSolicitud === "NO_ATENDIDA") {
                $escenarioWhatsapp = "SOLICITUD_NO_ATENDIDA";
            }

            if ($escenarioWhatsapp !== "") {
                $resultado["whatsapp"] = construirPayloadWhatsappManualDesdeSolicitud($serviciosemer, (int) $idSeguridad, $escenarioWhatsapp);
            }
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "anular":
        $resultado = $serviciosemer->anularSolicitud($idSeguridad);
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "SOFTDELETE Seguridad y Emergencia ID $idSeguridad");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "activar":
        $resultado = $serviciosemer->reactivarSolicitud($idSeguridad, $idUsuario);
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "REACTIVAR Seguridad y Emergencia ID $idSeguridad");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "finalizar":
        $resultado = $serviciosemer->finalizarSolicitud($idSeguridad);
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "FINALIZAR Seguridad y Emergencia ID $idSeguridad");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "listarbeneficiarios":
        $term = isset($_GET["term"]) ? limpiarCadena($_GET["term"]) : "";
        $rspta = $serviciosemer->listarBeneficiarios($term);
        $items = array();
        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id" => (int) $reg->id_beneficiario,
                "text" => $reg->nacionalidad . "-" . $reg->cedula . " " . $reg->nombre_beneficiario,
                "telefono" => $reg->telefono
            );
        }
        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "listartiposseguridad":
        $rspta = $serviciosemer->listarTiposSeguridad();
        $items = array();
        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id" => (int) $reg->id_tipo_seguridad,
                "text" => $reg->nombre_tipo,
                "requiere_ambulancia" => (int) $reg->requiere_ambulancia
            );
        }
        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "listarsolicitudesseguridad":
        $rspta = $serviciosemer->listarSolicitudesSeguridad();
        $items = array();
        while ($reg = $rspta->fetch_object()) {
            $items[] = array("id" => (int) $reg->id_solicitud_seguridad, "text" => $reg->nombre_solicitud);
        }
        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "listarestadossolicitud":
        $rspta = $serviciosemer->listarEstadosSolicitud();
        $items = array();
        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id" => (int) $reg->id_estado_solicitud,
                "text" => $reg->nombre_estado,
                "codigo" => $reg->codigo_estado,
                "clase_badge" => $reg->clase_badge,
                "es_atendida" => (int) $reg->es_atendida
            );
        }
        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "sugerirdespacho":
        $tipo = isset($_GET["id_tipo_seguridad"]) ? limpiarCadena($_GET["id_tipo_seguridad"]) : "";
        $resultado = $serviciosemer->sugerirDespacho($tipo);
        responderJson($resultado["ok"], isset($resultado["msg"]) ? $resultado["msg"] : "Consulta realizada.", $resultado);
    break;

    case "listarempleados":
        $term = isset($_GET["term"]) ? limpiarCadena($_GET["term"]) : "";
        $rspta = $serviciosemer->listarEmpleadosOperativos($term);
        $items = array();
        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id" => (int) $reg->id_empleado,
                "text" => $reg->cedula . " - " . $reg->nombre_completo,
                "dependencia" => $reg->nombre_dependencia,
                "cedula" => $reg->cedula,
                "nombre_completo" => $reg->nombre_completo,
                "id_chofer_ambulancia" => !empty($reg->id_chofer_ambulancia) ? (int) $reg->id_chofer_ambulancia : 0,
                "chofer_registrado" => !empty($reg->id_chofer_ambulancia),
                "estado_chofer" => isset($reg->estado_chofer) ? (int) $reg->estado_chofer : null,
                "numero_licencia" => $reg->numero_licencia,
                "categoria_licencia" => $reg->categoria_licencia,
                "vencimiento_licencia" => $reg->vencimiento_licencia,
                "contacto_emergencia" => $reg->contacto_emergencia,
                "telefono_contacto_emergencia" => $reg->telefono_contacto_emergencia,
                "observaciones" => $reg->observaciones
            );
        }
        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "listarchoferes":
        $soloDisponibles = isset($_GET["solo_disponibles"]) && (int) $_GET["solo_disponibles"] === 1;
        $rspta = $serviciosemer->listarChoferesAmbulancia($soloDisponibles);
        $items = array();
        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id" => (int) $reg->id_chofer_ambulancia,
                "text" => $reg->cedula . " - " . $reg->nombre_chofer,
                "id_empleado" => (int) $reg->id_empleado,
                "cedula" => $reg->cedula,
                "nombre_chofer" => $reg->nombre_chofer,
                "licencia" => $reg->numero_licencia,
                "categoria" => $reg->categoria_licencia,
                "vencimiento" => $reg->vencimiento_licencia,
                "contacto_emergencia" => $reg->contacto_emergencia,
                "telefono_contacto_emergencia" => $reg->telefono_contacto_emergencia,
                "observaciones" => $reg->observaciones,
                "asignado" => !empty($reg->id_asignacion_unidad_chofer),
                "id_unidad" => !empty($reg->id_unidad) ? (int) $reg->id_unidad : 0,
                "codigo_unidad" => $reg->codigo_unidad,
                "placa" => $reg->placa,
                "estado_unidad" => $reg->estado_unidad,
                "ticket_interno" => $reg->ticket_interno
            );
        }
        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "listarunidades":
        $rspta = $serviciosemer->listarUnidades();
        $items = array();
        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id" => (int) $reg->id_unidad,
                "text" => $reg->codigo_unidad . " - " . $reg->placa,
                "estado_operativo" => $reg->estado_operativo,
                "ubicacion_actual" => $reg->ubicacion_actual
            );
        }
        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "guardarchofer":
        if (
            !isset($_POST["id_empleado"], $_POST["numero_licencia"], $_POST["categoria_licencia"], $_POST["vencimiento_licencia"], $_POST["contacto_emergencia"], $_POST["telefono_contacto_emergencia"]) ||
            trim((string) $_POST["id_empleado"]) === "" ||
            trim((string) $_POST["numero_licencia"]) === "" ||
            trim((string) $_POST["categoria_licencia"]) === "" ||
            trim((string) $_POST["vencimiento_licencia"]) === "" ||
            trim((string) $_POST["contacto_emergencia"]) === "" ||
            trim((string) $_POST["telefono_contacto_emergencia"]) === ""
        ) {
            responderJson(false, "Debe completar los datos principales del chofer.");
        }

        $resultado = $serviciosemer->guardarChoferAmbulancia(
            isset($_POST["id_empleado"]) ? limpiarCadena($_POST["id_empleado"]) : "",
            isset($_POST["numero_licencia"]) ? limpiarCadena($_POST["numero_licencia"]) : "",
            isset($_POST["categoria_licencia"]) ? limpiarCadena($_POST["categoria_licencia"]) : "",
            isset($_POST["vencimiento_licencia"]) ? limpiarCadena($_POST["vencimiento_licencia"]) : "",
            isset($_POST["contacto_emergencia"]) ? limpiarCadena($_POST["contacto_emergencia"]) : "",
            isset($_POST["telefono_contacto_emergencia"]) ? limpiarCadena($_POST["telefono_contacto_emergencia"]) : "",
            isset($_POST["observaciones_chofer"]) ? limpiarCadena($_POST["observaciones_chofer"]) : "",
            isset($_POST["id_unidad_asignada"]) ? limpiarCadena($_POST["id_unidad_asignada"]) : ""
        );
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "GUARDAR perfil operativo de chofer");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "desactivarchofer":
        if (!isset($_POST["id_chofer_ambulancia"]) || trim((string) $_POST["id_chofer_ambulancia"]) === "") {
            responderJson(false, "Debe indicar el chofer que desea desactivar.");
        }

        $resultado = $serviciosemer->desactivarChoferAmbulancia(
            isset($_POST["id_chofer_ambulancia"]) ? limpiarCadena($_POST["id_chofer_ambulancia"]) : ""
        );
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "DESACTIVAR perfil operativo de chofer");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "guardarasignacionoperativa":
        if (
            !isset($_POST["id_unidad"], $_POST["id_chofer_ambulancia"], $_POST["fecha_inicio"], $_POST["ubicacion_actual"], $_POST["prioridad_despacho"]) ||
            trim((string) $_POST["id_unidad"]) === "" ||
            trim((string) $_POST["id_chofer_ambulancia"]) === "" ||
            trim((string) $_POST["fecha_inicio"]) === "" ||
            trim((string) $_POST["ubicacion_actual"]) === "" ||
            trim((string) $_POST["prioridad_despacho"]) === ""
        ) {
            responderJson(false, "Debe completar los datos de la asignacion operativa.");
        }

        $resultado = $serviciosemer->guardarAsignacionOperativa(
            isset($_POST["id_unidad"]) ? limpiarCadena($_POST["id_unidad"]) : "",
            isset($_POST["id_chofer_ambulancia"]) ? limpiarCadena($_POST["id_chofer_ambulancia"]) : "",
            isset($_POST["fecha_inicio"]) ? normalizarFechaHora(limpiarCadena($_POST["fecha_inicio"])) : "",
            isset($_POST["ubicacion_actual"]) ? limpiarCadena($_POST["ubicacion_actual"]) : "",
            isset($_POST["referencia_actual"]) ? limpiarCadena($_POST["referencia_actual"]) : "",
            isset($_POST["prioridad_despacho"]) ? limpiarCadena($_POST["prioridad_despacho"]) : "100",
            isset($_POST["estado_operativo"]) ? limpiarCadena($_POST["estado_operativo"]) : "DISPONIBLE",
            isset($_POST["observaciones_asignacion"]) ? limpiarCadena($_POST["observaciones_asignacion"]) : ""
        );
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "GUARDAR asignacion operativa de ambulancia");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "actualizarunidadoperativa":
        if (
            !isset($_POST["id_unidad"], $_POST["estado_operativo"], $_POST["ubicacion_actual"], $_POST["prioridad_despacho"]) ||
            trim((string) $_POST["id_unidad"]) === "" ||
            trim((string) $_POST["estado_operativo"]) === "" ||
            trim((string) $_POST["ubicacion_actual"]) === "" ||
            trim((string) $_POST["prioridad_despacho"]) === ""
        ) {
            responderJson(false, "Debe completar los datos del control de unidad.");
        }

        $resultado = $serviciosemer->actualizarUnidadOperativa(
            isset($_POST["id_unidad"]) ? limpiarCadena($_POST["id_unidad"]) : "",
            isset($_POST["estado_operativo"]) ? limpiarCadena($_POST["estado_operativo"]) : "DISPONIBLE",
            isset($_POST["ubicacion_actual"]) ? limpiarCadena($_POST["ubicacion_actual"]) : "",
            isset($_POST["referencia_actual"]) ? limpiarCadena($_POST["referencia_actual"]) : "",
            isset($_POST["prioridad_despacho"]) ? limpiarCadena($_POST["prioridad_despacho"]) : "100"
        );
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "ACTUALIZAR estado operativo de ambulancia");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "guardarunidadoperativa":
        if (
            !isset($_POST["codigo_unidad"], $_POST["descripcion"], $_POST["placa"], $_POST["estado_operativo"], $_POST["ubicacion_actual"], $_POST["prioridad_despacho"]) ||
            trim((string) $_POST["codigo_unidad"]) === "" ||
            trim((string) $_POST["descripcion"]) === "" ||
            trim((string) $_POST["placa"]) === "" ||
            trim((string) $_POST["estado_operativo"]) === "" ||
            trim((string) $_POST["ubicacion_actual"]) === "" ||
            trim((string) $_POST["prioridad_despacho"]) === ""
        ) {
            responderJson(false, "Debe completar los datos principales de la unidad.");
        }

        $resultado = $serviciosemer->guardarUnidadOperativa(
            isset($_POST["id_unidad"]) ? limpiarCadena($_POST["id_unidad"]) : "",
            isset($_POST["codigo_unidad"]) ? limpiarCadena($_POST["codigo_unidad"]) : "",
            isset($_POST["descripcion"]) ? limpiarCadena($_POST["descripcion"]) : "",
            isset($_POST["placa"]) ? limpiarCadena($_POST["placa"]) : "",
            isset($_POST["estado_operativo"]) ? limpiarCadena($_POST["estado_operativo"]) : "DISPONIBLE",
            isset($_POST["ubicacion_actual"]) ? limpiarCadena($_POST["ubicacion_actual"]) : "",
            isset($_POST["referencia_actual"]) ? limpiarCadena($_POST["referencia_actual"]) : "",
            isset($_POST["prioridad_despacho"]) ? limpiarCadena($_POST["prioridad_despacho"]) : "1"
        );
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "GUARDAR unidad operativa de ambulancia");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "listaroperativo":
        $rspta = $serviciosemer->listarOperativoUnidades();
        $items = array();
        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id_unidad" => (int) $reg->id_unidad,
                "codigo_unidad" => $reg->codigo_unidad,
                "descripcion" => $reg->descripcion,
                "placa" => $reg->placa,
                "estado_operativo" => $reg->estado_operativo,
                "ubicacion_actual" => $reg->ubicacion_actual,
                "referencia_actual" => $reg->referencia_actual,
                "prioridad_despacho" => (int) $reg->prioridad_despacho,
                "id_asignacion_unidad_chofer" => !empty($reg->id_asignacion_unidad_chofer) ? (int) $reg->id_asignacion_unidad_chofer : 0,
                "id_chofer_ambulancia" => !empty($reg->id_chofer_ambulancia) ? (int) $reg->id_chofer_ambulancia : 0,
                "nombre_chofer" => $reg->nombre_chofer,
                "cedula_chofer" => $reg->cedula_chofer,
                "telefono_chofer" => $reg->telefono_chofer,
                "numero_licencia" => $reg->numero_licencia,
                "categoria_licencia" => $reg->categoria_licencia,
                "ticket_interno" => $reg->ticket_interno
            );
        }
        responderJson(true, "Operativo cargado.", array("items" => $items));
    break;

    case "listarasignacionesdisponibles":
        $rspta = $serviciosemer->listarAsignacionesDisponibles();
        $items = array();
        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id" => (int) $reg->id_asignacion_unidad_chofer,
                "text" => $reg->codigo_unidad . " / " . $reg->placa . " / " . $reg->nombre_chofer,
                "unidad" => array(
                    "codigo_unidad" => $reg->codigo_unidad,
                    "placa" => $reg->placa,
                    "descripcion_unidad" => $reg->descripcion_unidad,
                    "ubicacion_actual" => $reg->ubicacion_actual,
                    "referencia_actual" => $reg->referencia_actual
                ),
                "chofer" => array(
                    "nombre_chofer" => $reg->nombre_chofer,
                    "cedula_chofer" => $reg->cedula_chofer,
                    "numero_licencia" => $reg->numero_licencia
                )
            );
        }
        responderJson(true, "Asignaciones disponibles cargadas.", array("items" => $items));
    break;

    case "asignarmanual":
        if (!isset($_POST["id_asignacion_unidad_chofer"]) || trim((string) $_POST["id_asignacion_unidad_chofer"]) === "") {
            responderJson(false, "Debe seleccionar una unidad disponible.");
        }

        $resultado = $serviciosemer->asignarManual(
            $idSeguridad,
            isset($_POST["id_asignacion_unidad_chofer"]) ? limpiarCadena($_POST["id_asignacion_unidad_chofer"]) : "",
            $idUsuario,
            isset($_POST["observaciones_manual"]) ? limpiarCadena($_POST["observaciones_manual"]) : ""
        );
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "ASIGNAR manualmente ambulancia a solicitud ID $idSeguridad");
            $resultado["whatsapp"] = construirPayloadWhatsappManualDesdeSolicitud($serviciosemer, (int) $idSeguridad, "AMBULANCIA_DESPACHADA");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "mostrardespachoactivo":
        $registro = $serviciosemer->obtenerDespachoActivo($idSeguridad);
        if (!$registro) {
            responderJson(false, "No existe un despacho activo para esta solicitud.");
        }
        responderJson(true, "Despacho cargado.", $registro);
    break;

    case "cerrardespacho":
        if (!isset($_POST["fecha_cierre"], $_POST["ubicacion_cierre"]) || trim((string) $_POST["fecha_cierre"]) === "" || trim((string) $_POST["ubicacion_cierre"]) === "") {
            responderJson(false, "Debe completar la informacion de cierre.");
        }

        $rutaFoto = guardarArchivoEvidencia("evidencia_foto");
        $resultado = $serviciosemer->cerrarDespacho(
            $idSeguridad,
            $idUsuario,
            isset($_POST["fecha_cierre"]) ? normalizarFechaHora(limpiarCadena($_POST["fecha_cierre"])) : date("Y-m-d H:i:s"),
            isset($_POST["diagnostico_paciente"]) ? limpiarCadena($_POST["diagnostico_paciente"]) : "",
            $rutaFoto,
            isset($_POST["km_salida"]) ? limpiarCadena($_POST["km_salida"]) : 0,
            isset($_POST["km_llegada"]) ? limpiarCadena($_POST["km_llegada"]) : 0,
            isset($_POST["estado_unidad_final"]) ? limpiarCadena($_POST["estado_unidad_final"]) : "DISPONIBLE",
            isset($_POST["ubicacion_cierre"]) ? limpiarCadena($_POST["ubicacion_cierre"]) : "",
            isset($_POST["referencia_cierre"]) ? limpiarCadena($_POST["referencia_cierre"]) : "",
            $enviarReporteChofer
        );
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "CERRAR despacho de Seguridad y Emergencia ID $idSeguridad");
            $resultado["whatsapp"] = construirPayloadWhatsappManualDesdeSolicitud($serviciosemer, (int) $idSeguridad, "SOLICITUD_FINALIZADA");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "enviarreportechofer":
        if ($idSeguridad === "") {
            responderJson(false, "Solicitud no especificada.");
        }

        $resultado = $serviciosemer->reenviarReporteSolicitudChofer($idSeguridad, $idReporteSolicitud);
        if ($resultado["ok"]) {
            registrarBitacoraOperacion($idUsuario, "REENVIAR reporte al correo del chofer en solicitud ID $idSeguridad");
        }
        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "verreporte":
        if ($idSeguridad === "") {
            header("Content-Type: text/html; charset=utf-8");
            echo "<h3>Solicitud no especificada.</h3>";
            exit;
        }

        $resultado = $serviciosemer->obtenerReporteSolicitud($idSeguridad, $idReporteSolicitud);
        if (!$resultado["ok"]) {
            header("Content-Type: text/html; charset=utf-8");
            echo "<h3>No se pudo visualizar el reporte.</h3><p>" . escaparHtmlReporte($resultado["msg"]) . "</p>";
            exit;
        }

        renderizarVistaReporteSolicitud($resultado["item"]);
    break;

    case "descargarreporte":
        if ($idSeguridad === "") {
            responderJson(false, "Solicitud no especificada.");
        }

        $resultado = $serviciosemer->obtenerReporteSolicitud($idSeguridad, $idReporteSolicitud);
        if (!$resultado["ok"] || !isset($resultado["item"])) {
            responderJson(false, $resultado["msg"]);
        }

        $item = $resultado["item"];
        $rutaAbsoluta = isset($item["ruta_absoluta"]) ? (string) $item["ruta_absoluta"] : "";
        if ($rutaAbsoluta === "" || !is_file($rutaAbsoluta)) {
            responderJson(false, "El archivo del reporte no esta disponible para descargar.");
        }

        $nombreArchivo = isset($item["nombre_archivo"]) ? (string) $item["nombre_archivo"] : "reporte_solicitud_ambulancia.pdf";
        $nombreDescarga = preg_replace('/[^A-Za-z0-9_\.\-]/', "_", $nombreArchivo);
        if ($nombreDescarga === "") {
            $nombreDescarga = "reporte_solicitud_ambulancia.pdf";
        }

        $extensionArchivo = strtolower((string) pathinfo($nombreDescarga, PATHINFO_EXTENSION));
        $contentType = "application/octet-stream";
        if ($extensionArchivo === "pdf") {
            $contentType = "application/pdf";
        } elseif ($extensionArchivo === "html" || $extensionArchivo === "htm") {
            $contentType = "text/html; charset=utf-8";
        }

        header("Content-Description: File Transfer");
        header("Content-Type: " . $contentType);
        header("Content-Transfer-Encoding: binary");
        header("Content-Disposition: attachment; filename=\"" . $nombreDescarga . "\"");
        header("Content-Length: " . filesize($rutaAbsoluta));
        readfile($rutaAbsoluta);
        exit;
    break;

    default:
        responderJson(false, "Operacion no soportada.");
    break;
}
?>
