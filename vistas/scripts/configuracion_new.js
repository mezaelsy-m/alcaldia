let configuracionMeta = null;
let configuracionCatalogos = {};
let configuracionGrupos = {};
let configuracionTablas = {};
let configuracionResumenes = {};
let configuracionUsuariosMeta = null;
let configuracionUsuariosTabla = null;
let configuracionUsuariosResumen = {};
let configuracionUsuarioModal = {
    id: 0,
    tieneAccesoTotal: false,
    esUsuarioActual: false
};
let configuracionEmpleadosMeta = null;
let configuracionEmpleadosTabla = null;
let configuracionEmpleadosResumen = {};
let configuracionEmpleadoModal = {
    id: 0
};
let configuracionBitacoraTabla = null;

function obtenerTituloSegunIconoConfiguracion(icono) {
    if (icono === "success") {
        return "Operacion exitosa";
    }
    if (icono === "warning") {
        return "Atencion";
    }
    if (icono === "error") {
        return "Error";
    }
    return "Informacion";
}

function mostrarAlertaConfiguracion(icono, mensaje, titulo) {
    return Swal.fire({
        icon: icono,
        title: titulo || obtenerTituloSegunIconoConfiguracion(icono),
        text: mensaje || "Operacion completada.",
        confirmButtonText: "Aceptar",
        customClass: {
            confirmButton: "btn btn-primary"
        },
        buttonsStyling: false
    });
}

function confirmarAccionConfiguracion(mensaje, textoConfirmacion) {
    return Swal.fire({
        icon: "question",
        title: "Confirmar accion",
        text: mensaje,
        showCancelButton: true,
        confirmButtonText: textoConfirmacion || "Si, continuar",
        cancelButtonText: "Cancelar",
        reverseButtons: true,
        customClass: {
            confirmButton: "btn btn-primary mr-2",
            cancelButton: "btn btn-light"
        },
        buttonsStyling: false
    });
}

function confirmacionAceptadaConfiguracion(resultado) {
    return !!(resultado && (resultado.isConfirmed || resultado.value === true));
}

function escapeHtmlConfiguracion(valor) {
    return $("<div>").text(valor == null ? "" : String(valor)).html();
}

function escapeAttrConfiguracion(valor) {
    return escapeHtmlConfiguracion(valor).replace(/"/g, "&quot;");
}

function sanitizarClaseBadgeConfiguracion(valor) {
    const clase = (valor || "draft").toString().replace(/[^a-z0-9_-]/gi, "");
    return clase || "draft";
}

function obtenerGrupoActivoConfiguracion() {
    const activo = $("#configuracionTabsNav .nav-link.active").data("group");
    return activo || "";
}

function obtenerPanelActivoConfiguracion() {
    const activo = $("#configuracionRootTabs .nav-link.active").attr("href");
    return activo || "";
}

function initConfiguracion() {
    const vista = $("#configuracionHubView");
    if (!vista.length) {
        return;
    }

    configurarEventosConfiguracion();

    if (parseInt(vista.data("can-catalogs"), 10) === 1) {
        cargarMetadatosConfiguracion();
    }

    if (parseInt(vista.data("can-users"), 10) === 1) {
        cargarMetadatosUsuariosConfiguracion();
    }

    if (parseInt(vista.data("can-employees"), 10) === 1) {
        cargarMetadatosEmpleadosConfiguracion();
    }

    if (parseInt(vista.data("can-smtp"), 10) === 1) {
        cargarConfiguracionSmtp(false);
    }

    if (parseInt(vista.data("can-bitacora"), 10) === 1) {
        inicializarBitacoraConfiguracion();
    }
}

function configurarEventosConfiguracion() {
    $(document)
        .off(".configuracion")
        .on("input.configuracion search.configuracion", ".js-config-search", function () {
            const catalogo = $(this).data("catalogo");
            const tabla = configuracionTablas[catalogo];
            if (!tabla) {
                return;
            }

            tabla.search($(this).val() || "").draw();
        })
        .on("click.configuracion", ".js-config-refresh", function () {
            recargarCatalogoConfiguracion($(this).data("catalogo"), false);
        })
        .on("click.configuracion", ".js-config-nuevo", function () {
            abrirModalCatalogoConfiguracion($(this).data("catalogo"), 0);
        })
        .on("click.configuracion", ".js-config-editar", function () {
            abrirModalCatalogoConfiguracion($(this).data("catalogo"), $(this).data("id"));
        })
        .on("click.configuracion", ".js-config-desactivar", function () {
            if ($(this).prop("disabled")) {
                return;
            }

            cambiarEstadoCatalogoConfiguracion($(this).data("catalogo"), $(this).data("id"), "desactivar");
        })
        .on("click.configuracion", ".js-config-reactivar", function () {
            cambiarEstadoCatalogoConfiguracion($(this).data("catalogo"), $(this).data("id"), "reactivar");
        })
        .on("click.configuracion", ".js-config-state-filter", function () {
            const boton = $(this);
            const contenedor = boton.closest(".config-master-state-filter");
            const catalogo = boton.data("catalogo");

            contenedor.find(".btn").removeClass("active btn-primary").addClass("btn-outline-secondary");
            boton.addClass("active btn-primary").removeClass("btn-outline-secondary");
            recargarCatalogoConfiguracion(catalogo, true);
        })
        .on("shown.bs.tab.configuracion", "#configuracionTabsNav .nav-link", function () {
            ajustarTablasGrupoConfiguracion($(this).data("group"));
        })
        .on("shown.bs.tab.configuracion", ".js-config-browser-tab", function () {
            ajustarTablaCatalogoConfiguracion($(this).data("catalogo"));
        })
        .on("shown.bs.tab.configuracion", "#configuracionRootTabs .nav-link", function () {
            if ($(this).attr("href") === "#configuracion-root-usuarios" && configuracionUsuariosTabla) {
                configuracionUsuariosTabla.columns.adjust().responsive.recalc();
            }

            if ($(this).attr("href") === "#configuracion-root-empleados" && configuracionEmpleadosTabla) {
                configuracionEmpleadosTabla.columns.adjust().responsive.recalc();
            }

            if ($(this).attr("href") === "#configuracion-root-bitacora") {
                if (!configuracionBitacoraTabla) {
                    inicializarBitacoraConfiguracion();
                }
                if (configuracionBitacoraTabla) {
                    configuracionBitacoraTabla.columns.adjust();
                }
            }
        })
        .on("input.configuracion search.configuracion", "#buscadorUsuariosSistema", function () {
            if (configuracionUsuariosTabla) {
                configuracionUsuariosTabla.search($(this).val() || "").draw();
            }
        })
        .on("input.configuracion search.configuracion", "#buscadorEmpleadosSistema", function () {
            if (configuracionEmpleadosTabla) {
                configuracionEmpleadosTabla.search($(this).val() || "").draw();
            }
        })
        .on("input.configuracion search.configuracion", "#buscadorBitacoraSistema", function () {
            if (configuracionBitacoraTabla) {
                configuracionBitacoraTabla.search($(this).val() || "").draw();
            }
        })
        .on("change.configuracion", "#filtroBitacoraSistemaScope", function () {
            recargarBitacoraConfiguracion(true);
        })
        .on("click.configuracion", ".js-user-state-filter", function () {
            const boton = $(this);
            const contenedor = boton.closest(".config-master-state-filter");

            contenedor.find(".btn").removeClass("active btn-primary").addClass("btn-outline-secondary");
            boton.addClass("active btn-primary").removeClass("btn-outline-secondary");
            recargarUsuariosConfiguracion(true);
        })
        .on("click.configuracion", ".js-employee-state-filter", function () {
            const boton = $(this);
            const contenedor = boton.closest(".config-master-state-filter");

            contenedor.find(".btn").removeClass("active btn-primary").addClass("btn-outline-secondary");
            boton.addClass("active btn-primary").removeClass("btn-outline-secondary");
            recargarEmpleadosConfiguracion(true);
        })
        .on("click.configuracion", ".js-user-edit", function () {
            abrirModalUsuarioSistema($(this).data("id"));
        })
        .on("click.configuracion", ".js-user-desactivar", function () {
            cambiarEstadoUsuarioSistema($(this).data("id"), "desactivar");
        })
        .on("click.configuracion", ".js-user-reactivar", function () {
            cambiarEstadoUsuarioSistema($(this).data("id"), "reactivar");
        })
        .on("click.configuracion", ".js-employee-edit", function () {
            abrirModalEmpleadoSistema($(this).data("id"));
        })
        .on("click.configuracion", ".js-employee-desactivar", function () {
            cambiarEstadoEmpleadoSistema($(this).data("id"), "desactivar");
        })
        .on("click.configuracion", ".js-employee-reactivar", function () {
            cambiarEstadoEmpleadoSistema($(this).data("id"), "reactivar");
        });

    $("#btnRecargarConfiguracion")
        .off(".configuracion")
        .on("click.configuracion", function () {
            cargarMetadatosConfiguracion(obtenerGrupoActivoConfiguracion());
        });

    $("#btnRecargarUsuariosConfiguracion")
        .off(".configuracion")
        .on("click.configuracion", function () {
            cargarMetadatosUsuariosConfiguracion(false);
        });

    $("#btnNuevoUsuarioSistema")
        .off(".configuracion")
        .on("click.configuracion", function () {
            abrirModalUsuarioSistema(0);
        });

    $("#btnRecargarEmpleadosConfiguracion")
        .off(".configuracion")
        .on("click.configuracion", function () {
            cargarMetadatosEmpleadosConfiguracion(false);
        });

    $("#btnNuevoEmpleadoSistema")
        .off(".configuracion")
        .on("click.configuracion", function () {
            abrirModalEmpleadoSistema(0);
        });

    $("#btnRecargarSmtpConfiguracion")
        .off(".configuracion")
        .on("click.configuracion", function () {
            cargarConfiguracionSmtp(false);
        });

    $("#btnRecargarBitacoraConfiguracion")
        .off(".configuracion")
        .on("click.configuracion", function () {
            if (!configuracionBitacoraTabla) {
                inicializarBitacoraConfiguracion();
                return;
            }
            recargarBitacoraConfiguracion(false);
        });

    $("#btnReporteBitacoraConfiguracion")
        .off(".configuracion")
        .on("click.configuracion", function () {
            generarReporteBitacoraConfiguracion();
        });

    $("#formularioConfiguracionCatalogo")
        .off(".configuracion")
        .on("submit.configuracion", function (event) {
            event.preventDefault();
            guardarCatalogoConfiguracion();
        });

    $("#formularioUsuarioSistema")
        .off(".configuracion")
        .on("submit.configuracion", function (event) {
            event.preventDefault();
            guardarUsuarioSistema();
        });

    $("#formularioEmpleadoSistema")
        .off(".configuracion")
        .on("submit.configuracion", function (event) {
            event.preventDefault();
            guardarEmpleadoSistema();
        });

    $("#formularioSmtpConfiguracion")
        .off(".configuracion")
        .on("submit.configuracion", function (event) {
            event.preventDefault();
            guardarConfiguracionSmtp();
        });

    $("#btnGestionarAccesoTotalUsuario")
        .off(".configuracion")
        .on("click.configuracion", function () {
            gestionarAccesoTotalUsuario();
        });

    $("#btnEnviarPruebaSmtp")
        .off(".configuracion")
        .on("click.configuracion", function () {
            enviarPruebaSmtp();
        });

    $("#usuarioSistemaEmpleado")
        .off("change.configuracion")
        .on("change.configuracion", function () {
            actualizarDependenciaUsuarioSeleccionada();
        });

    $("#configuracionCatalogoModal")
        .off("hidden.bs.modal.configuracion")
        .on("hidden.bs.modal.configuracion", function () {
            limpiarFormularioCatalogoConfiguracion();
        });

    $("#usuarioSistemaModal")
        .off("hidden.bs.modal.configuracion")
        .on("hidden.bs.modal.configuracion", function () {
            limpiarFormularioUsuarioSistema();
        });

    $("#empleadoSistemaModal")
        .off("hidden.bs.modal.configuracion")
        .on("hidden.bs.modal.configuracion", function () {
            limpiarFormularioEmpleadoSistema();
        });
}

function destruirTablasConfiguracion() {
    Object.keys(configuracionTablas).forEach(function (catalogo) {
        const tabla = configuracionTablas[catalogo];
        if (tabla && $.fn.DataTable.isDataTable("#configTabla__" + catalogo)) {
            tabla.destroy();
        }
    });

    configuracionTablas = {};
    configuracionResumenes = {};
}

function cargarMetadatosConfiguracion(grupoActivoPreferido) {
    const grupoActivo = grupoActivoPreferido || obtenerGrupoActivoConfiguracion();
    destruirTablasConfiguracion();

    $("#configuracionResumenGeneral").html(
        '<div class="col-12"><div class="config-master-empty">Cargando centro de configuracion...</div></div>'
    );
    $("#configuracionTabsNav").empty();
    $("#configuracionTabsContent").html(
        '<div class="config-master-empty">Preparando panel de configuracion...</div>'
    );

    $.ajax({
        url: "../ajax/configuracion.php?op=metadata",
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo cargar la configuracion.");
                $("#configuracionTabsContent").html(
                    '<div class="config-master-empty">No fue posible cargar la configuracion maestra.</div>'
                );
                return;
            }

            configuracionMeta = response.data;
            indexarMetadatosConfiguracion(configuracionMeta);
            renderizarResumenGeneralConfiguracion();
            renderizarNavegacionConfiguracion();
            renderizarContenidoConfiguracion();
            inicializarTablasConfiguracion();

            const grupoMostrar = grupoActivo && configuracionGrupos[grupoActivo]
                ? grupoActivo
                : Object.keys(configuracionGrupos)[0];

            if (grupoMostrar) {
                $('#configuracionTabsNav .nav-link[data-group="' + grupoMostrar + '"]').tab("show");
            }
        },
        error: function (xhr) {
            console.error("Error al cargar metadatos de configuracion:", xhr.responseText);
            $("#configuracionTabsContent").html(
                '<div class="config-master-empty">No fue posible cargar la configuracion maestra.</div>'
            );
            mostrarAlertaConfiguracion("error", "No se pudo cargar el centro de configuracion.");
        }
    });
}

