<?php
require_once "../config/Conexion.php";
require_once __DIR__ . "/EstadoSolicitud.php";

class Ayudasocial
{
    private $estadoSolicitud;

    public function __construct()
    {
        $this->estadoSolicitud = new EstadoSolicitud();
    }

    private function db()
    {
        global $conexion;
        return $conexion;
    }

    private function esc($valor)
    {
        return mysqli_real_escape_string($this->db(), (string) $valor);
    }

    private function generarTicketInterno($idAyuda, $fechaAyuda)
    {
        $timestamp = strtotime((string) $fechaAyuda);
        if ($timestamp === false) {
            $timestamp = time();
        }

        return "AYU-" . date("Ymd", $timestamp) . "-" . str_pad((string) $idAyuda, 6, "0", STR_PAD_LEFT);
    }

    private function obtenerRegistroTicket($idAyuda)
    {
        $idAyuda = (int) $idAyuda;
        $sql = "SELECT id_ayuda, fecha_ayuda, ticket_interno
                FROM ayuda_social
                WHERE id_ayuda = '$idAyuda'
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    private function obtenerIdEstadoSolicitudPorCodigo($codigoEstado)
    {
        return $this->estadoSolicitud->obtenerIdPorCodigo($codigoEstado);
    }

    private function obtenerUltimoSeguimientoEstado($idAyuda)
    {
        return $this->estadoSolicitud->obtenerUltimoSeguimiento("AYUDA_SOCIAL", $idAyuda);
    }

    private function registrarSeguimientoEstado($idAyuda, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)
    {
        return $this->estadoSolicitud->registrarSeguimiento(
            "AYUDA_SOCIAL",
            $idAyuda,
            $idEstadoSolicitud,
            $idUsuario,
            $fechaGestion,
            $observacion
        );
    }

    public function registrarEstadoInicial($idAyuda, $idUsuario, $fechaAyuda)
    {
        $idAyuda = (int) $idAyuda;
        $idUsuario = (int) $idUsuario;
        if ($idAyuda <= 0) {
            return false;
        }

        $registro = ejecutarConsultaSimpleFila("SELECT id_estado_solicitud FROM ayuda_social WHERE id_ayuda = '$idAyuda' LIMIT 1");
        if (!$registro || (int) $registro["id_estado_solicitud"] <= 0) {
            return false;
        }

        $ultimoSeguimiento = $this->obtenerUltimoSeguimientoEstado($idAyuda);
        if ($ultimoSeguimiento) {
            return true;
        }

        $fechaGestion = trim((string) $fechaAyuda) !== ""
            ? $fechaAyuda . " 08:00:00"
            : date("Y-m-d H:i:s");

        return $this->registrarSeguimientoEstado(
            $idAyuda,
            (int) $registro["id_estado_solicitud"],
            $idUsuario,
            $fechaGestion,
            "Solicitud registrada en ayuda social."
        );
    }

    public function listarEstadosSolicitud()
    {
        return $this->estadoSolicitud->listarActivos();
    }

    public function actualizarEstadoSolicitud($idAyuda, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)
    {
        $idAyuda = (int) $idAyuda;
        $idEstadoSolicitud = (int) $idEstadoSolicitud;
        $idUsuario = (int) $idUsuario;
        $fechaGestion = trim((string) $fechaGestion);
        $observacion = trim((string) $observacion);

        $registro = ejecutarConsultaSimpleFila("SELECT id_ayuda, estado FROM ayuda_social WHERE id_ayuda = '$idAyuda' LIMIT 1");
        if (!$registro || (int) $registro["estado"] !== 1) {
            return array("ok" => false, "msg" => "La solicitud no esta disponible para actualizarse.");
        }

        $estadoSolicitud = $this->estadoSolicitud->obtener($idEstadoSolicitud);
        if (!$estadoSolicitud) {
            return array("ok" => false, "msg" => "Debe seleccionar un estado de solicitud valido.");
        }

        $sql = "UPDATE ayuda_social
                SET id_estado_solicitud = '$idEstadoSolicitud'
                WHERE id_ayuda = '$idAyuda'";
        if (!ejecutarConsulta($sql)) {
            return array("ok" => false, "msg" => "No se pudo actualizar el estado de la solicitud.");
        }

        if (!$this->registrarSeguimientoEstado($idAyuda, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)) {
            return array("ok" => false, "msg" => "La solicitud cambio de estado, pero no se pudo guardar el seguimiento.");
        }

        return array(
            "ok" => true,
            "msg" => "Estado de la solicitud actualizado correctamente.",
            "estado_solicitud" => $estadoSolicitud["nombre_estado"],
            "codigo_estado_solicitud" => $estadoSolicitud["codigo_estado"],
            "clase_badge_estado_solicitud" => $estadoSolicitud["clase_badge"],
            "es_atendida" => (int) $estadoSolicitud["es_atendida"]
        );
    }

    public function insertar($id_beneficiario, $id_usuario, $id_tipo_ayuda_social, $id_solicitud_ayuda_social, $fecha_ayuda, $descripcion)
    {
        $sql = "INSERT INTO ayuda_social (
                    id_beneficiario,
                    id_usuario,
                    id_tipo_ayuda_social,
                    id_solicitud_ayuda_social,
                    id_estado_solicitud,
                    tipo_ayuda,
                    solicitud_ayuda,
                    fecha_ayuda,
                    descripcion,
                    ticket_interno,
                    estado
                )
                SELECT
                    '$id_beneficiario',
                    '$id_usuario',
                    ta.id_tipo_ayuda_social,
                    sg.id_solicitud_general,
                    (SELECT id_estado_solicitud FROM estados_solicitudes WHERE codigo_estado = 'REGISTRADA' AND estado = 1 LIMIT 1),
                    ta.nombre_tipo_ayuda,
                    sg.nombre_solicitud,
                    '$fecha_ayuda',
                    '$descripcion',
                    '',
                    1
                FROM tipos_ayuda_social AS ta
                INNER JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = '$id_solicitud_ayuda_social'
                WHERE ta.id_tipo_ayuda_social = '$id_tipo_ayuda_social'
                  AND ta.estado = 1
                  AND sg.estado = 1";

        return ejecutarConsulta_retornarID($sql);
    }

