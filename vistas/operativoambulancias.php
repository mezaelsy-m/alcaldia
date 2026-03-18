<?php
ob_start();
session_start();

if (!isset($_SESSION["nombre"])) {
    header("Location: login.html");
} else {
    require "header.php";

    if ($_SESSION["Emergencia"] == 1) {
?>
<section class="content" id="operativoAmbulanciasView">
    <div class="container-fluid">
        <div class="card operativo-page-card mt-2">
            <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                <h3 class="card-title">Control Operativo de Ambulancias</h3>
                <div class="d-flex align-items-center flex-wrap ml-auto" style="gap:8px;">
                    <a href="serviciosemergencia.php" class="btn btn-outline-secondary btn-sm">
                        <i class="fas fa-arrow-left"></i> Volver a emergencias
                    </a>
                </div>
            </div>
            <div class="card-body">
                <p class="text-muted mb-3">Desde esta vista puedes crear perfiles de chofer, dejar conectada una unidad disponible desde el mismo registro, administrar ambulancias y revisar en tiempo real cuales pares estan listos para la salida inmediata.</p>
                <?php include __DIR__ . "/partials/operativo_ambulancias_panel.php"; ?>
            </div>
        </div>
    </div>
</section>
<?php include __DIR__ . "/partials/operativo_ambulancias_modals.php"; ?>
<?php
    } else {
        require "noacceso.php";
    }

    require "footer.php";
?>
<script type="text/javascript" src="scripts/serviciosemergencia_new.js"></script>
<?php
}
ob_end_flush();
?>
