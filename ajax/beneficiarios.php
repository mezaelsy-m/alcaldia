<?php
session_start();
require_once "../modelos/Beneficiarios.php";

$beneficiario = new Beneficiario();

$idbeneficiarios = isset($_POST["idbeneficiarios"]) ? limpiarCadena($_POST["idbeneficiarios"]) : "";
$nacionalidad = isset($_POST["nacionalidad"]) ? limpiarCadena($_POST["nacionalidad"]) : "";
$cedula = isset($_POST["cedula"]) ? limpiarCadena($_POST["cedula"]) : "";
$nombrebeneficiario = isset($_POST["nombrebeneficiario"]) ? limpiarCadena($_POST["nombrebeneficiario"]) : "";
$telefono = isset($_POST["telefono"]) ? limpiarCadena($_POST["telefono"]) : "";
$idcomunidad = isset($_POST["idcomunidad"]) ? limpiarCadena($_POST["idcomunidad"]) : "";
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

$op = isset($_GET["op"]) ? $_GET["op"] : "";

switch ($op) {
    case "guardaryeditar":
        if ($nacionalidad === "" || $cedula === "" || $nombrebeneficiario === "" || $telefono === "" || $idcomunidad === "") {
            responderJson(false, "Todos los campos son obligatorios.");
        }

        if (!ctype_digit((string) $idcomunidad) || (int) $idcomunidad <= 0) {
            responderJson(false, "Debe seleccionar una comunidad valida.");
        }

        if ($idbeneficiarios === "") {
            $registroExistente = $beneficiario->buscarPorCedula($cedula);
            if ($registroExistente) {
                if ((int) $registroExistente["estado"] !== 1) {
                    $idExistente = (int) $registroExistente["id_beneficiario"];
                    $actualizado = $beneficiario->editar($idExistente, $nacionalidad, $cedula, $nombrebeneficiario, $telefono, $idcomunidad);
                    $reactivado = $actualizado ? $beneficiario->activar($idExistente) : false;

                    if ($actualizado && $reactivado) {
                        $detalle = "REACTIVAR Beneficiario ID $idExistente - $nacionalidad-$cedula - $nombrebeneficiario";
                        registrarBitacoraOperacion($id_usuario, $detalle);
                        responderJson(true, "El beneficiario ya existia y fue reactivado correctamente.", array(
                            "id_beneficiario" => $idExistente,
                            "beneficiario" => $nacionalidad . "-" . $cedula . " " . $nombrebeneficiario,
                            "existente" => true,
                            "reactivado" => true,
                            "estado" => 1
                        ));
                    }

                    responderJson(false, "El beneficiario existe, pero no se pudo reactivar correctamente.");
                }

                responderJson(true, "El beneficiario ya existe. Se usara el registro encontrado.", array(
                    "id_beneficiario" => (int) $registroExistente["id_beneficiario"],
                    "beneficiario" => $registroExistente["nacionalidad"] . "-" . $registroExistente["cedula"] . " " . $registroExistente["nombre_beneficiario"],
                    "existente" => true,
                    "estado" => (int) $registroExistente["estado"]
                ));
            }

            $idInsertado = $beneficiario->insertar($nacionalidad, $cedula, $nombrebeneficiario, $telefono, $idcomunidad);
            if ((int) $idInsertado > 0) {
                $detalle = "INSERTAR Beneficiario ID $idInsertado - $nacionalidad-$cedula - $nombrebeneficiario";
                registrarBitacoraOperacion($id_usuario, $detalle);
                responderJson(true, "Beneficiario registrado correctamente.", array(
                    "id_beneficiario" => (int) $idInsertado,
                    "beneficiario" => $nacionalidad . "-" . $cedula . " " . $nombrebeneficiario,
                    "existente" => false
                ));
            }

            responderJson(false, "No se pudo registrar el beneficiario.");
        }

        $editado = $beneficiario->editar($idbeneficiarios, $nacionalidad, $cedula, $nombrebeneficiario, $telefono, $idcomunidad);
        if ($editado) {
            $detalle = "ACTUALIZAR Beneficiario ID $idbeneficiarios - $nacionalidad-$cedula - $nombrebeneficiario";
            registrarBitacoraOperacion($id_usuario, $detalle);
            responderJson(true, "Beneficiario actualizado correctamente.");
        }

        responderJson(false, "No se pudo actualizar el beneficiario.");
    break;

    case "mostrar":
        if ($idbeneficiarios === "") {
            responderJson(false, "Beneficiario no especificado.");
        }

        $registro = $beneficiario->mostrar($idbeneficiarios);
        if ($registro) {
            responderJson(true, "Registro cargado.", $registro);
        }

        responderJson(false, "No se encontro el beneficiario.");
    break;

    case "listar":
        $rspta = $beneficiario->listar();
        $data = array();

        while ($reg = $rspta->fetch_object()) {
            $id = (int) $reg->id_beneficiario;
            $btnEditar = '<button type="button" class="btn btn-sm btn-outline-primary js-editar" data-id="' . $id . '" title="Editar"><i class="fas fa-pen"></i></button>';
            $btnEliminar = '<button type="button" class="btn btn-sm btn-outline-danger js-eliminar" data-id="' . $id . '" title="Eliminar"><i class="fas fa-trash-alt"></i></button>';

            $data[] = array(
                "cedula_completa" => $reg->nacionalidad . "-" . $reg->cedula,
                "nombre_beneficiario" => $reg->nombre_beneficiario,
                "telefono" => $reg->telefono,
                "comunidad" => $reg->comunidad,
                "fecha_registro" => isset($reg->fecha_registro_12h) ? $reg->fecha_registro_12h : "",
                "acciones" => '<div class="btn-group justify-content-end w-100">' . $btnEditar . $btnEliminar . '</div>'
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
        $resumen = $beneficiario->resumen();
        if (!$resumen) {
            responderJson(false, "No se pudo cargar el resumen.");
        }

        $data = array(
            "total" => isset($resumen["total"]) ? (int) $resumen["total"] : 0,
            "activos" => isset($resumen["activos"]) ? (int) $resumen["activos"] : 0,
            "inactivos" => isset($resumen["inactivos"]) ? (int) $resumen["inactivos"] : 0
        );
        responderJson(true, "Resumen cargado.", $data);
    break;

    case "activar":
        if ($idbeneficiarios === "") {
            responderJson(false, "Beneficiario no especificado.");
        }

        $rspta = $beneficiario->activar($idbeneficiarios);
        if ($rspta) {
            registrarBitacoraOperacion($id_usuario, "ACTIVAR Beneficiario ID $idbeneficiarios");
            responderJson(true, "Beneficiario activado correctamente.");
        }
        responderJson(false, "No se pudo activar el beneficiario.");
    break;

    case "desactivar":
        if ($idbeneficiarios === "") {
            responderJson(false, "Beneficiario no especificado.");
        }

        $rspta = $beneficiario->desactivar($idbeneficiarios);
        if ($rspta) {
            registrarBitacoraOperacion($id_usuario, "SOFTDELETE Beneficiario ID $idbeneficiarios");
            responderJson(true, "Beneficiario eliminado correctamente.");
        }
        responderJson(false, "No se pudo eliminar el beneficiario.");
    break;

    case "selectbeneficiario":
        $rspta = $beneficiario->selectbeneficiario();
        while ($reg = $rspta->fetch_object()) {
            echo '<option value="' . $reg->id_beneficiario . '">' . $reg->nacionalidad . '-' . $reg->cedula . ' ' . $reg->nombre_beneficiario . '</option>';
        }
    break;

    case "listarcomunidades":
        $term = isset($_GET["term"]) ? limpiarCadena($_GET["term"]) : "";
        $rspta = $beneficiario->listarComunidades($term);
        $items = array();

        while ($reg = $rspta->fetch_object()) {
            $items[] = array(
                "id" => (int) $reg->id_comunidad,
                "text" => $reg->nombre_comunidad
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