    public function editar($id_ayuda, $id_beneficiario, $id_usuario, $id_tipo_ayuda_social, $id_solicitud_ayuda_social, $fecha_ayuda, $descripcion)
    {
        $sql = "UPDATE ayuda_social AS a
                INNER JOIN tipos_ayuda_social AS ta
                    ON ta.id_tipo_ayuda_social = '$id_tipo_ayuda_social'
                   AND ta.estado = 1
                INNER JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = '$id_solicitud_ayuda_social'
                   AND sg.estado = 1
                SET a.id_beneficiario = '$id_beneficiario',
                    a.id_usuario = '$id_usuario',
                    a.id_tipo_ayuda_social = ta.id_tipo_ayuda_social,
                    a.id_solicitud_ayuda_social = sg.id_solicitud_general,
                    a.tipo_ayuda = ta.nombre_tipo_ayuda,
                    a.solicitud_ayuda = sg.nombre_solicitud,
                    a.fecha_ayuda = '$fecha_ayuda',
                    a.descripcion = '$descripcion'
                WHERE a.id_ayuda = '$id_ayuda'";

        return ejecutarConsulta($sql);
    }

    public function asegurarTicketInterno($idAyuda)
    {
        $registro = $this->obtenerRegistroTicket($idAyuda);
        if (!$registro) {
            return "";
        }

        $ticketActual = trim((string) $registro["ticket_interno"]);
        if ($ticketActual !== "") {
            return $ticketActual;
        }

        $ticketNuevo = $this->generarTicketInterno((int) $registro["id_ayuda"], $registro["fecha_ayuda"]);
        $ticketEscapado = $this->esc($ticketNuevo);
        $idAyuda = (int) $registro["id_ayuda"];

        ejecutarConsulta("UPDATE ayuda_social SET ticket_interno = '$ticketEscapado' WHERE id_ayuda = '$idAyuda'");
        return $ticketNuevo;
    }

    public function activar($id_ayuda)
    {
        $sql = "UPDATE ayuda_social
                SET estado = '1'
                WHERE id_ayuda = '$id_ayuda'";

        return ejecutarConsulta($sql);
    }

    public function desactivar($id_ayuda)
    {
        $sql = "UPDATE ayuda_social
                SET estado = '0'
                WHERE id_ayuda = '$id_ayuda'";

        return ejecutarConsulta($sql);
    }

    public function mostrar($id_ayuda)
    {
        $sql = "SELECT a.id_ayuda,
                       a.id_beneficiario,
                       a.id_usuario,
                       a.id_tipo_ayuda_social,
                       a.id_solicitud_ayuda_social,
                       a.id_estado_solicitud,
                       COALESCE(ta.nombre_tipo_ayuda, a.tipo_ayuda) AS tipo_ayuda,
                       COALESCE(sg.nombre_solicitud, a.solicitud_ayuda) AS solicitud_ayuda,
                       COALESCE(es.nombre_estado, 'Registrada') AS estado_solicitud,
                       COALESCE(es.codigo_estado, 'REGISTRADA') AS codigo_estado_solicitud,
                       COALESCE(es.clase_badge, 'draft') AS clase_badge_estado_solicitud,
                       COALESCE(es.es_atendida, 0) AS es_atendida,
                       a.fecha_ayuda,
                       a.descripcion,
                       a.ticket_interno,
                       a.estado,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono,
                       CONCAT(b.nacionalidad, '-', b.cedula, ' ', b.nombre_beneficiario) AS beneficiario
                FROM ayuda_social AS a
                LEFT JOIN tipos_ayuda_social AS ta
                    ON ta.id_tipo_ayuda_social = a.id_tipo_ayuda_social
                LEFT JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = a.id_solicitud_ayuda_social
                LEFT JOIN estados_solicitudes AS es
                    ON es.id_estado_solicitud = a.id_estado_solicitud
                LEFT JOIN beneficiarios AS b
                    ON b.id_beneficiario = a.id_beneficiario
                WHERE a.id_ayuda = '$id_ayuda'
                LIMIT 1";

        $registro = ejecutarConsultaSimpleFila($sql);
        if ($registro) {
            $ultimoSeguimiento = $this->obtenerUltimoSeguimientoEstado($id_ayuda);
            if ($ultimoSeguimiento) {
                $registro["fecha_estado_solicitud"] = $ultimoSeguimiento["fecha_gestion_formateada"];
                $registro["fecha_estado_solicitud_input"] = $ultimoSeguimiento["fecha_gestion_input"];
                $registro["observacion_estado_solicitud"] = $ultimoSeguimiento["observacion"];
            } else {
                $registro["fecha_estado_solicitud"] = "";
                $registro["fecha_estado_solicitud_input"] = "";
                $registro["observacion_estado_solicitud"] = "";
            }
        }

        return $registro;
    }

