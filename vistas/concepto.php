<?php
//Activamos el almacenamiento en el buffer
ob_start();
session_start();

if (!isset($_SESSION["nombre"]))
{
  header("Location: login.html");
}
else
{
require 'header.php';

if ($_SESSION['Concepto']==1)
{
?>

        <section class="content">
            <div class="container-fluid">
                <!-- Small boxes (Stat box) -->
                <div class="row">
                    <!-- Beneficiarios -->
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-info">
                            <div class="inner">
                                <h3 id="total-beneficiarios">0</h3>
                                <p>Beneficiarios Registrados</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-users"></i>
                            </div>
                            <a href="beneficiarios.php" class="small-box-footer">Más info <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                    
                    <!-- Ayuda Social -->
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-success">
                            <div class="inner">
                                <h3 id="total-ayudas">0</h3>
                                <p>Ayudas Sociales</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-hands-helping"></i>
                            </div>
                            <a href="ayudasocial.php" class="small-box-footer">Más info <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                    
                    <!-- Servicios Públicos -->
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-warning">
                            <div class="inner">
                                <h3 id="total-servicios">0</h3>
                                <p>Servicios Públicos</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-building"></i>
                            </div>
                            <a href="serviciospublicos.php" class="small-box-footer">Más info <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                    
                    <!-- Seguridad -->
                    <div class="col-lg-3 col-6">
                        <div class="small-box bg-danger">
                            <div class="inner">
                                <h3 id="total-seguridad">0</h3>
                                <p>Seguridad y Emergencia</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <a href="serviciosemergencia.php" class="small-box-footer">Más info <i class="fas fa-arrow-circle-right"></i></a>
                        </div>
                    </div>
                </div>
                
                <!-- Statistics Row -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title">
                                    <i class="fas fa-chart-pie mr-2"></i>
                                    Estadísticas Generales del Sistema
                                </h3>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-3 col-sm-6">
                                        <div class="info-box">
                                            <span class="info-box-icon bg-info"><i class="fas fa-users"></i></span>
                                            <div class="info-box-content">
                                                <span class="info-box-text">Total Beneficiarios</span>
                                                <span class="info-box-number" id="stat-beneficiarios">0</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3 col-sm-6">
                                        <div class="info-box">
                                            <span class="info-box-icon bg-success"><i class="fas fa-hands-helping"></i></span>
                                            <div class="info-box-content">
                                                <span class="info-box-text">Ayudas Entregadas</span>
                                                <span class="info-box-number" id="stat-ayudas">0</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3 col-sm-6">
                                        <div class="info-box">
                                            <span class="info-box-icon bg-warning"><i class="fas fa-building"></i></span>
                                            <div class="info-box-content">
                                                <span class="info-box-text">Servicios Realizados</span>
                                                <span class="info-box-number" id="stat-servicios">0</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3 col-sm-6">
                                        <div class="info-box">
                                            <span class="info-box-icon bg-danger"><i class="fas fa-shield-alt"></i></span>
                                            <div class="info-box-content">
                                                <span class="info-box-text">Emergencias Atendidas</span>
                                                <span class="info-box-number" id="stat-emergencias">0</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
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

<script>
console.log('Escritorio cargado - Módulos visibles');
</script>
<script type="text/javascript" src="scripts/concepto.js"></script>
<?php 
}
ob_end_flush();
?>
