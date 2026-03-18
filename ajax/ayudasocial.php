<?php
session_start();
require_once "../modelos/Ayudasocial.php";

$ayudasocial = new Ayudasocial();

$idayuda = isset($_POST["idayuda"]) ? limpiarCadena($_POST["idayuda"]) : "";
$id_tipo_ayuda_social = isset($_POST["id_tipo_ayuda_social"]) ? limpiarCadena($_POST["id_tipo_ayuda_social"]) : "";
$id_solicitud_ayuda_social = isset($_POST["id_solicitud_ayuda_social"]) ? limpiarCadena($_POST["id_solicitud_ayuda_social"]) : "";
$fecha_ayuda = isset($_POST["fecha_ayuda"]) ? limpiarCadena($_POST["fecha_ayuda"]) : "";
$descripcion = isset($_POST["descripcion"]) ? limpiarCadena($_POST["descripcion"]) : "";
$id_beneficiario = isset($_POST["id_beneficiario"]) ? limpiarCadena($_POST["id_beneficiario"]) : "";
$id_estado_solicitud = isset($_POST["id_estado_solicitud"]) ? limpiarCadena($_POST["id_estado_solicitud"]) : "";
$fecha_estado_solicitud = isset($_POST["fecha_estado_solicitud"]) ? limpiarCadena($_POST["fecha_estado_solicitud"]) : "";
$observacion_estado_solicitud = isset($_POST["observacion_estado_solicitud"]) ? limpiarCadena($_POST["observacion_estado_solicitud"]) : "";
$id_usuario = isset($_SESSION["idusuario"]) ? $_SESSION["idusuario"] : "";

function responderJson($ok, $msg, $data = null)
{
    header("Content-Type: application/json; charset=utf-8");
    echo json_encode(array("ok" => $ok, "msg" => $msg, "data" => $data));
    exit;
}

function registrarBitacoraOperacion($idUsuario, $detalle)
{
    if ($idUsuario === "") {
        return;
    }

    require_once "../modelos/Bitacora.php";
    $bitacora = new Bitacora();
    $bitacora->insertar($idUsuario, $detalle);
}

function badgeEstadoSolicitudGestion($nombreEstado, $claseBadge)
{
    $nombreEstado = trim((string) $nombreEstado);
    $claseBadge = preg_replace('/[^a-z0-9_-]/i', '', (string) $claseBadge);
    if ($claseBadge === "") {
        $claseBadge = "draft";
    }

    return '<span class="status-pill ' . $claseBadge . '">' . htmlspecialchars($nombreEstado !== "" ? $nombreEstado : "Registrada", ENT_QUOTES, "UTF-8") . '</span>';
}

$op = isset($_GET["op"]) ? $_GET["op"] : "";