function indexarMetadatosConfiguracion(meta) {
    configuracionCatalogos = {};
    configuracionGrupos = {};

    const grupos = meta && Array.isArray(meta.groups) ? meta.groups : [];
    grupos.forEach(function (grupo) {
        configuracionGrupos[grupo.key] = grupo;
        const catalogos = Array.isArray(grupo.catalogs) ? grupo.catalogs : [];
        catalogos.forEach(function (catalogo) {
            catalogo.group = grupo.key;
            configuracionCatalogos[catalogo.key] = catalogo;
        });
    });
}

function renderizarResumenGeneralConfiguracion() {
    const grupos = Object.keys(configuracionGrupos);
    if (!grupos.length) {
        $("#configuracionResumenGeneral").html(
            '<div class="col-12"><div class="config-master-empty">No hay catalogos configurados.</div></div>'
        );
        return;
    }

    const html = grupos.map(function (groupKey) {
        const grupo = configuracionGrupos[groupKey];
        return '' +
            '<div class="col-md-6 col-xl-4 mb-3">' +
            '    <article class="config-master-overview-card" data-group-summary="' + escapeAttrConfiguracion(groupKey) + '">' +
            '        <div class="config-master-overview-icon">' +
            '            <i class="' + escapeAttrConfiguracion(grupo.icon) + '"></i>' +
            '        </div>' +
            '        <div>' +
            '            <p class="eyebrow">Configuracion</p>' +
            '            <h4>' + escapeHtmlConfiguracion(grupo.label) + '</h4>' +
            '            <p data-group-summary-text>0 activos de 0 registros en 0 catalogos</p>' +
            '        </div>' +
            '    </article>' +
            '</div>';
    }).join("");

    $("#configuracionResumenGeneral").html(html);
}

function renderizarNavegacionConfiguracion() {
    const grupos = Object.keys(configuracionGrupos);
    const html = grupos.map(function (groupKey, index) {
        const grupo = configuracionGrupos[groupKey];
        const activa = index === 0 ? " active" : "";

        return '' +
            '<a class="nav-link' + activa + '" id="configuracion-tab-' + escapeAttrConfiguracion(groupKey) + '"' +
            ' data-toggle="pill" href="#configuracion-pane-' + escapeAttrConfiguracion(groupKey) + '"' +
            ' role="tab" aria-controls="configuracion-pane-' + escapeAttrConfiguracion(groupKey) + '"' +
            ' aria-selected="' + (index === 0 ? "true" : "false") + '"' +
            ' data-group="' + escapeAttrConfiguracion(groupKey) + '">' +
            '    <i class="' + escapeAttrConfiguracion(grupo.icon) + '"></i>' +
            '    <span class="config-master-nav-copy">' +
            '        <strong>' + escapeHtmlConfiguracion(grupo.label) + '</strong>' +
            '        <span>' + escapeHtmlConfiguracion(grupo.description) + '</span>' +
            '    </span>' +
            '    <span class="config-master-nav-badge" data-group-nav-badge="' + escapeAttrConfiguracion(groupKey) + '">0</span>' +
            '</a>';
    }).join("");

    $("#configuracionTabsNav").html(html);
}

function renderizarContenidoConfiguracion() {
    const grupos = Object.keys(configuracionGrupos);
    const html = grupos.map(function (groupKey, index) {
        const grupo = configuracionGrupos[groupKey];
        const catalogos = Array.isArray(grupo.catalogs) ? grupo.catalogs : [];
        let contenidoCatalogos = "";

        if (catalogos.length > 1) {
            contenidoCatalogos =
                '<ul class="nav nav-tabs config-master-browser-tabs" role="tablist">' +
                catalogos.map(function (catalogo, catalogIndex) {
                    return '' +
                        '<li class="nav-item" role="presentation">' +
                        '    <a class="nav-link js-config-browser-tab' + (catalogIndex === 0 ? " active" : "") + '"' +
                        ' data-toggle="tab" href="#configuracion-browser-' + escapeAttrConfiguracion(groupKey) + '-' + escapeAttrConfiguracion(catalogo.key) + '"' +
                        ' role="tab" data-catalogo="' + escapeAttrConfiguracion(catalogo.key) + '">' +
                        escapeHtmlConfiguracion(catalogo.title) +
                        "</a>" +
                        "</li>";
                }).join("") +
                "</ul>" +
                '<div class="tab-content config-master-browser-content">' +
                catalogos.map(function (catalogo, catalogIndex) {
                    return '' +
                        '<div class="tab-pane fade' + (catalogIndex === 0 ? " show active" : "") + '"' +
                        ' id="configuracion-browser-' + escapeAttrConfiguracion(groupKey) + '-' + escapeAttrConfiguracion(catalogo.key) + '"' +
                        ' role="tabpanel">' +
                        renderizarTarjetaCatalogoConfiguracion(catalogo) +
                        "</div>";
                }).join("") +
                "</div>";
        } else {
            contenidoCatalogos = catalogos.map(function (catalogo) {
                return renderizarTarjetaCatalogoConfiguracion(catalogo);
            }).join("");
        }

        return '' +
            '<div class="tab-pane fade' + (index === 0 ? " show active" : "") + '" id="configuracion-pane-' + escapeAttrConfiguracion(groupKey) + '"' +
            ' role="tabpanel" aria-labelledby="configuracion-tab-' + escapeAttrConfiguracion(groupKey) + '">' +
            '   <div class="config-master-group-head">' +
            '       <h3>' + escapeHtmlConfiguracion(grupo.label) + '</h3>' +
            '       <p>' + escapeHtmlConfiguracion(grupo.description) + '</p>' +
            '   </div>' +
                    contenidoCatalogos +
            '</div>';
    }).join("");

    $("#configuracionTabsContent").html(html);
}

function renderizarTarjetaCatalogoConfiguracion(catalogo) {
    const tableId = "configTabla__" + catalogo.key;
    const searchId = "configSearch__" + catalogo.key;
    const lengthId = "configLength__" + catalogo.key;
    const esSoloLectura = catalogo.read_only === true;

    return '' +
        '<div class="card config-master-card mb-4" data-catalogo-card="' + escapeAttrConfiguracion(catalogo.key) + '">' +
        '    <div class="card-header config-master-card-header d-flex justify-content-between align-items-start flex-wrap">' +
        '        <div class="config-master-card-copy">' +
        '            <h5 class="card-title">' + escapeHtmlConfiguracion(catalogo.title) + '</h5>' +
        '        </div>' +
        '        <div class="card-tools">' +
        '            <div class="config-master-card-summary">' +
        '                <span class="status-pill active" data-catalog-summary-active="' + escapeAttrConfiguracion(catalogo.key) + '">0 activos</span>' +
        '                <span class="status-pill inactive" data-catalog-summary-inactive="' + escapeAttrConfiguracion(catalogo.key) + '">0 inactivos</span>' +
        '                <span class="status-pill draft" data-catalog-summary-total="' + escapeAttrConfiguracion(catalogo.key) + '">0 total</span>' +
        '            </div>' +
        (esSoloLectura
            ? ""
            : '            <button type="button" class="btn btn-primary btn-sm js-config-nuevo" data-catalogo="' + escapeAttrConfiguracion(catalogo.key) + '">' +
              '                <i class="fas fa-plus"></i> Nuevo' +
              '            </button>') +
        '            <button type="button" class="btn btn-outline-secondary btn-sm icon-only-btn js-config-refresh" data-catalogo="' + escapeAttrConfiguracion(catalogo.key) + '"' +
        '                title="Actualizar catalogo" aria-label="Actualizar catalogo">' +
        '                <i class="fas fa-sync-alt"></i>' +
        '            </button>' +
        '        </div>' +
        '    </div>' +
        '    <div class="card-body table-responsive p-3">' +
        '        <div class="row mb-3 align-items-end">' +
        '            <div class="col-lg-5">' +
        '                <label for="' + escapeAttrConfiguracion(searchId) + '" class="sr-only">Buscar</label>' +
        '                <div class="input-group">' +
        '                    <div class="input-group-prepend">' +
        '                        <span class="input-group-text"><i class="fas fa-search"></i></span>' +
        '                    </div>' +
        '                    <input type="search" class="form-control js-config-search" id="' + escapeAttrConfiguracion(searchId) + '"' +
        '                        data-catalogo="' + escapeAttrConfiguracion(catalogo.key) + '"' +
        '                        placeholder="' + escapeAttrConfiguracion(catalogo.search_placeholder || "Buscar registro") + '" autocomplete="off">' +
        '                </div>' +
        '            </div>' +
        '            <div class="col-lg-4 mt-2 mt-lg-0">' +
        '                <div class="btn-group btn-group-sm config-master-state-filter d-flex" role="group" aria-label="Filtrar por estado">' +
        '                    <button type="button" class="btn btn-primary active js-config-state-filter" data-catalogo="' + escapeAttrConfiguracion(catalogo.key) + '" data-filter="activos">Activos</button>' +
        '                    <button type="button" class="btn btn-outline-secondary js-config-state-filter" data-catalogo="' + escapeAttrConfiguracion(catalogo.key) + '" data-filter="inactivos">Inactivos</button>' +
        '                    <button type="button" class="btn btn-outline-secondary js-config-state-filter" data-catalogo="' + escapeAttrConfiguracion(catalogo.key) + '" data-filter="todos">Todos</button>' +
        '                </div>' +
        '            </div>' +
        '            <div class="col-lg-3 text-lg-right mt-2 mt-lg-0" id="' + escapeAttrConfiguracion(lengthId) + '"></div>' +
        '        </div>' +
        '        <table id="' + escapeAttrConfiguracion(tableId) + '" class="table table-hover table-striped w-100 config-master-table">' +
        '            <thead><tr>' + construirEncabezadosTablaConfiguracion(catalogo) + '</tr></thead>' +
        '            <tbody></tbody>' +
        '        </table>' +
        '    </div>' +
        '</div>';
}

