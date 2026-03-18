<?php
ob_start();
session_start();

if (!isset($_SESSION["nombre"])) {
    header("Location: login.html");
} else {
    require "header.php";

    $tiene_permiso = isset($_SESSION["Escritorio"]) && (int) $_SESSION["Escritorio"] === 1;

    if ($tiene_permiso) {
?>
<section class="content" id="beneficiariosView">
    <div class="container-fluid">
        <style>
        .benef-stat-card {
            border: 1px solid #dbe5ef;
            border-radius: 12px;
            background: #ffffff;
            padding: 14px 16px;
            box-shadow: 0 4px 14px rgba(16, 37, 56, 0.06);
            height: 100%;
        }

        .benef-stat-card .label {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: #688199;
            margin: 0 0 6px;
        }

        .benef-stat-card .value {
            margin: 0;
            font-size: 1.55rem;
            font-weight: 700;
            color: #133652;
        }

        .benef-card {
            border: 1px solid #dbe5ef;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 8px 22px rgba(16, 37, 56, 0.08);
        }

        .benef-card .card-header {
            background: #f6f9fc;
            border-bottom: 1px solid #dbe5ef;
        }

        .benef-card .card-title {
            font-weight: 700;
            margin: 0;
        }

        .benef-card .card-tools {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            margin-left: auto;
            gap: 8px;
        }

        .benef-card .card-tools .btn-primary {
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

        #tbllistado_wrapper .dataTables_filter input {
            border-radius: 8px;
            border: 1px solid #cad8e8;
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

        #tbllistado td:last-child,
        #tbllistado th:last-child {
            text-align: right;
        }
        </style>

        <div class="row mb-3 mt-2">
            <div class="col-md-4 col-sm-6 mb-2">
                <article class="benef-stat-card">
                    <p class="label">Total beneficiarios</p>
                    <p class="value" id="totalBeneficiarios">0</p>
                </article>
            </div>
            <div class="col-md-4 col-sm-6 mb-2">
                <article class="benef-stat-card">
                    <p class="label">Beneficiarios activos</p>
                    <p class="value text-success" id="totalActivos">0</p>
                </article>
            </div>
            <div class="col-md-4 col-sm-6 mb-2">
                <article class="benef-stat-card">
                    <p class="label">Beneficiarios inactivos</p>
                    <p class="value text-danger" id="totalInactivos">0</p>
                </article>
            </div>
        </div>

        <div class="card benef-card">
            <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                <h3 class="card-title">Listado de beneficiarios</h3>
                <div class="card-tools">
                    <button type="button" class="btn btn-primary btn-sm" id="btnNuevoBeneficiario">
                        <i class="fas fa-user-plus"></i> Nuevo beneficiario
                    </button>
                    <button type="button" class="btn btn-success btn-sm icon-only-btn" id="btnReporte"
                        title="Reporte rapido" aria-label="Reporte rapido">
                        <i class="fas fa-file-pdf"></i>
                    </button>
                    <button type="button" class="btn btn-outline-secondary btn-sm icon-only-btn" id="btnRecargarListado"
                        title="Actualizar listado" aria-label="Actualizar listado">
                        <i class="fas fa-sync-alt"></i>
                    </button>
                </div>
            </div>
            <div class="card-body table-responsive p-3">
                <div class="row mb-3 align-items-center">
                    <div class="col-md-6 col-lg-4">
                        <label for="buscadorBeneficiarios" class="sr-only">Buscar beneficiarios</label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text"><i class="fas fa-search"></i></span>
                            </div>
                            <input type="search" id="buscadorBeneficiarios" class="form-control"
                                placeholder="Buscar por cedula, nombre, telefono o comunidad" autocomplete="off">
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-4 ml-auto text-md-right mt-2 mt-md-0" id="beneficiariosLengthContainer">
                    </div>
                </div>
                <table id="tbllistado" class="table table-hover table-striped w-100">
                    <thead>
                        <tr>
                            <th>Cedula</th>
                            <th>Nombre</th>
                            <th>Telefono</th>
                            <th>Comunidad</th>
                            <th>Fecha registro</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<div class="modal fade" id="beneficiarioModal" tabindex="-1" aria-labelledby="beneficiarioModalLabel"
    aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <form id="formularioBeneficiario" class="modal-content" method="POST" novalidate>
            <div class="modal-header">
                <h5 class="modal-title" id="beneficiarioModalLabel">Nuevo beneficiario</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="idbeneficiarios" name="idbeneficiarios" value="">
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label for="nacionalidad">Nacionalidad</label>
                        <select id="nacionalidad" name="nacionalidad" class="form-control" required>
                            <option value="">Seleccione la nacionalidad</option>
                            <option value="V">V</option>
                            <option value="E">E</option>
                        </select>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="cedula">Cedula</label>
                        <input type="text" id="cedula" name="cedula" class="form-control" maxlength="12"
                            placeholder="Ej: 12345678" autocomplete="off" required>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="telefono">Telefono</label>
                        <input type="text" id="telefono" name="telefono" class="form-control" maxlength="20"
                            placeholder="Ej: 0412-1234567" autocomplete="off" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-8">
                        <label for="nombrebeneficiario">Nombre beneficiario</label>
                        <input type="text" id="nombrebeneficiario" name="nombrebeneficiario" class="form-control"
                            maxlength="150" placeholder="Ej: Maria Perez" autocomplete="off" required>
                    </div>
                    <div class="form-group col-md-4">
                        <label for="idcomunidad">Comunidad</label>
                        <select id="idcomunidad" name="idcomunidad" class="form-control"
                            data-placeholder="Busque o seleccione una comunidad" required>
                            <option value="">Busque o seleccione una comunidad</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary" id="btnGuardar">
                    <i class="fas fa-save"></i> Guardar
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
<script type="text/javascript" src="scripts/beneficiarios_new.js"></script>
<?php
}
ob_end_flush();
?>
