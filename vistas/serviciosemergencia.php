<?php
ob_start();
session_start();

if (!isset($_SESSION["nombre"])) {
    header("Location: login.html");
} else {
    require "header.php";

    if ($_SESSION["Emergencia"] == 1) {
?>
<section class="content" id="seguridadEmergenciaView">
    <div class="container-fluid">
        <style>
        .emergency-stat-card {
            border: 1px solid #d7e2ef;
            border-radius: 14px;
            background: linear-gradient(180deg, #ffffff 0%, #f5f9fc 100%);
            padding: 14px 16px;
            box-shadow: 0 8px 22px rgba(15, 35, 55, 0.08);
            height: 100%;
        }

        .emergency-stat-card .label {
            font-size: 0.74rem;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: #6f7f92;
            margin: 0 0 6px;
        }

        .emergency-stat-card .value {
            margin: 0;
            font-size: 1.48rem;
            font-weight: 700;
            color: #102d45;
        }

        .emergency-card {
            border: 1px solid #d8e4ef;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 10px 24px rgba(15, 35, 55, 0.08);
        }

        .emergency-card .card-header {
            background: #f6fafc;
            border-bottom: 1px solid #d8e4ef;
        }

        .emergency-card .card-title {
            font-weight: 700;
            margin: 0;
        }

        .emergency-card .card-tools {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            margin-left: auto;
            gap: 8px;
        }

        .emergency-card .card-tools .btn-primary {
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

        .status-pill.pending {
            background: #fff0cf;
            color: #9a6700;
        }

        .status-pill.active-dispatch {
            background: #dceffe;
            color: #165d8d;
        }

        .status-pill.done {
            background: #d9f6e8;
            color: #0f6b43;
        }

        .status-pill.active {
            background: #d9f6e8;
            color: #0f6b43;
        }

        .status-pill.info {
            background: #dceffe;
            color: #165d8d;
        }

        .status-pill.warning {
            background: #fff0cf;
            color: #9a6700;
        }

        .status-pill.draft {
            background: #eef2f6;
            color: #556476;
        }

        .status-pill.annulled {
            background: #ffe3e3;
            color: #9b2323;
        }

        #tbllistado th.emergency-align-right,
        #tbllistado td.emergency-align-right {
            text-align: right;
        }

        .emergency-actions {
            gap: 0.35rem;
        }

        .attended-status-note {
            border-radius: 12px;
            border: 1px solid #bde5cb;
            background: linear-gradient(180deg, #f6fffa 0%, #ecfbf2 100%);
            color: #17543a;
        }

        .dispatch-preview {
            border: 1px dashed #b9cde2;
            border-radius: 12px;
            padding: 12px 14px;
            background: #f8fbfe;
        }

        .dispatch-preview .preview-title {
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: #607489;
            margin-bottom: 0;
        }

        .dispatch-preview .preview-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 10px;
            margin-top: 12px;
        }

        .dispatch-preview .preview-item {
            border: 1px solid #dbe5ef;
            border-radius: 10px;
            background: #ffffff;
            padding: 10px 12px;
        }

        .dispatch-preview .preview-item small {
            display: block;
            color: #6b7b8e;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 4px;
        }

        .dispatch-preview .preview-item strong {
            color: #12324c;
            font-size: 0.94rem;
        }

        .dispatch-preview-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
        }

        .dispatch-preview-meta {
            color: #6f8092;
            font-size: 0.83rem;
        }

        .select2-container--bootstrap4 .select2-selection--single {
            min-height: calc(2.25rem + 2px);
        }

        .beneficiario-inline-row .form-group {
            margin-bottom: 0;
        }

        .beneficiario-inline-row .btn {
            height: calc(2.25rem + 2px);
        }

        .email-loading-overlay {
            position: fixed;
            inset: 0;
            background: rgba(15, 35, 55, 0.45);
            z-index: 3000;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .email-loading-card {
            min-width: 280px;
            max-width: 420px;
            text-align: center;
            border-radius: 14px;
            border: 1px solid #d6e1ec;
            background: #fff;
            box-shadow: 0 14px 30px rgba(10, 26, 42, 0.24);
            padding: 22px 20px;
            color: #1b344d;
            font-weight: 600;
        }

        .email-loading-card .spinner-border {
            width: 2.2rem;
            height: 2.2rem;
        }
        </style>

        <div class="row mb-3 mt-2">
            <div class="col-md-6 col-lg mb-2">
                <article class="emergency-stat-card">
                    <p class="label">Total solicitudes</p>
                    <p class="value" id="totalSolicitudesSeguridad">0</p>
                </article>
            </div>
            <div class="col-md-6 col-lg mb-2">
                <article class="emergency-stat-card">
                    <p class="label">Pendientes de unidad</p>
                    <p class="value text-warning" id="totalPendientesUnidad">0</p>
                </article>
            </div>
            <div class="col-md-6 col-lg mb-2">
                <article class="emergency-stat-card">
                    <p class="label">Despachos activos</p>
                    <p class="value text-info" id="totalDespachadosSeguridad">0</p>
                </article>
            </div>
            <div class="col-md-6 col-lg mb-2">
                <article class="emergency-stat-card">
                    <p class="label">Finalizadas</p>
                    <p class="value text-success" id="totalFinalizadasSeguridad">0</p>
                </article>
            </div>
            <div class="col-md-6 col-lg mb-2">
                <article class="emergency-stat-card">
                    <p class="label">Unidades disponibles</p>
                    <p class="value text-primary" id="totalUnidadesDisponibles">0</p>
                </article>
            </div>
        </div>

        <div class="card emergency-card">
            <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                <h3 class="card-title">Seguridad y Emergencia</h3>
                <div class="card-tools">
                    <button type="button" class="btn btn-primary btn-sm" id="btnNuevaSolicitudSeguridad">
                        <i class="fas fa-plus-circle"></i> Registrar solicitud
                    </button>
                    <button type="button" class="btn btn-warning btn-sm" id="btnOperativaSeguridad" title="Abrir el panel operativo completo de ambulancias">
                        <i class="fas fa-ambulance"></i> Operativa
                    </button>
                    <button type="button" class="btn btn-success btn-sm icon-only-btn" id="btnReporteSeguridad" title="Reporte rapido" aria-label="Reporte rapido">
                        <i class="fas fa-file-pdf"></i>
                    </button>
                    <button type="button" class="btn btn-outline-secondary btn-sm icon-only-btn" id="btnRecargarSeguridad" title="Actualizar listado" aria-label="Actualizar listado">
                        <i class="fas fa-sync-alt"></i>
                    </button>
                </div>
            </div>
            <div class="card-body table-responsive p-3">
                <div class="row mb-3 align-items-center">
                    <div class="col-md-6 col-lg-4">
                        <label for="buscadorSeguridad" class="sr-only">Buscar solicitudes</label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text"><i class="fas fa-search"></i></span>
                            </div>
                            <input type="search" id="buscadorSeguridad" class="form-control" placeholder="Buscar por ticket, beneficiario, servicio, unidad o chofer" autocomplete="off">
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-4 ml-auto text-md-right mt-2 mt-md-0" id="seguridadLengthContainer"></div>
                </div>
                <table id="tbllistado" class="table table-hover table-striped w-100">
                    <thead>
                        <tr>
                            <th>Beneficiario</th>
                            <th>Servicio</th>
                            <th>Solicitud</th>
                            <th>Fecha</th>
                            <th>Ticket</th>
                            <th>Ambulancia</th>
                            <th>Chofer</th>
                            <th>Ubicacion</th>
                            <th>Telefono</th>
                            <th class="emergency-align-right">Estado solicitud</th>
                            <th class="emergency-align-right">Acciones</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<div class="modal fade" id="seguridadEmergenciaModal" tabindex="-1" aria-labelledby="seguridadEmergenciaModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <form id="formularioSeguridadEmergencia" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="seguridadEmergenciaModalLabel">Registrar solicitud de seguridad</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="id_seguridad" name="id_seguridad" value="">
                <input type="hidden" id="id_asignacion_preferida" name="id_asignacion_preferida" value="">
                <div class="form-row beneficiario-inline-row">
                    <div class="form-group col-md-9">
                        <label for="id_beneficiario" data-toggle="tooltip" title="Busque al ciudadano que recibira la atencion. Si no existe puede registrarlo al instante.">Beneficiario</label>
                        <select id="id_beneficiario" name="id_beneficiario" class="form-control" data-placeholder="Busque o seleccione un beneficiario" required title="Seleccione o busque el beneficiario relacionado con la emergencia.">
                            <option value="">Busque o seleccione un beneficiario</option>
                        </select>
                    </div>
                    <div class="form-group col-md-3">
                        <label class="d-block">&nbsp;</label>
                        <button type="button" class="btn btn-outline-primary btn-block" id="btnRegistrarBeneficiarioSeguridad" data-toggle="tooltip" title="Permite registrar al beneficiario sin salir de esta solicitud y continuar con el llenado.">
                            <i class="fas fa-user-plus"></i> Registrar beneficiario
                        </button>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-12 mb-0">
                        <small class="form-text text-muted">Si el beneficiario no existe, puede registrarlo desde esta misma vista y continuar el flujo.</small>
                    </div>
                </div>
                <div class="form-row mt-2">
                    <div class="form-group col-md-4">
                        <label for="id_tipo_seguridad" data-toggle="tooltip" title="Seleccione el tipo de ayuda que aplica a la incidencia.">Tipo de ayuda</label>
                        <select id="id_tipo_seguridad" name="id_tipo_seguridad" class="form-control" required title="Seleccione el tipo de ayuda principal de la incidencia.">
                            <option value="">Seleccione el tipo de ayuda</option>
                        </select>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="id_solicitud_seguridad" data-toggle="tooltip" title="Origen por el cual entro la incidencia al sistema.">Tipo de solicitud</label>
                        <select id="id_solicitud_seguridad" name="id_solicitud_seguridad" class="form-control" required title="Indique el canal por el que se recibio la solicitud.">
                            <option value="">Seleccione el origen de la solicitud</option>
                        </select>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="ticket_interno_seguridad" data-toggle="tooltip" title="Codigo interno automatico de seguimiento de la solicitud.">Ticket interno</label>
                        <input type="text" id="ticket_interno_seguridad" class="form-control" placeholder="Se genera automaticamente al guardar" readonly title="El ticket se genera automaticamente al guardar.">
                    </div>
                </div>
                <div id="panelDespachoSugerido" class="dispatch-preview d-none mb-3">
                    <div class="dispatch-preview-header">
                        <div>
                            <div class="preview-title">Sugerencia operativa inmediata</div>
                            <div class="dispatch-preview-meta" id="previewSugerenciaMeta">Se mostrara el primer par operativo disponible.</div>
                        </div>
                        <button type="button" class="btn btn-outline-primary btn-sm d-none" id="btnIntercambiarSugerencia" data-toggle="tooltip" title="Cambia automaticamente al siguiente par unidad-chofer disponible sin abrir otra ventana.">
                            <i class="fas fa-random"></i> Intercambiar
                        </button>
                    </div>
                    <div class="preview-grid" id="dispatchPreviewGrid"></div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label for="fecha_seguridad" data-toggle="tooltip" title="Fecha y hora exacta del reporte o de la atencion requerida.">Fecha y hora</label>
                        <input type="datetime-local" id="fecha_seguridad" name="fecha_seguridad" class="form-control" placeholder="AAAA-MM-DD HH:MM" required title="Seleccione la fecha y hora del evento.">
                    </div>
                    <div class="form-group col-md-4">
                        <label for="ubicacion_evento" data-toggle="tooltip" title="Lugar principal donde se encuentra el evento o el paciente.">Ubicacion del evento</label>
                        <input type="text" id="ubicacion_evento" name="ubicacion_evento" class="form-control" maxlength="190" placeholder="Ej: Av. principal, sector, comunidad" autocomplete="off" required title="Escriba la ubicacion principal del evento.">
                    </div>
                    <div class="form-group col-md-4">
                        <label for="referencia_evento" data-toggle="tooltip" title="Referencia visual o de acceso para llegar mas rapido al sitio.">Referencia</label>
                        <input type="text" id="referencia_evento" name="referencia_evento" class="form-control" maxlength="190" placeholder="Ej: Frente al liceo, casa azul, punto conocido" autocomplete="off" title="Agregue una referencia corta para orientar la llegada al sitio.">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-12">
                        <label for="descripcion" data-toggle="tooltip" title="Resumen rapido de lo ocurrido, el estado del paciente o la novedad reportada.">Descripcion de la incidencia</label>
                        <textarea id="descripcion" name="descripcion" class="form-control" rows="3" placeholder="Detalle brevemente la situacion, condicion del paciente o hecho reportado" title="Describa de forma breve y clara la incidencia."></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardarSeguridad">
                    <i class="fas fa-save"></i> Guardar solicitud
                </button>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="estadoSolicitudSeguridadModal" tabindex="-1" aria-labelledby="estadoSolicitudSeguridadModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioEstadoSolicitudSeguridad" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="estadoSolicitudSeguridadModalLabel">Gestionar estado de la solicitud</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="id_seguridad_estado" name="id_seguridad" value="">
                <div class="alert attended-status-note d-none" id="avisoSolicitudAtendidaSeguridad" role="alert">
                    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between">
                        <div>
                            <strong>Solicitud atendida</strong>
                            <div id="mensajeSolicitudAtendidaSeguridad" class="mb-0"></div>
                        </div>
                        <button type="button" class="btn btn-outline-success btn-sm mt-3 mt-md-0 d-none" id="btnVerObservacionAtendidaSeguridad">
                            <i class="fas fa-sticky-note"></i> Ver observacion
                        </button>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label for="ticket_interno_estado_seguridad">Ticket interno</label>
                        <input type="text" id="ticket_interno_estado_seguridad" class="form-control" readonly>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="estado_actual_seguridad">Estado general actual</label>
                        <input type="text" id="estado_actual_seguridad" class="form-control" readonly>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="estado_operativo_seguridad">Estado operativo actual</label>
                        <input type="text" id="estado_operativo_seguridad" class="form-control" readonly>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="id_estado_solicitud_seguridad">Nuevo estado de solicitud</label>
                        <select id="id_estado_solicitud_seguridad" name="id_estado_solicitud" class="form-control" required>
                            <option value="">Seleccione el estado</option>
                        </select>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="fecha_estado_solicitud_seguridad">Fecha de gestion</label>
                        <input type="datetime-local" id="fecha_estado_solicitud_seguridad" name="fecha_estado_solicitud" class="form-control" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-12">
                        <label for="observacion_estado_solicitud_seguridad">Observacion</label>
                        <textarea id="observacion_estado_solicitud_seguridad" name="observacion_estado_solicitud" class="form-control" rows="3" placeholder="Detalle la gestion realizada, la entrega o la novedad operativa"></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardarEstadoSeguridad">
                    <i class="fas fa-save"></i> Guardar gestion
                </button>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="beneficiarioSeguridadModal" tabindex="-1" aria-labelledby="beneficiarioSeguridadModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioBeneficiarioSeguridad" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="beneficiarioSeguridadModalLabel">Registrar beneficiario</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="idbeneficiariosSeguridad" name="idbeneficiarios" value="">
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label for="nacionalidadSeguridad">Nacionalidad</label>
                        <select id="nacionalidadSeguridad" name="nacionalidad" class="form-control" required>
                            <option value="">Seleccione la nacionalidad</option>
                            <option value="V">V</option>
                            <option value="E">E</option>
                        </select>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="cedulaSeguridad">Cedula</label>
                        <input type="text" id="cedulaSeguridad" name="cedula" class="form-control" maxlength="12" placeholder="Ej: 12345678" autocomplete="off" required>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="telefonoSeguridad">Telefono</label>
                        <input type="text" id="telefonoSeguridad" name="telefono" class="form-control" maxlength="20" placeholder="Ej: 0412-1234567" autocomplete="off" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-8">
                        <label for="nombrebeneficiarioSeguridad">Nombre beneficiario</label>
                        <input type="text" id="nombrebeneficiarioSeguridad" name="nombrebeneficiario" class="form-control" maxlength="150" placeholder="Ej: Maria Perez" autocomplete="off" required>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="idcomunidadSeguridad">Comunidad</label>
                        <select id="idcomunidadSeguridad" name="idcomunidad" class="form-control" data-placeholder="Busque o seleccione una comunidad" required>
                            <option value="">Busque o seleccione una comunidad</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardarBeneficiarioSeguridad">
                    <i class="fas fa-save"></i> Guardar beneficiario
                </button>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="asignacionManualModal" tabindex="-1" aria-labelledby="asignacionManualModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioAsignacionManual" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="asignacionManualModalLabel">Asignar ambulancia manualmente</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="id_seguridad_manual" name="id_seguridad" value="">
                <div class="dispatch-preview mb-3">
                    <div class="preview-grid" id="manualAssignmentHeader"></div>
                </div>
                <div class="form-group">
                    <label for="id_asignacion_unidad_chofer" data-toggle="tooltip" title="Par operativo disponible para cubrir manualmente la solicitud.">Unidad disponible</label>
                    <select id="id_asignacion_unidad_chofer" name="id_asignacion_unidad_chofer" class="form-control" required title="Seleccione la unidad y el chofer que atenderan la solicitud.">
                        <option value="">Seleccione una unidad disponible</option>
                    </select>
                </div>
                <div id="manualAssignmentSummary" class="dispatch-preview d-none mb-3">
                    <div class="preview-grid" id="manualAssignmentGrid"></div>
                </div>
                <div class="form-group">
                    <label for="observaciones_manual" data-toggle="tooltip" title="Motivo del cambio manual o detalle que justifique la seleccion hecha por el operador.">Observaciones de asignacion</label>
                    <textarea id="observaciones_manual" name="observaciones_manual" class="form-control" rows="3" placeholder="Indique motivo del override o detalle operativo" title="Explique por que se realiza la asignacion manual."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-warning" id="btnGuardarAsignacionManual">
                    <i class="fas fa-ambulance"></i> Confirmar asignacion
                </button>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="cierreDespachoModal" tabindex="-1" aria-labelledby="cierreDespachoModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioCierreDespacho" class="modal-content" method="POST" enctype="multipart/form-data" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="cierreDespachoModalLabel">Cerrar despacho de ambulancia</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="id_seguridad_cierre" name="id_seguridad" value="">
                <div class="dispatch-preview mb-3">
                    <div class="preview-grid" id="cierreDespachoHeader"></div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label for="fecha_cierre">Fecha y hora de cierre</label>
                        <input type="datetime-local" id="fecha_cierre" name="fecha_cierre" class="form-control" required>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="km_salida">Kilometraje salida</label>
                        <input type="number" id="km_salida" name="km_salida" class="form-control" min="0" placeholder="Ej: 15320" autocomplete="off">
                    </div>
                    <div class="form-group col-md-4">
                        <label for="km_llegada">Kilometraje llegada</label>
                        <input type="number" id="km_llegada" name="km_llegada" class="form-control" min="0" placeholder="Ej: 15348" autocomplete="off">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label for="estado_unidad_final">Estado final de la unidad</label>
                        <select id="estado_unidad_final" name="estado_unidad_final" class="form-control" required>
                            <option value="DISPONIBLE">Disponible</option>
                            <option value="FUERA_SERVICIO">Fuera de servicio</option>
                        </select>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="ubicacion_cierre">Ubicacion final</label>
                        <input type="text" id="ubicacion_cierre" name="ubicacion_cierre" class="form-control" maxlength="190" placeholder="Ej: Base operativa, ambulatorio, sector final" autocomplete="off" required>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="referencia_cierre">Referencia final</label>
                        <input type="text" id="referencia_cierre" name="referencia_cierre" class="form-control" maxlength="190" placeholder="Ej: Frente a la plaza, estacionamiento" autocomplete="off">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-8">
                        <label for="diagnostico_paciente">Resultado o diagnostico</label>
                        <textarea id="diagnostico_paciente" name="diagnostico_paciente" class="form-control" rows="3" placeholder="Describa el servicio realizado, diagnostico o novedad de cierre"></textarea>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="evidencia_foto">Evidencia fotografica</label>
                        <input type="file" id="evidencia_foto" name="evidencia_foto" class="form-control-file" accept="image/*">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-12 mb-0">
                        <div class="custom-control custom-switch mt-2">
                            <input type="checkbox" class="custom-control-input" id="enviar_reporte_chofer_cierre" name="enviar_reporte_chofer" value="1">
                            <label class="custom-control-label" for="enviar_reporte_chofer_cierre">Enviar reporte de cierre al correo del chofer (si tiene correo valido)</label>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-success" id="btnGuardarCierreDespacho">
                    <i class="fas fa-clipboard-check"></i> Cerrar despacho
                </button>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="operativoEmergenciaModal" tabindex="-1" aria-labelledby="operativoEmergenciaModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-operativo-full modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="operativoEmergenciaModalLabel">Configuracion operativa de ambulancias</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <?php include __DIR__ . "/partials/operativo_ambulancias_panel.php"; ?>
            </div>
            <div class="modal-footer justify-content-between">
                <small class="text-muted">Tambien puedes gestionar este panel desde el menu lateral en Control Ambulancias.</small>
                <div>
                    <a href="operativoambulancias.php" class="btn btn-outline-dark">
                        <i class="fas fa-external-link-alt"></i> Abrir vista completa
                    </a>
                    <button type="button" class="btn btn-light" data-dismiss="modal">Cerrar</button>
                </div>
            </div>
        </div>
    </div>
</div>

<?php include __DIR__ . "/partials/operativo_ambulancias_modals.php"; ?>

<div id="overlayEnvioCorreoChofer" class="email-loading-overlay d-none" aria-live="polite" aria-busy="true">
    <div class="email-loading-card">
        <div class="spinner-border text-primary mb-3" role="status" aria-hidden="true"></div>
        <div id="overlayEnvioCorreoChoferTexto">Enviando correo al chofer...</div>
    </div>
</div>
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