function construirEncabezadosTablaConfiguracion(catalogo) {
    const encabezados = [];
    const columnas = Array.isArray(catalogo.columns) ? catalogo.columns : [];

    columnas.forEach(function (columna) {
        encabezados.push("<th>" + escapeHtmlConfiguracion(columna.label) + "</th>");
    });

    encabezados.push('<th class="config-align-right">Estado</th>');
    if (!(catalogo.read_only === true)) {
        encabezados.push('<th class="config-align-right">Acciones</th>');
    }
    return encabezados.join("");
}

function inicializarTablasConfiguracion() {
    Object.keys(configuracionCatalogos).forEach(function (catalogoKey) {
        inicializarTablaCatalogoConfiguracion(catalogoKey);
    });
}

function inicializarTablaCatalogoConfiguracion(catalogoKey) {
    const catalogo = configuracionCatalogos[catalogoKey];
    const selectorTabla = "#configTabla__" + catalogoKey;

    if (!$(selectorTabla).length) {
        return;
    }

    configuracionTablas[catalogoKey] = $(selectorTabla).DataTable({
        processing: true,
        serverSide: false,
        responsive: true,
        autoWidth: false,
        destroy: true,
        searching: true,
        dom: "lrtip",
        ajax: {
            url: "../ajax/configuracion.php?op=listar",
            type: "GET",
            dataType: "json",
            data: function () {
                return {
                    catalogo: catalogoKey,
                    estado: obtenerFiltroEstadoCatalogoConfiguracion(catalogoKey)
                };
            },
            dataSrc: function (response) {
                if (!response || response.ok !== true) {
                    actualizarResumenCatalogoConfiguracion(catalogoKey, null);
                    if (response && response.msg) {
                        console.warn("No se pudo cargar el catalogo " + catalogoKey + ": " + response.msg);
                    }
                    return [];
                }

                actualizarResumenCatalogoConfiguracion(catalogoKey, response.data ? response.data.resumen : null);
                return response.data && Array.isArray(response.data.items) ? response.data.items : [];
            },
            error: function (xhr) {
                console.error("Error al cargar catalogo " + catalogoKey + ":", xhr.responseText);
                actualizarResumenCatalogoConfiguracion(catalogoKey, null);
                mostrarAlertaConfiguracion("error", "No se pudo cargar el catalogo " + catalogo.title + ".");
            }
        },
        columns: construirColumnasDataTableConfiguracion(catalogo),
        order: [[0, "asc"]],
        pageLength: 10,
        language: {
            decimal: "",
            emptyTable: "No hay datos disponibles",
            info: "Mostrando _START_ a _END_ de _TOTAL_ registros",
            infoEmpty: "Mostrando 0 a 0 de 0 registros",
            infoFiltered: "(filtrado de _MAX_ registros totales)",
            lengthMenu: "Mostrar registros _MENU_",
            loadingRecords: "Cargando...",
            processing: "Procesando...",
            search: "Buscar:",
            zeroRecords: "No se encontraron resultados",
            paginate: {
                first: "Primero",
                last: "Ultimo",
                next: "Siguiente",
                previous: "Anterior"
            }
        },
        initComplete: function () {
            reubicarControlLongitudConfiguracion(catalogoKey);
        }
    });
}

function construirColumnasDataTableConfiguracion(catalogo) {
    const columnas = [];

    (catalogo.columns || []).forEach(function (columna) {
        columnas.push({
            data: columna.key,
            render: function (valor, tipo, fila) {
                if (tipo !== "display") {
                    return obtenerValorPlanoColumnaConfiguracion(columna, fila);
                }

                return renderizarCeldaConfiguracion(columna, fila);
            }
        });
    });

    columnas.push({
        data: "estado_texto",
        className: "text-nowrap text-right",
        render: function (valor, tipo, fila) {
            if (tipo !== "display") {
                return fila.estado_texto || "";
            }

            return '<span class="status-pill ' + sanitizarClaseBadgeConfiguracion(fila.estado_badge) + '">' +
                escapeHtmlConfiguracion(fila.estado_texto || "") +
                "</span>";
        }
    });

    if (!(catalogo.read_only === true)) {
        columnas.push({
            data: null,
            orderable: false,
            searchable: false,
            className: "text-nowrap text-right",
            render: function (valor, tipo, fila) {
                if (tipo !== "display") {
                    return "";
                }

                return renderizarAccionesFilaConfiguracion(catalogo, fila);
            }
        });
    }

    return columnas;
}

function obtenerValorPlanoColumnaConfiguracion(columna, fila) {
    if (columna.type === "boolean") {
        return fila[columna.key + "_texto"] || (String(fila[columna.key]) === "1" ? "Si" : "No");
    }

    if (columna.type === "badge_preview") {
        return fila.badge_preview || fila[columna.key] || "";
    }

    return fila[columna.key] == null ? "" : fila[columna.key];
}

function renderizarCeldaConfiguracion(columna, fila) {
    const valor = fila[columna.key];

    if (columna.type === "boolean") {
        const texto = fila[columna.key + "_texto"] || (String(valor) === "1" ? "Si" : "No");
        const clase = String(valor) === "1" ? "active" : "secondary";
        return '<span class="status-pill ' + clase + '">' + escapeHtmlConfiguracion(texto) + "</span>";
    }

    if (columna.type === "badge_preview") {
        return '<span class="status-pill ' + sanitizarClaseBadgeConfiguracion(fila.clase_badge) + '">' +
            escapeHtmlConfiguracion(fila.badge_preview || valor || "") +
            "</span>";
    }

    if (valor == null || valor === "") {
        return '<span class="text-muted">Sin datos</span>';
    }

    return escapeHtmlConfiguracion(valor);
}

function renderizarAccionesFilaConfiguracion(catalogo, fila) {
    if (catalogo.read_only === true) {
        return "";
    }

    const idRegistro = fila[catalogo.pk];
    const botones = [];
    const edicionBloqueada = catalogo.key === "dependencias" && !!fila.registro_protegido;
    const tituloEditar = edicionBloqueada ? (fila.motivo_bloqueo || "Registro protegido") : "Editar";
    const disabledEditar = edicionBloqueada ? " disabled" : "";

    botones.push('<div class="d-flex justify-content-end flex-nowrap config-master-actions">');
    botones.push(
        '<button type="button" class="btn btn-sm btn-outline-primary js-config-editar" data-catalogo="' +
        escapeAttrConfiguracion(catalogo.key) +
        '" data-id="' + escapeAttrConfiguracion(idRegistro) +
        '" title="' + escapeAttrConfiguracion(tituloEditar) + '"' + disabledEditar + '><i class="fas fa-pen"></i></button>'
    );

    if (parseInt(fila.estado, 10) === 1) {
        const deshabilitado = fila.puede_desactivar ? "" : " disabled";
        const titulo = fila.motivo_bloqueo || "Desactivar";
        botones.push(
            '<button type="button" class="btn btn-sm btn-outline-danger js-config-desactivar" data-catalogo="' +
            escapeAttrConfiguracion(catalogo.key) +
            '" data-id="' + escapeAttrConfiguracion(idRegistro) +
            '" title="' + escapeAttrConfiguracion(titulo) + '"' + deshabilitado + ">" +
            '<i class="fas fa-trash-alt"></i></button>'
        );
    } else {
        const reactivarBloqueado = !!fila.registro_protegido;
        const tituloReactivar = reactivarBloqueado ? (fila.motivo_bloqueo || "Registro protegido") : "Reactivar";
        const disabledReactivar = reactivarBloqueado ? " disabled" : "";
        botones.push(
            '<button type="button" class="btn btn-sm btn-outline-success js-config-reactivar" data-catalogo="' +
            escapeAttrConfiguracion(catalogo.key) +
            '" data-id="' + escapeAttrConfiguracion(idRegistro) +
            '" title="' + escapeAttrConfiguracion(tituloReactivar) + '"' + disabledReactivar + '><i class="fas fa-undo"></i></button>'
        );
    }

    botones.push("</div>");
    return botones.join("");
}

function reubicarControlLongitudConfiguracion(catalogoKey) {
    const control = $("#configTabla__" + catalogoKey + "_wrapper .dataTables_length");
    const contenedor = $("#configLength__" + catalogoKey);

    if (!control.length || !contenedor.length) {
        return;
    }

    contenedor.empty().append(control);
}

function obtenerFiltroEstadoCatalogoConfiguracion(catalogoKey) {
    const activo = $('.js-config-state-filter[data-catalogo="' + catalogoKey + '"].active').data("filter");
    return activo || "activos";
}

function recargarCatalogoConfiguracion(catalogoKey, resetPaging) {
    const tabla = configuracionTablas[catalogoKey];
    if (!tabla) {
        return;
    }

    tabla.ajax.reload(null, !!resetPaging);
}

function actualizarResumenCatalogoConfiguracion(catalogoKey, resumen) {
    const datos = resumen || { activos: 0, inactivos: 0, total: 0 };
    configuracionResumenes[catalogoKey] = {
        activos: parseInt(datos.activos, 10) || 0,
        inactivos: parseInt(datos.inactivos, 10) || 0,
        total: parseInt(datos.total, 10) || 0
    };

    $('[data-catalog-summary-active="' + catalogoKey + '"]').text(configuracionResumenes[catalogoKey].activos + " activos");
    $('[data-catalog-summary-inactive="' + catalogoKey + '"]').text(configuracionResumenes[catalogoKey].inactivos + " inactivos");
    $('[data-catalog-summary-total="' + catalogoKey + '"]').text(configuracionResumenes[catalogoKey].total + " total");

    actualizarResumenGruposConfiguracion();
}

