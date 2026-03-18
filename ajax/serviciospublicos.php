<?php
session_start();
require_once "../modelos/Serviciospublicos.php";

$serviciospublicos = new Serviciospublicos();

$id_servicio = isset($_POST["id_servicio"]) ? limpiarCadena($_POST["id_servicio"]) : "";
$id_tipo_servicio_publico = isset($_POST["id_tipo_servicio_publico"]) ? limpiarCadena($_POST["id_tipo_servicio_publico"]) : "";
$id_solicitud_servicio_publico = isset($_POST["id_solicitud_servicio_publico"]) ? limpiarCadena($_POST["id_solicitud_servicio_publico"]) : "";
$fecha_servicio = isset($_POST["fecha_servicio"]) ? limpiarCadena($_POST["fecha_servicio"]) : "";
$ticket_interno = isset($_POST["ticket_interno"]) ? limpiarCadena($_POST["ticket_interno"]) : "";
$descripcion = isset($_POST["descripcion"]) ? limpiarCadena($_POST["descripcion"]) : "";
$id_beneficiario = isset($_POST["id_beneficiario"]) ? limpiarCadena($_POST["id_beneficiario"]) : "";
$id_estado_solicitud = isset($_POST["id_estado_solicitud"]) ? limpiarCadena($_POST["id_estado_solicitud"]) : "";
$fecha_estado_solicitud = isset($_POST["fecha_estado_solicitud"]) ? limpiarCadena($_POST["fecha_estado_solicitud"]) : "";
$observacion_estado_solicitud = isset($_POST["observacion_estado_solicitud"]) ? limpiarCadena($_POST["observacion_estado_solicitud"]) : "";
$id_usuario = isset($_SESSION["idusuario"]) ? $_SESSION["idusuario"] : "";

function responderJsonServiciosPublicos($ok, $msg, $data = null)
{
    header("Content-Type: application/json; charset=utf-8");
    echo json_encode(array("ok" => $ok, "msg" => $msg, "data" => $data));
    exit;
}

function registrarBitacoraServiciosPublicos($idUsuario, $detalle)
{
    if ($idUsuario === "") {
        return;
    }

    require_once "../modelos/Bitacora.php";
    $bitacora = new Bitacora();
    $bitacora->insertar($idUsuario, $detalle);
}

