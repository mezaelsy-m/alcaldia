<?php
ob_start();
session_start();

if (!isset($_SESSION["nombre"])) {
    header("Location: login.php");
} else {
    require "header.php";

    if (isset($_SESSION["Concepto"]) && (int) $_SESSION["Concepto"] === 1) {
        $canBeneficiarios = isset($_SESSION["Escritorio"]) && (int) $_SESSION["Escritorio"] === 1;
        $canAyuda = isset($_SESSION["Ayuda"]) && (int) $_SESSION["Ayuda"] === 1;
        $canPublicos = isset($_SESSION["Publicos"]) && (int) $_SESSION["Publicos"] === 1;
        $canEmergencia = isset($_SESSION["Emergencia"]) && (int) $_SESSION["Emergencia"] === 1;
        $canBitacora = isset($_SESSION["Tribunal"]) && (int) $_SESSION["Tribunal"] === 1;
        $canConfiguracion = (isset($_SESSION["Concepto"]) && (int) $_SESSION["Concepto"] === 1)
            || (isset($_SESSION["Usuarios"]) && (int) $_SESSION["Usuarios"] === 1)
            || (isset($_SESSION["Tribunal"]) && (int) $_SESSION["Tribunal"] === 1);

        $modulos = array(
            array(
                "enabled" => $canBeneficiarios,
                "href" => "beneficiarios.php",
                "icon" => "fas fa-users",
                "title" => "Beneficiarios",
                "subtitle" => "Ciudadanos activos",
                "stat_key" => "total_beneficiarios",
                "box_class" => "bg-info"
            ),
            array(
                "enabled" => $canAyuda,
                "href" => "ayudasocial.php",
                "icon" => "fas fa-hands-helping",
                "title" => "Ayuda Social",
                "subtitle" => "Solicitudes activas",
                "stat_key" => "total_ayudas",
                "box_class" => "bg-success"
            ),
            array(
                "enabled" => $canPublicos,
                "href" => "serviciospublicos.php",
                "icon" => "fas fa-building",
                "title" => "Servicios Publicos",
                "subtitle" => "Casos operativos",
                "stat_key" => "total_servicios",
                "box_class" => "bg-warning"
            ),
            array(
                "enabled" => $canEmergencia,
                "href" => "serviciosemergencia.php",
                "icon" => "fas fa-shield-alt",
                "title" => "Seguridad y Emergencia",
                "subtitle" => "Eventos activos",
                "stat_key" => "total_seguridad",
                "box_class" => "bg-danger"
            )
        );

        $indicadores = array(
            array(
                "enabled" => $canAyuda || $canPublicos || $canEmergencia,
                "icon_bg" => "bg-success",
                "icon" => "fas fa-check-circle",
                "label" => "Total atendidos",
                "stat_key" => "total_atendidos",
                "suffix" => ""
            ),
            array(
                "enabled" => $canAyuda || $canPublicos || $canEmergencia,
                "icon_bg" => "bg-warning",
                "icon" => "fas fa-clock",
                "label" => "Total pendientes",
                "stat_key" => "total_pendientes",
                "suffix" => ""
            ),
            array(
                "enabled" => true,
                "icon_bg" => "bg-primary",
                "icon" => "fas fa-calendar-alt",
                "label" => "Registros del mes",
                "stat_key" => "total_registros_mes",
                "suffix" => ""
            ),
            array(
                "enabled" => $canEmergencia,
                "icon_bg" => "bg-danger",
                "icon" => "fas fa-ambulance",
                "label" => "Traslados registrados",
                "stat_key" => "total_traslados",
                "suffix" => ""
            ),
            array(
                "enabled" => $canEmergencia,
                "icon_bg" => "bg-info",
                "icon" => "fas fa-ambulance",
                "label" => "Unidades disponibles",
                "stat_key" => "unidades_disponibles",
                "suffix" => ""
            ),
            array(
                "enabled" => $canAyuda || $canPublicos || $canEmergencia,
                "icon_bg" => "bg-secondary",
                "icon" => "fas fa-percentage",
                "label" => "Atencion global",
                "stat_key" => "porcentaje_atencion",
                "suffix" => "%"
            ),
            array(
                "enabled" => $canConfiguracion,
                "icon_bg" => "bg-dark",
                "icon" => "fas fa-user-cog",
                "label" => "Usuarios activos",
                "stat_key" => "total_usuarios_activos",
                "suffix" => ""
            )
        );

        $accesosRapidos = array(
            array(
                "enabled" => $canBeneficiarios,
                "href" => "beneficiarios.php",
                "icon" => "fas fa-user-plus",
                "label" => "Gestionar beneficiarios",
                "helper" => "Registro y consulta"
            ),
            array(
                "enabled" => $canAyuda,
                "href" => "ayudasocial.php",
                "icon" => "fas fa-hand-holding-heart",
                "label" => "Gestionar ayudas",
                "helper" => "Solicitudes y seguimiento"
            ),
            array(
                "enabled" => $canPublicos,
                "href" => "serviciospublicos.php",
                "icon" => "fas fa-city",
                "label" => "Gestionar servicios",
                "helper" => "Servicios publicos"
            ),
            array(
                "enabled" => $canEmergencia,
                "href" => "serviciosemergencia.php",
                "icon" => "fas fa-life-ring",
                "label" => "Atender emergencia",
                "helper" => "Despacho y control"
            ),
            array(
                "enabled" => $canEmergencia,
                "href" => "operativoambulancias.php",
                "icon" => "fas fa-ambulance",
                "label" => "Control ambulancias",
                "helper" => "Operacion en tiempo real"
            ),
            array(
                "enabled" => $canBitacora,
                "href" => "bitacora.php",
                "icon" => "fas fa-clipboard-list",
                "label" => "Ver bitacora",
                "helper" => "Trazabilidad del sistema"
            ),
            array(
                "enabled" => $canConfiguracion,
                "href" => "configuracion.php",
                "icon" => "fas fa-sliders-h",
                "label" => "Configuracion",
                "helper" => "Catalogos y permisos"
            )
        );

        $hayModulosActivos = false;
        foreach ($modulos as $modulo) {
            if ($modulo["enabled"]) {
                $hayModulosActivos = true;
                break;
            }
        }
?>
<section class="content">
    <div class="container-fluid">
        <div class="row mb-3 mt-3">
            <div class="col-12">
                <div class="card card-outline card-primary mb-0">
                    <div class="card-body d-flex flex-column flex-lg-row align-items-lg-center justify-content-between">
                        <div>
                            <h5 class="mb-1"><i class="fas fa-chart-line mr-2"></i>Panel operativo general</h5>
                            <p class="text-muted mb-0">Resumen en tiempo real de la gestion institucional y accesos
                                segun permisos.</p>
                        </div>
                        <span id="concepto-actualizado"
                            class="badge badge-light border mt-3 mt-lg-0 ml-lg-auto align-self-end align-self-lg-center concept-update-badge">Actualizando...</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <?php foreach ($modulos as $modulo) {
                if (!$modulo["enabled"]) {
                    continue;
                } ?>
            <div class="col-lg-3 col-md-6 col-12">
                <div class="small-box <?php echo htmlspecialchars($modulo["box_class"], ENT_QUOTES, "UTF-8"); ?>">
                    <div class="inner">
                        <h3 data-stat="<?php echo htmlspecialchars($modulo["stat_key"], ENT_QUOTES, "UTF-8"); ?>">0</h3>
                        <p class="mb-1"><?php echo htmlspecialchars($modulo["title"], ENT_QUOTES, "UTF-8"); ?></p>
                        <small><?php echo htmlspecialchars($modulo["subtitle"], ENT_QUOTES, "UTF-8"); ?></small>
                    </div>
                    <div class="icon">
                        <i class="<?php echo htmlspecialchars($modulo["icon"], ENT_QUOTES, "UTF-8"); ?>"></i>
                    </div>
                    <a href="<?php echo htmlspecialchars($modulo["href"], ENT_QUOTES, "UTF-8"); ?>"
                        class="small-box-footer">
                        Abrir modulo <i class="fas fa-arrow-circle-right"></i>
                    </a>
                </div>
            </div>
            <?php } ?>
            <?php if (!$hayModulosActivos) { ?>
            <div class="col-12">
                <div class="alert alert-info mb-3">
                    No tienes modulos operativos habilitados en este momento.
                </div>
            </div>
            <?php } ?>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header border-0">
                        <h3 class="card-title">
                            <i class="fas fa-chart-pie mr-2"></i>Indicadores clave
                        </h3>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <?php foreach ($indicadores as $indicador) {
                                if (!$indicador["enabled"]) {
                                    continue;
                                } ?>
                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-6">
                                <div class="info-box mb-3">
                                    <span
                                        class="info-box-icon <?php echo htmlspecialchars($indicador["icon_bg"], ENT_QUOTES, "UTF-8"); ?>">
                                        <i
                                            class="<?php echo htmlspecialchars($indicador["icon"], ENT_QUOTES, "UTF-8"); ?>"></i>
                                    </span>
                                    <div class="info-box-content">
                                        <span
                                            class="info-box-text"><?php echo htmlspecialchars($indicador["label"], ENT_QUOTES, "UTF-8"); ?></span>
                                        <span class="info-box-number"
                                            data-stat="<?php echo htmlspecialchars($indicador["stat_key"], ENT_QUOTES, "UTF-8"); ?>"
                                            data-suffix="<?php echo htmlspecialchars($indicador["suffix"], ENT_QUOTES, "UTF-8"); ?>">0<?php echo htmlspecialchars($indicador["suffix"], ENT_QUOTES, "UTF-8"); ?></span>
                                    </div>
                                </div>
                            </div>
                            <?php } ?>
                        </div>
                        <div id="concepto-error" class="alert alert-warning d-none mb-0">
                            No se pudieron cargar todas las estadisticas. Se muestran valores por defecto.
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header border-0">
                        <h3 class="card-title"><i class="fas fa-stream mr-2"></i>Casos recientes</h3>
                    </div>
                    <div class="card-body p-0">
                        <div id="concepto-casos-recientes" class="list-group list-group-flush">
                            <div class="list-group-item text-muted">Cargando casos recientes...</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="card">
                    <div class="card-header border-0">
                        <h3 class="card-title"><i class="fas fa-database mr-2"></i>Respaldo de bitacora</h3>
                    </div>
                    <div class="card-body">
                        <div id="concepto-respaldo-bitacora" class="text-muted">Consultando estado del respaldo...</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header border-0">
                        <h3 class="card-title"><i class="fas fa-bolt mr-2"></i>Accesos rapidos</h3>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <?php foreach ($accesosRapidos as $acceso) {
                                if (!$acceso["enabled"]) {
                                    continue;
                                } ?>
                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-6 mb-3">
                                <a href="<?php echo htmlspecialchars($acceso["href"], ENT_QUOTES, "UTF-8"); ?>"
                                    class="btn btn-outline-primary btn-block text-left concept-shortcut-btn">
                                    <span class="d-block font-weight-bold"><i
                                            class="<?php echo htmlspecialchars($acceso["icon"], ENT_QUOTES, "UTF-8"); ?> mr-2"></i><?php echo htmlspecialchars($acceso["label"], ENT_QUOTES, "UTF-8"); ?></span>
                                    <small
                                        class="d-block text-muted"><?php echo htmlspecialchars($acceso["helper"], ENT_QUOTES, "UTF-8"); ?></small>
                                </a>
                            </div>
                            <?php } ?>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
<?php
    } else {
        require "noacceso.php";
    }

    require "footer.php";

    $conceptoJsVersion = @filemtime(__DIR__ . "/scripts/concepto.js");
?>
<script type="text/javascript" src="scripts/concepto.js?v=<?php echo $conceptoJsVersion ?: time(); ?>"></script>
<?php
}
ob_end_flush();
?>