function actualizarResumenGruposConfiguracion() {
    Object.keys(configuracionGrupos).forEach(function (groupKey) {
        const grupo = configuracionGrupos[groupKey];
        const catalogos = Array.isArray(grupo.catalogs) ? grupo.catalogs : [];
        let activos = 0;
        let total = 0;

        catalogos.forEach(function (catalogo) {
            const resumen = configuracionResumenes[catalogo.key] || { activos: 0, total: 0 };
            activos += resumen.activos;
            total += resumen.total;
        });

        $('[data-group-summary="' + groupKey + '"] [data-group-summary-text]').text(
            activos + " activos de " + total + " registros en " + catalogos.length + " catalogos"
        );
        $('[data-group-nav-badge="' + groupKey + '"]').text(activos);
    });
}

function ajustarTablasGrupoConfiguracion(groupKey) {
    const grupo = configuracionGrupos[groupKey];
    if (!grupo || !Array.isArray(grupo.catalogs)) {
        return;
    }

    grupo.catalogs.forEach(function (catalogo) {
        ajustarTablaCatalogoConfiguracion(catalogo.key);
    });
}

function ajustarTablaCatalogoConfiguracion(catalogoKey) {
    const tabla = configuracionTablas[catalogoKey];
    if (tabla) {
        tabla.columns.adjust().responsive.recalc();
    }
}

function abrirModalCatalogoConfiguracion(catalogoKey, idRegistro) {
    const catalogo = configuracionCatalogos[catalogoKey];
    if (!catalogo) {
        mostrarAlertaConfiguracion("error", "No se encontro el catalogo solicitado.");
        return;
    }
    if (catalogo.read_only === true) {
        mostrarAlertaConfiguracion("warning", "El catalogo " + catalogo.title + " es fijo del sistema y solo permite consulta.");
        return;
    }

    $("#configuracionCatalogo").val(catalogoKey);
    $("#configuracionRegistroId").val(idRegistro || "");
    $("#configuracionModalNotice").addClass("d-none").text("");

    if (parseInt(idRegistro, 10) > 0) {
        cargarRegistroCatalogoConfiguracion(catalogo, idRegistro);
        return;
    }

    $("#configuracionCatalogoModalLabel").text("Nuevo registro - " + catalogo.title);
    $("#btnGuardarConfiguracionCatalogo").html('<i class="fas fa-save"></i> Guardar registro');
    renderizarCamposModalConfiguracion(catalogo, {}, {});
    $("#configuracionCatalogoModal").modal("show");
}

function cargarRegistroCatalogoConfiguracion(catalogo, idRegistro) {
    $.ajax({
        url: "../ajax/configuracion.php?op=mostrar",
        type: "GET",
        dataType: "json",
        data: {
            catalogo: catalogo.key,
            id_registro: idRegistro
        },
        success: function (response) {
            if (!response || response.ok !== true || !response.data || !response.data.item) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo cargar el registro.");
                return;
            }

            $("#configuracionCatalogoModalLabel").text("Editar registro - " + catalogo.title);
            $("#btnGuardarConfiguracionCatalogo").html('<i class="fas fa-save"></i> Guardar cambios');
            renderizarCamposModalConfiguracion(
                catalogo,
                response.data.item || {},
                response.data.locks || {}
            );

            if (response.data.notice) {
                $("#configuracionModalNotice").removeClass("d-none").text(response.data.notice);
            } else {
                $("#configuracionModalNotice").addClass("d-none").text("");
            }

            $("#configuracionCatalogoModal").modal("show");
        },
        error: function (xhr) {
            console.error("Error al consultar registro de configuracion:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo consultar el registro.");
        }
    });
}

function renderizarCamposModalConfiguracion(catalogo, item, locks) {
    const html = [];
    const campos = Array.isArray(catalogo.fields) ? catalogo.fields : [];

    campos.forEach(function (field) {
        const valor = item && item[field.name] != null ? item[field.name] : "";
        const locked = !!locks[field.name];
        const fieldId = "configField__" + field.name;
        const colClass = field.type === "textarea" ? "col-12" : "col-md-6";
        const required = field.required ? ' required' : "";
        const disabled = locked ? ' disabled="disabled"' : "";
        const readOnlyClass = locked ? " field-locked" : "";
        const helpLocked = locked
            ? '<div class="modal-help text-warning">Este campo esta protegido y no puede modificarse en este registro.</div>'
            : "";
        const helpText = field.help
            ? '<div class="modal-help">' + escapeHtmlConfiguracion(field.help) + "</div>"
            : "";

        html.push('<div class="form-group ' + colClass + '">');
        html.push(
            '<label for="' + escapeAttrConfiguracion(fieldId) + '">' +
            escapeHtmlConfiguracion(field.label) +
            (field.required ? ' <span class="text-danger">*</span>' : "") +
            "</label>"
        );

        if (field.type === "textarea") {
            html.push(
                '<textarea class="form-control' + readOnlyClass + '" id="' + escapeAttrConfiguracion(fieldId) +
                '" name="' + escapeAttrConfiguracion(field.name) + '" rows="3" maxlength="' +
                escapeAttrConfiguracion(field.maxlength || "") + '"' + required + disabled +
                ' placeholder="' + escapeAttrConfiguracion(field.placeholder || "") + '">' +
                escapeHtmlConfiguracion(valor) +
                "</textarea>"
            );
        } else if (field.type === "select") {
            html.push(
                '<select class="form-control js-config-select' + readOnlyClass + '" id="' +
                escapeAttrConfiguracion(fieldId) + '" name="' + escapeAttrConfiguracion(field.name) + '"' +
                required + disabled + '>'
            );
            html.push('<option value="">Seleccione una opcion</option>');

            (field.options || []).forEach(function (option) {
                const selected = String(option.value) === String(valor) ? ' selected="selected"' : "";
                html.push(
                    '<option value="' + escapeAttrConfiguracion(option.value) + '"' + selected + ">" +
                    escapeHtmlConfiguracion(option.label) +
                    "</option>"
                );
            });

            html.push("</select>");
        } else {
            const type = field.type === "number" ? "number" : "text";
            const min = field.type === "number" && field.min != null ? ' min="' + escapeAttrConfiguracion(field.min) + '"' : "";
            const maxLength = field.maxlength != null ? ' maxlength="' + escapeAttrConfiguracion(field.maxlength) + '"' : "";
            const value = valor == null ? "" : valor;
            html.push(
                '<input type="' + type + '" class="form-control' + readOnlyClass + '" id="' +
                escapeAttrConfiguracion(fieldId) + '" name="' + escapeAttrConfiguracion(field.name) +
                '" value="' + escapeAttrConfiguracion(value) + '"' + maxLength + min + required + disabled +
                ' placeholder="' + escapeAttrConfiguracion(field.placeholder || "") + '">'
            );
        }

        html.push(helpText);
        html.push(helpLocked);
        html.push("</div>");
    });

    $("#configuracionModalFields").html(html.join(""));
    inicializarSelectsModalConfiguracion();
}

function inicializarSelectsModalConfiguracion() {
    if (typeof $.fn.select2 !== "function") {
        return;
    }

    $("#configuracionModalFields .js-config-select").each(function () {
        const select = $(this);

        if (select.hasClass("select2-hidden-accessible")) {
            select.select2("destroy");
        }

        select.select2({
            theme: "bootstrap4",
            width: "100%",
            dropdownParent: $("#configuracionCatalogoModal"),
            allowClear: false,
            minimumResultsForSearch: Infinity
        });
    });
}

function limpiarFormularioCatalogoConfiguracion() {
    const formulario = $("#formularioConfiguracionCatalogo");
    if (!formulario.length) {
        return;
    }

    formulario[0].reset();
    $("#configuracionCatalogo").val("");
    $("#configuracionRegistroId").val("");
    $("#configuracionModalNotice").addClass("d-none").text("");
    $("#configuracionModalFields").empty();
}

function guardarCatalogoConfiguracion() {
    const boton = $("#btnGuardarConfiguracionCatalogo");
    boton.prop("disabled", true);

    $.ajax({
        url: "../ajax/configuracion.php?op=guardaryeditar",
        type: "POST",
        dataType: "json",
        data: new FormData(document.getElementById("formularioConfiguracionCatalogo")),
        contentType: false,
        processData: false,
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo guardar el registro.");
                return;
            }

            const catalogoKey = $("#configuracionCatalogo").val();
            limpiarFormularioCatalogoConfiguracion();
            $("#configuracionCatalogoModal").modal("hide");
            recargarCatalogoConfiguracion(catalogoKey, true);
            mostrarAlertaConfiguracion("success", response.msg || "Registro guardado correctamente.");
        },
        error: function (xhr) {
            console.error("Error al guardar configuracion:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            boton.prop("disabled", false);
        }
    });
}

function cambiarEstadoCatalogoConfiguracion(catalogoKey, idRegistro, operacion) {
    const catalogo = configuracionCatalogos[catalogoKey];
    if (!catalogo) {
        return;
    }
    if (catalogo.read_only === true) {
        mostrarAlertaConfiguracion("warning", "El catalogo " + catalogo.title + " es fijo del sistema y no admite cambios.");
        return;
    }

    const accion = operacion === "reactivar" ? "reactivar" : "desactivar";
    const mensaje = accion === "reactivar"
        ? "Confirma que deseas reactivar este registro del catalogo " + catalogo.title + "?"
        : "Confirma que deseas desactivar este registro del catalogo " + catalogo.title + "?";

    confirmarAccionConfiguracion(mensaje, accion === "reactivar" ? "Si, reactivar" : "Si, desactivar")
        .then(function (resultado) {
            if (!confirmacionAceptadaConfiguracion(resultado)) {
                return;
            }

            $.ajax({
                url: "../ajax/configuracion.php?op=" + operacion,
                type: "POST",
                dataType: "json",
                data: {
                    catalogo: catalogoKey,
                    id_registro: idRegistro
                },
                success: function (response) {
                    if (!response || response.ok !== true) {
                        mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo completar la operacion.");
                        return;
                    }

                    recargarCatalogoConfiguracion(catalogoKey, true);
                    mostrarAlertaConfiguracion("success", response.msg || "Operacion realizada correctamente.");
                },
                error: function (xhr) {
                    console.error("Error al cambiar estado del catalogo:", xhr.responseText);
                    mostrarAlertaConfiguracion("error", "No se pudo completar la operacion.");
                }
            });
        });
}

function obtenerFiltroEstadoUsuariosConfiguracion() {
    const activo = $(".js-user-state-filter.active").data("filter");
    return activo || "activos";
}

function cargarMetadatosUsuariosConfiguracion(reinicializarTabla) {
    const resumen = $("#configuracionUsuariosResumen");
    if (!resumen.length) {
        return;
    }

    resumen.html('<div class="col-12"><div class="config-master-empty">Cargando panel de usuarios...</div></div>');

    $.ajax({
        url: "../ajax/configuracion.php?op=metadatausuarios",
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo cargar la configuracion de usuarios.");
                return;
            }

            configuracionUsuariosMeta = response.data;
            renderizarResumenUsuariosConfiguracion(null);

            if (!configuracionUsuariosTabla || reinicializarTabla !== false) {
                inicializarTablaUsuariosConfiguracion();
            } else {
                recargarUsuariosConfiguracion(false);
            }
        },
        error: function (xhr) {
            console.error("Error al cargar metadatos de usuarios:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo cargar el panel de usuarios.");
        }
    });
}

