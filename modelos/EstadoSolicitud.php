<?php
require_once "../config/Conexion.php";

class EstadoSolicitud
{
    private function db()
    {
        global $conexion;
        return $conexion;
    }

    private function esc($valor)
    {
        return mysqli_real_escape_string($this->db(), (string) $valor);
    }

    public function listarActivos()
    {
        $sql = "SELECT id_estado_solicitud,
                       codigo_estado,
                       nombre_estado,
                       descripcion,
                       clase_badge,
                       es_atendida,
                       orden_visual
                FROM estados_solicitudes
                WHERE estado = 1
                ORDER BY orden_visual ASC, nombre_estado ASC";

        return ejecutarConsulta($sql);
    }

    public function obtener($idEstadoSolicitud)
    {
        $idEstadoSolicitud = (int) $idEstadoSolicitud;
        $sql = "SELECT id_estado_solicitud,
                       codigo_estado,
                       nombre_estado,
                       descripcion,
                       clase_badge,
                       es_atendida
                FROM estados_solicitudes
                WHERE id_estado_solicitud = '$idEstadoSolicitud'
                  AND estado = 1
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    public function obtenerIdPorCodigo($codigoEstado)
    {
        $codigoEstado = $this->esc(strtoupper(trim((string) $codigoEstado)));
        $sql = "SELECT id_estado_solicitud
                FROM estados_solicitudes
                WHERE codigo_estado = '$codigoEstado'
                  AND estado = 1
                LIMIT 1";

        $fila = ejecutarConsultaSimpleFila($sql);
        return $fila ? (int) $fila["id_estado_solicitud"] : 0;
    }

    public function registrarSeguimiento($modulo, $idReferencia, $idEstadoSolicitud, $idUsuario, $fechaGestion, $observacion)
    {
        $modulo = strtoupper(trim((string) $modulo));
        $idReferencia = (int) $idReferencia;
        $idEstadoSolicitud = (int) $idEstadoSolicitud;
        $idUsuario = (int) $idUsuario;
        $fechaGestion = trim((string) $fechaGestion);
        $observacion = $this->esc($observacion);

        if ($fechaGestion === "") {
            $fechaGestion = date("Y-m-d H:i:s");
        }

        $fechaGestion = $this->esc($fechaGestion);
        $modulosValidos = array("AYUDA_SOCIAL", "SEGURIDAD", "SERVICIOS_PUBLICOS");
        if (!in_array($modulo, $modulosValidos, true) || $idReferencia <= 0 || $idEstadoSolicitud <= 0) {
            return false;
        }

        $sql = "INSERT INTO seguimientos_solicitudes (
                    modulo,
                    id_referencia,
                    id_estado_solicitud,
                    id_usuario,
                    fecha_gestion,
                    observacion,
                    estado
                ) VALUES (
                    '$modulo',
                    '$idReferencia',
                    '$idEstadoSolicitud',
                    " . ($idUsuario > 0 ? "'$idUsuario'" : "NULL") . ",
                    '$fechaGestion',
                    '$observacion',
                    1
                )";

        return ejecutarConsulta($sql);
    }

    public function obtenerUltimoSeguimiento($modulo, $idReferencia)
    {
        $modulo = $this->esc(strtoupper(trim((string) $modulo)));
        $idReferencia = (int) $idReferencia;

        $sql = "SELECT ss.id_seguimiento_solicitud,
                       ss.modulo,
                       ss.id_referencia,
                       ss.id_estado_solicitud,
                       ss.id_usuario,
                       ss.fecha_gestion,
                       DATE_FORMAT(ss.fecha_gestion, '%Y-%m-%dT%H:%i') AS fecha_gestion_input,
                       DATE_FORMAT(ss.fecha_gestion, '%d/%m/%Y %h:%i %p') AS fecha_gestion_formateada,
                       ss.observacion,
                       es.codigo_estado,
                       es.nombre_estado,
                       es.clase_badge,
                       es.es_atendida
                FROM seguimientos_solicitudes AS ss
                INNER JOIN estados_solicitudes AS es
                    ON es.id_estado_solicitud = ss.id_estado_solicitud
                WHERE ss.modulo = '$modulo'
                  AND ss.id_referencia = '$idReferencia'
                  AND ss.estado = 1
                ORDER BY ss.id_seguimiento_solicitud DESC
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }
}
?>