switch ($op) {
    case "guardaryeditar":
        if ($id_beneficiario === "" || $id_tipo_ayuda_social === "" || $id_solicitud_ayuda_social === "" || $fecha_ayuda === "") {
            responderJson(false, "Debe completar los campos obligatorios.");
        }

        if (!ctype_digit((string) $id_beneficiario) || (int) $id_beneficiario <= 0) {
            responderJson(false, "Debe seleccionar un beneficiario valido.");
        }

        if (!ctype_digit((string) $id_tipo_ayuda_social) || (int) $id_tipo_ayuda_social <= 0) {
            responderJson(false, "Debe seleccionar un tipo de ayuda valido.");
        }

        if (!ctype_digit((string) $id_solicitud_ayuda_social) || (int) $id_solicitud_ayuda_social <= 0) {
            responderJson(false, "Debe seleccionar un tipo de solicitud valido.");
        }

        if ($idayuda === "") {
            $idInsertado = $ayudasocial->insertar(
                $id_beneficiario,
                $id_usuario,
                $id_tipo_ayuda_social,
                $id_solicitud_ayuda_social,
                $fecha_ayuda,
                $descripcion
            );

            if ((int) $idInsertado > 0) {
                $ticketGenerado = $ayudasocial->asegurarTicketInterno($idInsertado);
                if ($ticketGenerado === "") {
                    responderJson(false, "La solicitud se guardo, pero no se pudo generar el ticket interno.");
                }

                $ayudasocial->registrarEstadoInicial($idInsertado, $id_usuario, $fecha_ayuda);

                registrarBitacoraOperacion(
                    $id_usuario,
                    "INSERTAR Ayuda Social - Beneficiario: $id_beneficiario - Tipo ID: $id_tipo_ayuda_social - Solicitud ID: $id_solicitud_ayuda_social"
                );
                responderJson(true, "Solicitud registrada correctamente. Ticket interno: $ticketGenerado.", array(
                    "id_ayuda" => (int) $idInsertado,
                    "ticket_interno" => $ticketGenerado
                ));
            }

            responderJson(false, "No se pudo registrar la solicitud.");
        }

        $rspta = $ayudasocial->editar(
            $idayuda,
            $id_beneficiario,
            $id_usuario,
            $id_tipo_ayuda_social,
            $id_solicitud_ayuda_social,
            $fecha_ayuda,
            $descripcion
        );

        if ($rspta) {
            $ticketGenerado = $ayudasocial->asegurarTicketInterno($idayuda);
            if ($ticketGenerado === "") {
                responderJson(false, "La solicitud se actualizo, pero no se pudo confirmar el ticket interno.");
            }

            registrarBitacoraOperacion(
                $id_usuario,
                "ACTUALIZAR Ayuda Social ID $idayuda - Beneficiario: $id_beneficiario - Tipo ID: $id_tipo_ayuda_social"
            );
            responderJson(true, "Solicitud actualizada correctamente. Ticket interno: $ticketGenerado.", array(
                "id_ayuda" => (int) $idayuda,
                "ticket_interno" => $ticketGenerado
            ));
        }

        responderJson(false, "No se pudo actualizar la solicitud.");
    break;

    case "mostrar":
        if ($idayuda === "") {
            responderJson(false, "Solicitud no especificada.");
        }

        $registro = $ayudasocial->mostrar($idayuda);
        if ($registro) {
            responderJson(true, "Registro cargado.", $registro);
        }

        responderJson(false, "No se encontro la solicitud.");
    break;

    case "listar":
        $rspta = $ayudasocial->listar();
        $data = array();

        while ($reg = $rspta->fetch_object()) {
            $id = (int) $reg->id_ayuda;
            $nombre = trim((string) $reg->nombre_beneficiario);
            $cedula = trim((string) $reg->cedula);
            $nacionalidad = trim((string) $reg->nacionalidad);
            $tipoAyuda = htmlspecialchars((string) $reg->tipo_ayuda, ENT_QUOTES, "UTF-8");
            $solicitudAyuda = htmlspecialchars((string) $reg->solicitud_ayuda, ENT_QUOTES, "UTF-8");
            $fechaAyuda = htmlspecialchars((string) ($reg->fecha_ayuda_formateada !== "" ? $reg->fecha_ayuda_formateada : $reg->fecha_ayuda), ENT_QUOTES, "UTF-8");
            $ticketInterno = htmlspecialchars((string) $reg->ticket_interno, ENT_QUOTES, "UTF-8");
            $descripcionAyuda = htmlspecialchars((string) $reg->descripcion, ENT_QUOTES, "UTF-8");

            $beneficiario = trim($nacionalidad . "-" . $cedula . " " . $nombre);
            if ($beneficiario === "-") {
                $beneficiario = "Beneficiario no disponible";
            }
            $beneficiario = htmlspecialchars($beneficiario, ENT_QUOTES, "UTF-8");

            $badge = badgeEstadoSolicitudGestion($reg->estado_solicitud, $reg->clase_badge_estado_solicitud);

            $btnEditar = '<button type="button" class="btn btn-sm btn-outline-primary js-editar" data-id="' . $id . '" title="Editar"><i class="fas fa-pen"></i></button>';
            $btnGestion = '<button type="button" class="btn btn-sm btn-outline-success js-gestionar-estado" data-id="' . $id . '" title="Gestionar estado de solicitud"><i class="fas fa-clipboard-check"></i></button>';
            $btnEliminar = '<button type="button" class="btn btn-sm btn-outline-danger js-eliminar" data-id="' . $id . '" title="Eliminar"><i class="fas fa-trash-alt"></i></button>';

            $telefono = trim((string) $reg->telefono);
            if ($telefono !== "") {
                $telefonoNormalizado = preg_replace('/[^0-9]/', '', $telefono);
                $telefonoWhatsapp = $telefonoNormalizado;

                if ($telefonoWhatsapp !== "" && strpos($telefonoWhatsapp, "58") !== 0) {
                    $telefonoWhatsapp = "58" . ltrim($telefonoWhatsapp, "0");
                }

                $mensaje = urlencode("Hola, su solicitud de ayuda social esta siendo atendida.");
                $telefonoHtml = '<a href="https://wa.me/' . $telefonoWhatsapp . '?text=' . $mensaje . '" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-outline-success"><i class="fab fa-whatsapp"></i> ' . htmlspecialchars($telefono, ENT_QUOTES, "UTF-8") . '</a>';
            } else {
                $telefonoHtml = '<span class="text-muted">Sin telefono</span>';
            }

            $data[] = array(
                "beneficiario" => $beneficiario,
                "tipo_ayuda" => $tipoAyuda,
                "solicitud_ayuda" => $solicitudAyuda,
                "fecha_ayuda" => $fechaAyuda,
                "ticket_interno" => $ticketInterno,
                "descripcion" => $descripcionAyuda,
                "telefono" => $telefonoHtml,
                "estado_solicitud" => $badge,
                "acciones" => '<div class="d-flex justify-content-end flex-nowrap help-actions">' . $btnEditar . $btnGestion . $btnEliminar . '</div>'
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
        $resumen = $ayudasocial->resumen();
        if (!$resumen) {
            responderJson(false, "No se pudo cargar el resumen.");
        }

        responderJson(true, "Resumen cargado.", array(
            "total" => isset($resumen["total"]) ? (int) $resumen["total"] : 0,
            "atendidas" => isset($resumen["atendidas"]) ? (int) $resumen["atendidas"] : 0,
            "no_atendidas" => isset($resumen["no_atendidas"]) ? (int) $resumen["no_atendidas"] : 0
        ));
    break;

    case "actualizarestadosolicitud":
        if ($idayuda === "" || $id_estado_solicitud === "") {
            responderJson(false, "Debe indicar la solicitud y el estado a registrar.");
        }

        $resultado = $ayudasocial->actualizarEstadoSolicitud(
            $idayuda,
            $id_estado_solicitud,
            $id_usuario,
            $fecha_estado_solicitud,
            $observacion_estado_solicitud
        );

        if ($resultado["ok"]) {
            registrarBitacoraOperacion($id_usuario, "GESTIONAR estado de solicitud de ayuda social ID $idayuda");
        }

        responderJson($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "activar":
        if ($idayuda === "") {
            responderJson(false, "Solicitud no especificada.");
        }

        $rspta = $ayudasocial->activar($idayuda);
        if ($rspta) {
            registrarBitacoraOperacion($id_usuario, "ACTIVAR Ayuda Social ID $idayuda");
            responderJson(true, "Solicitud marcada como atendida.");
        }

        responderJson(false, "No se pudo actualizar el estado de la solicitud.");
    break;

    case "desactivar":
        if ($idayuda === "") {
            responderJson(false, "Solicitud no especificada.");
        }

        $rspta = $ayudasocial->desactivar($idayuda);
        if ($rspta) {
            registrarBitacoraOperacion($id_usuario, "SOFTDELETE Ayuda Social ID $idayuda");
            responderJson(true, "Solicitud eliminada correctamente.");
        }

        responderJson(false, "No se pudo eliminar la solicitud.");
    break;

    case "selectbeneficiario":
        $rspta = $ayudasocial->selectbeneficiario();
        while ($reg = $rspta->fetch_object()) {
            echo '<option value="' . $reg->id_beneficiario . '">' . $reg->nacionalidad . '-' . $reg->cedula . ' ' . $reg->nombre_beneficiario . '</option>';
        }
    break;

    case "listarbeneficiarios":
        $term = isset($_GET["term"]) ? limpiarCadena($_GET["term"]) : "";
        $rspta = $ayudasocial->listarBeneficiarios($term);
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

    case "listartiposayuda":
        $rspta = $ayudasocial->listarTiposAyuda();
        $items = array();

        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id" => (int) $reg->id_tipo_ayuda_social,
                "text" => $reg->nombre_tipo_ayuda
            );
        }

        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "listarsolicitudesayuda":
        $rspta = $ayudasocial->listarSolicitudesAyuda();
        $items = array();

        while ($reg = $rspta->fetch_object()) {
            $texto = trim((string) $reg->codigo_solicitud) !== ""
                ? $reg->codigo_solicitud . " - " . $reg->nombre_solicitud_ayuda
                : $reg->nombre_solicitud_ayuda;
            $items[] = array(
                "id" => (int) $reg->id_solicitud_ayuda_social,
                "text" => $texto,
                "codigo" => isset($reg->codigo_solicitud) ? $reg->codigo_solicitud : "",
                "nombre" => $reg->nombre_solicitud_ayuda
            );
        }

        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "listarestadossolicitud":
        $rspta = $ayudasocial->listarEstadosSolicitud();
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

    default:
        responderJson(false, "Operacion no soportada.");
    break;
}
?>