function renderizarResumenUsuariosConfiguracion(resumen) {
    const datos = resumen || {
        total: 0,
        activos: 0,
        inactivos: 0,
        administradores: 0,
        bloqueados: 0,
        con_clave_temporal: 0,
        con_acceso_total: 0
    };

    configuracionUsuariosResumen = {
        total: parseInt(datos.total, 10) || 0,
        activos: parseInt(datos.activos, 10) || 0,
        inactivos: parseInt(datos.inactivos, 10) || 0,
        administradores: parseInt(datos.administradores, 10) || 0,
        bloqueados: parseInt(datos.bloqueados, 10) || 0,
        conClaveTemporal: parseInt(datos.con_clave_temporal, 10) || 0,
        conAccesoTotal: parseInt(datos.con_acceso_total, 10) || 0
    };

    const html = '' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-users-cog"></i></div>' +
        '       <div><p class="eyebrow">Usuarios</p><h4>' + configuracionUsuariosResumen.total + '</h4><p>Total de cuentas registradas.</p></div>' +
        '   </article>' +
        '</div>' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-user-check"></i></div>' +
        '       <div><p class="eyebrow">Activos</p><h4>' + configuracionUsuariosResumen.activos + '</h4><p>Cuentas operativas disponibles.</p></div>' +
        '   </article>' +
        '</div>' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-user-shield"></i></div>' +
        '       <div><p class="eyebrow">Administradores</p><h4>' + configuracionUsuariosResumen.administradores + '</h4><p>Usuarios con rol administrativo.</p></div>' +
        '   </article>' +
        '</div>' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-user-lock"></i></div>' +
        '       <div><p class="eyebrow">Bloqueados</p><h4>' + configuracionUsuariosResumen.bloqueados + '</h4><p>Cuentas bloqueadas por intentos fallidos.</p></div>' +
        '   </article>' +
        '</div>' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-envelope-open-text"></i></div>' +
        '       <div><p class="eyebrow">Clave temporal</p><h4>' + configuracionUsuariosResumen.conClaveTemporal + '</h4><p>Usuarios pendientes por cambiar clave.</p></div>' +
        '   </article>' +
        '</div>' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-key"></i></div>' +
        '       <div><p class="eyebrow">Acceso total</p><h4>' + configuracionUsuariosResumen.conAccesoTotal + '</h4><p>Cuentas con permiso total habilitado.</p></div>' +
        '   </article>' +
        '</div>';

    $("#configuracionUsuariosResumen").html(html);
}

function inicializarTablaUsuariosConfiguracion() {
    if (!$("#tblUsuariosSistema").length) {
        return;
    }

    if (configuracionUsuariosTabla && $.fn.DataTable.isDataTable("#tblUsuariosSistema")) {
        configuracionUsuariosTabla.destroy();
    }

    configuracionUsuariosTabla = $("#tblUsuariosSistema").DataTable({
        processing: true,
        serverSide: false,
        responsive: true,
        autoWidth: false,
        destroy: true,
        searching: true,
        dom: "lrtip",
        ajax: {
            url: "../ajax/configuracion.php?op=listarusuarios",
            type: "GET",
            dataType: "json",
            data: function () {
                return {
                    estado: obtenerFiltroEstadoUsuariosConfiguracion()
                };
            },
            dataSrc: function (response) {
                if (!response || response.ok !== true) {
                    renderizarResumenUsuariosConfiguracion(null);
                    return [];
                }

                renderizarResumenUsuariosConfiguracion(response.data ? response.data.resumen : null);
                return response.data && Array.isArray(response.data.items) ? response.data.items : [];
            },
            error: function (xhr) {
                console.error("Error al cargar usuarios:", xhr.responseText);
                renderizarResumenUsuariosConfiguracion(null);
                mostrarAlertaConfiguracion("error", "No se pudo cargar el listado de usuarios.");
            }
        },
        columns: [
            {
                data: "usuario",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return [fila.usuario || "", fila.rol || ""].join(" ");
                    }

                    return '' +
                        '<div class="config-user-cell">' +
                        '   <strong>' + escapeHtmlConfiguracion(fila.usuario || "") + '</strong>' +
                        '   <span>' + escapeHtmlConfiguracion(fila.es_usuario_actual ? "Sesion actual" : (fila.rol_texto || "")) + '</span>' +
                        '</div>';
                }
            },
            {
                data: "empleado_label",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return [fila.empleado_label || "", fila.empleado || ""].join(" ");
                    }

                    return '' +
                        '<div class="config-user-cell">' +
                        '   <strong>' + escapeHtmlConfiguracion(fila.empleado || "") + '</strong>' +
                        '   <span>' + escapeHtmlConfiguracion(fila.cedula || "") + '</span>' +
                        '</div>';
                }
            },
            { data: "dependencia", defaultContent: "" },
            {
                data: "rol_texto",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return fila.rol || "";
                    }

                    return '<span class="status-pill ' + (fila.es_admin ? "info" : "draft") + '">' +
                        escapeHtmlConfiguracion(fila.rol_texto || "") +
                        '</span>';
                }
            },
            {
                data: "permisos_regulares_texto",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return fila.permisos_regulares_texto || "";
                    }

                    return fila.permisos_regulares_nombres && fila.permisos_regulares_nombres.length
                        ? '<span class="config-permissions-inline">' + escapeHtmlConfiguracion(fila.permisos_regulares_nombres.join(", ")) + '</span>'
                        : '<span class="text-muted">Sin permisos</span>';
                }
            },
            {
                data: "acceso_total_texto",
                className: "text-nowrap text-right",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return fila.acceso_total_texto || "";
                    }

                    return '<span class="status-pill ' + sanitizarClaseBadgeConfiguracion(fila.acceso_total_badge) + '">' +
                        escapeHtmlConfiguracion(fila.acceso_total_texto || "") +
                        '</span>';
                }
            },
            {
                data: "estado_texto",
                className: "text-nowrap text-right",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return fila.estado_texto || "";
                    }

                    return '<span class="status-pill ' + sanitizarClaseBadgeConfiguracion(fila.estado_badge) + '">' +
                        escapeHtmlConfiguracion(fila.estado_texto || "") +
                        '</span>';
                }
            },
            {
                data: null,
                orderable: false,
                searchable: false,
                className: "text-nowrap text-right",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return "";
                    }

                    const botones = [];
                    botones.push('<div class="d-flex justify-content-end flex-nowrap config-master-actions">');
                    botones.push('<button type="button" class="btn btn-sm btn-outline-primary js-user-edit" data-id="' + escapeAttrConfiguracion(fila.id_usuario) + '" title="Editar"><i class="fas fa-pen"></i></button>');

                    if (parseInt(fila.estado, 10) === 1) {
                        const disabled = fila.puede_desactivar ? "" : " disabled";
                        const titulo = fila.motivo_bloqueo || "Desactivar";
                        botones.push('<button type="button" class="btn btn-sm btn-outline-danger js-user-desactivar" data-id="' + escapeAttrConfiguracion(fila.id_usuario) + '" title="' + escapeAttrConfiguracion(titulo) + '"' + disabled + '><i class="fas fa-trash-alt"></i></button>');
                    } else {
                        botones.push('<button type="button" class="btn btn-sm btn-outline-success js-user-reactivar" data-id="' + escapeAttrConfiguracion(fila.id_usuario) + '" title="Reactivar"><i class="fas fa-undo"></i></button>');
                    }

                    botones.push("</div>");
                    return botones.join("");
                }
            }
        ],
        order: [[0, "asc"]],
        pageLength: 10,
        language: {
            decimal: "",
            emptyTable: "No hay datos disponibles",
            info: "Mostrando _START_ a _END_ de _TOTAL_ registros",
            infoEmpty: "Mostrando 0 a 0 de 0 registros",
            infoFiltered: "(filtrado de _MAX_ registros totales)",
            lengthMenu: "Mostrar registros _MENU_",
            loadingRecords: "Cargando...",
            processing: "Procesando...",
            search: "Buscar:",
            zeroRecords: "No se encontraron resultados",
            paginate: {
                first: "Primero",
                last: "Ultimo",
                next: "Siguiente",
                previous: "Anterior"
            }
        },
        initComplete: function () {
            const control = $("#tblUsuariosSistema_wrapper .dataTables_length");
            const contenedor = $("#usuariosSistemaLength");
            if (control.length && contenedor.length) {
                contenedor.empty().append(control);
            }
        }
    });
}

function recargarUsuariosConfiguracion(resetPaging) {
    if (configuracionUsuariosTabla) {
        configuracionUsuariosTabla.ajax.reload(null, !!resetPaging);
    }
}

function abrirModalUsuarioSistema(idUsuario) {
    if (!configuracionUsuariosMeta) {
        mostrarAlertaConfiguracion("error", "Los metadatos de usuarios aun no estan disponibles.");
        return;
    }

    configuracionUsuarioModal = {
        id: parseInt(idUsuario, 10) || 0,
        tieneAccesoTotal: false,
        esUsuarioActual: false
    };

    limpiarFormularioUsuarioSistema();
    $("#usuarioSistemaId").val(configuracionUsuarioModal.id || "");
    $("#usuarioSistemaNotice").addClass("d-none").text("");
    $("#usuarioSistemaModalLabel").text(configuracionUsuarioModal.id > 0 ? "Editar usuario" : "Nuevo usuario");
    $("#btnGuardarUsuarioSistema").html('<i class="fas fa-save"></i> Guardar usuario');

    poblarFormularioUsuarioSistema(null);

    if (configuracionUsuarioModal.id > 0) {
        cargarUsuarioSistema(configuracionUsuarioModal.id);
        return;
    }

    actualizarPanelAccesoTotalUsuario(null);
    $("#usuarioSistemaModal").modal("show");
}

function poblarFormularioUsuarioSistema(item) {
    const meta = configuracionUsuariosMeta || {};
    const usuarioId = item && item.id_usuario ? parseInt(item.id_usuario, 10) : 0;
    const empleadoId = item && item.id_empleado ? parseInt(item.id_empleado, 10) : 0;
    const rol = item && item.rol ? String(item.rol) : "";
    const tieneAccesoTotal = !!(item && item.tiene_acceso_total);
    const permisosIds = item && Array.isArray(item.id_permisos) ? item.id_permisos.map(function (id) { return String(id); }) : [];

    $("#usuarioSistemaEmpleado").html(construirOpcionesEmpleadosUsuario(meta.empleados || [], usuarioId, empleadoId));
    $("#usuarioSistemaRol").html(construirOpcionesRolesUsuario(meta.roles || [], rol, tieneAccesoTotal));
    $("#usuarioSistemaPermisos").html(construirOpcionesPermisosUsuario(meta.permisos || [], permisosIds));

    $("#usuarioSistemaUsuario").val(item && item.usuario ? item.usuario : "");
    $("#usuarioSistemaPassword").val("");
    $("#usuarioSistemaPasswordConfirm").val("");

    inicializarSelectsUsuariosConfiguracion();

    if (permisosIds.length) {
        $("#usuarioSistemaPermisos").val(permisosIds).trigger("change.select2");
    } else {
        $("#usuarioSistemaPermisos").val(null).trigger("change.select2");
    }

    actualizarDependenciaUsuarioSeleccionada();
}

