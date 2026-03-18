<?php
ob_start();
session_start();

if (!isset($_SESSION["nombre"])) {
    header("Location: login.html");
} else {
    require "header.php";

    if ($_SESSION["Publicos"] == 1) {
?>
<section class="content" id="serviciosPublicosView">
    <div class="container-fluid">
        <style>
        .public-service-stat-card {
            border: 1px solid #dde4ee;
            border-radius: 12px;
            background: linear-gradient(180deg, #ffffff 0%, #f7fafc 100%);
            padding: 14px 16px;
            box-shadow: 0 6px 18px rgba(16, 37, 56, 0.06);
            height: 100%;
        }

        .public-service-stat-card .label {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: #72849a;
            margin: 0 0 6px;
        }

        .public-service-stat-card .value {
            margin: 0;
            font-size: 1.55rem;
            font-weight: 700;
            color: #15324b;
        }

        .public-service-card {
            border: 1px solid #dbe5ef;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 8px 22px rgba(16, 37, 56, 0.08);
        }

        .public-service-card .card-header {
            background: #f7fafc;
            border-bottom: 1px solid #dbe5ef;
        }

        .public-service-card .card-title {
            font-weight: 700;
            margin: 0;
        }

        .public-service-card .card-tools {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            margin-left: auto;
            gap: 8px;
        }

        .public-service-card .card-tools .btn-primary {
            margin-right: 10px;
        }

        .icon-only-btn {
            width: 34px;
            height: 34px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        #tbllistado_wrapper .dataTables_filter {
            display: none;
        }

        #tbllistado_wrapper .dataTables_length {
            margin: 0;
        }

        #tbllistado_wrapper .dataTables_length label {
            margin: 0;
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            justify-content: flex-end;
            gap: 4px;
            white-space: nowrap;
            text-align: right;
        }

        #tbllistado_wrapper .dataTables_length select {
            min-width: 74px;
            border-radius: 8px;
            border: 1px solid #cad8e8;
        }

        .status-pill {
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 0.78rem;
            font-weight: 700;
            display: inline-block;
        }

        .status-pill.active {
            background: #d9f6e8;
            color: #0f6b43;
        }

        .status-pill.inactive {
            background: #ffe8d8;
            color: #9a4816;
        }

        .status-pill.draft {
            background: #e8eef5;
            color: #486176;
        }

        .status-pill.info {
            background: #d8edff;
            color: #0d5f92;
        }

        .status-pill.warning {
            background: #fff2d8;
            color: #8a5a00;
        }

        .select2-container--bootstrap4 .select2-selection--single {
            min-height: calc(2.25rem + 2px);
        }

        .catalog-tip {
            color: #72849a;
            font-size: 0.82rem;
        }

        .beneficiario-inline-row .form-group {
            margin-bottom: 0;
        }

        .beneficiario-inline-row .btn {
            height: calc(2.25rem + 2px);
        }

        #tbllistado th.public-service-align-right,
        #tbllistado td.public-service-align-right {
            text-align: right;
        }

        .public-service-actions {
            gap: 0.35rem;
        }

        .attended-status-note {
            border-radius: 12px;
            border: 1px solid #bde5cb;
            background: linear-gradient(180deg, #f6fffa 0%, #ecfbf2 100%);
            color: #17543a;
        }
        </style>

        <div class="row mb-3 mt-2">
            <div class="col-md-4 col-sm-6 mb-2">
                <article class="public-service-stat-card">
                    <p class="label">Total solicitudes</p>
                    <p class="value" id="totalServiciosPublicos">0</p>
                </article>
            </div>
            <div class="col-md-4 col-sm-6 mb-2">
                <article class="public-service-stat-card">
                    <p class="label">Solicitudes atendidas</p>
                    <p class="value text-success" id="totalServiciosAtendidos">0</p>
                </article>
            </div>
            <div class="col-md-4 col-sm-6 mb-2">
                <article class="public-service-stat-card">
                    <p class="label">Solicitudes pendientes</p>
                    <p class="value text-warning" id="totalServiciosPendientes">0</p>
                </article>
            </div>
        </div>

        <div class="card public-service-card">
            <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                <h3 class="card-title">Listado de solicitudes de servicios publicos</h3>
                <div class="card-tools">
                    <button type="button" class="btn btn-primary btn-sm" id="btnNuevoServicioPublico">
                        <i class="fas fa-bolt"></i> Registrar solicitud
                    </button>
                    <button type="button" class="btn btn-success btn-sm icon-only-btn" id="btnReporteServiciosPublicos"
                        title="Reporte rapido" aria-label="Reporte rapido">
                        <i class="fas fa-file-pdf"></i>
                    </button>
                    <button type="button" class="btn btn-outline-secondary btn-sm icon-only-btn"
                        id="btnRecargarServiciosPublicos" title="Actualizar listado" aria-label="Actualizar listado">
                        <i class="fas fa-sync-alt"></i>
                    </button>
                </div>
            </div>
            <div class="card-body table-responsive p-3">
                <div class="row mb-3 align-items-center">
                    <div class="col-md-6 col-lg-4">
                        <label for="buscadorServiciosPublicos" class="sr-only">Buscar solicitudes</label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text"><i class="fas fa-search"></i></span>
                            </div>
                            <input type="search" id="buscadorServiciosPublicos" class="form-control"
                                placeholder="Buscar por beneficiario, servicio, ticket o descripcion"
                                autocomplete="off">
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-4 ml-auto text-md-right mt-2 mt-md-0"
                        id="serviciosPublicosLengthContainer"></div>
                </div>
                <table id="tbllistado" class="table table-hover table-striped w-100">
                    <thead>
                        <tr>
                            <th>Beneficiario</th>
                            <th>Servicio publico</th>
                            <th>Tipo de solicitud</th>
                            <th>Fecha</th>
                            <th>Ticket interno</th>
                            <th>Descripcion</th>
                            <th>Telefono</th>
                            <th class="public-service-align-right">Estado solicitud</th>
                            <th class="public-service-align-right">Acciones</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<div class="modal fade" id="servicioPublicoModal" tabindex="-1" aria-labelledby="servicioPublicoModalLabel"
    aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioServicioPublico" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="servicioPublicoModalLabel">Registrar solicitud de servicio publico</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="id_servicio" name="id_servicio" value="">
                <div class="form-row beneficiario-inline-row">
                    <div class="form-group col-md-9">
                        <label for="id_beneficiario">Beneficiario</label>
                        <select id="id_beneficiario" name="id_beneficiario" class="form-control"
                            data-placeholder="Busque por cedula o nombre del beneficiario" required>
                            <option value="">Busque por cedula o nombre del beneficiario</option>
                        </select>
                    </div>
                    <div class="form-group col-md-3">
                        <label class="d-block">&nbsp;</label>
                        <button type="button" class="btn btn-outline-primary btn-block"
                            id="btnRegistrarBeneficiarioServiciosPublicos">
                            <i class="fas fa-user-plus"></i> Registrar beneficiario
                        </button>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-12 mb-0">
                        <small class="form-text text-muted">Si el beneficiario no existe, puede registrarlo sin salir de
                            esta vista.</small>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="id_tipo_servicio_publico">Servicio publico</label>
                        <select id="id_tipo_servicio_publico" name="id_tipo_servicio_publico" class="form-control"
                            data-placeholder="Busque por codigo o nombre del servicio" required>
                            <option value="">Busque por codigo o nombre del servicio</option>
                        </select>
                        <small class="catalog-tip">Tipifique por codigo o nombre para ubicar el servicio mas
                            rapido.</small>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="id_solicitud_servicio_publico">Tipo de solicitud</label>
                        <select id="id_solicitud_servicio_publico" name="id_solicitud_servicio_publico"
                            class="form-control" data-placeholder="Busque por codigo o nombre del canal" required>
                            <option value="">Busque por codigo o nombre del canal</option>
                        </select>
                        <small class="catalog-tip">Puede buscar el canal por codigo corto o por nombre.</small>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="fecha_servicio">Fecha de solicitud</label>
                        <input type="date" id="fecha_servicio" name="fecha_servicio" class="form-control"
                            placeholder="AAAA-MM-DD" required>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="ticket_interno">Ticket interno</label>
                        <input type="text" id="ticket_interno" name="ticket_interno" class="form-control" maxlength="20"
                            placeholder="Se genera automaticamente al guardar" autocomplete="off" readonly>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-12">
                        <label for="descripcion">Descripcion</label>
                        <textarea id="descripcion" name="descripcion" class="form-control" rows="3"
                            placeholder="Describa la incidencia, direccion o detalle del servicio solicitado"></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardarServicioPublico">
                    <i class="fas fa-save"></i> Guardar
                </button>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="estadoSolicitudServicioModal" tabindex="-1"
    aria-labelledby="estadoSolicitudServicioModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioEstadoSolicitudServicio" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="estadoSolicitudServicioModalLabel">Gestionar estado de la solicitud</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="id_servicio_estado" name="id_servicio" value="">
                <div class="alert attended-status-note d-none" id="avisoSolicitudAtendidaServicio" role="alert">
                    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between">
                        <div>
                            <strong>Solicitud atendida</strong>
                            <div id="mensajeSolicitudAtendidaServicio" class="mb-0"></div>
                        </div>

                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="ticket_interno_estado_servicio">Ticket interno</label>
                        <input type="text" id="ticket_interno_estado_servicio" class="form-control" readonly>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="estado_actual_servicio">Estado actual</label>
                        <input type="text" id="estado_actual_servicio" class="form-control" readonly>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="id_estado_solicitud_servicio">Nuevo estado de solicitud</label>
                        <select id="id_estado_solicitud_servicio" name="id_estado_solicitud" class="form-control"
                            required>
                            <option value="">Seleccione el estado</option>
                        </select>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="fecha_estado_solicitud_servicio">Fecha de gestion</label>
                        <input type="datetime-local" id="fecha_estado_solicitud_servicio" name="fecha_estado_solicitud"
                            class="form-control" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-12">
                        <label for="observacion_estado_solicitud_servicio">Observacion</label>
                        <textarea id="observacion_estado_solicitud_servicio" name="observacion_estado_solicitud"
                            class="form-control" rows="3"
                            placeholder="Indique el detalle de la gestion realizada sobre la solicitud"></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardarEstadoServicio">
                    <i class="fas fa-save"></i> Guardar gestion
                </button>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="beneficiarioServiciosPublicosModal" tabindex="-1"
    aria-labelledby="beneficiarioServiciosPublicosModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioBeneficiarioServiciosPublicos" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="beneficiarioServiciosPublicosModalLabel">Registrar beneficiario</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="idbeneficiariosServiciosPublicos" name="idbeneficiarios" value="">
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label for="nacionalidadServiciosPublicos">Nacionalidad</label>
                        <select id="nacionalidadServiciosPublicos" name="nacionalidad" class="form-control" required>
                            <option value="">Seleccione la nacionalidad</option>
                            <option value="V">V</option>
                            <option value="E">E</option>
                        </select>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="cedulaServiciosPublicos">Cedula</label>
                        <input type="text" id="cedulaServiciosPublicos" name="cedula" class="form-control"
                            maxlength="12" placeholder="Ej: 12345678" autocomplete="off" required>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="telefonoServiciosPublicos">Telefono</label>
                        <input type="text" id="telefonoServiciosPublicos" name="telefono" class="form-control"
                            maxlength="20" placeholder="Ej: 0412-1234567" autocomplete="off" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-8">
                        <label for="nombrebeneficiarioServiciosPublicos">Nombre beneficiario</label>
                        <input type="text" id="nombrebeneficiarioServiciosPublicos" name="nombrebeneficiario"
                            class="form-control" maxlength="150" placeholder="Ej: Maria Perez" autocomplete="off"
                            required>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="idcomunidadServiciosPublicos">Comunidad</label>
                        <select id="idcomunidadServiciosPublicos" name="idcomunidad" class="form-control"
                            data-placeholder="Busque o seleccione una comunidad" required>
                            <option value="">Busque o seleccione una comunidad</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardarBeneficiarioServiciosPublicos">
                    <i class="fas fa-save"></i> Guardar beneficiario
                </button>
            </div>
        </form>
    </div>
</div>

<?php
    } else {
        require "noacceso.php";
    }

    require "footer.php";
?>
<script type="text/javascript" src="scripts/serviciospublicos_new.js"></script>
<?php
}
ob_end_flush();
?>