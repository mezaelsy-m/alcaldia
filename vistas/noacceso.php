<?php
$nombreEmpleadoAcceso = isset($_SESSION["nombre_empleado"]) && trim((string) $_SESSION["nombre_empleado"]) !== ""
    ? trim((string) $_SESSION["nombre_empleado"])
    : (isset($_SESSION["nombre"]) ? trim((string) $_SESSION["nombre"]) : "Usuario");

$modulosPermitidos = array(
    array(
        "enabled" => isset($_SESSION["Concepto"]) && (int) $_SESSION["Concepto"] === 1,
        "href" => "concepto.php",
        "icon" => "fas fa-chart-pie",
        "label" => "Panel general"
    ),
    array(
        "enabled" => isset($_SESSION["Escritorio"]) && (int) $_SESSION["Escritorio"] === 1,
        "href" => "beneficiarios.php",
        "icon" => "fas fa-users",
        "label" => "Beneficiarios"
    ),
    array(
        "enabled" => isset($_SESSION["Ayuda"]) && (int) $_SESSION["Ayuda"] === 1,
        "href" => "ayudasocial.php",
        "icon" => "fas fa-hands-helping",
        "label" => "Ayuda social"
    ),
    array(
        "enabled" => isset($_SESSION["Publicos"]) && (int) $_SESSION["Publicos"] === 1,
        "href" => "serviciospublicos.php",
        "icon" => "fas fa-building",
        "label" => "Servicios publicos"
    ),
    array(
        "enabled" => isset($_SESSION["Emergencia"]) && (int) $_SESSION["Emergencia"] === 1,
        "href" => "serviciosemergencia.php",
        "icon" => "fas fa-shield-alt",
        "label" => "Seguridad y emergencia"
    ),
    array(
        "enabled" => isset($_SESSION["Emergencia"]) && (int) $_SESSION["Emergencia"] === 1,
        "href" => "operativoambulancias.php",
        "icon" => "fas fa-ambulance",
        "label" => "Control ambulancias"
    ),
    array(
        "enabled" => isset($_SESSION["Tribunal"]) && (int) $_SESSION["Tribunal"] === 1,
        "href" => "bitacora.php",
        "icon" => "fas fa-clipboard-list",
        "label" => "Bitacora"
    ),
    array(
        "enabled" => (isset($_SESSION["Concepto"]) && (int) $_SESSION["Concepto"] === 1)
            || (isset($_SESSION["Usuarios"]) && (int) $_SESSION["Usuarios"] === 1)
            || (isset($_SESSION["Tribunal"]) && (int) $_SESSION["Tribunal"] === 1),
        "href" => "configuracion.php",
        "icon" => "fas fa-sliders-h",
        "label" => "Configuracion"
    )
);

$hayModulosPermitidos = false;
foreach ($modulosPermitidos as $itemModuloPermitido) {
    if ($itemModuloPermitido["enabled"]) {
        $hayModulosPermitidos = true;
        break;
    }
}
?>
<section class="content">
    <div class="container-fluid">
        <div class="noaccess-shell">
            <div class="noaccess-card">
                <div class="noaccess-icon-wrap">
                    <span class="noaccess-icon">
                        <i class="fas fa-lock"></i>
                    </span>
                </div>
                <div class="noaccess-main">
                    <h2>Acceso restringido</h2>
                    <p>
                        No tienes permisos para entrar a esta seccion del sistema.
                        Si consideras que es un error, contacta al administrador.
                    </p>
                    <p class="noaccess-user-meta">
                        Sesion activa: <strong><?php echo htmlspecialchars($nombreEmpleadoAcceso, ENT_QUOTES, "UTF-8"); ?></strong>
                    </p>

                    <div class="noaccess-actions">
                        <a href="concepto.php" class="btn btn-primary noaccess-btn">
                            <i class="fas fa-home"></i> Ir al inicio
                        </a>
                        <a href="../ajax/usuarios.php?op=salir" class="btn btn-outline-danger noaccess-btn">
                            <i class="fas fa-sign-out-alt"></i> Cerrar sesion
                        </a>
                    </div>
                </div>
            </div>

            <div class="noaccess-modules-card">
                <h3><i class="fas fa-compass mr-2"></i>Modulos disponibles para tu perfil</h3>

                <?php if ($hayModulosPermitidos) { ?>
                <div class="noaccess-modules-grid">
                    <?php foreach ($modulosPermitidos as $moduloPermitido) {
                        if (!$moduloPermitido["enabled"]) {
                            continue;
                        } ?>
                    <a href="<?php echo htmlspecialchars($moduloPermitido["href"], ENT_QUOTES, "UTF-8"); ?>" class="noaccess-module-link">
                        <i class="<?php echo htmlspecialchars($moduloPermitido["icon"], ENT_QUOTES, "UTF-8"); ?>"></i>
                        <span><?php echo htmlspecialchars($moduloPermitido["label"], ENT_QUOTES, "UTF-8"); ?></span>
                    </a>
                    <?php } ?>
                </div>
                <?php } else { ?>
                <div class="alert alert-warning mb-0">
                    Tu usuario no tiene modulos habilitados por el momento.
                </div>
                <?php } ?>
            </div>
        </div>
    </div>
</section>
