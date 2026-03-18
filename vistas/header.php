<?php
if (strlen(session_id()) < 1) {
    session_start();
}

$currentPage = basename($_SERVER["PHP_SELF"] ?? "");
$userName = isset($_SESSION["nombre"]) ? $_SESSION["nombre"] : "Usuario";
$employeeName = isset($_SESSION["nombre_empleado"]) ? trim((string) $_SESSION["nombre_empleado"]) : "";

if ($employeeName === "" && isset($_SESSION["idusuario"])) {
    if (!function_exists("ejecutarConsultaSimpleFila")) {
        require_once __DIR__ . "/../config/Conexion.php";
    }

    $idUsuarioSesion = (int) $_SESSION["idusuario"];
    if ($idUsuarioSesion > 0 && function_exists("ejecutarConsultaSimpleFila")) {
        $filaEmpleadoSesion = ejecutarConsultaSimpleFila(
            "SELECT TRIM(CONCAT(COALESCE(e.nombre, ''), ' ', COALESCE(e.apellido, ''))) AS nombre_empleado
             FROM usuarios u
             INNER JOIN empleados e ON e.id_empleado = u.id_empleado
             WHERE u.id_usuario = '" . $idUsuarioSesion . "'
             LIMIT 1"
        );

        if (is_array($filaEmpleadoSesion) && isset($filaEmpleadoSesion["nombre_empleado"])) {
            $nombreSesion = trim((string) $filaEmpleadoSesion["nombre_empleado"]);
            if ($nombreSesion !== "") {
                $employeeName = $nombreSesion;
                $_SESSION["nombre_empleado"] = $nombreSesion;
            }
        }
    }
}

if ($employeeName === "") {
    $employeeName = $userName;
}
$userRole = isset($_SESSION["rol"]) ? $_SESSION["rol"] : "Operador";

$pageTitles = array(
    "concepto.php" => "Escritorio",
    "configuracion.php" => "Configuracion",
    "beneficiarios.php" => "Beneficiarios",
    "ayudasocial.php" => "Ayuda Social",
    "serviciosemergencia.php" => "Seguridad y Emergencia",
    "operativoambulancias.php" => "Control Operativo de Ambulancias",
    "serviciospublicos.php" => "Servicios Publicos",
    "bitacora.php" => "Bitacora"
);
$currentTitle = isset($pageTitles[$currentPage]) ? $pageTitles[$currentPage] : "Sala Situacional";
$headerCssVersion = @filemtime(__DIR__ . "/css/header-professional.css");
$configCssVersion = @filemtime(__DIR__ . "/css/configuracion-maestra.css");
$operativoCssVersion = @filemtime(__DIR__ . "/css/operativo-ambulancias.css");
$faviconPath = "../assets/images/favicon.png";

$menuItems = array(
    array("perm" => "Concepto", "href" => "concepto.php", "icon" => "fas fa-chart-pie", "label" => "Panel General"),
    array("perm" => "Escritorio", "href" => "beneficiarios.php", "icon" => "fas fa-users", "label" => "Beneficiarios"),
    array("perm" => "Ayuda", "href" => "ayudasocial.php", "icon" => "fas fa-hands-helping", "label" => "Ayuda Social"),
    array("perm" => "Emergencia", "href" => "serviciosemergencia.php", "icon" => "fas fa-shield-alt", "label" => "Seguridad y Emergencia"),
    array("perm" => "Emergencia", "href" => "operativoambulancias.php", "icon" => "fas fa-ambulance", "label" => "Control Ambulancias"),
    array("perm" => "Publicos", "href" => "serviciospublicos.php", "icon" => "fas fa-building", "label" => "Servicios Publicos")
);

$bottomMenuItem = array("href" => "configuracion.php", "icon" => "fas fa-sliders-h", "label" => "Configuracion");
$bottomAllowed = (isset($_SESSION["Concepto"]) && (int) $_SESSION["Concepto"] === 1)
    || (isset($_SESSION["Usuarios"]) && (int) $_SESSION["Usuarios"] === 1)
    || (isset($_SESSION["Tribunal"]) && (int) $_SESSION["Tribunal"] === 1);
?>
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Sala Situacional Alcaldia Libertador</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Panel institucional de la Sala Situacional de la Alcaldia de Libertador">

    <link rel="icon" type="image/x-icon" href="<?php echo htmlspecialchars($faviconPath, ENT_QUOTES, "UTF-8"); ?>">

    <link rel="stylesheet" href="../assets/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="../assets/plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="../assets/plugins/datatables-responsive/css/responsive.bootstrap4.min.css">
    <link rel="stylesheet" href="../assets/plugins/select2/css/select2.min.css">
    <link rel="stylesheet" href="../assets/plugins/select2-bootstrap4-theme/select2-bootstrap4.min.css">
    <link rel="stylesheet" href="../assets/plugins/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
    <link rel="stylesheet" href="../assets/plugins/sweetalert2/sweetalert2.min.css">
    <link rel="stylesheet" href="../assets/dist/css/adminlte.min.css">
    <link rel="stylesheet" href="css/escritorio.css">
    <link rel="stylesheet" href="css/header-professional.css?v=<?php echo $headerCssVersion ?: time(); ?>">
    <link rel="stylesheet" href="css/configuracion-maestra.css?v=<?php echo $configCssVersion ?: time(); ?>">
    <link rel="stylesheet" href="css/operativo-ambulancias.css?v=<?php echo $operativoCssVersion ?: time(); ?>">