function badgeEstadoSolicitudServicios($nombreEstado, $claseBadge)
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
        if ($id_beneficiario === "" || $id_tipo_servicio_publico === "" || $id_solicitud_servicio_publico === "" || $fecha_servicio === "") {
            responderJsonServiciosPublicos(false, "Debe completar los campos obligatorios.");
        }

        if (!ctype_digit((string) $id_beneficiario) || (int) $id_beneficiario <= 0) {
            responderJsonServiciosPublicos(false, "Debe seleccionar un beneficiario valido.");
        }

        if (!ctype_digit((string) $id_tipo_servicio_publico) || (int) $id_tipo_servicio_publico <= 0) {
            responderJsonServiciosPublicos(false, "Debe seleccionar un servicio publico valido.");
        }

        if (!ctype_digit((string) $id_solicitud_servicio_publico) || (int) $id_solicitud_servicio_publico <= 0) {
            responderJsonServiciosPublicos(false, "Debe seleccionar un tipo de solicitud valido.");
        }

        if ($id_servicio === "") {
            $idInsertado = $serviciospublicos->insertar(
                $id_beneficiario,
                $id_usuario,
                $id_tipo_servicio_publico,
                $id_solicitud_servicio_publico,
                $fecha_servicio,
                $ticket_interno,
                $descripcion
            );

            if ((int) $idInsertado > 0) {
                $ticketGenerado = $serviciospublicos->asegurarTicketInterno($idInsertado);
                if ($ticketGenerado === "") {
                    responderJsonServiciosPublicos(false, "La solicitud se guardo, pero no se pudo generar el ticket interno.");
                }

                $serviciospublicos->registrarEstadoInicial($idInsertado, $id_usuario, $fecha_servicio);

                registrarBitacoraServiciosPublicos(
                    $id_usuario,
                    "INSERTAR Servicios Publicos - Beneficiario: $id_beneficiario - Tipo ID: $id_tipo_servicio_publico - Solicitud ID: $id_solicitud_servicio_publico"
                );
                responderJsonServiciosPublicos(true, "Solicitud registrada correctamente. Ticket interno: $ticketGenerado.", array(
                    "id_servicio" => (int) $idInsertado,
                    "ticket_interno" => $ticketGenerado
                ));
            }

            responderJsonServiciosPublicos(false, "No se pudo registrar la solicitud.");
        }

        $rspta = $serviciospublicos->editar(
            $id_servicio,
            $id_beneficiario,
            $id_usuario,
            $id_tipo_servicio_publico,
            $id_solicitud_servicio_publico,
            $fecha_servicio,
            $ticket_interno,
            $descripcion
        );

        if ($rspta) {
            $ticketGenerado = $serviciospublicos->asegurarTicketInterno($id_servicio);
            if ($ticketGenerado === "") {
                responderJsonServiciosPublicos(false, "La solicitud se actualizo, pero no se pudo confirmar el ticket interno.");
            }

            registrarBitacoraServiciosPublicos(
                $id_usuario,
                "ACTUALIZAR Servicios Publicos ID $id_servicio - Beneficiario: $id_beneficiario - Tipo ID: $id_tipo_servicio_publico"
            );
            responderJsonServiciosPublicos(true, "Solicitud actualizada correctamente. Ticket interno: $ticketGenerado.", array(
                "id_servicio" => (int) $id_servicio,
                "ticket_interno" => $ticketGenerado
            ));
        }

        responderJsonServiciosPublicos(false, "No se pudo actualizar la solicitud.");
    break;

    case "mostrar":
        if ($id_servicio === "") {
            responderJsonServiciosPublicos(false, "Solicitud no especificada.");
        }

        $registro = $serviciospublicos->mostrar($id_servicio);
        if ($registro) {
            responderJsonServiciosPublicos(true, "Registro cargado.", $registro);
        }

        responderJsonServiciosPublicos(false, "No se encontro la solicitud.");
    break;

    case "listar":
        $rspta = $serviciospublicos->listar();
        $data = array();

        while ($reg = $rspta->fetch_object()) {
            $id = (int) $reg->id_servicio;
            $nombre = trim((string) $reg->nombre_beneficiario);
            $cedula = trim((string) $reg->cedula);
            $nacionalidad = trim((string) $reg->nacionalidad);
            $tipoServicio = htmlspecialchars((string) $reg->tipo_servicio_texto, ENT_QUOTES, "UTF-8");
            $solicitudServicio = htmlspecialchars((string) $reg->solicitud_servicio_texto, ENT_QUOTES, "UTF-8");
            $fechaServicio = htmlspecialchars((string) ($reg->fecha_servicio_formateada !== "" ? $reg->fecha_servicio_formateada : $reg->fecha_servicio), ENT_QUOTES, "UTF-8");
            $ticketServicio = htmlspecialchars((string) $reg->ticket_interno, ENT_QUOTES, "UTF-8");
            $descripcionServicio = htmlspecialchars((string) $reg->descripcion, ENT_QUOTES, "UTF-8");

            $beneficiario = trim($nacionalidad . "-" . $cedula . " " . $nombre);
            if ($beneficiario === "-") {
                $beneficiario = "Beneficiario no disponible";
            }
            $beneficiario = htmlspecialchars($beneficiario, ENT_QUOTES, "UTF-8");

            $badge = badgeEstadoSolicitudServicios($reg->estado_solicitud, $reg->clase_badge_estado_solicitud);

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

                $mensaje = urlencode("Hola, su solicitud de servicios publicos esta siendo atendida.");
                $telefonoHtml = '<a href="https://wa.me/' . $telefonoWhatsapp . '?text=' . $mensaje . '" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-outline-success"><i class="fab fa-whatsapp"></i> ' . htmlspecialchars($telefono, ENT_QUOTES, "UTF-8") . '</a>';
            } else {
                $telefonoHtml = '<span class="text-muted">Sin telefono</span>';
            }

            $data[] = array(
                "beneficiario" => $beneficiario,
                "tipo_servicio" => $tipoServicio,
                "solicitud_servicio" => $solicitudServicio,
                "fecha_servicio" => $fechaServicio,
                "ticket_interno" => $ticketServicio,
                "descripcion" => $descripcionServicio,
                "telefono" => $telefonoHtml,
                "estado_solicitud" => $badge,
                "acciones" => '<div class="d-flex justify-content-end flex-nowrap public-service-actions">' . $btnEditar . $btnGestion . $btnEliminar . '</div>'
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
        $resumen = $serviciospublicos->resumen();
        if (!$resumen) {
            responderJsonServiciosPublicos(false, "No se pudo cargar el resumen.");
        }

        responderJsonServiciosPublicos(true, "Resumen cargado.", array(
            "total" => isset($resumen["total"]) ? (int) $resumen["total"] : 0,
            "atendidas" => isset($resumen["atendidas"]) ? (int) $resumen["atendidas"] : 0,
            "pendientes" => isset($resumen["pendientes"]) ? (int) $resumen["pendientes"] : 0
        ));
    break;

    case "actualizarestadosolicitud":
        if ($id_servicio === "" || $id_estado_solicitud === "") {
            responderJsonServiciosPublicos(false, "Debe indicar la solicitud y el estado a registrar.");
        }

        $resultado = $serviciospublicos->actualizarEstadoSolicitud(
            $id_servicio,
            $id_estado_solicitud,
            $id_usuario,
            $fecha_estado_solicitud,
            $observacion_estado_solicitud
        );

        if ($resultado["ok"]) {
            registrarBitacoraServiciosPublicos($id_usuario, "GESTIONAR estado de solicitud de servicios publicos ID $id_servicio");
        }

        responderJsonServiciosPublicos($resultado["ok"], $resultado["msg"], $resultado);
    break;

    case "activar":
        if ($id_servicio === "") {
            responderJsonServiciosPublicos(false, "Solicitud no especificada.");
        }

        $rspta = $serviciospublicos->activar($id_servicio);
        if ($rspta) {
            registrarBitacoraServiciosPublicos($id_usuario, "ACTIVAR Servicios Publicos ID $id_servicio");
            responderJsonServiciosPublicos(true, "Solicitud marcada como atendida.");
        }

        responderJsonServiciosPublicos(false, "No se pudo actualizar el estado de la solicitud.");
    break;

    case "desactivar":
        if ($id_servicio === "") {
            responderJsonServiciosPublicos(false, "Solicitud no especificada.");
        }

        $rspta = $serviciospublicos->desactivar($id_servicio);
        if ($rspta) {
            registrarBitacoraServiciosPublicos($id_usuario, "SOFTDELETE Servicios Publicos ID $id_servicio");
            responderJsonServiciosPublicos(true, "Solicitud eliminada correctamente.");
        }

        responderJsonServiciosPublicos(false, "No se pudo eliminar la solicitud.");
    break;

    case "selectbeneficiario":
        $rspta = $serviciospublicos->selectbeneficiario();
        while ($reg = $rspta->fetch_object()) {
            echo '<option value="' . $reg->id_beneficiario . '">' . $reg->nacionalidad . '-' . $reg->cedula . ' ' . $reg->nombre_beneficiario . '</option>';
        }
    break;

    case "listarbeneficiarios":
        $term = isset($_GET["term"]) ? limpiarCadena($_GET["term"]) : "";
        $rspta = $serviciospublicos->listarBeneficiarios($term);
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

    case "listartiposserviciospublicos":
        $term = isset($_GET["term"]) ? limpiarCadena($_GET["term"]) : "";
        $rspta = $serviciospublicos->listarTiposServiciosPublicos($term);
        $items = array();

        while ($reg = $rspta->fetch_object()) {
            $texto = $reg->codigo_tipo_servicio_publico . " - " . $reg->nombre_tipo_servicio;
            $items[] = array(
                "id" => (int) $reg->id_tipo_servicio_publico,
                "text" => $texto,
                "codigo" => $reg->codigo_tipo_servicio_publico,
                "nombre" => $reg->nombre_tipo_servicio
            );
        }

        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "listarsolicitudesserviciospublicos":
        $term = isset($_GET["term"]) ? limpiarCadena($_GET["term"]) : "";
        $rspta = $serviciospublicos->listarSolicitudesServiciosPublicos($term);
        $items = array();

        while ($reg = $rspta->fetch_object()) {
            $texto = $reg->codigo_solicitud_servicio_publico . " - " . $reg->nombre_solicitud_servicio;
            $items[] = array(
                "id" => (int) $reg->id_solicitud_servicio_publico,
                "text" => $texto,
                "codigo" => $reg->codigo_solicitud_servicio_publico,
                "nombre" => $reg->nombre_solicitud_servicio
            );
        }

        header("Content-Type: application/json; charset=utf-8");
        echo json_encode(array("items" => $items));
    break;

    case "listarestadossolicitud":
        $rspta = $serviciospublicos->listarEstadosSolicitud();
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
        responderJsonServiciosPublicos(false, "Operacion no soportada.");
    break;
}
?>