    public function listar()
    {
        $sql = "SELECT a.id_ayuda,
                       a.id_beneficiario,
                       a.ticket_interno,
                       a.id_tipo_ayuda_social,
                       a.id_solicitud_ayuda_social,
                       a.id_estado_solicitud,
                       COALESCE(ta.nombre_tipo_ayuda, a.tipo_ayuda) AS tipo_ayuda,
                       COALESCE(sg.nombre_solicitud, a.solicitud_ayuda) AS solicitud_ayuda,
                       COALESCE(es.nombre_estado, 'Registrada') AS estado_solicitud,
                       COALESCE(es.codigo_estado, 'REGISTRADA') AS codigo_estado_solicitud,
                       COALESCE(es.clase_badge, 'draft') AS clase_badge_estado_solicitud,
                       COALESCE(es.es_atendida, 0) AS es_atendida,
                       a.fecha_ayuda,
                       DATE_FORMAT(a.fecha_ayuda, '%d/%m/%Y') AS fecha_ayuda_formateada,
                       a.descripcion,
                       a.estado,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono
                FROM ayuda_social AS a
                LEFT JOIN tipos_ayuda_social AS ta
                    ON ta.id_tipo_ayuda_social = a.id_tipo_ayuda_social
                LEFT JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = a.id_solicitud_ayuda_social
                LEFT JOIN estados_solicitudes AS es
                    ON es.id_estado_solicitud = a.id_estado_solicitud
                LEFT JOIN beneficiarios AS b
                    ON b.id_beneficiario = a.id_beneficiario
                WHERE a.estado = 1
                ORDER BY a.id_ayuda DESC";

        return ejecutarConsulta($sql);
    }

    public function resumen()
    {
        $sql = "SELECT COUNT(a.id_ayuda) AS total,
                       SUM(CASE WHEN COALESCE(es.es_atendida, 0) = 1 THEN 1 ELSE 0 END) AS atendidas,
                       SUM(CASE WHEN COALESCE(es.es_atendida, 0) = 1 THEN 0 ELSE 1 END) AS no_atendidas
                FROM ayuda_social AS a
                LEFT JOIN estados_solicitudes AS es
                    ON es.id_estado_solicitud = a.id_estado_solicitud
                WHERE a.estado = 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    public function selectbeneficiario()
    {
        $sql = "SELECT id_beneficiario,
                       nacionalidad,
                       cedula,
                       nombre_beneficiario
                FROM beneficiarios
                WHERE estado = 1
                ORDER BY nombre_beneficiario ASC";

        return ejecutarConsulta($sql);
    }

    public function listarBeneficiarios($termino = "")
    {
        $filtro = "";
        if ($termino !== "") {
            $filtro = "AND (
                nacionalidad LIKE '%$termino%'
                OR cedula LIKE '%$termino%'
                OR nombre_beneficiario LIKE '%$termino%'
                OR CONCAT(nacionalidad, '-', cedula, ' ', nombre_beneficiario) LIKE '%$termino%'
            )";
        }

        $sql = "SELECT id_beneficiario,
                       nacionalidad,
                       cedula,
                       nombre_beneficiario,
                       telefono
                FROM beneficiarios
                WHERE estado = 1
                $filtro
                ORDER BY nombre_beneficiario ASC
                LIMIT 150";

        return ejecutarConsulta($sql);
    }

    public function listarTiposAyuda()
    {
        $sql = "SELECT id_tipo_ayuda_social,
                       nombre_tipo_ayuda
                FROM tipos_ayuda_social
                WHERE estado = 1
                ORDER BY nombre_tipo_ayuda ASC";

        return ejecutarConsulta($sql);
    }

    public function listarSolicitudesAyuda()
    {
        $sql = "SELECT id_solicitud_general AS id_solicitud_ayuda_social,
                       codigo_solicitud,
                       nombre_solicitud AS nombre_solicitud_ayuda
                FROM solicitudes_generales
                WHERE estado = 1
                ORDER BY nombre_solicitud ASC";

        return ejecutarConsulta($sql);
    }
}
?>