</head>

<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed text-sm">
    <div class="wrapper" id="theme-wrapper">

        <nav class="main-header navbar navbar-expand navbar-dark header-pro">
            <ul class="navbar-nav align-items-center">
                <li class="nav-item">
                    <a class="nav-link header-icon-btn" data-widget="pushmenu" href="#" role="button"
                        aria-label="Abrir o cerrar menu lateral">
                        <i class="fas fa-bars"></i>
                    </a>
                </li>
                <li class="nav-item d-none d-md-inline-flex">
                    <a href="concepto.php" class="nav-link header-home-link">
                        <i class="fas fa-home"></i>
                        <span>Inicio</span>
                    </a>
                </li>
            </ul>

            <div class="header-brand-inline d-none d-md-flex" aria-hidden="true">
                <div class="header-brand-copy">
                    <strong>Sala Situacional</strong>
                    <span>Alcaldia de Libertador</span>
                </div>
            </div>

            <ul class="navbar-nav ml-auto align-items-center">
                <li class="nav-item d-none d-sm-inline-flex">
                    <span class="nav-link header-user-chip">
                        <i class="fas fa-user-circle"></i>
                        <span><?php echo htmlspecialchars($employeeName, ENT_QUOTES, "UTF-8"); ?></span>
                    </span>
                </li>
                <li class="nav-item">
                    <a href="../ajax/usuarios.php?op=salir" class="nav-link header-logout-link">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Salir</span>
                    </a>
                </li>
            </ul>
        </nav>
        <aside class="main-sidebar sidebar-dark-navy elevation-4 sidebar-pro">
            <a href="concepto.php" class="brand-link sidebar-brand">
                <img src="../assets/images/logo_login.png" alt="Logo Institucional"
                    class="brand-image sidebar-brand-logo">
            </a>

            <div class="sidebar">
                <div class="sidebar-user-card mt-5">
                    <div class="sidebar-user-avatar">
                        <i class="fas fa-user-shield" aria-hidden="true"></i>
                    </div>
                    <div class="sidebar-user-meta">
                        <p class="sidebar-user-name"><?php echo htmlspecialchars($userName, ENT_QUOTES, "UTF-8"); ?></p>
                        <p class="sidebar-user-role">
                            <?php echo htmlspecialchars($userRole, ENT_QUOTES, "UTF-8"); ?> | En linea
                        </p>
                    </div>
                </div>

                <nav class="mt-2">
                    <ul class="nav nav-pills nav-sidebar flex-column nav-child-indent" data-widget="treeview"
                        role="menu" data-accordion="false">
                        <?php
          $visibleItems = 0;
          foreach ($menuItems as $item) {
              $isAllowed = isset($_SESSION[$item["perm"]]) && (int) $_SESSION[$item["perm"]] === 1;
              if (!$isAllowed) {
                  continue;
              }

              $visibleItems++;
              $isActive = $currentPage === $item["href"];
              ?>
                        <li class="nav-item">
                            <a href="<?php echo htmlspecialchars($item["href"], ENT_QUOTES, "UTF-8"); ?>"
                                class="nav-link<?php echo $isActive ? " active" : ""; ?>">
                                <i
                                    class="nav-icon <?php echo htmlspecialchars($item["icon"], ENT_QUOTES, "UTF-8"); ?>"></i>
                                <p><?php echo htmlspecialchars($item["label"], ENT_QUOTES, "UTF-8"); ?></p>
                            </a>
                        </li>
                        <?php
          }
          if ($visibleItems === 0) {
              ?>
                        <li class="nav-item nav-item-disabled">
                            <span class="nav-link">
                                <i class="nav-icon fas fa-lock"></i>
                                <p>Sin modulos habilitados</p>
                            </span>
                        </li>
                        <?php } ?>
                    </ul>
                </nav>

            </div>

            <?php
      if ($bottomAllowed) {
          $bottomActive = $currentPage === $bottomMenuItem["href"];
          ?>
            <div class="sidebar-bottom-slot">
                <a href="<?php echo htmlspecialchars($bottomMenuItem["href"], ENT_QUOTES, "UTF-8"); ?>"
                    class="nav-link sidebar-bottom-link<?php echo $bottomActive ? " active" : ""; ?>">
                    <i
                        class="nav-icon <?php echo htmlspecialchars($bottomMenuItem["icon"], ENT_QUOTES, "UTF-8"); ?>"></i>
                    <p><?php echo htmlspecialchars($bottomMenuItem["label"], ENT_QUOTES, "UTF-8"); ?></p>
                </a>
            </div>
            <?php } ?>
        </aside>

        <div class="content-wrapper">
            <div class="content-header header-context">
                <div class="container-fluid header-context-shell">
                    <div class="row mb-2 align-items-center header-context-panel">
                        <div class="col-sm-6">
                            <h1 class="m-0"><?php echo htmlspecialchars($currentTitle, ENT_QUOTES, "UTF-8"); ?></h1>
                            <small>Gestion operativa municipal</small>
                        </div>
                        <div class="col-sm-6">
                            <ol class="breadcrumb float-sm-right mb-0">
                                <li class="breadcrumb-item"><a href="concepto.php">Inicio</a></li>
                                <li class="breadcrumb-item active">
                                    <?php echo htmlspecialchars($currentTitle, ENT_QUOTES, "UTF-8"); ?></li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
