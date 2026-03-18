<?php
require_once "../config/Conexion.php";
require_once __DIR__ . "/EstadoSolicitud.php";

class Serviciospublicos
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

    private function generarTicketInterno($idServicio, $fechaServicio)
    {
        $timestamp = strtotime((string) $fechaServicio);
        if ($timestamp === false) {
            $timestamp = time();
        }

        return "SPU-" . date("Ymd", $timestamp) . "-" . str_pad((string) $idServicio, 6, "0", STR_PAD_LEFT);
    }

    private function obtenerRegistroTicket($idServicio)
    {
        $idServicio = (int) $idServicio;
        $sql = "SELECT id_servicio, fecha_servicio, ticket_interno
                FROM servicios_publicos
                WHERE id_servicio = '$idServicio'
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    private function obtenerUltimoSeguimientoEstado($idServicio)
    {
        return $this->estadoSolicitud->obtenerUltimoSeguimiento("SERVICIOS_PUBLICOS", $idServicio);
    }

    private function registrarSeguimientoEstado($idServicio, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)
    {
        return $this->estadoSolicitud->registrarSeguimiento(
            "SERVICIOS_PUBLICOS",
            $idServicio,
            $idEstadoSolicitud,
            $idUsuario,
            $fechaGestion,
            $observacion
        );
    }

    public function registrarEstadoInicial($idServicio, $idUsuario, $fechaServicio)
    {
        $idServicio = (int) $idServicio;
        $idUsuario = (int) $idUsuario;
        if ($idServicio <= 0) {
            return false;
        }

        $registro = ejecutarConsultaSimpleFila("SELECT id_estado_solicitud FROM servicios_publicos WHERE id_servicio = '$idServicio' LIMIT 1");
        if (!$registro || (int) $registro["id_estado_solicitud"] <= 0) {
            return false;
        }

        $ultimoSeguimiento = $this->obtenerUltimoSeguimientoEstado($idServicio);
        if ($ultimoSeguimiento) {
            return true;
        }

        $fechaGestion = trim((string) $fechaServicio) !== ""
            ? $fechaServicio . " 08:00:00"
            : date("Y-m-d H:i:s");

        return $this->registrarSeguimientoEstado(
            $idServicio,
            (int) $registro["id_estado_solicitud"],
            $idUsuario,
            $fechaGestion,
            "Solicitud registrada en servicios publicos."
        );
    }

    public function listarEstadosSolicitud()
    {
        return $this->estadoSolicitud->listarActivos();
    }

    public function actualizarEstadoSolicitud($idServicio, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)
    {
        $idServicio = (int) $idServicio;
        $idEstadoSolicitud = (int) $idEstadoSolicitud;
        $idUsuario = (int) $idUsuario;
        $fechaGestion = trim((string) $fechaGestion);
        $observacion = trim((string) $observacion);

        $registro = ejecutarConsultaSimpleFila("SELECT id_servicio, estado FROM servicios_publicos WHERE id_servicio = '$idServicio' LIMIT 1");
        if (!$registro || (int) $registro["estado"] !== 1) {
            return array("ok" => false, "msg" => "La solicitud no esta disponible para actualizarse.");
        }

        $estadoSolicitud = $this->estadoSolicitud->obtener($idEstadoSolicitud);
        if (!$estadoSolicitud) {
            return array("ok" => false, "msg" => "Debe seleccionar un estado de solicitud valido.");
        }

        $sql = "UPDATE servicios_publicos
                SET id_estado_solicitud = '$idEstadoSolicitud'
                WHERE id_servicio = '$idServicio'";
        if (!ejecutarConsulta($sql)) {
            return array("ok" => false, "msg" => "No se pudo actualizar el estado de la solicitud.");
        }

        if (!$this->registrarSeguimientoEstado($idServicio, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)) {
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

    public function insertar($id_beneficiario, $id_usuario, $id_tipo_servicio_publico, $id_solicitud_servicio_publico, $fecha_servicio, $ticket_interno, $descripcion)
    {
        $sql = "INSERT INTO servicios_publicos (
                    id_beneficiario,
                    id_usuario,
                    id_tipo_servicio_publico,
                    id_solicitud_servicio_publico,
                    id_estado_solicitud,
                    tipo_servicio,
                    solicitud_servicio,
                    fecha_servicio,
                    ticket_interno,
                    descripcion,
                    estado
                )
                SELECT
                    '$id_beneficiario',
                    '$id_usuario',
                    tsp.id_tipo_servicio_publico,
                    sg.id_solicitud_general,
                    (SELECT id_estado_solicitud FROM estados_solicitudes WHERE codigo_estado = 'REGISTRADA' AND estado = 1 LIMIT 1),
                    tsp.nombre_tipo_servicio,
                    sg.nombre_solicitud,
                    '$fecha_servicio',
                    '',
                    '$descripcion',
                    1
                FROM tipos_servicios_publicos AS tsp
                INNER JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = '$id_solicitud_servicio_publico'
                WHERE tsp.id_tipo_servicio_publico = '$id_tipo_servicio_publico'
                  AND tsp.estado = 1
                  AND sg.estado = 1";

        return ejecutarConsulta_retornarID($sql);
    }

    public function editar($id_servicio, $id_beneficiario, $id_usuario, $id_tipo_servicio_publico, $id_solicitud_servicio_publico, $fecha_servicio, $ticket_interno, $descripcion)
    {
        $sql = "UPDATE servicios_publicos AS sp
                INNER JOIN tipos_servicios_publicos AS tsp
                    ON tsp.id_tipo_servicio_publico = '$id_tipo_servicio_publico'
                   AND tsp.estado = 1
                INNER JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = '$id_solicitud_servicio_publico'
                   AND sg.estado = 1
                SET sp.id_beneficiario = '$id_beneficiario',
                    sp.id_usuario = '$id_usuario',
                    sp.id_tipo_servicio_publico = tsp.id_tipo_servicio_publico,
                    sp.id_solicitud_servicio_publico = sg.id_solicitud_general,
                    sp.tipo_servicio = tsp.nombre_tipo_servicio,
                    sp.solicitud_servicio = sg.nombre_solicitud,
                    sp.fecha_servicio = '$fecha_servicio',
                    sp.descripcion = '$descripcion'
                WHERE sp.id_servicio = '$id_servicio'";

        return ejecutarConsulta($sql);
    }

    public function asegurarTicketInterno($idServicio)
    {
        $registro = $this->obtenerRegistroTicket($idServicio);
        if (!$registro) {
            return "";
        }

        $ticketActual = trim((string) $registro["ticket_interno"]);
        if ($ticketActual !== "") {
            return $ticketActual;
        }

        $ticketNuevo = $this->generarTicketInterno((int) $registro["id_servicio"], $registro["fecha_servicio"]);
        $ticketEscapado = $this->esc($ticketNuevo);
        $idServicio = (int) $registro["id_servicio"];

        ejecutarConsulta("UPDATE servicios_publicos SET ticket_interno = '$ticketEscapado' WHERE id_servicio = '$idServicio'");
        return $ticketNuevo;
    }

    public function activar($id_servicio)
    {
        $sql = "UPDATE servicios_publicos
                SET estado = 1
                WHERE id_servicio = '$id_servicio'";

        return ejecutarConsulta($sql);
    }

    public function desactivar($id_servicio)
    {
        $sql = "UPDATE servicios_publicos
                SET estado = 0
                WHERE id_servicio = '$id_servicio'";

        return ejecutarConsulta($sql);
    }

    public function mostrar($id_servicio)
    {
        $sql = "SELECT sp.id_servicio,
                       sp.ticket_interno,
                       sp.id_beneficiario,
                       sp.id_usuario,
                       sp.id_tipo_servicio_publico,
                       sp.id_solicitud_servicio_publico,
                       sp.id_estado_solicitud,
                       COALESCE(tsp.nombre_tipo_servicio, sp.tipo_servicio) AS tipo_servicio,
                       COALESCE(sg.nombre_solicitud, sp.solicitud_servicio) AS solicitud_servicio,
                       COALESCE(es.nombre_estado, 'Registrada') AS estado_solicitud,
                       COALESCE(es.codigo_estado, 'REGISTRADA') AS codigo_estado_solicitud,
                       COALESCE(es.clase_badge, 'draft') AS clase_badge_estado_solicitud,
                       COALESCE(es.es_atendida, 0) AS es_atendida,
                       CASE
                           WHEN tsp.codigo_tipo_servicio_publico IS NOT NULL AND tsp.codigo_tipo_servicio_publico <> ''
                               THEN CONCAT(tsp.codigo_tipo_servicio_publico, ' - ', tsp.nombre_tipo_servicio)
                           ELSE COALESCE(tsp.nombre_tipo_servicio, sp.tipo_servicio)
                       END AS tipo_servicio_texto,
                       CASE
                           WHEN sg.codigo_solicitud IS NOT NULL AND sg.codigo_solicitud <> ''
                               THEN CONCAT(sg.codigo_solicitud, ' - ', sg.nombre_solicitud)
                           ELSE COALESCE(sg.nombre_solicitud, sp.solicitud_servicio)
                       END AS solicitud_servicio_texto,
                       sp.fecha_servicio,
                       sp.descripcion,
                       sp.estado,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono,
                       CONCAT(b.nacionalidad, '-', b.cedula, ' ', b.nombre_beneficiario) AS beneficiario
                FROM servicios_publicos AS sp
                LEFT JOIN tipos_servicios_publicos AS tsp
                    ON tsp.id_tipo_servicio_publico = sp.id_tipo_servicio_publico
                LEFT JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = sp.id_solicitud_servicio_publico
                LEFT JOIN estados_solicitudes AS es
                    ON es.id_estado_solicitud = sp.id_estado_solicitud
                LEFT JOIN beneficiarios AS b
                    ON b.id_beneficiario = sp.id_beneficiario
                WHERE sp.id_servicio = '$id_servicio'
                LIMIT 1";

        $registro = ejecutarConsultaSimpleFila($sql);
        if ($registro) {
            $ultimoSeguimiento = $this->obtenerUltimoSeguimientoEstado($id_servicio);
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
        $sql = "SELECT sp.id_servicio,
                       sp.ticket_interno,
                       sp.id_beneficiario,
                       sp.id_usuario,
                       sp.id_tipo_servicio_publico,
                       sp.id_solicitud_servicio_publico,
                       sp.id_estado_solicitud,
                       COALESCE(tsp.nombre_tipo_servicio, sp.tipo_servicio) AS tipo_servicio,
                       COALESCE(sg.nombre_solicitud, sp.solicitud_servicio) AS solicitud_servicio,
                       COALESCE(es.nombre_estado, 'Registrada') AS estado_solicitud,
                       COALESCE(es.codigo_estado, 'REGISTRADA') AS codigo_estado_solicitud,
                       COALESCE(es.clase_badge, 'draft') AS clase_badge_estado_solicitud,
                       COALESCE(es.es_atendida, 0) AS es_atendida,
                       CASE
                           WHEN tsp.codigo_tipo_servicio_publico IS NOT NULL AND tsp.codigo_tipo_servicio_publico <> ''
                               THEN CONCAT(tsp.codigo_tipo_servicio_publico, ' - ', tsp.nombre_tipo_servicio)
                           ELSE COALESCE(tsp.nombre_tipo_servicio, sp.tipo_servicio)
                       END AS tipo_servicio_texto,
                       CASE
                           WHEN sg.codigo_solicitud IS NOT NULL AND sg.codigo_solicitud <> ''
                               THEN CONCAT(sg.codigo_solicitud, ' - ', sg.nombre_solicitud)
                           ELSE COALESCE(sg.nombre_solicitud, sp.solicitud_servicio)
                       END AS solicitud_servicio_texto,
                       sp.fecha_servicio,
                       DATE_FORMAT(sp.fecha_servicio, '%d/%m/%Y') AS fecha_servicio_formateada,
                       sp.descripcion,
                       sp.estado,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono
                FROM servicios_publicos AS sp
                LEFT JOIN tipos_servicios_publicos AS tsp
                    ON tsp.id_tipo_servicio_publico = sp.id_tipo_servicio_publico
                LEFT JOIN solicitudes_generales AS sg
                    ON sg.id_solicitud_general = sp.id_solicitud_servicio_publico
                LEFT JOIN estados_solicitudes AS es
                    ON es.id_estado_solicitud = sp.id_estado_solicitud
                LEFT JOIN beneficiarios AS b
                    ON b.id_beneficiario = sp.id_beneficiario
                WHERE sp.estado = 1
                ORDER BY sp.id_servicio DESC";

        return ejecutarConsulta($sql);
    }

    public function resumen()
    {
        $sql = "SELECT COUNT(sp.id_servicio) AS total,
                       SUM(CASE WHEN COALESCE(es.es_atendida, 0) = 1 THEN 1 ELSE 0 END) AS atendidas,
                       SUM(CASE WHEN COALESCE(es.es_atendida, 0) = 1 THEN 0 ELSE 1 END) AS pendientes
                FROM servicios_publicos AS sp
                LEFT JOIN estados_solicitudes AS es
                    ON es.id_estado_solicitud = sp.id_estado_solicitud
                WHERE sp.estado = 1";

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

    public function listarTiposServiciosPublicos($termino = "")
    {
        $filtro = "";
        if ($termino !== "") {
            $filtro = "AND (
                codigo_tipo_servicio_publico LIKE '%$termino%'
                OR nombre_tipo_servicio LIKE '%$termino%'
                OR CONCAT(codigo_tipo_servicio_publico, ' - ', nombre_tipo_servicio) LIKE '%$termino%'
            )";
        }

        $sql = "SELECT id_tipo_servicio_publico,
                       codigo_tipo_servicio_publico,
                       nombre_tipo_servicio
                FROM tipos_servicios_publicos
                WHERE estado = 1
                $filtro
                ORDER BY nombre_tipo_servicio ASC
                LIMIT 100";

        return ejecutarConsulta($sql);
    }

    public function listarSolicitudesServiciosPublicos($termino = "")
    {
        $filtro = "";
        if ($termino !== "") {
            $filtro = "AND (
                codigo_solicitud LIKE '%$termino%'
                OR nombre_solicitud LIKE '%$termino%'
                OR CONCAT(codigo_solicitud, ' - ', nombre_solicitud) LIKE '%$termino%'
            )";
        }

        $sql = "SELECT id_solicitud_general AS id_solicitud_servicio_publico,
                       codigo_solicitud AS codigo_solicitud_servicio_publico,
                       nombre_solicitud AS nombre_solicitud_servicio
                FROM solicitudes_generales
                WHERE estado = 1
                $filtro
                ORDER BY nombre_solicitud ASC
                LIMIT 100";

        return ejecutarConsulta($sql);
    }
}
?>
