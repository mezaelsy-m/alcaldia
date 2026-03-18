<?php
//Activamos el almacenamiento en el buffer
ob_start();
session_start();
if (!isset($_SESSION["nombre"]))
{
  header("Location: login.php");
}
else
{
require 'header.php';

// Verificar si el usuario tiene permiso para acceder al módulo de bitácora
$tiene_permiso = isset($_SESSION['Tribunal']) && (int) $_SESSION['Tribunal'] === 1;

if ($tiene_permiso)
{
?>
    <!-- Inicio Contenido PHP-->
	
<section class="content">
      <div class="container-fluid">
            <div class="row">
                  <div class="col-12">
                        <div class="card" id="bitacora">
                              <div class="card-header">
                                    <h3 class="card-title">Bitácora del Sistema</h3>
                              </div>
                              <div class="card-header">
                                    <div class="row">
                                          <div class="form-group col-md-12 col-sm-12 col-xs-1">
						      <button class="btn btn-success" id="btnreporte" onclick="generarReportePDF()"><i class="fa fa-file-pdf"></i> Reporte PDF</button>
                                     </div>
				            </div>
                              </div>
                              <div class="card-header">
                                    <h3 class="card-title">Historial de Actividades</h3>
                               </div>
                                  <div class="card-body">
                                 <table id="tbllistado" class="table table-bordered table-hover">
                                    <thead>
                                          <tr>
                                                <th>ID</th>
                                                <th>Usuario</th>
                                                <th>Resumen</th>
                                                <th>Detalle</th>
                                                <th>Fecha y Hora</th>
                                                <th>Dirección IP</th>
                                          </tr>
                                    </thead>
                                  <tbody>
                                     
                                 </tbody>
                                  </table>
                             </div>
            <!-- /.card-body -->
          </div>
          <!-- /.card -->
      </div>
</section>

    <!-- Fin Contenido PHP-->
    <?php
}
else
{
  require 'noacceso.php';
}

require 'footer.php';
?>
        <script type="text/javascript" src="scripts/bitacora_new.js"></script>
<?php 
}
ob_end_flush();
?>