function construirOpcionesEmpleadosUsuario(items, usuarioId, empleadoId) {
    const opciones = ['<option value="">Seleccione un empleado</option>'];

    items.forEach(function (item) {
        const ocupadoPorOtro = parseInt(item.usuario_activo_id, 10) > 0 && parseInt(item.usuario_activo_id, 10) !== parseInt(usuarioId, 10);
        const selected = parseInt(item.id_empleado, 10) === parseInt(empleadoId, 10) ? ' selected="selected"' : "";
        const disabled = ocupadoPorOtro ? ' disabled="disabled"' : "";
        const dataDependencia = ' data-dependencia="' + escapeAttrConfiguracion(item.nombre_dependencia || "Sin dependencia") + '"';
        const suffix = ocupadoPorOtro ? " | Ya asignado a " + item.usuario_activo : "";
        opciones.push(
            '<option value="' + escapeAttrConfiguracion(item.id_empleado) + '"' + selected + disabled + dataDependencia + '>' +
            escapeHtmlConfiguracion(item.label + suffix) +
            '</option>'
        );
    });

    return opciones.join("");
}

function actualizarDependenciaUsuarioSeleccionada() {
    const select = $("#usuarioSistemaEmpleado");
    const campo = $("#usuarioSistemaDependenciaVista");
    if (!select.length || !campo.length) {
        return;
    }

    const opcion = select.find("option:selected");
    const dependencia = opcion.data("dependencia");
    if (!select.val()) {
        campo.val("");
        return;
    }

    campo.val(dependencia ? String(dependencia) : "Sin dependencia");
}

function construirOpcionesSelectBasico(items, keyId, keyLabel, seleccionado) {
    const opciones = ['<option value="">Seleccione una opcion</option>'];

    items.forEach(function (item) {
        const selected = String(item[keyId]) === String(seleccionado || "") ? ' selected="selected"' : "";
        opciones.push(
            '<option value="' + escapeAttrConfiguracion(item[keyId]) + '"' + selected + '>' +
            escapeHtmlConfiguracion(item[keyLabel]) +
            '</option>'
        );
    });

    return opciones.join("");
}

function construirOpcionesRolesUsuario(items, seleccionado, soloAdministrador) {
    const seleccionadoNormalizado = String(seleccionado || "").toUpperCase();

    if (soloAdministrador) {
        return '<option value="ADMIN" selected="selected">Administrador</option>';
    }

    const opciones = ['<option value="">Seleccione un rol</option>'];

    items.forEach(function (item) {
        const valor = String(item.value || "").toUpperCase();
        if (valor === "ADMIN") {
            return;
        }

        const selected = valor === seleccionadoNormalizado ? ' selected="selected"' : "";
        opciones.push(
            '<option value="' + escapeAttrConfiguracion(valor) + '"' + selected + '>' +
            escapeHtmlConfiguracion(item.label) +
            '</option>'
        );
    });

    return opciones.join("");
}

function construirOpcionesPermisosUsuario(items, seleccionados) {
    const ids = Array.isArray(seleccionados) ? seleccionados.map(String) : [];
    return items.map(function (item) {
        const selected = ids.indexOf(String(item.id_permiso)) >= 0 ? ' selected="selected"' : "";
        const descripcion = item.descripcion ? " - " + item.descripcion : "";
        return '<option value="' + escapeAttrConfiguracion(item.id_permiso) + '"' + selected + '>' +
            escapeHtmlConfiguracion(item.nombre_permiso + descripcion) +
            '</option>';
    }).join("");
}

function inicializarSelectsUsuariosConfiguracion() {
    if (typeof $.fn.select2 !== "function") {
        return;
    }

    [
        { selector: "#usuarioSistemaEmpleado", placeholder: "Busque por cedula o nombre", multiple: false },
        { selector: "#usuarioSistemaRol", placeholder: "Seleccione un rol", multiple: false },
        { selector: "#usuarioSistemaPermisos", placeholder: "Seleccione permisos operativos", multiple: true }
    ].forEach(function (config) {
        const select = $(config.selector);
        if (!select.length) {
            return;
        }

        if (select.hasClass("select2-hidden-accessible")) {
            select.select2("destroy");
        }

        select.select2({
            theme: "bootstrap4",
            width: "100%",
            dropdownParent: $("#usuarioSistemaModal"),
            placeholder: config.placeholder,
            allowClear: !config.multiple,
            closeOnSelect: !config.multiple
        });
    });
}

function cargarUsuarioSistema(idUsuario) {
    $.ajax({
        url: "../ajax/configuracion.php?op=mostrarusuario",
        type: "GET",
        dataType: "json",
        data: {
            id_registro: idUsuario
        },
        success: function (response) {
            if (!response || response.ok !== true || !response.data || !response.data.item) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo cargar el usuario.");
                return;
            }

            const item = response.data.item;
            configuracionUsuarioModal.id = parseInt(item.id_usuario, 10) || 0;
            configuracionUsuarioModal.tieneAccesoTotal = !!item.tiene_acceso_total;
            configuracionUsuarioModal.esUsuarioActual = !!item.es_usuario_actual;
            $("#usuarioSistemaId").val(configuracionUsuarioModal.id);
            $("#usuarioSistemaModalLabel").text("Editar usuario");
            poblarFormularioUsuarioSistema(item);

            if (response.data.notice) {
                $("#usuarioSistemaNotice").removeClass("d-none").text(response.data.notice);
            }

            actualizarPanelAccesoTotalUsuario(item);
            $("#usuarioSistemaModal").modal("show");
        },
        error: function (xhr) {
            console.error("Error al cargar usuario:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo cargar el usuario seleccionado.");
        }
    });
}

function actualizarPanelAccesoTotalUsuario(item) {
    const panel = $("#usuarioSistemaAccesoTotalPanel");
    if (!panel.length) {
        return;
    }

    const puedeGestionar = !!(configuracionUsuariosMeta && configuracionUsuariosMeta.puede_gestionar_acceso_total);
    const tieneAcceso = !!(item && item.tiene_acceso_total);
    const esUsuarioActual = !!(item && item.es_usuario_actual);
    const bloquearRetiroPropio = puedeGestionar && esUsuarioActual && tieneAcceso;
    configuracionUsuarioModal.tieneAccesoTotal = tieneAcceso;
    configuracionUsuarioModal.esUsuarioActual = esUsuarioActual;

    if (!item || !item.id_usuario) {
        panel.addClass("d-none");
        return;
    }

    panel.removeClass("d-none");
    $("#usuarioSistemaAccesoTotalTexto").text(
        bloquearRetiroPropio
            ? "Tu cuenta tiene acceso total activo. Para cederlo debes abrir otra cuenta y otorgarselo."
            : (tieneAcceso
            ? "De acuerdo al sistema, este usuario ya cuenta con el permiso de acceso total."
            : "Este usuario no tiene el permiso de acceso total asignado.")
    );
    $("#usuarioSistemaAccesoTotalBadge")
        .removeClass("active secondary")
        .addClass(tieneAcceso ? "active" : "secondary")
        .text(tieneAcceso ? "Habilitado" : "No asignado");

    $("#btnGestionarAccesoTotalUsuario")
        .prop("disabled", !puedeGestionar || bloquearRetiroPropio)
        .toggleClass("d-none", !puedeGestionar)
        .text(bloquearRetiroPropio ? "Transferir acceso total" : (tieneAcceso ? "Retirar acceso total" : "Otorgar acceso total"))
        .attr("title", bloquearRetiroPropio ? "Para transferirlo, abre otro usuario y otorgale el acceso total." : "");
}

function guardarUsuarioSistema() {
    const boton = $("#btnGuardarUsuarioSistema");
    boton.prop("disabled", true);

    $.ajax({
        url: "../ajax/configuracion.php?op=guardaryeditarusuario",
        type: "POST",
        dataType: "json",
        data: new FormData(document.getElementById("formularioUsuarioSistema")),
        contentType: false,
        processData: false,
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo guardar el usuario.");
                return;
            }

            limpiarFormularioUsuarioSistema();
            $("#usuarioSistemaModal").modal("hide");
            cargarMetadatosUsuariosConfiguracion(false);
            mostrarAlertaConfiguracion("success", response.msg || "Usuario guardado correctamente.");
        },
        error: function (xhr) {
            console.error("Error al guardar usuario:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo guardar el usuario.");
        },
        complete: function () {
            boton.prop("disabled", false);
        }
    });
}

function cambiarEstadoUsuarioSistema(idUsuario, operacion) {
    const activar = operacion === "reactivar";
    const mensaje = activar
        ? "Confirma que deseas reactivar este usuario del sistema?"
        : "Confirma que deseas desactivar este usuario del sistema?";

    confirmarAccionConfiguracion(mensaje, activar ? "Si, reactivar" : "Si, desactivar")
        .then(function (resultado) {
            if (!confirmacionAceptadaConfiguracion(resultado)) {
                return;
            }

            $.ajax({
                url: "../ajax/configuracion.php?op=" + (activar ? "reactivarusuario" : "desactivarusuario"),
                type: "POST",
                dataType: "json",
                data: {
                    id_registro: idUsuario
                },
                success: function (response) {
                    if (!response || response.ok !== true) {
                        mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo completar la operacion.");
                        return;
                    }

                    cargarMetadatosUsuariosConfiguracion(false);
                    mostrarAlertaConfiguracion("success", response.msg || "Operacion realizada correctamente.");
                },
                error: function (xhr) {
                    console.error("Error al cambiar estado del usuario:", xhr.responseText);
                    mostrarAlertaConfiguracion("error", "No se pudo completar la operacion.");
                }
            });
        });
}

function gestionarAccesoTotalUsuario() {
    if (!configuracionUsuarioModal.id) {
        return;
    }

    const otorgar = !configuracionUsuarioModal.tieneAccesoTotal;
    if (!otorgar && configuracionUsuarioModal.esUsuarioActual) {
        mostrarAlertaConfiguracion(
            "warning",
            "No puedes retirar tu propio acceso total. Para transferirlo, abre otra cuenta y otorgale ese permiso."
        );
        return;
    }

    const mensaje = otorgar
        ? "Solo un administrador puede transferir este permiso. Deseas otorgar acceso total a este usuario?"
        : "Deseas retirar el acceso total de este usuario?";

    confirmarAccionConfiguracion(mensaje, otorgar ? "Si, otorgar" : "Si, retirar")
        .then(function (resultado) {
            if (!confirmacionAceptadaConfiguracion(resultado)) {
                return;
            }

            $.ajax({
                url: "../ajax/configuracion.php?op=accesototalusuario",
                type: "POST",
                dataType: "json",
                data: {
                    id_registro: configuracionUsuarioModal.id,
                    otorgar: otorgar ? 1 : 0
                },
                success: function (response) {
                    if (!response || response.ok !== true) {
                        mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo gestionar el acceso total.");
                        return;
                    }

                    recargarUsuariosConfiguracion(false);
                    cargarUsuarioSistema(configuracionUsuarioModal.id);
                    mostrarAlertaConfiguracion("success", response.msg || "Acceso total actualizado correctamente.");
                },
                error: function (xhr) {
                    console.error("Error al gestionar acceso total:", xhr.responseText);
                    mostrarAlertaConfiguracion("error", "No se pudo gestionar el acceso total.");
                }
            });
        });
}

function obtenerFiltroEstadoEmpleadosConfiguracion() {
    const activo = $(".js-employee-state-filter.active").data("filter");
    return activo || "activos";
}

