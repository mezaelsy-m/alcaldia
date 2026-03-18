<?php
ob_start();
session_start();

if (!isset($_SESSION["nombre"])) {
    header("Location: login.php");
} else {
    require "header.php";

    $puedeCatalogos = isset($_SESSION["Concepto"]) && (int) $_SESSION["Concepto"] === 1;
    $puedeUsuarios = isset($_SESSION["Usuarios"]) && (int) $_SESSION["Usuarios"] === 1;
    $puedeBitacora = isset($_SESSION["Tribunal"]) && (int) $_SESSION["Tribunal"] === 1;
    $puedeEmpleados = $puedeCatalogos || $puedeUsuarios;
    $puedeSmtp = $puedeCatalogos || $puedeUsuarios;
    if ($puedeCatalogos) {
        $tabInicial = "catalogos";
    } elseif ($puedeUsuarios) {
        $tabInicial = "usuarios";
    } elseif ($puedeEmpleados) {
        $tabInicial = "empleados";
    } elseif ($puedeSmtp) {
        $tabInicial = "smtp";
    } elseif ($puedeBitacora) {
        $tabInicial = "bitacora";
    } else {
        $tabInicial = "catalogos";
    }

    if ($puedeCatalogos || $puedeUsuarios || $puedeBitacora) {
?>
<section class="content" id="configuracionHubView" data-can-catalogs="<?php echo $puedeCatalogos ? 1 : 0; ?>"
    data-can-users="<?php echo $puedeUsuarios ? 1 : 0; ?>" data-can-employees="<?php echo $puedeEmpleados ? 1 : 0; ?>"
    data-can-smtp="<?php echo $puedeSmtp ? 1 : 0; ?>" data-can-bitacora="<?php echo $puedeBitacora ? 1 : 0; ?>">
    <div class="container-fluid">
        <div class="config-hub-switcher mb-3 mt-2">
            <ul class="nav nav-tabs config-hub-tabs" id="configuracionRootTabs" role="tablist">
                <?php if ($puedeCatalogos) { ?>
                <li class="nav-item" role="presentation">
                    <a class="nav-link<?php echo $tabInicial === "catalogos" ? " active" : ""; ?>" data-toggle="tab"
                        href="#configuracion-root-catalogos" role="tab"
                        aria-selected="<?php echo $tabInicial === "catalogos" ? "true" : "false"; ?>">
                        <i class="fas fa-sliders-h"></i>
                        <span>Tablas maestras</span>
                    </a>
                </li>
                <?php } ?>
                <?php if ($puedeUsuarios) { ?>
                <li class="nav-item" role="presentation">
                    <a class="nav-link<?php echo $tabInicial === "usuarios" ? " active" : ""; ?>" data-toggle="tab"
                        href="#configuracion-root-usuarios" role="tab"
                        aria-selected="<?php echo $tabInicial === "usuarios" ? "true" : "false"; ?>">
                        <i class="fas fa-user-cog"></i>
                        <span>Usuarios del sistema</span>
                    </a>
                </li>
                <?php } ?>
                <?php if ($puedeEmpleados) { ?>
                <li class="nav-item" role="presentation">
                    <a class="nav-link" data-toggle="tab" href="#configuracion-root-empleados" role="tab"
                        aria-selected="false">
                        <i class="fas fa-id-badge"></i>
                        <span>Empleados</span>
                    </a>
                </li>
                <?php } ?>
                <?php if ($puedeSmtp) { ?>
                <li class="nav-item" role="presentation">
                    <a class="nav-link" data-toggle="tab" href="#configuracion-root-smtp" role="tab"
                        aria-selected="false">
                        <i class="fas fa-envelope-open-text"></i>
                        <span>SMTP</span>
                    </a>
                </li>
                <?php } ?>
                <?php if ($puedeBitacora) { ?>
                <li class="nav-item" role="presentation">
                    <a class="nav-link<?php echo $tabInicial === "bitacora" ? " active" : ""; ?>" data-toggle="tab"
                        href="#configuracion-root-bitacora" role="tab"
                        aria-selected="<?php echo $tabInicial === "bitacora" ? "true" : "false"; ?>">
                        <i class="fas fa-history"></i>
                        <span>Bitacora</span>
                    </a>
                </li>
                <?php } ?>
            </ul>
        </div>

        <div class="tab-content">
            <?php if ($puedeCatalogos) { ?>
            <div class="tab-pane fade<?php echo $tabInicial === "catalogos" ? " show active" : ""; ?>"
                id="configuracion-root-catalogos" role="tabpanel">
                <div class="row mb-3 mt-2" id="configuracionResumenGeneral">
                    <div class="col-12">
                        <div class="config-master-empty">Cargando centro de configuracion...</div>
                    </div>
                </div>

                <div class="card config-master-shell">
                    <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <h3 class="card-title">Configuracion maestra centralizada</h3>
                        </div>
                        <div class="card-tools">
                            <button type="button" class="btn btn-outline-secondary btn-sm icon-only-btn"
                                id="btnRecargarConfiguracion" title="Actualizar configuracion"
                                aria-label="Actualizar configuracion">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="row no-gutters">
                            <div class="col-lg-3 config-master-sidebar">
                                <div class="p-3 p-lg-4">
                                    <div class="config-master-sidebar-head">
                                        <p class="eyebrow">Centro administrativo</p>
                                        <h4>Catalogos maestros</h4>
                                        <p>Usa las pestanas para cargar, editar, desactivar o reactivar las tablas base
                                            que
                                            alimentan los modulos del sistema.</p>
                                    </div>
                                    <div class="nav flex-column nav-pills config-master-nav" id="configuracionTabsNav"
                                        role="tablist" aria-orientation="vertical">
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-9">
                                <div class="p-3 p-lg-4">
                                    <div class="tab-content" id="configuracionTabsContent">
                                        <div class="config-master-empty">Preparando panel de configuracion...</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <?php } ?>

            <?php if ($puedeUsuarios) { ?>
            <div class="tab-pane fade<?php echo $tabInicial === "usuarios" ? " show active" : ""; ?>"
                id="configuracion-root-usuarios" role="tabpanel">
                <div class="row mb-3 mt-2" id="configuracionUsuariosResumen">
                    <div class="col-12">
                        <div class="config-master-empty">Cargando panel de usuarios...</div>
                    </div>
                </div>

                <div class="card config-master-shell config-users-shell">
                    <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <h3 class="card-title">Usuarios del sistema</h3>
                            <br>
                            <p class="card-subtitle mb-0">Administra cuentas, dependencias, roles y permisos
                                operativos desde
                                un solo lugar.</p>
                        </div>
                        <div class="card-tools">
                            <button type="button" class="btn btn-primary btn-sm" id="btnNuevoUsuarioSistema">
                                <i class="fas fa-user-plus"></i> Nuevo usuario
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm icon-only-btn"
                                id="btnRecargarUsuariosConfiguracion" title="Actualizar usuarios"
                                aria-label="Actualizar usuarios">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body table-responsive p-3">
                        <div class="row mb-3 align-items-end">
                            <div class="col-lg-5">
                                <label for="buscadorUsuariosSistema" class="sr-only">Buscar usuarios</label>
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                    </div>
                                    <input type="search" class="form-control" id="buscadorUsuariosSistema"
                                        placeholder="Buscar por usuario, empleado, cedula o dependencia"
                                        autocomplete="off">
                                </div>
                            </div>
                            <div class="col-lg-4 mt-2 mt-lg-0">
                                <div class="btn-group btn-group-sm config-master-state-filter d-flex" role="group"
                                    aria-label="Filtrar usuarios por estado">
                                    <button type="button" class="btn btn-primary active js-user-state-filter"
                                        data-filter="activos">Activos</button>
                                    <button type="button" class="btn btn-outline-secondary js-user-state-filter"
                                        data-filter="inactivos">Inactivos</button>
                                    <button type="button" class="btn btn-outline-secondary js-user-state-filter"
                                        data-filter="todos">Todos</button>
                                </div>
                            </div>
                            <div class="col-lg-3 text-lg-right mt-2 mt-lg-0" id="usuariosSistemaLength"></div>
                        </div>

                        <table id="tblUsuariosSistema"
                            class="table table-hover table-striped w-100 config-master-table">
                            <thead>
                                <tr>
                                    <th>Usuario</th>
                                    <th>Empleado</th>
                                    <th>Dependencia</th>
                                    <th>Rol</th>
                                    <th>Permisos</th>
                                    <th class="config-align-right">Acceso total</th>
                                    <th class="config-align-right">Estado</th>
                                    <th class="config-align-right">Acciones</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <?php } ?>

            <?php if ($puedeEmpleados) { ?>
            <div class="tab-pane fade" id="configuracion-root-empleados" role="tabpanel">
                <div class="row mb-3 mt-2" id="configuracionEmpleadosResumen">
                    <div class="col-12">
                        <div class="config-master-empty">Cargando panel de empleados...</div>
                    </div>
                </div>

                <div class="card config-master-shell config-users-shell">
                    <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <h3 class="card-title">Empleados institucionales</h3>
                            <br>
                            <p class="card-subtitle mb-0">Gestiona los datos del personal operativo y su dependencia
                                institucional.</p>
                        </div>
                        <div class="card-tools">
                            <button type="button" class="btn btn-primary btn-sm" id="btnNuevoEmpleadoSistema">
                                <i class="fas fa-user-plus"></i> Nuevo empleado
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm icon-only-btn"
                                id="btnRecargarEmpleadosConfiguracion" title="Actualizar empleados"
                                aria-label="Actualizar empleados">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body table-responsive p-3">
                        <div class="row mb-3 align-items-end">
                            <div class="col-lg-5">
                                <label for="buscadorEmpleadosSistema" class="sr-only">Buscar empleados</label>
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                    </div>
                                    <input type="search" class="form-control" id="buscadorEmpleadosSistema"
                                        placeholder="Buscar por cedula, nombre, correo o dependencia"
                                        autocomplete="off">
                                </div>
                            </div>
                            <div class="col-lg-4 mt-2 mt-lg-0">
                                <div class="btn-group btn-group-sm config-master-state-filter d-flex" role="group"
                                    aria-label="Filtrar empleados por estado">
                                    <button type="button" class="btn btn-primary active js-employee-state-filter"
                                        data-filter="activos">Activos</button>
                                    <button type="button" class="btn btn-outline-secondary js-employee-state-filter"
                                        data-filter="inactivos">Inactivos</button>
                                    <button type="button" class="btn btn-outline-secondary js-employee-state-filter"
                                        data-filter="todos">Todos</button>
                                </div>
                            </div>
                            <div class="col-lg-3 text-lg-right mt-2 mt-lg-0" id="empleadosSistemaLength"></div>
                        </div>

                        <table id="tblEmpleadosSistema"
                            class="table table-hover table-striped w-100 config-master-table">
                            <thead>
                                <tr>
                                    <th>Cedula</th>
                                    <th>Empleado</th>
                                    <th>Dependencia</th>
                                    <th>Telefono</th>
                                    <th>Correo</th>
                                    <th class="config-align-right">Estado</th>
                                    <th class="config-align-right">Acciones</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <?php } ?>

            <?php if ($puedeSmtp) { ?>
            <div class="tab-pane fade" id="configuracion-root-smtp" role="tabpanel">
                <div class="card config-master-shell config-smtp-shell">
                    <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <h3 class="card-title">Configuracion SMTP</h3>
                            <br>
                            <p class="card-subtitle mb-0">Define las credenciales de envio y ejecuta una prueba de
                                correo.</p>
                        </div>
                        <div class="card-tools">
                            <button type="button" class="btn btn-outline-secondary btn-sm icon-only-btn"
                                id="btnRecargarSmtpConfiguracion" title="Actualizar configuracion SMTP"
                                aria-label="Actualizar configuracion SMTP">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body p-3">
                        <div class="alert alert-info d-none" id="smtpConfiguracionNotice"></div>
                        <form id="formularioSmtpConfiguracion" novalidate>
                            <div class="form-row">
                                <div class="form-group col-md-6">
                                    <label for="smtpHost">Servidor SMTP <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="smtpHost" name="host"
                                        placeholder="smtp.gmail.com" maxlength="150" required>
                                </div>
                                <div class="form-group col-md-3">
                                    <label for="smtpPuerto">Puerto <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="smtpPuerto" name="puerto" min="1"
                                        max="65535" placeholder="587" required>
                                </div>
                                <div class="form-group col-md-3">
                                    <label for="smtpUsarTls">STARTTLS</label>
                                    <select id="smtpUsarTls" name="usar_tls" class="form-control">
                                        <option value="1">Si</option>
                                        <option value="0">No</option>
                                    </select>
                                </div>
                                <div class="form-group col-md-6">
                                    <label for="smtpUsuario">Usuario SMTP <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="smtpUsuario" name="usuario"
                                        placeholder="usuario@gmail.com" maxlength="150" required>
                                </div>
                                <div class="form-group col-md-6">
                                    <label for="smtpClave">Clave SMTP</label>
                                    <input type="password" class="form-control" id="smtpClave" name="clave"
                                        placeholder="Contrasena de aplicacion de Google" maxlength="255"
                                        autocomplete="new-password">
                                    <div class="modal-help">Deja vacio para conservar la clave ya guardada.</div>
                                </div>
                                <div class="form-group col-md-6">
                                    <label for="smtpCorreoRemitente">Correo remitente <span
                                            class="text-danger">*</span></label>
                                    <input type="email" class="form-control" id="smtpCorreoRemitente"
                                        name="correo_remitente" placeholder="usuario@gmail.com" maxlength="150"
                                        required>
                                </div>
                                <div class="form-group col-md-6">
                                    <label for="smtpNombreRemitente">Nombre remitente</label>
                                    <input type="text" class="form-control" id="smtpNombreRemitente"
                                        name="nombre_remitente" placeholder="Sala Situacional" maxlength="150">
                                </div>
                            </div>
                            <div class="text-right">
                                <button type="submit" class="btn btn-primary" id="btnGuardarSmtpConfiguracion">
                                    <i class="fas fa-save"></i> Guardar configuracion SMTP
                                </button>
                            </div>
                        </form>

                        <hr>

                        <div class="form-row align-items-end">
                            <div class="form-group col-md-8 mb-md-0">
                                <label for="smtpDestinatarioPrueba">Correo destino para prueba</label>
                                <input type="email" class="form-control" id="smtpDestinatarioPrueba"
                                    placeholder="destino@correo.com" maxlength="150">
                            </div>
                            <div class="form-group col-md-4 text-md-right mb-0">
                                <button type="button" class="btn btn-outline-primary btn-block"
                                    id="btnEnviarPruebaSmtp">
                                    <i class="fas fa-paper-plane"></i> Enviar prueba
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <?php } ?>

            <?php if ($puedeBitacora) { ?>
            <div class="tab-pane fade<?php echo $tabInicial === "bitacora" ? " show active" : ""; ?>"
                id="configuracion-root-bitacora" role="tabpanel">
                <div class="card config-master-shell config-users-shell">
                    <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <h3 class="card-title">Bitacora del sistema</h3>
                            <br>
                            <p class="card-subtitle mb-0">Consulta el historial de actividades y genera un reporte
                                rapido en PDF.</p>
                        </div>
                        <div class="card-tools">
                            <button type="button" class="btn btn-outline-danger btn-sm"
                                id="btnReporteBitacoraConfiguracion">
                                <i class="fas fa-file-pdf"></i> Reporte PDF
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm icon-only-btn"
                                id="btnRecargarBitacoraConfiguracion" title="Actualizar bitacora"
                                aria-label="Actualizar bitacora">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body table-responsive p-3">
                        <div class="row mb-3 align-items-end">
                            <div class="col-lg-9">
                                <label for="buscadorBitacoraSistema" class="sr-only">Buscar registros de bitacora</label>
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                    </div>
                                    <input type="search" class="form-control" id="buscadorBitacoraSistema"
                                        placeholder="Buscar por usuario, resumen o detalle" autocomplete="off">
                                </div>
                            </div>
                            <div class="col-lg-3 text-lg-right mt-2 mt-lg-0" id="bitacoraSistemaLength"></div>
                        </div>

                        <table id="tblBitacoraSistema"
                            class="table table-hover table-striped w-100 config-master-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Usuario</th>
                                    <th>Resumen</th>
                                    <th>Detalle</th>
                                    <th>Fecha y hora</th>
                                    <th>Direccion IP</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <?php } ?>
        </div>
    </div>
</section>

<?php if ($puedeCatalogos) { ?>
<div class="modal fade config-master-modal" id="configuracionCatalogoModal" tabindex="-1"
    aria-labelledby="configuracionCatalogoModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioConfiguracionCatalogo" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="configuracionCatalogoModalLabel">Nuevo registro</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="configuracionCatalogo" name="catalogo" value="">
                <input type="hidden" id="configuracionRegistroId" name="id_registro" value="">
                <div class="alert alert-info d-none" id="configuracionModalNotice"></div>
                <div class="form-row" id="configuracionModalFields"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardarConfiguracionCatalogo">
                    <i class="fas fa-save"></i> Guardar cambios
                </button>
            </div>
        </form>
    </div>
</div>
<?php } ?>

<?php if ($puedeUsuarios) { ?>
<div class="modal fade config-master-modal" id="usuarioSistemaModal" tabindex="-1"
    aria-labelledby="usuarioSistemaModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <form id="formularioUsuarioSistema" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="usuarioSistemaModalLabel">Nuevo usuario</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="usuarioSistemaId" name="id_registro" value="">
                <div class="alert alert-info d-none" id="usuarioSistemaNotice"></div>

                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="usuarioSistemaEmpleado">Empleado <span class="text-danger">*</span></label>
                        <select id="usuarioSistemaEmpleado" name="id_empleado" class="form-control" required></select>
                        <div class="modal-help">Busca por cedula o nombre para vincular la cuenta al empleado correcto.
                        </div>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="usuarioSistemaDependencia">Dependencia <span class="text-danger">*</span></label>
                        <select id="usuarioSistemaDependencia" name="id_dependencia" class="form-control"
                            required></select>
                        <div class="modal-help">Area institucional a la que estara adscrito este usuario.</div>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="usuarioSistemaUsuario">Usuario <span class="text-danger">*</span></label>
                        <input type="text" id="usuarioSistemaUsuario" name="usuario" class="form-control" maxlength="50"
                            placeholder="Ej: operador_sala" autocomplete="off" required>
                        <div class="modal-help">Nombre de acceso unico dentro del sistema.</div>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="usuarioSistemaRol">Rol <span class="text-danger">*</span></label>
                        <select id="usuarioSistemaRol" name="rol" class="form-control" required></select>
                        <div class="modal-help">Nivel funcional de la cuenta. El permiso de acceso total se controla
                            aparte.</div>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="usuarioSistemaPassword">Clave</label>
                        <input type="password" id="usuarioSistemaPassword" name="password" class="form-control"
                            minlength="6" placeholder="Minimo 6 caracteres" autocomplete="new-password">
                        <div class="modal-help">En edicion, deja este campo vacio si deseas conservar la clave actual.
                        </div>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="usuarioSistemaPasswordConfirm">Confirmar clave</label>
                        <input type="password" id="usuarioSistemaPasswordConfirm" name="confirmar_password"
                            class="form-control" minlength="6" placeholder="Repita la clave"
                            autocomplete="new-password">
                        <div class="modal-help">Debe coincidir con la clave indicada en el campo anterior.</div>
                    </div>
                    <div class="form-group col-12">
                        <label for="usuarioSistemaPermisos">Permisos operativos</label>
                        <select id="usuarioSistemaPermisos" name="id_permisos[]" class="form-control" multiple></select>
                        <div class="modal-help">Selecciona los accesos visibles para el usuario. El permiso especial de
                            acceso
                            total no se asigna desde aqui.</div>
                    </div>
                </div>

                <div class="config-user-special-access d-none" id="usuarioSistemaAccesoTotalPanel">
                    <div class="config-user-special-copy">
                        <p class="eyebrow">Permiso especial</p>
                        <h6>Acceso total del sistema</h6>
                        <p id="usuarioSistemaAccesoTotalTexto">Este usuario no tiene acceso total asignado.</p>
                    </div>
                    <div class="config-user-special-actions">
                        <span class="status-pill secondary" id="usuarioSistemaAccesoTotalBadge">No asignado</span>
                        <button type="button" class="btn btn-outline-primary btn-sm"
                            id="btnGestionarAccesoTotalUsuario">
                            Gestionar acceso total
                        </button>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardarUsuarioSistema">
                    <i class="fas fa-save"></i> Guardar usuario
                </button>
            </div>
        </form>
    </div>
</div>
<?php } ?>

<?php if ($puedeEmpleados) { ?>
<div class="modal fade config-master-modal" id="empleadoSistemaModal" tabindex="-1"
    aria-labelledby="empleadoSistemaModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioEmpleadoSistema" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="empleadoSistemaModalLabel">Nuevo empleado</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="empleadoSistemaId" name="id_registro" value="">
                <div class="alert alert-info d-none" id="empleadoSistemaNotice"></div>

                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="empleadoSistemaCedula">Cedula <span class="text-danger">*</span></label>
                        <input type="number" id="empleadoSistemaCedula" name="cedula" class="form-control"
                            placeholder="Ej: 12345678" min="1" step="1" required>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="empleadoSistemaDependencia">Dependencia <span class="text-danger">*</span></label>
                        <select id="empleadoSistemaDependencia" name="id_dependencia" class="form-control"
                            required></select>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="empleadoSistemaNombre">Nombre <span class="text-danger">*</span></label>
                        <input type="text" id="empleadoSistemaNombre" name="nombre" class="form-control" maxlength="100"
                            placeholder="Ej: Maria" autocomplete="off" required>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="empleadoSistemaApellido">Apellido <span class="text-danger">*</span></label>
                        <input type="text" id="empleadoSistemaApellido" name="apellido" class="form-control"
                            maxlength="100" placeholder="Ej: Gomez" autocomplete="off" required>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="empleadoSistemaTelefono">Telefono</label>
                        <input type="text" id="empleadoSistemaTelefono" name="telefono" class="form-control"
                            maxlength="20" placeholder="Ej: 0412-0000000" autocomplete="off">
                    </div>
                    <div class="form-group col-md-6">
                        <label for="empleadoSistemaCorreo">Correo</label>
                        <input type="email" id="empleadoSistemaCorreo" name="correo" class="form-control"
                            maxlength="150" placeholder="Ej: usuario@correo.com" autocomplete="off">
                    </div>
                    <div class="form-group col-12">
                        <label for="empleadoSistemaDireccion">Direccion</label>
                        <textarea id="empleadoSistemaDireccion" name="direccion" class="form-control" maxlength="255"
                            rows="3" placeholder="Direccion de contacto del empleado"></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardarEmpleadoSistema">
                    <i class="fas fa-save"></i> Guardar empleado
                </button>
            </div>
        </form>
    </div>
</div>
<?php } ?>
<?php
    } else {
        require "noacceso.php";
    }

    require "footer.php";
?>
<script type="text/javascript" src="scripts/configuracion_new.js"></script>
<?php
}
ob_end_flush();
?>

