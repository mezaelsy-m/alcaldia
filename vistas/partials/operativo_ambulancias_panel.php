<div id="operativoControlPanel" class="operativo-panel">
    <div class="operativo-toolbar">
        <div class="btn-group btn-group-sm operativo-action-group" role="group" aria-label="Acciones operativas">
            <button type="button" class="btn btn-primary" id="btnNuevoChoferOperativo" data-toggle="tooltip"
                title="Abre el modal para crear o actualizar el perfil operativo de un chofer.">
                <i class="fas fa-id-card"></i> Registrar chofer
            </button>
            <button type="button" class="btn btn-secondary" id="btnNuevoControlUnidad" data-toggle="tooltip"
                title="Abre el modal para ver las unidades registradas, su estado operativo y crear una nueva.">
                <i class="fas fa-ambulance"></i> Unidades
            </button>
        </div>
        <button type="button" class="btn btn-outline-secondary btn-sm operativo-icon-btn" id="btnRecargarOperativoPanel"
            data-toggle="tooltip" title="Actualizar panel operativo" aria-label="Actualizar panel operativo">
            <i class="fas fa-sync-alt"></i>
        </button>
    </div>

    <div class="operativo-legend">
        <span><i class="dot-ready"></i> Lista para salida</span>
        <span><i class="dot-warning"></i> Sin asignacion</span>
        <span><i class="dot-danger"></i> Fuera de servicio</span>
        <span><i class="dot-info"></i> En despacho o con unidad activa</span>
    </div>

    <div class="row mt-3 mb-2">
        <div class="col-md-6 col-lg mb-3">
            <article class="operativo-summary-card">
                <p class="label">Total unidades</p>
                <p class="value" id="operativoTotalUnidades">0</p>
            </article>
        </div>
        <div class="col-md-6 col-lg mb-3">
            <article class="operativo-summary-card">
                <p class="label">Listas para salida</p>
                <p class="value text-success" id="operativoUnidadesListas">0</p>
            </article>
        </div>
        <div class="col-md-6 col-lg mb-3">
            <article class="operativo-summary-card">
                <p class="label">Sin chofer</p>
                <p class="value text-warning" id="operativoUnidadesSinChofer">0</p>
            </article>
        </div>
        <div class="col-md-6 col-lg mb-3">
            <article class="operativo-summary-card">
                <p class="label">Choferes sin unidad</p>
                <p class="value text-info" id="operativoChoferesSinUnidad">0</p>
            </article>
        </div>
        <div class="col-md-6 col-lg mb-3">
            <article class="operativo-summary-card">
                <p class="label">Fuera de servicio</p>
                <p class="value text-danger" id="operativoUnidadesFueraServicio">0</p>
            </article>
        </div>
    </div>

    <div class="row">
        <div class="col-xl-7 mb-4">
            <div class="card operativo-list-card h-100">
                <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                    <h6 class="card-title">Unidades y disponibilidad</h6>
                    <small class="text-muted">Asigna, vigila y detecta rapido unidades sin chofer o fuera de
                        servicio.</small>
                </div>
                <div class="card-body">
                    <div id="operativoUnidadesCards" class="operativo-cards-grid units"></div>
                </div>
            </div>
        </div>
        <div class="col-xl-5 mb-4">
            <div class="card operativo-list-card h-100">
                <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                    <h6 class="card-title">Choferes creados</h6>
                    <small class="text-muted">Identifica rapido quien ya tiene unidad y quien esta libre para
                        salir.</small>
                </div>
                <div class="card-body">
                    <div id="operativoChoferesCards" class="operativo-cards-grid drivers"></div>
                </div>
            </div>
        </div>
    </div>
</div>
