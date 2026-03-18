<?php 
// Incluimos inicialmente la conexion a la base de datos
require_once "../config/Conexion.php";

Class Bitacora
{
	// Implementamos nuestro constructor
	public function __construct()
	{

	}

	// Implementamos un metodo para insertar registros en bitacora
	public function insertar($idusuario, $detalle)
	{
		$sql="INSERT INTO bitacora(id_usuario, resumen, detalle, moment) VALUES ('$idusuario', 'Operacion del sistema', '$detalle', NOW())";
		return ejecutarConsulta($sql);
	}

	// Implementar un metodo para mostrar los datos de un registro
	public function mostrar($id_bitacora)
	{
		$sql="SELECT id_bitacora,
		            id_usuario,
		            resumen,
		            detalle,
		            moment,
		            ipaddr
		      FROM bitacora
		      WHERE id_bitacora='$id_bitacora'
		      LIMIT 1";
		return ejecutarConsultaSimpleFila($sql);
	}

	// Implementar un metodo para listar los registros
	public function listar()
	{
		$sql="SELECT b.id_bitacora, b.id_usuario, b.resumen, b.detalle, b.moment 
			   FROM bitacora b 
			   ORDER BY b.id_bitacora DESC";
		return ejecutarConsulta($sql);
	}
}

?>