function cargarMetadatosEmpleadosConfiguracion(reinicializarTabla) {
    const resumen = $("#configuracionEmpleadosResumen");
    if (!resumen.length) {
        return;
    }

    resumen.html('<div class="col-12"><div class="config-master-empty">Cargando panel de empleados...</div></div>');

    $.ajax({
        url: "../ajax/configuracion.php?op=metadataempleados",
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo cargar la configuracion de empleados.");
                return;
            }

            configuracionEmpleadosMeta = response.data;
            renderizarResumenEmpleadosConfiguracion(null);

            if (!configuracionEmpleadosTabla || reinicializarTabla !== false) {
                inicializarTablaEmpleadosConfiguracion();
            } else {
                recargarEmpleadosConfiguracion(false);
            }
        },
        error: function (xhr) {
            console.error("Error al cargar metadatos de empleados:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo cargar el panel de empleados.");
        }
    });
}

function renderizarResumenEmpleadosConfiguracion(resumen) {
    const datos = resumen || {};
    configuracionEmpleadosResumen = {
        total: parseInt(datos.total, 10) || 0,
        activos: parseInt(datos.activos, 10) || 0,
        inactivos: parseInt(datos.inactivos, 10) || 0,
        conCorreo: parseInt(datos.con_correo, 10) || 0
    };

    const html = '' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-id-card"></i></div>' +
        '       <div><p class="eyebrow">Empleados</p><h4>' + configuracionEmpleadosResumen.total + '</h4><p>Total de registros institucionales.</p></div>' +
        '   </article>' +
        '</div>' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-user-check"></i></div>' +
        '       <div><p class="eyebrow">Activos</p><h4>' + configuracionEmpleadosResumen.activos + '</h4><p>Personal disponible para operaciones.</p></div>' +
        '   </article>' +
        '</div>' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-user-times"></i></div>' +
        '       <div><p class="eyebrow">Inactivos</p><h4>' + configuracionEmpleadosResumen.inactivos + '</h4><p>Registros deshabilitados temporalmente.</p></div>' +
        '   </article>' +
        '</div>' +
        '<div class="col-md-6 col-xl-3 mb-3">' +
        '   <article class="config-master-overview-card">' +
        '       <div class="config-master-overview-icon"><i class="fas fa-envelope"></i></div>' +
        '       <div><p class="eyebrow">Con correo</p><h4>' + configuracionEmpleadosResumen.conCorreo + '</h4><p>Registros con correo institucional cargado.</p></div>' +
        '   </article>' +
        '</div>';

    $("#configuracionEmpleadosResumen").html(html);
}

function inicializarTablaEmpleadosConfiguracion() {
    if (!$("#tblEmpleadosSistema").length) {
        return;
    }

    if (configuracionEmpleadosTabla && $.fn.DataTable.isDataTable("#tblEmpleadosSistema")) {
        configuracionEmpleadosTabla.destroy();
    }

    configuracionEmpleadosTabla = $("#tblEmpleadosSistema").DataTable({
        processing: true,
        serverSide: false,
        responsive: true,
        autoWidth: false,
        dom: "lrtip",
        ajax: {
            url: "../ajax/configuracion.php?op=listarempleados",
            type: "GET",
            dataType: "json",
            data: function () {
                return {
                    estado: obtenerFiltroEstadoEmpleadosConfiguracion()
                };
            },
            dataSrc: function (response) {
                if (!response || response.ok !== true) {
                    renderizarResumenEmpleadosConfiguracion(null);
                    mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo cargar el listado de empleados.");
                    return [];
                }

                renderizarResumenEmpleadosConfiguracion(response.data ? response.data.resumen : null);
                return response.data && Array.isArray(response.data.items) ? response.data.items : [];
            },
            error: function (xhr) {
                console.error("Error al cargar empleados:", xhr.responseText);
                renderizarResumenEmpleadosConfiguracion(null);
                mostrarAlertaConfiguracion("error", "No se pudo cargar el listado de empleados.");
            }
        },
        columns: [
            {
                data: "cedula",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return fila.cedula || "";
                    }

                    return '<strong>' + escapeHtmlConfiguracion(fila.cedula || "") + '</strong>';
                }
            },
            {
                data: "empleado",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return [fila.empleado || "", fila.nombre || "", fila.apellido || ""].join(" ");
                    }

                    return '' +
                        '<div class="config-user-cell">' +
                        '   <strong>' + escapeHtmlConfiguracion(fila.empleado || "") + '</strong>' +
                        '   <span>' + escapeHtmlConfiguracion((fila.nombre || "") + " " + (fila.apellido || "")) + '</span>' +
                        '</div>';
                }
            },
            { data: "dependencia", defaultContent: "" },
            { data: "telefono", defaultContent: "" },
            {
                data: "correo",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return fila.correo || "";
                    }

                    return fila.correo
                        ? '<span class="config-permissions-inline">' + escapeHtmlConfiguracion(fila.correo) + '</span>'
                        : '<span class="text-muted">Sin correo</span>';
                }
            },
            {
                data: "estado_texto",
                className: "text-nowrap text-right",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return fila.estado_texto || "";
                    }

                    return '<span class="status-pill ' + sanitizarClaseBadgeConfiguracion(fila.estado_badge) + '">' +
                        escapeHtmlConfiguracion(fila.estado_texto || "") +
                        '</span>';
                }
            },
            {
                data: null,
                orderable: false,
                searchable: false,
                className: "text-nowrap text-right",
                render: function (valor, tipo, fila) {
                    if (tipo !== "display") {
                        return "";
                    }

                    const botones = [];
                    botones.push('<div class="d-flex justify-content-end flex-nowrap config-master-actions">');
                    botones.push('<button type="button" class="btn btn-sm btn-outline-primary js-employee-edit" data-id="' + escapeAttrConfiguracion(fila.id_empleado) + '" title="Editar"><i class="fas fa-pen"></i></button>');

                    if (parseInt(fila.estado, 10) === 1) {
                        const disabled = fila.puede_desactivar ? "" : " disabled";
                        const titulo = fila.motivo_bloqueo || "Desactivar";
                        botones.push('<button type="button" class="btn btn-sm btn-outline-danger js-employee-desactivar" data-id="' + escapeAttrConfiguracion(fila.id_empleado) + '" title="' + escapeAttrConfiguracion(titulo) + '"' + disabled + '><i class="fas fa-trash-alt"></i></button>');
                    } else {
                        botones.push('<button type="button" class="btn btn-sm btn-outline-success js-employee-reactivar" data-id="' + escapeAttrConfiguracion(fila.id_empleado) + '" title="Reactivar"><i class="fas fa-undo"></i></button>');
                    }

                    botones.push("</div>");
                    return botones.join("");
                }
            }
        ],
        order: [[1, "asc"]],
        pageLength: 10,
        language: {
            decimal: "",
            emptyTable: "No hay datos disponibles",
            info: "Mostrando _START_ a _END_ de _TOTAL_ registros",
            infoEmpty: "Mostrando 0 a 0 de 0 registros",
            infoFiltered: "(filtrado de _MAX_ registros totales)",
            lengthMenu: "Mostrar registros _MENU_",
            loadingRecords: "Cargando...",
            processing: "Procesando...",
            search: "Buscar:",
            zeroRecords: "No se encontraron resultados",
            paginate: {
                first: "Primero",
                last: "Ultimo",
                next: "Siguiente",
                previous: "Anterior"
            }
        },
        initComplete: function () {
            const control = $("#tblEmpleadosSistema_wrapper .dataTables_length");
            const contenedor = $("#empleadosSistemaLength");
            if (control.length && contenedor.length) {
                contenedor.empty().append(control);
            }
        }
    });
}

function recargarEmpleadosConfiguracion(resetPaging) {
    if (configuracionEmpleadosTabla) {
        configuracionEmpleadosTabla.ajax.reload(null, !!resetPaging);
    }
}

function abrirModalEmpleadoSistema(idEmpleado) {
    if (!configuracionEmpleadosMeta) {
        mostrarAlertaConfiguracion("error", "Los metadatos de empleados aun no estan disponibles.");
        return;
    }

    configuracionEmpleadoModal = {
        id: parseInt(idEmpleado, 10) || 0
    };

    limpiarFormularioEmpleadoSistema();
    $("#empleadoSistemaId").val(configuracionEmpleadoModal.id || "");
    $("#empleadoSistemaNotice").addClass("d-none").text("");
    $("#empleadoSistemaModalLabel").text(configuracionEmpleadoModal.id > 0 ? "Editar empleado" : "Nuevo empleado");
    $("#btnGuardarEmpleadoSistema").html('<i class="fas fa-save"></i> Guardar empleado');

    poblarFormularioEmpleadoSistema(null);

    if (configuracionEmpleadoModal.id > 0) {
        cargarEmpleadoSistema(configuracionEmpleadoModal.id);
        return;
    }

    $("#empleadoSistemaModal").modal("show");
}

function poblarFormularioEmpleadoSistema(item) {
    const meta = configuracionEmpleadosMeta || {};
    const dependenciaId = item && item.id_dependencia ? parseInt(item.id_dependencia, 10) : 0;

    $("#empleadoSistemaDependencia").html(
        construirOpcionesSelectBasico(meta.dependencias || [], "id_dependencia", "nombre_dependencia", dependenciaId)
    );

    $("#empleadoSistemaCedula").val(item && item.cedula ? item.cedula : "");
    $("#empleadoSistemaNombre").val(item && item.nombre ? item.nombre : "");
    $("#empleadoSistemaApellido").val(item && item.apellido ? item.apellido : "");
    $("#empleadoSistemaTelefono").val(item && item.telefono ? item.telefono : "");
    $("#empleadoSistemaCorreo").val(item && item.correo ? item.correo : "");
    $("#empleadoSistemaDireccion").val(item && item.direccion ? item.direccion : "");

    inicializarSelectEmpleadosConfiguracion();
}

function inicializarSelectEmpleadosConfiguracion() {
    if (typeof $.fn.select2 !== "function") {
        return;
    }

    const select = $("#empleadoSistemaDependencia");
    if (!select.length) {
        return;
    }

    if (select.hasClass("select2-hidden-accessible")) {
        select.select2("destroy");
    }

    select.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#empleadoSistemaModal"),
        placeholder: "Seleccione una dependencia",
        allowClear: false,
        closeOnSelect: true
    });
}

function cargarEmpleadoSistema(idEmpleado) {
    $.ajax({
        url: "../ajax/configuracion.php?op=mostrarempleado",
        type: "GET",
        dataType: "json",
        data: {
            id_registro: idEmpleado
        },
        success: function (response) {
            if (!response || response.ok !== true || !response.data || !response.data.item) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo cargar el empleado.");
                return;
            }

            const item = response.data.item;
            configuracionEmpleadoModal.id = parseInt(item.id_empleado, 10) || 0;
            $("#empleadoSistemaId").val(configuracionEmpleadoModal.id);
            $("#empleadoSistemaModalLabel").text("Editar empleado");
            poblarFormularioEmpleadoSistema(item);

            if (response.data.notice) {
                $("#empleadoSistemaNotice").removeClass("d-none").text(response.data.notice);
            }

            $("#empleadoSistemaModal").modal("show");
        },
        error: function (xhr) {
            console.error("Error al cargar empleado:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo cargar el empleado seleccionado.");
        }
    });
}

