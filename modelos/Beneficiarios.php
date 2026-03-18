<?php
require_once "../config/Conexion.php";

class Beneficiario
{
    public function __construct()
    {
    }

    public function insertar($nacionalidad, $cedula, $nombre_beneficiario, $telefono, $id_comunidad)
    {
        $sql = "INSERT INTO beneficiarios (
                    nacionalidad,
                    cedula,
                    nombre_beneficiario,
                    telefono,
                    id_comunidad,
                    comunidad,
                    fecha_registro,
                    estado
                )
                SELECT
                    '$nacionalidad',
                    '$cedula',
                    '$nombre_beneficiario',
                    '$telefono',
                    c.id_comunidad,
                    c.nombre_comunidad,
                    NOW(),
                    1
                FROM comunidades AS c
                WHERE c.id_comunidad = '$id_comunidad'
                  AND c.estado = 1";
        return ejecutarConsulta_retornarID($sql);
    }

    public function buscarPorCedula($cedula)
    {
        $sql = "SELECT b.id_beneficiario,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono,
                       b.id_comunidad,
                       COALESCE(c.nombre_comunidad, b.comunidad) AS comunidad,
                       b.estado
                FROM beneficiarios AS b
                LEFT JOIN comunidades AS c
                    ON c.id_comunidad = b.id_comunidad
                WHERE b.cedula = '$cedula'
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    public function editar($id_beneficiario, $nacionalidad, $cedula, $nombre_beneficiario, $telefono, $id_comunidad)
    {
        $sql = "UPDATE beneficiarios AS b
                INNER JOIN comunidades AS c
                    ON c.id_comunidad = '$id_comunidad'
                SET b.nacionalidad = '$nacionalidad',
                    b.cedula = '$cedula',
                    b.nombre_beneficiario = '$nombre_beneficiario',
                    b.telefono = '$telefono',
                    b.id_comunidad = c.id_comunidad,
                    b.comunidad = c.nombre_comunidad
                WHERE b.id_beneficiario = '$id_beneficiario'
                  AND c.estado = 1";
        return ejecutarConsulta($sql);
    }

    public function activar($id_beneficiario)
    {
        $sql = "UPDATE beneficiarios
                SET estado = 1
                WHERE id_beneficiario = '$id_beneficiario'";
        return ejecutarConsulta($sql);
    }

    public function desactivar($id_beneficiario)
    {
        $sql = "UPDATE beneficiarios
                SET estado = 0
                WHERE id_beneficiario = '$id_beneficiario'";
        return ejecutarConsulta($sql);
    }

    public function mostrar($id_beneficiario)
    {
        $sql = "SELECT b.id_beneficiario,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono,
                       b.id_comunidad,
                       COALESCE(c.nombre_comunidad, b.comunidad) AS comunidad,
                       b.fecha_registro,
                       DATE_FORMAT(b.fecha_registro, '%d/%m/%Y %h:%i %p') AS fecha_registro_12h,
                       b.estado
                FROM beneficiarios AS b
                LEFT JOIN comunidades AS c
                    ON c.id_comunidad = b.id_comunidad
                WHERE b.id_beneficiario = '$id_beneficiario'
                LIMIT 1";
        return ejecutarConsultaSimpleFila($sql);
    }

    public function listar()
    {
        $sql = "SELECT b.id_beneficiario,
                       b.nacionalidad,
                       b.cedula,
                       b.nombre_beneficiario,
                       b.telefono,
                       COALESCE(c.nombre_comunidad, b.comunidad) AS comunidad,
                       b.fecha_registro,
                       DATE_FORMAT(b.fecha_registro, '%d/%m/%Y %h:%i %p') AS fecha_registro_12h,
                       b.estado
                FROM beneficiarios AS b
                LEFT JOIN comunidades AS c
                    ON c.id_comunidad = b.id_comunidad
                WHERE b.estado = 1
                ORDER BY b.id_beneficiario DESC";
        return ejecutarConsulta($sql);
    }

    public function resumen()
    {
        $sql = "SELECT COUNT(id_beneficiario) AS total,
                       SUM(CASE WHEN estado = 1 THEN 1 ELSE 0 END) AS activos,
                       SUM(CASE WHEN estado = 0 THEN 1 ELSE 0 END) AS inactivos
                FROM beneficiarios";
        return ejecutarConsultaSimpleFila($sql);
    }

    public function selectbeneficiario()
    {
        $sql = "SELECT id_beneficiario, nacionalidad, cedula, nombre_beneficiario
                FROM beneficiarios
                WHERE estado = 1
                ORDER BY nombre_beneficiario ASC";
        return ejecutarConsulta($sql);
    }

    public function listarComunidades($termino = "")
    {
        $filtro = "";
        if ($termino !== "") {
            $filtro = "AND nombre_comunidad LIKE '%$termino%'";
        }

        $sql = "SELECT id_comunidad, nombre_comunidad
                FROM comunidades
                WHERE estado = 1
                $filtro
                ORDER BY nombre_comunidad ASC
                LIMIT 150";
        return ejecutarConsulta($sql);
    }
}
?>
