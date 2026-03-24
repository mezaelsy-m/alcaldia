<?php 
// Incluimos inicialmente la conexion a la base de datos
require_once "../config/Conexion.php";

Class Bitacora
{
	// Implementamos nuestro constructor
	public function __construct()
	{

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

	private function sqlNullableString($valor)
	{
		if ($valor === null) {
			return "NULL";
		}

		$valor = trim((string) $valor);
		if ($valor === "") {
			return "NULL";
		}

		return "'" . $this->esc($valor) . "'";
	}

	private function sqlNullableInt($valor)
	{
		$valor = (int) $valor;
		return $valor > 0 ? "'" . $valor . "'" : "NULL";
	}

	private function obtenerIpActual()
	{
		return isset($_SERVER["REMOTE_ADDR"]) ? (string) $_SERVER["REMOTE_ADDR"] : "127.0.0.1";
	}

	// Implementamos un metodo para insertar registros en bitacora
	public function insertar($idusuario, $detalle)
	{
		return $this->registrarEvento(
			$idusuario,
			"SISTEMA",
			"OPERACION",
			null,
			"Operacion del sistema",
			$detalle
		);
	}

	public function registrarEvento($idusuario, $tablaAfectada, $accion, $idRegistro, $resumen, $detalle, $datosAntes = null, $datosDespues = null, $ipaddr = null, $estado = 1)
	{
		$ipaddr = $ipaddr !== null ? $ipaddr : $this->obtenerIpActual();
		$sql = "CALL sp_bitacora_registrar_evento("
			. $this->sqlNullableInt($idusuario) . ", "
			. $this->sqlNullableString($tablaAfectada) . ", "
			. $this->sqlNullableString($accion) . ", "
			. $this->sqlNullableString($idRegistro) . ", "
			. $this->sqlNullableString($resumen) . ", "
			. $this->sqlNullableString($detalle) . ", "
			. $this->sqlNullableString($datosAntes) . ", "
			. $this->sqlNullableString($datosDespues) . ", "
			. $this->sqlNullableString($ipaddr) . ", "
			. "'" . (int) $estado . "'"
			. ")";

		return ejecutarProcedimientoNoResultado($sql);
	}

	// Implementar un metodo para mostrar los datos de un registro
	public function mostrar($id_bitacora)
	{
		$sql="SELECT id_bitacora,
		            id_usuario,
		            usuario_login,
		            usuario_nombre,
		            usuario_mostrar,
		            tabla_afectada,
		            accion,
		            origen_evento,
		            resumen,
		            detalle,
		            ipaddr,
		            fecha_evento,
		            fecha_evento_formateada,
		            estado
		      FROM vw_bitacora_sistema
		      WHERE id_bitacora='$id_bitacora'
		      LIMIT 1";
		return ejecutarConsultaSimpleFila($sql);
	}

	// Implementar un metodo para listar los registros
	public function listar()
	{
		$sql="SELECT id_bitacora,
		             id_usuario,
		             usuario_login,
		             usuario_nombre,
		             usuario_mostrar,
		             tabla_afectada,
		             accion,
		             origen_evento,
		             resumen,
		             detalle,
		             ipaddr,
		             fecha_evento,
		             fecha_evento_formateada
		      FROM vw_bitacora_sistema
		      WHERE estado = 1
		      ORDER BY id_bitacora DESC";
		return ejecutarConsulta($sql);
	}

	public function listarAutenticacion($fechaDesde = null, $fechaHasta = null, $usuario = "", $accion = "")
	{
		$sql = "CALL sp_bitacora_consultar_autenticacion("
			. $this->sqlNullableString($fechaDesde) . ", "
			. $this->sqlNullableString($fechaHasta) . ", "
			. $this->sqlNullableString($usuario) . ", "
			. $this->sqlNullableString($accion)
			. ")";

		return ejecutarProcedimientoLista($sql);
	}
}

?>