function guardarEmpleadoSistema() {
    const boton = $("#btnGuardarEmpleadoSistema");
    boton.prop("disabled", true);

    $.ajax({
        url: "../ajax/configuracion.php?op=guardaryeditarempleado",
        type: "POST",
        dataType: "json",
        data: new FormData(document.getElementById("formularioEmpleadoSistema")),
        contentType: false,
        processData: false,
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo guardar el empleado.");
                return;
            }

            limpiarFormularioEmpleadoSistema();
            $("#empleadoSistemaModal").modal("hide");
            cargarMetadatosEmpleadosConfiguracion(false);
            if (configuracionUsuariosMeta) {
                cargarMetadatosUsuariosConfiguracion(false);
            }
            mostrarAlertaConfiguracion("success", response.msg || "Empleado guardado correctamente.");
        },
        error: function (xhr) {
            console.error("Error al guardar empleado:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo guardar el empleado.");
        },
        complete: function () {
            boton.prop("disabled", false);
        }
    });
}

function limpiarFormularioUsuarioSistema() {
    const formulario = $("#formularioUsuarioSistema");
    if (!formulario.length) {
        return;
    }

    formulario[0].reset();
    $("#usuarioSistemaId").val("");
    $("#usuarioSistemaNotice").addClass("d-none").text("");
    $("#usuarioSistemaDependenciaVista").val("");
}

function limpiarFormularioEmpleadoSistema() {
    const formulario = $("#formularioEmpleadoSistema");
    if (!formulario.length) {
        return;
    }

    formulario[0].reset();
    $("#empleadoSistemaId").val("");
    $("#empleadoSistemaNotice").addClass("d-none").text("");
}

function cambiarEstadoEmpleadoSistema(idEmpleado, operacion) {
    const activar = operacion === "reactivar";
    const mensaje = activar
        ? "Confirma que deseas reactivar este empleado?"
        : "Confirma que deseas desactivar este empleado?";

    confirmarAccionConfiguracion(mensaje, activar ? "Si, reactivar" : "Si, desactivar")
        .then(function (resultado) {
            if (!confirmacionAceptadaConfiguracion(resultado)) {
                return;
            }

            $.ajax({
                url: "../ajax/configuracion.php?op=" + (activar ? "reactivarempleado" : "desactivarempleado"),
                type: "POST",
                dataType: "json",
                data: {
                    id_registro: idEmpleado
                },
                success: function (response) {
                    if (!response || response.ok !== true) {
                        mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo completar la operacion.");
                        return;
                    }

                    cargarMetadatosEmpleadosConfiguracion(false);
                    if (configuracionUsuariosMeta) {
                        cargarMetadatosUsuariosConfiguracion(false);
                    }
                    mostrarAlertaConfiguracion("success", response.msg || "Operacion realizada correctamente.");
                },
                error: function (xhr) {
                    console.error("Error al cambiar estado del empleado:", xhr.responseText);
                    mostrarAlertaConfiguracion("error", "No se pudo completar la operacion.");
                }
            });
        });
}

function inicializarBitacoraConfiguracion() {
    if (!$("#tblBitacoraSistema").length || typeof $.fn.DataTable !== "function") {
        return;
    }

    if (configuracionBitacoraTabla && $.fn.DataTable.isDataTable("#tblBitacoraSistema")) {
        return;
    }

    configuracionBitacoraTabla = $("#tblBitacoraSistema").DataTable({
        aProcessing: true,
        aServerSide: true,
        dom: "lfrtip",
        ajax: {
            url: "../ajax/bitacora.php?op=listar",
            type: "GET",
            dataType: "json",
            data: function () {
                return {
                    scope: $("#filtroBitacoraSistemaScope").val() || "sistema"
                };
            },
            error: function (xhr) {
                console.error("Error al cargar bitacora:", xhr.responseText);
                mostrarAlertaConfiguracion("error", "No se pudo cargar la bitacora.");
            }
        },
        bDestroy: true,
        iDisplayLength: 25,
        order: [[0, "desc"]],
        language: {
            decimal: "",
            emptyTable: "No hay datos disponibles en la tabla",
            info: "Mostrando _START_ a _END_ de _TOTAL_ registros",
            infoEmpty: "Mostrando 0 a 0 de 0 registros",
            infoFiltered: "(filtrado de _MAX_ registros totales)",
            lengthMenu: "Mostrar _MENU_ registros",
            loadingRecords: "Cargando...",
            processing: "Procesando...",
            search: "Buscar:",
            zeroRecords: "No se encontraron resultados",
            paginate: {
                first: "Primero",
                last: "Ultimo",
                next: "Siguiente",
                previous: "Anterior"
            }
        },
        initComplete: function () {
            const control = $("#tblBitacoraSistema_wrapper .dataTables_length");
            const contenedor = $("#bitacoraSistemaLength");
            if (control.length && contenedor.length) {
                contenedor.empty().append(control);
            }
        }
    });
}

function recargarBitacoraConfiguracion(resetPaging) {
    if (configuracionBitacoraTabla) {
        configuracionBitacoraTabla.ajax.reload(null, !!resetPaging);
    }
}

function generarReporteBitacoraConfiguracion() {
    if (!configuracionBitacoraTabla) {
        mostrarAlertaConfiguracion("warning", "La tabla de bitacora aun no esta disponible.");
        return;
    }

    const data = configuracionBitacoraTabla.rows({ search: "applied" }).data().toArray();
    if (!data.length) {
        mostrarAlertaConfiguracion("warning", "No hay registros de bitacora para generar el reporte.");
        return;
    }

    let contenido = '' +
        '<html><head><title>Reporte de Bitacora</title>' +
        '<style>' +
        "body{font-family:Arial,Helvetica,sans-serif;margin:20px;color:#1e2d3d;}" +
        "h1,h2{margin:0;text-align:center;}" +
        "h2{margin-top:4px;margin-bottom:14px;font-size:18px;}" +
        ".fecha{margin-bottom:14px;text-align:right;font-size:13px;}" +
        "table{width:100%;border-collapse:collapse;font-size:12px;}" +
        "th,td{border:1px solid #d0d7de;padding:6px 8px;text-align:left;vertical-align:top;}" +
        "th{background:#f3f6f9;}" +
        ".pie{margin-top:14px;text-align:center;font-size:12px;}" +
        "</style></head><body>" +
        '<h1>Sala Situacional Libertador</h1>' +
        '<h2>Reporte de Bitacora ' + escapeHtmlConfiguracion(($("#filtroBitacoraSistemaScope").val() || "sistema") === "autenticacion" ? 'de Autenticacion' : 'del Sistema') + '</h2>' +
        '<div class="fecha">Fecha: ' + escapeHtmlConfiguracion(new Date().toLocaleDateString("es-VE")) + "</div>" +
        "<table><thead><tr>" +
        "<th>ID</th><th>Usuario</th><th>Resumen</th><th>Detalle</th><th>Fecha y hora</th><th>Direccion IP</th>" +
        "</tr></thead><tbody>";

    data.forEach(function (row) {
        contenido += "<tr>" +
            "<td>" + escapeHtmlConfiguracion(row[0] || "") + "</td>" +
            "<td>" + escapeHtmlConfiguracion(row[1] || "") + "</td>" +
            "<td>" + escapeHtmlConfiguracion(row[2] || "") + "</td>" +
            "<td>" + escapeHtmlConfiguracion(row[3] || "") + "</td>" +
            "<td>" + escapeHtmlConfiguracion(row[4] || "") + "</td>" +
            "<td>" + escapeHtmlConfiguracion(row[5] || "") + "</td>" +
            "</tr>";
    });

    contenido += "</tbody></table>" +
        '<div class="pie">Total de registros: ' + escapeHtmlConfiguracion(data.length) + "</div>" +
        "</body></html>";

    const ventana = window.open("", "_blank");
    if (!ventana) {
        mostrarAlertaConfiguracion("warning", "El navegador bloqueo la ventana de impresion. Habilite las ventanas emergentes.");
        return;
    }

    ventana.document.open();
    ventana.document.write(contenido);
    ventana.document.close();

    ventana.onload = function () {
        ventana.print();
        setTimeout(function () {
            ventana.close();
        }, 1200);
    };
}

function poblarFormularioSmtp(item) {
    const data = item || {};
    const notice = $("#smtpConfiguracionNotice");

    $("#smtpHost").val(data.host || "smtp.gmail.com");
    $("#smtpPuerto").val(data.puerto || 587);
    $("#smtpUsuario").val(data.usuario || "");
    $("#smtpCorreoRemitente").val(data.correo_remitente || "");
    $("#smtpNombreRemitente").val(data.nombre_remitente || "");
    $("#smtpUsarTls").val(String(data.usar_tls != null ? data.usar_tls : 1));
    $("#smtpClave").val("");

    if (data && data.fecha_actualizacion_formateada) {
        const actualizadoPor = data.usuario_actualiza ? " por " + data.usuario_actualiza : "";
        notice
            .removeClass("d-none")
            .text("Configuracion actualizada el " + data.fecha_actualizacion_formateada + actualizadoPor + ".");
    } else {
        notice.addClass("d-none").text("");
    }
}

function cargarConfiguracionSmtp(mostrarExito) {
    if (!$("#formularioSmtpConfiguracion").length) {
        return;
    }

    $.ajax({
        url: "../ajax/configuracion.php?op=metadatasmtp",
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo cargar la configuracion SMTP.");
                return;
            }

            poblarFormularioSmtp(response.data.item || null);

            if (mostrarExito) {
                mostrarAlertaConfiguracion("success", "Configuracion SMTP recargada correctamente.");
            }
        },
        error: function (xhr) {
            console.error("Error al cargar SMTP:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo cargar la configuracion SMTP.");
        }
    });
}

function guardarConfiguracionSmtp() {
    const boton = $("#btnGuardarSmtpConfiguracion");
    boton.prop("disabled", true);

    $.ajax({
        url: "../ajax/configuracion.php?op=guardarsmtp",
        type: "POST",
        dataType: "json",
        data: new FormData(document.getElementById("formularioSmtpConfiguracion")),
        contentType: false,
        processData: false,
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo guardar la configuracion SMTP.");
                return;
            }

            $("#smtpClave").val("");
            cargarConfiguracionSmtp(false);
            mostrarAlertaConfiguracion("success", response.msg || "Configuracion SMTP guardada correctamente.");
        },
        error: function (xhr) {
            console.error("Error al guardar SMTP:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo guardar la configuracion SMTP.");
        },
        complete: function () {
            boton.prop("disabled", false);
        }
    });
}

function enviarPruebaSmtp() {
    const boton = $("#btnEnviarPruebaSmtp");
    const destinatario = ($("#smtpDestinatarioPrueba").val() || "").trim();

    if (!destinatario) {
        mostrarAlertaConfiguracion("warning", "Debe indicar un correo destino para la prueba.");
        return;
    }

    boton.prop("disabled", true);
    $.ajax({
        url: "../ajax/configuracion.php?op=enviarsmtptest",
        type: "POST",
        dataType: "json",
        data: {
            destinatario: destinatario
        },
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaConfiguracion("error", response && response.msg ? response.msg : "No se pudo enviar el correo de prueba.");
                return;
            }

            mostrarAlertaConfiguracion("success", response.msg || "Correo de prueba enviado correctamente.");
        },
        error: function (xhr) {
            console.error("Error al enviar prueba SMTP:", xhr.responseText);
            mostrarAlertaConfiguracion("error", "No se pudo enviar el correo de prueba.");
        },
        complete: function () {
            boton.prop("disabled", false);
        }
    });
}

$(initConfiguracion);
