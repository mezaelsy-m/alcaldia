let tablaSeguridad = null;
let estadoFormularioSeguridad = null;
let reabrirSeguridadTrasBeneficiario = false;
let sugerenciaActual = null;
let asignacionesDisponibles = [];
let sugerenciasDespacho = [];
let indiceSugerenciaActual = 0;
let operativoChoferes = [];
let operativoUnidades = [];
let operativoEmpleados = [];

$(document).ready(function () {
    initSeguridad();
});

function mostrarAlertaSeguridad(icono, mensaje, titulo) {
    return Swal.fire({
        icon: icono,
        title: titulo || obtenerTituloIconoSeguridad(icono),
        text: mensaje || "Operacion completada.",
        confirmButtonText: "Aceptar",
        customClass: {
            confirmButton: "btn btn-primary"
        },
        buttonsStyling: false
    });
}

function confirmarAccionSeguridad(mensaje, confirmar) {
    return Swal.fire({
        icon: "question",
        title: "Confirmar accion",
        text: mensaje,
        showCancelButton: true,
        confirmButtonText: confirmar || "Si, continuar",
        cancelButtonText: "Cancelar",
        reverseButtons: true,
        customClass: {
            confirmButton: "btn btn-primary mr-2",
            cancelButton: "btn btn-light"
        },
        buttonsStyling: false
    });
}

function obtenerTituloIconoSeguridad(icono) {
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

function confirmacionAceptadaSeguridad(resultado) {
    return !!(resultado && (resultado.isConfirmed || resultado.value === true));
}

function mostrarCapaCargaCorreoSeguridad(mensaje) {
    const overlay = $("#overlayEnvioCorreoChofer");
    if (!overlay.length) {
        return;
    }

    $("#overlayEnvioCorreoChoferTexto").text(mensaje || "Enviando correo al chofer...");
    overlay.removeClass("d-none");
}

function ocultarCapaCargaCorreoSeguridad() {
    const overlay = $("#overlayEnvioCorreoChofer");
    if (!overlay.length) {
        return;
    }

    overlay.addClass("d-none");
}

function formatearFechaEstadoTextoSeguridad(valor) {
    const texto = String(valor || "").trim();
    if (!texto) {
        return "";
    }

    if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/.test(texto)) {
        return texto;
    }

    const fecha = new Date(texto);
    if (Number.isNaN(fecha.getTime())) {
        return texto;
    }

    const dia = String(fecha.getDate()).padStart(2, "0");
    const mes = String(fecha.getMonth() + 1).padStart(2, "0");
    const anio = fecha.getFullYear();
    let horas = fecha.getHours();
    const minutos = String(fecha.getMinutes()).padStart(2, "0");
    const sufijo = horas >= 12 ? "PM" : "AM";
    horas = horas % 12 || 12;

    return dia + "/" + mes + "/" + anio + " " + String(horas).padStart(2, "0") + ":" + minutos + " " + sufijo;
}

function limpiarAvisoSolicitudAtendidaSeguridad() {
    $("#avisoSolicitudAtendidaSeguridad").addClass("d-none");
    $("#mensajeSolicitudAtendidaSeguridad").text("");
    $("#btnVerObservacionAtendidaSeguridad").addClass("d-none").removeData("observacion");
}

function actualizarAvisoSolicitudAtendidaSeguridad(data) {
    limpiarAvisoSolicitudAtendidaSeguridad();

    if (!data || Number(data.es_atendida) !== 1) {
        return;
    }

    const fechaTexto = formatearFechaEstadoTextoSeguridad(data.fecha_estado_solicitud || data.fecha_estado_solicitud_input || "");
    const mensaje = fechaTexto
        ? "De acuerdo al sistema, esta solicitud fue atendida el " + fechaTexto + "."
        : "De acuerdo al sistema, esta solicitud ya fue atendida.";
    const observacion = String(data.observacion_estado_solicitud || "").trim();

    $("#mensajeSolicitudAtendidaSeguridad").text(mensaje);
    $("#avisoSolicitudAtendidaSeguridad").removeClass("d-none");

    if (observacion) {
        $("#btnVerObservacionAtendidaSeguridad").removeClass("d-none").data("observacion", observacion);
    }
}

function initSeguridad() {
    activarTooltipsSeguridad();
    configurarEventosOperativos();
    inicializarComboEmpleadoOperativo();
    inicializarComboUnidadChoferOperativo();

    if ($("#seguridadEmergenciaView").length) {
        inicializarSelectBeneficiariosSeguridad();
        inicializarComboComunidadesSeguridad();
        inicializarComboCatalogoSeguridad("#id_tipo_seguridad", "Busque el tipo de ayuda");
        inicializarComboCatalogoSeguridad("#id_solicitud_seguridad", "Busque el tipo de solicitud");
        cargarCatalogosSeguridad();
        configurarTablaSeguridad();
        reubicarControlLongitudSeguridad();
        configurarBuscadorSeguridad();
        configurarEventosSeguridad();
        cargarResumenSeguridad();
    }

    if ($("#operativoControlPanel").length) {
        limpiarFormulariosOperativos();
    }

    if ($("#operativoAmbulanciasView").length) {
        cargarPanelOperativoCompleto();
    }
}

function activarTooltipsSeguridad() {
    if (typeof $.fn.tooltip !== "function") {
        return;
    }

    if ($("body").data("seguridad-tooltips") === true) {
        return;
    }

    $("body").tooltip({
        selector: "[data-toggle='tooltip']",
        container: "body",
        trigger: "hover"
    });
    $("body").data("seguridad-tooltips", true);
}

function inicializarSelectBeneficiariosSeguridad() {
    const combo = $("#id_beneficiario");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#seguridadEmergenciaModal"),
        placeholder: combo.data("placeholder") || "Busque o seleccione un beneficiario",
        allowClear: true,
        minimumInputLength: 0,
        ajax: {
            url: "../ajax/serviciosemergencia.php?op=listarbeneficiarios",
            dataType: "json",
            delay: 220,
            data: function (params) {
                return { term: params.term || "" };
            },
            processResults: function (response) {
                return { results: response && Array.isArray(response.items) ? response.items : [] };
            },
            cache: true
        },
        language: {
            inputTooShort: function () {
                return "Escribe para buscar beneficiarios";
            },
            noResults: function () {
                return "No se encontraron beneficiarios";
            },
            searching: function () {
                return "Buscando...";
            }
        }
    });
}

function inicializarComboComunidadesSeguridad() {
    const combo = $("#idcomunidadSeguridad");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#beneficiarioSeguridadModal"),
        placeholder: combo.data("placeholder") || "Busque o seleccione una comunidad",
        allowClear: true,
        minimumInputLength: 0,
        ajax: {
            url: "../ajax/beneficiarios.php?op=listarcomunidades",
            dataType: "json",
            delay: 220,
            data: function (params) {
                return { term: params.term || "" };
            },
            processResults: function (response) {
                return { results: response && Array.isArray(response.items) ? response.items : [] };
            },
            cache: true
        },
        language: {
            inputTooShort: function () {
                return "Escribe para buscar comunidades";
            },
            noResults: function () {
                return "No se encontraron comunidades";
            },
            searching: function () {
                return "Buscando...";
            }
        }
    });
}

function inicializarComboCatalogoSeguridad(selector, placeholder) {
    const combo = $(selector);
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    if (combo.hasClass("select2-hidden-accessible")) {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#seguridadEmergenciaModal"),
        placeholder: placeholder || "Seleccione una opcion",
        minimumResultsForSearch: 0
    });
}

function inicializarComboEmpleadoOperativo() {
    const combo = $("#id_empleado_operativo");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    if (combo.hasClass("select2-hidden-accessible")) {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#choferOperativoModal"),
        placeholder: "Busque por cedula o nombre del empleado",
        allowClear: true
    });
}

function inicializarComboUnidadChoferOperativo() {
    const combo = $("#id_unidad_asignada_chofer");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    if (combo.hasClass("select2-hidden-accessible")) {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#choferOperativoModal"),
        placeholder: "Busque una unidad disponible por codigo o placa",
        allowClear: true
    });
}

function obtenerFechaActualISO() {
    const hoy = new Date();
    const mes = String(hoy.getMonth() + 1).padStart(2, "0");
    const dia = String(hoy.getDate()).padStart(2, "0");
    return hoy.getFullYear() + "-" + mes + "-" + dia;
}

function licenciaEstaVencida(valor) {
    const fecha = String(valor || "").trim();
    if (!fecha) {
        return false;
    }

    return fecha < obtenerFechaActualISO();
}

function actualizarHintLicenciaVencida() {
    const input = $("#vencimiento_licencia");
    const hint = $("#licenciaVencidaHint");
    if (!input.length || !hint.length) {
        return false;
    }

    const fecha = input.val() || "";
    const vencida = licenciaEstaVencida(fecha);
    input[0].setCustomValidity(vencida ? "La licencia del chofer se encuentra vencida." : "");

    if (!vencida) {
        hint.addClass("d-none").text("");
        input.removeClass("is-invalid");
        return false;
    }

    hint.removeClass("d-none").html("<strong>Licencia vencida.</strong><br>Debe registrar una fecha vigente para poder guardar el chofer operativo.");
    input.addClass("is-invalid");
    return true;
}

function cargarCatalogosSeguridad(valorTipo, valorSolicitud) {
    return $.when(cargarTiposSeguridad(valorTipo), cargarSolicitudesSeguridad(valorSolicitud));
}

function cargarTiposSeguridad(valorSeleccionado) {
    return $.ajax({
        url: "../ajax/serviciosemergencia.php?op=listartiposseguridad",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const combo = $("#id_tipo_seguridad");
        const items = response && Array.isArray(response.items) ? response.items : [];
        combo.empty().append('<option value="">Seleccione el tipo de ayuda</option>');
        for (let i = 0; i < items.length; i += 1) {
            const opcion = new Option(items[i].text, items[i].id);
            $(opcion).attr("data-requiere-ambulancia", String(items[i].requiere_ambulancia || 0));
            combo.append(opcion);
        }

        if (valorSeleccionado) {
            combo.val(String(valorSeleccionado));
        }

        combo.trigger("change.select2");
    });
}

function cargarSolicitudesSeguridad(valorSeleccionado) {
    return $.ajax({
        url: "../ajax/serviciosemergencia.php?op=listarsolicitudesseguridad",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const combo = $("#id_solicitud_seguridad");
        const items = response && Array.isArray(response.items) ? response.items : [];
        combo.empty().append('<option value="">Seleccione el origen de la solicitud</option>');
        for (let i = 0; i < items.length; i += 1) {
            combo.append(new Option(items[i].text, items[i].id));
        }

        if (valorSeleccionado) {
            combo.val(String(valorSeleccionado));
        }

        combo.trigger("change.select2");
    });
}

function configurarTablaSeguridad() {
    if (!$("#tbllistado").length || typeof $.fn.DataTable !== "function") {
        return;
    }

    tablaSeguridad = $("#tbllistado").DataTable({
        processing: true,
        serverSide: false,
        responsive: true,
        autoWidth: false,
        destroy: true,
        searching: true,
        dom: "lrtip",
        ajax: {
            url: "../ajax/serviciosemergencia.php?op=listar",
            type: "GET",
            dataType: "json",
            dataSrc: function (json) {
                return json && Array.isArray(json.aaData) ? json.aaData : [];
            },
            error: function (xhr) {
                console.error("Error al cargar seguridad y emergencia:", xhr.responseText);
                mostrarAlertaSeguridad("error", "No se pudo cargar el listado de solicitudes.");
            }
        },
        columns: [
            { data: "beneficiario" },
            { data: "tipo_seguridad" },
            { data: "tipo_solicitud" },
            { data: "fecha_seguridad" },
            { data: "ticket_interno" },
            { data: "ambulancia" },
            { data: "chofer" },
            { data: "ubicacion_evento" },
            { data: "telefono" },
            { data: "estado_solicitud", className: "emergency-align-right text-nowrap" },
            { data: "acciones", orderable: false, searchable: false, className: "emergency-align-right text-nowrap" }
        ],
        order: [],
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
            zeroRecords: "No se encontraron resultados",
            paginate: {
                first: "Primero",
                last: "Ultimo",
                next: "Siguiente",
                previous: "Anterior"
            }
        }
    });
}

function reubicarControlLongitudSeguridad() {
    const control = $("#tbllistado_wrapper .dataTables_length");
    const contenedor = $("#seguridadLengthContainer");

    if (!control.length || !contenedor.length) {
        return;
    }

    contenedor.empty().append(control);
}

function configurarBuscadorSeguridad() {
    $("#buscadorSeguridad")
        .off(".seguridad")
        .on("input.seguridad search.seguridad", function () {
            if (!tablaSeguridad) {
                return;
            }

            tablaSeguridad.search($(this).val() || "").draw();
        });
}

function configurarEventosSeguridad() {
    $("#btnNuevaSolicitudSeguridad").off(".seguridad").on("click.seguridad", function () {
        abrirModalNuevaSolicitud();
    });

    $("#btnRecargarSeguridad").off(".seguridad").on("click.seguridad", function () {
        recargarSeccionSeguridad();
    });

    $("#btnReporteSeguridad").off(".seguridad").on("click.seguridad", function () {
        generarReporteRapidoSeguridad();
    });

    $("#btnOperativaSeguridad").off(".seguridad").on("click.seguridad", function () {
        abrirModalOperativa();
    });

    $("#btnRegistrarBeneficiarioSeguridad").off(".seguridad").on("click.seguridad", function () {
        abrirModalBeneficiarioDesdeSeguridad();
    });

    $("#btnIntercambiarSugerencia").off(".seguridad").on("click.seguridad", function () {
        intercambiarSugerenciaAutomatica();
    });

    $("#id_tipo_seguridad").off(".seguridad").on("change.seguridad", function () {
        gestionarSugerenciaDespacho();
    });

    $("#formularioSeguridadEmergencia").off(".seguridad").on("submit.seguridad", function (event) {
        event.preventDefault();
        guardarSolicitudSeguridad();
    });

    $("#formularioBeneficiarioSeguridad").off(".seguridad").on("submit.seguridad", function (event) {
        event.preventDefault();
        guardarBeneficiarioDesdeSeguridad();
    });

    $("#formularioEstadoSolicitudSeguridad").off(".seguridad").on("submit.seguridad", function (event) {
        event.preventDefault();
        guardarEstadoSolicitudSeguridad();
    });

    $("#btnVerObservacionAtendidaSeguridad").off(".seguridad").on("click.seguridad", function () {
        const observacion = $(this).data("observacion");
        if (!observacion) {
            return;
        }

        Swal.fire({
            icon: "info",
            title: "Observacion registrada",
            text: observacion,
            confirmButtonText: "Aceptar",
            customClass: {
                confirmButton: "btn btn-primary"
            },
            buttonsStyling: false
        });
    });

    $("#formularioAsignacionManual").off(".seguridad").on("submit.seguridad", function (event) {
        event.preventDefault();
        guardarAsignacionManual();
    });

    $("#formularioCierreDespacho").off(".seguridad").on("submit.seguridad", function (event) {
        event.preventDefault();
        guardarCierreDespacho();
    });

    $("#id_asignacion_unidad_chofer").off(".seguridad").on("change.seguridad", function () {
        actualizarResumenAsignacionManual($(this).val());
    });

    $("#tbllistado").off("click.seguridadEditar").on("click.seguridadEditar", ".js-editar", function () {
        mostrarSolicitudSeguridad($(this).data("id"));
    });

    $("#tbllistado").off("click.seguridadAsignar").on("click.seguridadAsignar", ".js-asignar", function () {
        abrirAsignacionManual($(this).data("id"));
    });

    $("#tbllistado").off("click.seguridadCerrar").on("click.seguridadCerrar", ".js-cerrar", function () {
        abrirCierreDespacho($(this).data("id"));
    });

    $("#tbllistado").off("click.seguridadEstado").on("click.seguridadEstado", ".js-gestionar-estado", function () {
        abrirModalEstadoSolicitudSeguridad($(this).data("id"));
    });

    $("#tbllistado").off("click.seguridadReporte").on("click.seguridadReporte", ".js-ver-reporte", function () {
        abrirReporteSolicitud($(this).data("id"), $(this).data("reporte"));
    });

    $("#tbllistado").off("click.seguridadReenviarReporte").on("click.seguridadReenviarReporte", ".js-reenviar-reporte", function () {
        reenviarReporteChoferDesdeLista(
            $(this).data("id"),
            $(this).data("reporte"),
            $(this).attr("data-tipo"),
            $(this).attr("data-estado-envio")
        );
    });

    $("#tbllistado").off("click.seguridadWhatsappManual").on("click.seguridadWhatsappManual", ".js-notificar-whatsapp", function () {
        notificarBeneficiarioWhatsappManual($(this).data("url"));
    });

    $("#tbllistado").off("click.seguridadEliminar").on("click.seguridadEliminar", ".js-eliminar", function () {
        cambiarEstadoSolicitud($(this).data("id"), "anular");
    });

    $("#beneficiarioSeguridadModal").off("hidden.bs.modal.seguridad").on("hidden.bs.modal.seguridad", function () {
        limpiarFormularioBeneficiarioSeguridad();
        if (reabrirSeguridadTrasBeneficiario) {
            reabrirSeguridadTrasBeneficiario = false;
            restaurarFormularioSeguridad();
            $("#seguridadEmergenciaModal").modal("show");
        }
    });

    $("#estadoSolicitudSeguridadModal").off("hidden.bs.modal.seguridad").on("hidden.bs.modal.seguridad", function () {
        limpiarFormularioEstadoSolicitudSeguridad();
    });
}

function configurarEventosOperativos() {
    $("#btnRecargarOperativoPanel, #btnRecargarOperativoAmbulancias")
        .off(".operativo")
        .on("click.operativo", function () {
            cargarPanelOperativoCompleto();
        });

    $("#btnNuevoChoferOperativo")
        .off(".operativo")
        .on("click.operativo", function () {
            abrirModalChoferOperativo();
        });

    $("#btnNuevoControlUnidad")
        .off(".operativo")
        .on("click.operativo", function () {
            abrirModalControlUnidad();
        });

    $("#formularioChoferOperativo")
        .off(".operativo")
        .on("submit.operativo", function (event) {
            event.preventDefault();
            guardarChoferOperativo();
        });

    $("#formularioControlUnidad")
        .off(".operativo")
        .on("submit.operativo", function (event) {
            event.preventDefault();
            guardarControlUnidadOperativa();
        });

    $("#id_empleado_operativo")
        .off(".operativo")
        .on("change.operativo", function () {
            autocompletarChoferDesdeEmpleado($(this).val());
        });

    $("#id_unidad_asignada_chofer")
        .off(".operativo")
        .on("change.operativo", function () {
            actualizarHintUnidadChoferOperativo();
        });

    $("#vencimiento_licencia")
        .off(".operativo")
        .on("change.operativo input.operativo", function () {
            actualizarHintLicenciaVencida();
        });

    $("#estado_operativo_control")
        .off(".operativo")
        .on("change.operativo", function () {
            actualizarResumenUnidadControl();
        });

    $("#buscadorUnidadesControl")
        .off(".operativo")
        .on("input.operativo search.operativo", function () {
            renderizarListaUnidadesControl(operativoUnidades);
        });

    $("#btnNuevaUnidadOperativa")
        .off(".operativo")
        .on("click.operativo", function () {
            prepararNuevaUnidadOperativa();
        });

    $("#choferOperativoModal")
        .off("hidden.bs.modal.operativo")
        .on("hidden.bs.modal.operativo", function () {
            resetFormularioChoferOperativo();
            restaurarModalOperativoPadre();
        });

    $("#controlUnidadOperativaModal")
        .off("hidden.bs.modal.operativo")
        .on("hidden.bs.modal.operativo", function () {
            resetFormularioControlUnidad();
            restaurarModalOperativoPadre();
        });

    $("#operativoUnidadesCards")
        .off("click.operativoAsignar")
        .on("click.operativoAsignar", ".js-cargar-unidad-asignacion", function () {
            cargarUnidadEnFormulario($(this).data("id"), "chofer");
        })
        .off("click.operativoControl")
        .on("click.operativoControl", ".js-cargar-unidad-control", function () {
            cargarUnidadEnFormulario($(this).data("id"), "unidad");
        });

    $("#listaUnidadesControl")
        .off("click.operativoListaUnidad")
        .on("click.operativoListaUnidad", ".js-seleccionar-unidad-control", function () {
            cargarUnidadEnFormulario($(this).data("id"), "unidad");
        });

    $("#operativoChoferesCards")
        .off("click.operativoChoferEditar")
        .on("click.operativoChoferEditar", ".js-cargar-chofer-perfil", function () {
            cargarChoferEnFormulario($(this).data("id"));
        })
        .off("click.operativoChoferDesactivar")
        .on("click.operativoChoferDesactivar", ".js-desactivar-chofer", function () {
            desactivarChoferOperativo($(this).data("id"));
        })
        .off("click.operativoChoferAsignacion")
        .on("click.operativoChoferAsignacion", ".js-cargar-chofer-asignacion", function () {
            cargarChoferEnFormulario($(this).data("id"));
        });
}

function abrirModalNuevaSolicitud() {
    limpiarFormularioSeguridad();
    $("#fecha_seguridad").val(obtenerFechaHoraActualInput());
    $("#seguridadEmergenciaModalLabel").text("Registrar solicitud de seguridad");
    cargarCatalogosSeguridad().always(function () {
        $("#seguridadEmergenciaModal").modal("show");
    });
}

function mostrarSolicitudSeguridad(idSeguridad) {
    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=mostrar",
        type: "POST",
        dataType: "json",
        data: { id_seguridad: idSeguridad },
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo cargar la solicitud.");
                return;
            }

            const data = response.data;
            $.when(cargarCatalogosSeguridad(data.id_tipo_seguridad, data.id_solicitud_seguridad)).always(function () {
                $("#id_seguridad").val(data.id_seguridad || "");
                $("#fecha_seguridad").val(data.fecha_seguridad_input || "");
                $("#descripcion").val(data.descripcion || "");
                $("#ubicacion_evento").val(data.ubicacion_evento || "");
                $("#referencia_evento").val(data.referencia_evento || "");
                $("#ticket_interno_seguridad").val(data.ticket_interno || "");
                $("#id_asignacion_preferida").val("");
                seleccionarBeneficiarioSeguridad(data.id_beneficiario, data.beneficiario);

                $("#seguridadEmergenciaModalLabel").text("Editar solicitud de seguridad");
                $("#seguridadEmergenciaModal").modal("show");

                if (Number(data.requiere_ambulancia) === 1 && data.id_despacho_unidad) {
                    sugerenciasDespacho = [];
                    indiceSugerenciaActual = 0;
                    sugerenciaActual = {
                        id_asignacion_unidad_chofer: 0,
                        unidad: {
                            codigo_unidad: data.codigo_unidad,
                            placa: data.placa,
                            descripcion_unidad: data.descripcion_unidad,
                            ubicacion_actual: data.ubicacion_actual,
                            referencia_actual: data.referencia_actual
                        },
                        chofer: {
                            nombre_chofer: data.nombre_chofer,
                            cedula_chofer: data.cedula_chofer,
                            numero_licencia: data.numero_licencia,
                            categoria_licencia: data.categoria_licencia
                        }
                    };
                    renderizarPreviewDespacho(sugerenciaActual, "Asignacion activa");
                } else if (Number(data.requiere_ambulancia) === 1) {
                    gestionarSugerenciaDespacho();
                } else {
                    ocultarPreviewDespacho();
                }
            });
        },
        error: function (xhr) {
            console.error("Error al consultar seguridad:", xhr.responseText);
            mostrarAlertaSeguridad("error", "No se pudo consultar la solicitud.");
        }
    });
}

function guardarSolicitudSeguridad() {
    const btnGuardar = $("#btnGuardarSeguridad");
    const requiereAmbulancia = tipoSeleccionadoRequiereAmbulancia();

    const continuar = function (enviarReporteChofer) {
        btnGuardar.prop("disabled", true);
        const mostrarCargaCorreo = requiereAmbulancia && enviarReporteChofer === true;
        if (mostrarCargaCorreo) {
            mostrarCapaCargaCorreoSeguridad("Guardando solicitud y enviando reporte al correo del chofer...");
        }

        const formData = new FormData(document.getElementById("formularioSeguridadEmergencia"));
        formData.append("enviar_reporte_chofer", enviarReporteChofer ? "1" : "0");

        $.ajax({
            url: "../ajax/serviciosemergencia.php?op=guardaryeditar",
            type: "POST",
            data: formData,
            contentType: false,
            processData: false,
            dataType: "json",
            success: function (response) {
                if (!response || response.ok !== true) {
                    mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo guardar la solicitud.");
                    return;
                }

                $("#seguridadEmergenciaModal").modal("hide");
                recargarSeccionSeguridad();

                if (response.data && response.data.pendiente_asignacion_manual === true) {
                    mostrarAlertaSeguridad("warning", construirMensajeResultadoConReporte(response.msg || "La solicitud fue registrada, pero quedo pendiente de unidad.", response.data)).then(function () {
                        abrirAsignacionManual(response.data.id_seguridad);
                        sugerirEnvioCorreoChoferDesdeResultado(response.data || null).then(function () {
                            sugerirNotificacionWhatsappDesdeResultado(response.data);
                        });
                    });
                    return;
                }

                if (response.data && response.data.auto_asignado === true) {
                    mostrarAlertaSeguridad("success", construirMensajeAutoAsignacion(response.data) + construirMensajeReporteComplemento(response.data)).then(function () {
                        sugerirEnvioCorreoChoferDesdeResultado(response.data || null).then(function () {
                            sugerirNotificacionWhatsappDesdeResultado(response.data);
                        });
                    });
                    return;
                }

                mostrarAlertaSeguridad("success", construirMensajeResultadoConReporte(response.msg || "Solicitud guardada correctamente.", response.data || null)).then(function () {
                    sugerirEnvioCorreoChoferDesdeResultado(response.data || null).then(function () {
                        sugerirNotificacionWhatsappDesdeResultado(response.data || null);
                    });
                });
            },
            error: function (xhr) {
                console.error("Error al guardar seguridad:", xhr.responseText);
                mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor.");
            },
            complete: function () {
                btnGuardar.prop("disabled", false);
                if (mostrarCargaCorreo) {
                    ocultarCapaCargaCorreoSeguridad();
                }
            }
        });
    };

    const continuarConValidaciones = function (enviarReporteChofer) {
        if (requiereAmbulancia && !sugerenciaActual) {
            confirmarAccionSeguridad("No hay una ambulancia disponible en este momento. La solicitud se registrara en pendiente y se abrira la asignacion manual.", "Si, guardar").then(function (resultado) {
                if (!confirmacionAceptadaSeguridad(resultado)) {
                    return;
                }
                continuar(enviarReporteChofer);
            });
            return;
        }

        continuar(enviarReporteChofer);
    };

    if (!requiereAmbulancia) {
        continuarConValidaciones(false);
        return;
    }

    Swal.fire({
        icon: "question",
        title: "Envio de reporte al chofer",
        text: "Deseas enviar el reporte de la solicitud al correo del chofer? Solo se enviara si el chofer tiene correo valido registrado.",
        showCancelButton: true,
        confirmButtonText: "Si, enviar",
        cancelButtonText: "No enviar",
        allowOutsideClick: false,
        allowEscapeKey: false,
        customClass: {
            confirmButton: "btn btn-primary mr-2",
            cancelButton: "btn btn-light"
        },
        buttonsStyling: false
    }).then(function (resultado) {
        continuarConValidaciones(confirmacionAceptadaSeguridad(resultado));
    });
}

function cargarEstadosSolicitudSeguridad(valorSeleccionado) {
    return $.ajax({
        url: "../ajax/serviciosemergencia.php?op=listarestadossolicitud",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const combo = $("#id_estado_solicitud_seguridad");
        const items = response && Array.isArray(response.items) ? response.items : [];
        combo.empty().append('<option value="">Seleccione el estado</option>');

        for (let i = 0; i < items.length; i += 1) {
            combo.append(new Option(items[i].text, items[i].id));
        }

        if (valorSeleccionado) {
            combo.val(String(valorSeleccionado));
        }
    });
}

function abrirModalEstadoSolicitudSeguridad(idSeguridad) {
    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=mostrar",
        type: "POST",
        dataType: "json",
        data: { id_seguridad: idSeguridad },
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo cargar la solicitud.");
                return;
            }

            const data = response.data;
            cargarEstadosSolicitudSeguridad(data.id_estado_solicitud).always(function () {
                $("#id_seguridad_estado").val(data.id_seguridad || "");
                $("#ticket_interno_estado_seguridad").val(data.ticket_interno || "");
                $("#estado_actual_seguridad").val(data.estado_solicitud || "");
                $("#estado_operativo_seguridad").val(data.estado_atencion || "");
                $("#fecha_estado_solicitud_seguridad").val(data.fecha_estado_solicitud_input || obtenerFechaHoraActualInput());
                $("#observacion_estado_solicitud_seguridad").val(data.observacion_estado_solicitud || "");
                actualizarAvisoSolicitudAtendidaSeguridad(data);
                $("#estadoSolicitudSeguridadModal").modal("show");
            });
        },
        error: function (xhr) {
            console.error("Error al preparar el estado de seguridad:", xhr.responseText);
            mostrarAlertaSeguridad("error", "No se pudo preparar la gestion del estado.");
        }
    });
}

function guardarEstadoSolicitudSeguridad() {
    const btnGuardar = $("#btnGuardarEstadoSeguridad");
    btnGuardar.prop("disabled", true);

    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=actualizarestadosolicitud",
        type: "POST",
        data: new FormData(document.getElementById("formularioEstadoSolicitudSeguridad")),
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo actualizar el estado de la solicitud.");
                return;
            }

            $("#estadoSolicitudSeguridadModal").modal("hide");
            recargarSeccionSeguridad();
            mostrarAlertaSeguridad("success", response.msg || "Estado de solicitud actualizado correctamente.").then(function () {
                sugerirEnvioCorreoChoferDesdeResultado(response.data || null).then(function () {
                    sugerirNotificacionWhatsappDesdeResultado(response.data || null);
                });
            });
        },
        error: function (xhr) {
            console.error("Error al guardar estado de seguridad:", xhr.responseText);
            mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function recargarSeccionSeguridad() {
    if (tablaSeguridad) {
        tablaSeguridad.ajax.reload(null, false);
    }
    cargarResumenSeguridad();
    cargarOperativoUnidades();
    cargarChoferesOperativos();
}

function cargarResumenSeguridad() {
    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=resumen",
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                return;
            }

            $("#totalSolicitudesSeguridad").text(response.data.total || 0);
            $("#totalPendientesUnidad").text(response.data.pendientes_unidad || 0);
            $("#totalDespachadosSeguridad").text(response.data.despachados || 0);
            $("#totalFinalizadasSeguridad").text(response.data.finalizadas || 0);
            $("#totalUnidadesDisponibles").text(response.data.unidades_disponibles || 0);
        },
        error: function (xhr) {
            console.error("Error al cargar resumen:", xhr.responseText);
        }
    });
}

function abrirModalBeneficiarioDesdeSeguridad() {
    estadoFormularioSeguridad = obtenerEstadoFormularioSeguridad();
    reabrirSeguridadTrasBeneficiario = true;
    limpiarFormularioBeneficiarioSeguridad();
    $("#seguridadEmergenciaModal").modal("hide");

    setTimeout(function () {
        $("#beneficiarioSeguridadModal").modal("show");
    }, 180);
}

function guardarBeneficiarioDesdeSeguridad() {
    const btnGuardar = $("#btnGuardarBeneficiarioSeguridad");
    btnGuardar.prop("disabled", true);

    $.ajax({
        url: "../ajax/beneficiarios.php?op=guardaryeditar",
        type: "POST",
        data: new FormData(document.getElementById("formularioBeneficiarioSeguridad")),
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data || !response.data.id_beneficiario) {
                mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo registrar el beneficiario.");
                return;
            }

            if (!estadoFormularioSeguridad) {
                estadoFormularioSeguridad = obtenerEstadoFormularioSeguridad();
            }

            estadoFormularioSeguridad.id_beneficiario = String(response.data.id_beneficiario);
            estadoFormularioSeguridad.texto_beneficiario = response.data.beneficiario || construirTextoBeneficiarioSeguridad();
            $("#beneficiarioSeguridadModal").modal("hide");
            mostrarAlertaSeguridad("success", response.msg || "Beneficiario registrado correctamente.");
        },
        error: function (xhr) {
            console.error("Error al guardar beneficiario:", xhr.responseText);
            mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function obtenerEstadoFormularioSeguridad() {
    const combo = $("#id_beneficiario");
    const opcion = combo.find("option:selected");
    return {
        id_seguridad: $("#id_seguridad").val() || "",
        id_beneficiario: combo.val() || "",
        texto_beneficiario: opcion.length ? opcion.text() : "",
        id_tipo_seguridad: $("#id_tipo_seguridad").val() || "",
        id_solicitud_seguridad: $("#id_solicitud_seguridad").val() || "",
        fecha_seguridad: $("#fecha_seguridad").val() || "",
        descripcion: $("#descripcion").val() || "",
        ubicacion_evento: $("#ubicacion_evento").val() || "",
        referencia_evento: $("#referencia_evento").val() || "",
        ticket_interno: $("#ticket_interno_seguridad").val() || "",
        id_asignacion_preferida: $("#id_asignacion_preferida").val() || ""
    };
}

function restaurarFormularioSeguridad() {
    if (!estadoFormularioSeguridad) {
        return;
    }

    $("#id_seguridad").val(estadoFormularioSeguridad.id_seguridad || "");
    $("#id_tipo_seguridad").val(estadoFormularioSeguridad.id_tipo_seguridad || "");
    $("#id_solicitud_seguridad").val(estadoFormularioSeguridad.id_solicitud_seguridad || "");
    $("#fecha_seguridad").val(estadoFormularioSeguridad.fecha_seguridad || "");
    $("#descripcion").val(estadoFormularioSeguridad.descripcion || "");
    $("#ubicacion_evento").val(estadoFormularioSeguridad.ubicacion_evento || "");
    $("#referencia_evento").val(estadoFormularioSeguridad.referencia_evento || "");
    $("#ticket_interno_seguridad").val(estadoFormularioSeguridad.ticket_interno || "");
    $("#id_asignacion_preferida").val(estadoFormularioSeguridad.id_asignacion_preferida || "");

    if (estadoFormularioSeguridad.id_beneficiario) {
        seleccionarBeneficiarioSeguridad(estadoFormularioSeguridad.id_beneficiario, estadoFormularioSeguridad.texto_beneficiario);
    }

    gestionarSugerenciaDespacho();
}

function seleccionarBeneficiarioSeguridad(idBeneficiario, textoBeneficiario) {
    const combo = $("#id_beneficiario");
    if (!combo.length) {
        return;
    }

    if (!idBeneficiario) {
        combo.val(null).trigger("change");
        return;
    }

    const idTexto = String(idBeneficiario);
    let opcion = combo.find("option[value='" + idTexto + "']");
    if (!opcion.length) {
        opcion = new Option(textoBeneficiario || idTexto, idTexto, true, true);
        combo.append(opcion);
    }

    combo.val(idTexto).trigger("change");
}

function construirTextoBeneficiarioSeguridad() {
    const nacionalidad = $("#nacionalidadSeguridad").val() || "";
    const cedula = $("#cedulaSeguridad").val() || "";
    const nombre = $("#nombrebeneficiarioSeguridad").val() || "";
    return (nacionalidad ? nacionalidad + "-" : "") + cedula + (nombre ? " " + nombre : "");
}

function limpiarFormularioBeneficiarioSeguridad() {
    $("#idbeneficiariosSeguridad").val("");
    $("#nacionalidadSeguridad").val("");
    $("#cedulaSeguridad").val("");
    $("#telefonoSeguridad").val("");
    $("#nombrebeneficiarioSeguridad").val("");
    $("#idcomunidadSeguridad").val(null).trigger("change");
}

function limpiarFormularioSeguridad() {
    $("#id_seguridad").val("");
    $("#id_beneficiario").val(null).trigger("change");
    $("#id_tipo_seguridad").val("");
    $("#id_solicitud_seguridad").val("");
    $("#fecha_seguridad").val("");
    $("#descripcion").val("");
    $("#ubicacion_evento").val("");
    $("#referencia_evento").val("");
    $("#ticket_interno_seguridad").val("");
    $("#id_asignacion_preferida").val("");
    estadoFormularioSeguridad = null;
    sugerenciaActual = null;
    sugerenciasDespacho = [];
    indiceSugerenciaActual = 0;
    ocultarPreviewDespacho();
}

function limpiarFormularioEstadoSolicitudSeguridad() {
    $("#id_seguridad_estado").val("");
    $("#ticket_interno_estado_seguridad").val("");
    $("#estado_actual_seguridad").val("");
    $("#estado_operativo_seguridad").val("");
    $("#id_estado_solicitud_seguridad").val("");
    $("#fecha_estado_solicitud_seguridad").val("");
    $("#observacion_estado_solicitud_seguridad").val("");
    limpiarAvisoSolicitudAtendidaSeguridad();
}

function tipoSeleccionadoRequiereAmbulancia() {
    const opcion = $("#id_tipo_seguridad option:selected");
    return Number(opcion.data("requiere-ambulancia") || 0) === 1;
}

function gestionarSugerenciaDespacho() {
    const idPreferido = $("#id_asignacion_preferida").val() || "";

    if (!tipoSeleccionadoRequiereAmbulancia()) {
        sugerenciaActual = null;
        sugerenciasDespacho = [];
        indiceSugerenciaActual = 0;
        $("#id_asignacion_preferida").val("");
        ocultarPreviewDespacho();
        return;
    }

    const idTipo = $("#id_tipo_seguridad").val();
    if (!idTipo) {
        sugerenciaActual = null;
        sugerenciasDespacho = [];
        indiceSugerenciaActual = 0;
        $("#id_asignacion_preferida").val("");
        ocultarPreviewDespacho();
        return;
    }

    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=sugerirdespacho&id_tipo_seguridad=" + encodeURIComponent(idTipo),
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                sugerenciaActual = null;
                sugerenciasDespacho = [];
                indiceSugerenciaActual = 0;
                $("#id_asignacion_preferida").val("");
                renderizarPreviewSinDisponibilidad();
                return;
            }

            if (response.data.disponible === true) {
                sugerenciasDespacho = Array.isArray(response.data.sugerencias) ? response.data.sugerencias : [];
                indiceSugerenciaActual = sugerenciasDespacho.findIndex(function (item) {
                    return String(item.id_asignacion_unidad_chofer || "") === String(idPreferido);
                });
                if (indiceSugerenciaActual < 0) {
                    indiceSugerenciaActual = 0;
                }
                sugerenciaActual = sugerenciasDespacho.length ? sugerenciasDespacho[0] : response.data;
                if (sugerenciasDespacho.length) {
                    sugerenciaActual = sugerenciasDespacho[indiceSugerenciaActual];
                }
                $("#id_asignacion_preferida").val(sugerenciaActual && sugerenciaActual.id_asignacion_unidad_chofer ? sugerenciaActual.id_asignacion_unidad_chofer : "");
                renderizarPreviewDespacho(sugerenciaActual, "Sugerencia disponible");
            } else {
                sugerenciaActual = null;
                sugerenciasDespacho = [];
                indiceSugerenciaActual = 0;
                $("#id_asignacion_preferida").val("");
                renderizarPreviewSinDisponibilidad();
            }
        },
        error: function (xhr) {
            console.error("Error al consultar sugerencia de despacho:", xhr.responseText);
            sugerenciaActual = null;
            sugerenciasDespacho = [];
            indiceSugerenciaActual = 0;
            $("#id_asignacion_preferida").val("");
            renderizarPreviewSinDisponibilidad();
        }
    });
}

function renderizarPreviewDespacho(data, titulo) {
    const unidad = data && data.unidad ? data.unidad : {};
    const chofer = data && data.chofer ? data.chofer : {};
    const grid = $("#dispatchPreviewGrid");
    grid.empty();
    grid.append(crearPreviewItem("Ambulancia", (unidad.codigo_unidad || "N/D") + " / " + (unidad.placa || "N/D")));
    grid.append(crearPreviewItem("Chofer", chofer.nombre_chofer || "No disponible"));
    grid.append(crearPreviewItem("Licencia", chofer.numero_licencia || "Sin licencia"));
    grid.append(crearPreviewItem("Ubicacion actual", unidad.ubicacion_actual || "Sin ubicacion cargada"));
    if (unidad.referencia_actual) {
        grid.append(crearPreviewItem("Referencia", unidad.referencia_actual));
    }
    $("#panelDespachoSugerido .preview-title").text(titulo || "Sugerencia operativa inmediata");
    $("#previewSugerenciaMeta").text(titulo === "Asignacion activa"
        ? "La solicitud ya tiene una unidad y un chofer vinculados."
        : construirMetaSugerencia());
    $("#btnIntercambiarSugerencia").toggleClass("d-none", sugerenciasDespacho.length < 2);
    $("#panelDespachoSugerido").removeClass("d-none");
}

function renderizarPreviewSinDisponibilidad() {
    const grid = $("#dispatchPreviewGrid");
    grid.empty();
    grid.append(crearPreviewItem("Disponibilidad", "No hay ambulancias con chofer disponibles."));
    grid.append(crearPreviewItem("Accion siguiente", "La solicitud se guardara como pendiente y se abrira la asignacion manual."));
    $("#panelDespachoSugerido .preview-title").text("Sin disponibilidad automatica");
    $("#previewSugerenciaMeta").text("Configura choferes y unidades en el panel operativo para habilitar la salida automatica.");
    $("#btnIntercambiarSugerencia").addClass("d-none");
    $("#panelDespachoSugerido").removeClass("d-none");
}

function ocultarPreviewDespacho() {
    $("#dispatchPreviewGrid").empty();
    $("#previewSugerenciaMeta").text("");
    $("#btnIntercambiarSugerencia").addClass("d-none");
    $("#panelDespachoSugerido").addClass("d-none");
}

function crearPreviewItem(etiqueta, valor) {
    return '<div class="preview-item"><small>' + escaparHtml(etiqueta) + '</small><strong>' + escaparHtml(valor || "") + '</strong></div>';
}

function construirMetaSugerencia() {
    if (!sugerenciasDespacho.length) {
        return "Se mostrara la primera sugerencia operativa disponible.";
    }

    if (sugerenciasDespacho.length === 1) {
        return "1 par unidad-chofer disponible para salida inmediata.";
    }

    return "Mostrando " + (indiceSugerenciaActual + 1) + " de " + sugerenciasDespacho.length + " pares operativos disponibles.";
}

function intercambiarSugerenciaAutomatica() {
    if (sugerenciasDespacho.length < 2) {
        return;
    }

    indiceSugerenciaActual = (indiceSugerenciaActual + 1) % sugerenciasDespacho.length;
    sugerenciaActual = sugerenciasDespacho[indiceSugerenciaActual];
    $("#id_asignacion_preferida").val(sugerenciaActual && sugerenciaActual.id_asignacion_unidad_chofer ? sugerenciaActual.id_asignacion_unidad_chofer : "");
    renderizarPreviewDespacho(sugerenciaActual, "Sugerencia intercambiada");
}

function abrirAsignacionManual(idSeguridad) {
    $("#id_seguridad_manual").val(idSeguridad);
    $("#id_asignacion_unidad_chofer").val("");
    $("#observaciones_manual").val("");
    $("#manualAssignmentGrid").empty();
    $("#manualAssignmentSummary").addClass("d-none");

    $.when(
        $.ajax({
            url: "../ajax/serviciosemergencia.php?op=mostrar",
            type: "POST",
            dataType: "json",
            data: { id_seguridad: idSeguridad }
        }),
        $.ajax({
            url: "../ajax/serviciosemergencia.php?op=listarasignacionesdisponibles",
            type: "GET",
            dataType: "json"
        })
    ).done(function (solicitudResponse, asignacionesResponse) {
        const solicitud = solicitudResponse[0];
        const asignaciones = asignacionesResponse[0];

        if (!solicitud || solicitud.ok !== true || !solicitud.data) {
            mostrarAlertaSeguridad("error", "No se pudo cargar la solicitud para asignacion manual.");
            return;
        }

        asignacionesDisponibles = asignaciones && asignaciones.data && Array.isArray(asignaciones.data.items)
            ? asignaciones.data.items
            : [];

        $("#manualAssignmentHeader").html(
            crearPreviewItem("Ticket", solicitud.data.ticket_interno || "Sin ticket") +
            crearPreviewItem("Servicio", solicitud.data.tipo_seguridad || "Sin servicio") +
            crearPreviewItem("Beneficiario", solicitud.data.beneficiario || "Sin beneficiario") +
            crearPreviewItem("Ubicacion", solicitud.data.ubicacion_evento || "Sin ubicacion")
        );

        const combo = $("#id_asignacion_unidad_chofer");
        combo.empty().append('<option value="">Seleccione una unidad disponible</option>');
        for (let i = 0; i < asignacionesDisponibles.length; i += 1) {
            combo.append(new Option(asignacionesDisponibles[i].text, asignacionesDisponibles[i].id));
        }

        $("#asignacionManualModal").modal("show");

        if (!asignacionesDisponibles.length) {
            mostrarAlertaSeguridad("warning", "Todavia no hay pares unidad-chofer disponibles. Configure la operativa y vuelva a intentar.");
        }
    }).fail(function (xhr) {
        console.error("Error al cargar asignacion manual:", xhr.responseText);
        mostrarAlertaSeguridad("error", "No se pudo abrir la asignacion manual.");
    });
}

function actualizarResumenAsignacionManual(idAsignacion) {
    const idTexto = String(idAsignacion || "");
    const seleccionado = asignacionesDisponibles.find(function (item) {
        return String(item.id) === idTexto;
    });

    if (!seleccionado) {
        $("#manualAssignmentGrid").empty();
        $("#manualAssignmentSummary").addClass("d-none");
        return;
    }

    $("#manualAssignmentGrid").html(
        crearPreviewItem("Unidad", seleccionado.unidad.codigo_unidad + " / " + seleccionado.unidad.placa) +
        crearPreviewItem("Chofer", seleccionado.chofer.nombre_chofer) +
        crearPreviewItem("Licencia", seleccionado.chofer.numero_licencia || "Sin licencia") +
        crearPreviewItem("Ubicacion", seleccionado.unidad.ubicacion_actual || "Sin ubicacion")
    );
    $("#manualAssignmentSummary").removeClass("d-none");
}

function guardarAsignacionManual() {
    const btnGuardar = $("#btnGuardarAsignacionManual");
    btnGuardar.prop("disabled", true);

    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=asignarmanual",
        type: "POST",
        data: new FormData(document.getElementById("formularioAsignacionManual")),
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo asignar la ambulancia.");
                return;
            }

            $("#asignacionManualModal").modal("hide");
            recargarSeccionSeguridad();
            mostrarAlertaSeguridad("success", response.msg || "Ambulancia asignada correctamente.").then(function () {
                sugerirEnvioCorreoChoferDesdeResultado(response.data || null).then(function () {
                    sugerirNotificacionWhatsappDesdeResultado(response.data || null);
                });
            });
        },
        error: function (xhr) {
            console.error("Error al asignar manualmente:", xhr.responseText);
            mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function abrirCierreDespacho(idSeguridad) {
    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=mostrardespachoactivo",
        type: "POST",
        dataType: "json",
        data: { id_seguridad: idSeguridad },
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo cargar el despacho.");
                return;
            }

            const data = response.data;
            $("#id_seguridad_cierre").val(idSeguridad);
            $("#fecha_cierre").val(obtenerFechaHoraActualInput());
            $("#km_salida").val("");
            $("#km_llegada").val("");
            $("#estado_unidad_final").val("DISPONIBLE");
            $("#ubicacion_cierre").val(data.ubicacion_actual || "");
            $("#referencia_cierre").val(data.referencia_actual || "");
            $("#diagnostico_paciente").val("");
            $("#evidencia_foto").val("");
            $("#enviar_reporte_chofer_cierre").prop("checked", false);

            $("#cierreDespachoHeader").html(
                crearPreviewItem("Ticket", data.ticket_interno || "Sin ticket") +
                crearPreviewItem("Unidad", data.codigo_unidad + " / " + data.placa) +
                crearPreviewItem("Chofer", data.nombre_chofer || "Sin chofer") +
                crearPreviewItem("Licencia", data.numero_licencia || "Sin licencia")
            );

            $("#cierreDespachoModal").modal("show");
        },
        error: function (xhr) {
            console.error("Error al abrir cierre de despacho:", xhr.responseText);
            mostrarAlertaSeguridad("error", "No se pudo abrir el formulario de cierre.");
        }
    });
}

function guardarCierreDespacho() {
    const btnGuardar = $("#btnGuardarCierreDespacho");
    btnGuardar.prop("disabled", true);
    const enviarCorreo = $("#enviar_reporte_chofer_cierre").is(":checked");
    if (enviarCorreo) {
        mostrarCapaCargaCorreoSeguridad("Cerrando despacho y enviando reporte al correo del chofer...");
    }

    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=cerrardespacho",
        type: "POST",
        data: new FormData(document.getElementById("formularioCierreDespacho")),
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo cerrar el despacho.");
                return;
            }

            $("#cierreDespachoModal").modal("hide");
            recargarSeccionSeguridad();
            mostrarAlertaSeguridad("success", construirMensajeResultadoConReporte(response.msg || "Despacho cerrado correctamente.", response.data || null)).then(function () {
                sugerirEnvioCorreoChoferDesdeResultado(response.data || null).then(function () {
                    sugerirNotificacionWhatsappDesdeResultado(response.data || null);
                });
            });
        },
        error: function (xhr) {
            console.error("Error al cerrar despacho:", xhr.responseText);
            mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
            if (enviarCorreo) {
                ocultarCapaCargaCorreoSeguridad();
            }
        }
    });
}

function abrirModalOperativa() {
    limpiarFormulariosOperativos();
    cargarPanelOperativoCompleto().always(function () {
        $("#operativoEmergenciaModal").modal("show");
    });
}

function cargarPanelOperativoCompleto() {
    return $.when(
        cargarEmpleadosOperativos(),
        cargarChoferesOperativos(),
        cargarOperativoUnidades()
    );
}

function abrirModalChoferOperativo(preservarValores) {
    if (preservarValores !== true) {
        resetFormularioChoferOperativo();
    }
    actualizarHintLicenciaVencida();
    actualizarHintUnidadChoferOperativo();
    if ($("#choferOperativoModal").length) {
        $("#choferOperativoModal").modal("show");
    }
}

function abrirModalControlUnidad(preservarValores) {
    if (preservarValores !== true) {
        resetFormularioControlUnidad();
    }
    renderizarListaUnidadesControl(operativoUnidades);
    if ($("#controlUnidadOperativaModal").length) {
        $("#controlUnidadOperativaModal").modal("show");
    }
}

function restaurarModalOperativoPadre() {
    if (!$("#operativoEmergenciaModal").hasClass("show")) {
        return;
    }

    window.setTimeout(function () {
        $("body").addClass("modal-open");
    }, 120);
}

function cargarEmpleadosOperativos() {
    return $.ajax({
        url: "../ajax/serviciosemergencia.php?op=listarempleados",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const combo = $("#id_empleado_operativo");
        const actual = combo.data("pendingValue") || combo.val() || "";
        const items = response && Array.isArray(response.items) ? response.items : [];
        operativoEmpleados = items;
        combo.empty().append('<option value="">Seleccione un empleado</option>');
        for (let i = 0; i < items.length; i += 1) {
            combo.append(new Option(items[i].text, items[i].id));
        }

        if (actual) {
            combo.val(String(actual));
            autocompletarChoferDesdeEmpleado(actual);
        }
        combo.removeData("pendingValue");
        if (combo.hasClass("select2-hidden-accessible")) {
            combo.trigger("change.select2");
        }
    });
}

function obtenerEmpleadoOperativoPorId(idEmpleado) {
    return operativoEmpleados.find(function (item) {
        return String(item.id) === String(idEmpleado || "");
    }) || null;
}

function obtenerUnidadOperativaPorId(idUnidad) {
    return operativoUnidades.find(function (item) {
        return String(item.id_unidad) === String(idUnidad || "");
    }) || null;
}

function obtenerChoferOperativoPorId(idChofer) {
    return operativoChoferes.find(function (item) {
        return String(item.id) === String(idChofer || "");
    }) || null;
}

function autocompletarChoferDesdeEmpleado(idEmpleado) {
    const empleado = obtenerEmpleadoOperativoPorId(idEmpleado);
    const choferActivo = operativoChoferes.find(function (item) {
        return String(item.id_empleado) === String(idEmpleado || "");
    }) || null;

    if (!empleado) {
        ocultarHintChoferExistente();
        cargarComboUnidadChoferOperativo(null, "");
        actualizarHintLicenciaVencida();
        actualizarHintUnidadChoferOperativo();
        return;
    }

    if (empleado.chofer_registrado !== true) {
        $("#numero_licencia").val("");
        $("#categoria_licencia").val("");
        $("#vencimiento_licencia").val("");
        $("#contacto_emergencia").val("");
        $("#telefono_contacto_emergencia").val("");
        $("#observaciones_chofer").val("");
        cargarComboUnidadChoferOperativo(null, $("#id_unidad_asignada_chofer").data("pendingValue") || $("#id_unidad_asignada_chofer").val() || "");
        mostrarHintChoferExistente("Este empleado aun no tiene perfil operativo. Completa los datos para registrarlo.", "info");
        actualizarHintLicenciaVencida();
        actualizarHintUnidadChoferOperativo();
        return;
    }

    $("#numero_licencia").val(empleado.numero_licencia || "");
    $("#categoria_licencia").val(empleado.categoria_licencia || "");
    $("#vencimiento_licencia").val(empleado.vencimiento_licencia || "");
    $("#contacto_emergencia").val(empleado.contacto_emergencia || "");
    $("#telefono_contacto_emergencia").val(empleado.telefono_contacto_emergencia || "");
    $("#observaciones_chofer").val(empleado.observaciones || "");
    cargarComboUnidadChoferOperativo(choferActivo, choferActivo && choferActivo.id_unidad ? String(choferActivo.id_unidad) : "");

    if (Number(empleado.estado_chofer) === 1) {
        if (choferActivo && choferActivo.asignado === true && choferActivo.id_unidad) {
            mostrarHintChoferExistente(
                "Este chofer ya tiene asignada la unidad " + (choferActivo.codigo_unidad || "sin codigo") + (choferActivo.placa ? " / " + choferActivo.placa : "") + ". Puedes actualizar su perfil, pero para vincular otra unidad primero debes liberarla desde Unidades.",
                "primary"
            );
            actualizarHintLicenciaVencida();
            actualizarHintUnidadChoferOperativo();
            return;
        }

        mostrarHintChoferExistente("Este empleado ya tiene un perfil operativo activo. Puedes modificar los datos y guardar para actualizarlos.", "primary");
        actualizarHintLicenciaVencida();
        actualizarHintUnidadChoferOperativo();
        return;
    }

    mostrarHintChoferExistente("Este empleado tiene un perfil operativo inactivo. Si guardas, el sistema lo reactivara con los nuevos datos.", "warning");
    actualizarHintLicenciaVencida();
    actualizarHintUnidadChoferOperativo();
}

function mostrarHintChoferExistente(mensaje, tono) {
    const hint = $("#choferExistenteHint");
    if (!hint.length) {
        return;
    }

    hint.removeClass("d-none alert-info alert-primary alert-warning alert-success")
        .addClass("alert-" + (tono || "info"))
        .text(mensaje || "");
}

function ocultarHintChoferExistente() {
    const hint = $("#choferExistenteHint");
    if (!hint.length) {
        return;
    }

    hint.addClass("d-none")
        .removeClass("alert-info alert-primary alert-warning alert-success")
        .text("");
}

function mostrarHintUnidadChoferOperativo(html, tono) {
    const hint = $("#unidadChoferOperativoHint");
    if (!hint.length) {
        return;
    }

    hint.removeClass("d-none alert-warning alert-info alert-primary alert-success")
        .addClass("alert-" + (tono || "warning"))
        .html(html || "");
}

function ocultarHintUnidadChoferOperativo() {
    const hint = $("#unidadChoferOperativoHint");
    if (!hint.length) {
        return;
    }

    hint.addClass("d-none")
        .removeClass("alert-warning alert-info alert-primary alert-success")
        .html("");
}

function actualizarHintUnidadChoferOperativo() {
    const unidad = obtenerUnidadOperativaPorId($("#id_unidad_asignada_chofer").val());
    const idEmpleado = $("#id_empleado_operativo").val() || "";
    const choferSeleccionado = operativoChoferes.find(function (item) {
        return String(item.id_empleado) === String(idEmpleado);
    }) || null;

    if (!unidad) {
        ocultarHintUnidadChoferOperativo();
        return;
    }

    if (choferSeleccionado && choferSeleccionado.asignado === true && String(choferSeleccionado.id_unidad || "") === String(unidad.id_unidad || "")) {
        mostrarHintUnidadChoferOperativo(
            "<strong>Este chofer ya cuenta con esta unidad.</strong><br>" +
            "Unidad actual: " + escaparHtml(unidad.codigo_unidad || "Sin codigo") +
            (unidad.placa ? " / " + escaparHtml(unidad.placa) : "") +
            ". Puedes actualizar el perfil del conductor y mantener la misma asignacion.",
            "info"
        );
        return;
    }

    if (unidad.id_chofer_ambulancia && unidad.nombre_chofer) {
        mostrarHintUnidadChoferOperativo(
            "<strong>La unidad ya cuenta con un chofer asignado.</strong><br>" +
            "Chofer actual: " + escaparHtml(unidad.nombre_chofer || "Sin nombre") +
            " | Cedula: " + escaparHtml(unidad.cedula_chofer || "Sin cedula") +
            " | Licencia: " + escaparHtml(unidad.numero_licencia || "Sin licencia"),
            "warning"
        );
        return;
    }

    mostrarHintUnidadChoferOperativo(
        "<strong>Unidad disponible para asignacion inmediata.</strong><br>" +
        "Ubicacion actual: " + escaparHtml(unidad.ubicacion_actual || "Sin ubicacion") +
        " | Prioridad: " + escaparHtml(String(unidad.prioridad_despacho || "1")) +
        (unidad.referencia_actual ? " | Referencia: " + escaparHtml(unidad.referencia_actual) : ""),
        "success"
    );
}

function cargarComboUnidadChoferOperativo(choferActual, valorSeleccionado) {
    const combo = $("#id_unidad_asignada_chofer");
    if (!combo.length) {
        return;
    }

    const actual = valorSeleccionado || combo.data("pendingValue") || combo.val() || "";
    const unidadesDisponibles = operativoUnidades.filter(function (item) {
        if (item.estado_operativo !== "DISPONIBLE") {
            return false;
        }

        if (choferActual && choferActual.asignado === true && String(item.id_unidad) === String(choferActual.id_unidad || "")) {
            return true;
        }

        return !item.id_chofer_ambulancia;
    });

    combo.empty().append('<option value="">Dejar sin unidad por ahora</option>');
    for (let i = 0; i < unidadesDisponibles.length; i += 1) {
        const unidad = unidadesDisponibles[i];
        let texto = (unidad.codigo_unidad || "Unidad") + " - " + (unidad.placa || "Sin placa");
        if (choferActual && choferActual.asignado === true && String(unidad.id_unidad) === String(choferActual.id_unidad || "")) {
            texto += " (actual)";
        }
        combo.append(new Option(texto, unidad.id_unidad));
    }

    combo.prop("disabled", !!(choferActual && choferActual.asignado === true && choferActual.id_unidad));

    if (actual) {
        combo.val(String(actual));
    } else {
        combo.val("");
    }

    combo.removeData("pendingValue");
    if (combo.hasClass("select2-hidden-accessible")) {
        combo.trigger("change.select2");
    }
}

function cargarChoferesOperativos() {
    return $.ajax({
        url: "../ajax/serviciosemergencia.php?op=listarchoferes",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const items = response && Array.isArray(response.items) ? response.items : [];
        operativoChoferes = items;
        renderizarChoferesOperativos(items);
        actualizarResumenOperativo();
        const idEmpleado = $("#id_empleado_operativo").val() || "";
        if (idEmpleado) {
            autocompletarChoferDesdeEmpleado(idEmpleado);
        } else {
            actualizarHintUnidadChoferOperativo();
        }
    });
}

function cargarOperativoUnidades() {
    return $.ajax({
        url: "../ajax/serviciosemergencia.php?op=listaroperativo",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const items = response && response.data && Array.isArray(response.data.items) ? response.data.items : [];
        operativoUnidades = items;
        renderizarUnidadesOperativas(items);
        renderizarListaUnidadesControl(items);
        actualizarResumenOperativo();
        const idEmpleado = $("#id_empleado_operativo").val() || "";
        if (idEmpleado) {
            autocompletarChoferDesdeEmpleado(idEmpleado);
        } else {
            cargarComboUnidadChoferOperativo(null, $("#id_unidad_asignada_chofer").val() || "");
            actualizarHintUnidadChoferOperativo();
        }
    });
}

function llenarComboChoferesDisponibles(items) {
    return items;
}

function llenarCombosUnidadesOperativas(items) {
    return items;
}

function renderizarListaUnidadesControl(items) {
    const contenedor = $("#listaUnidadesControl");
    if (!contenedor.length) {
        return;
    }

    const termino = ($("#buscadorUnidadesControl").val() || "").toLowerCase().trim();
    const filtradas = items.filter(function (item) {
        if (!termino) {
            return true;
        }

        const texto = [
            item.codigo_unidad || "",
            item.placa || "",
            item.descripcion || "",
            item.nombre_chofer || ""
        ].join(" ").toLowerCase();

        return texto.indexOf(termino) !== -1;
    });

    contenedor.empty();
    if (!filtradas.length) {
        contenedor.html('<div class="operativo-empty-state">No hay unidades que coincidan con la busqueda.</div>');
        return;
    }

    for (let i = 0; i < filtradas.length; i += 1) {
        const unidad = filtradas[i];
        const estado = obtenerEstadoUnidadOperativa(unidad);
        contenedor.append(
            '<article class="operativo-unit-item ' + estado.cardClass + '">' +
                '<div class="d-flex align-items-start justify-content-between" style="gap:12px;">' +
                    '<div>' +
                        '<strong>' + escaparHtml(unidad.codigo_unidad || "Unidad") + '</strong>' +
                        '<div class="small text-muted">' + escaparHtml(unidad.placa || "Sin placa") + " - " + escaparHtml(unidad.descripcion || "Sin descripcion") + '</div>' +
                        '<div class="small text-muted">Chofer: ' + escaparHtml(unidad.nombre_chofer || "Sin asignar") + '</div>' +
                    '</div>' +
                    '<span class="operativo-status-chip ' + estado.chipClass + '">' + escaparHtml(estado.label) + '</span>' +
                '</div>' +
                '<button type="button" class="btn btn-outline-secondary btn-sm mt-2 js-seleccionar-unidad-control" data-id="' + escaparHtml(String(unidad.id_unidad || "")) + '">' +
                    '<i class="fas fa-pen"></i> Editar' +
                '</button>' +
            '</article>'
        );
    }
}

function renderizarUnidadesOperativas(items) {
    const contenedor = $("#operativoUnidadesCards");
    if (!contenedor.length) {
        return;
    }

    contenedor.empty();
    if (!items.length) {
        contenedor.html('<div class="operativo-empty-state">No hay unidades operativas cargadas todavia.</div>');
        return;
    }

    for (let i = 0; i < items.length; i += 1) {
        const unidad = items[i];
        const estado = obtenerEstadoUnidadOperativa(unidad);
        const botonAsignacion = unidad.estado_operativo === "DISPONIBLE" && !unidad.nombre_chofer
            ? '<button type="button" class="btn btn-outline-warning btn-sm js-cargar-unidad-asignacion" data-id="' + escaparHtml(String(unidad.id_unidad || "")) + '" title="Usar esta unidad disponible en el registro de chofer">' +
                '<i class="fas fa-link"></i> Asignar chofer' +
              '</button>'
            : "";
        contenedor.append(
            '<article class="operativo-card ' + estado.cardClass + '">' +
                '<div class="title-row">' +
                    '<div>' +
                        '<h6>' + escaparHtml(unidad.codigo_unidad || "Unidad") + '</h6>' +
                        '<div class="subtitle">' + escaparHtml(unidad.placa || "Sin placa") + ' - ' + escaparHtml(unidad.descripcion || "Sin descripcion") + '</div>' +
                    '</div>' +
                    '<span class="operativo-status-chip ' + estado.chipClass + '">' + escaparHtml(estado.label) + '</span>' +
                '</div>' +
                '<div class="details">' +
                    '<div class="detail"><small>Chofer</small><strong>' + escaparHtml(unidad.nombre_chofer || "Sin chofer asignado") + '</strong></div>' +
                    '<div class="detail"><small>Licencia</small><strong>' + escaparHtml(unidad.numero_licencia || "Sin licencia") + '</strong></div>' +
                    '<div class="detail"><small>Ubicacion</small><strong>' + escaparHtml(unidad.ubicacion_actual || "Sin ubicacion") + '</strong></div>' +
                    '<div class="detail"><small>Prioridad</small><strong>' + escaparHtml(String(unidad.prioridad_despacho || "0")) + '</strong></div>' +
                    '<div class="detail"><small>Referencia</small><strong>' + escaparHtml(unidad.referencia_actual || "Sin referencia") + '</strong></div>' +
                    '<div class="detail"><small>Ticket</small><strong>' + escaparHtml(unidad.ticket_interno || "Sin despacho") + '</strong></div>' +
                '</div>' +
                '<div class="actions">' +
                    botonAsignacion +
                    '<button type="button" class="btn btn-outline-secondary btn-sm js-cargar-unidad-control" data-id="' + escaparHtml(String(unidad.id_unidad || "")) + '" title="Cargar esta unidad en el formulario de control operativo">' +
                        '<i class="fas fa-sliders-h"></i> Ver unidad' +
                    '</button>' +
                '</div>' +
            '</article>'
        );
    }

    activarTooltipsSeguridad();
}

function renderizarChoferesOperativos(items) {
    const contenedor = $("#operativoChoferesCards");
    if (!contenedor.length) {
        return;
    }

    contenedor.empty();
    if (!items.length) {
        contenedor.html('<div class="operativo-empty-state">Todavia no hay choferes operativos creados.</div>');
        return;
    }

    for (let i = 0; i < items.length; i += 1) {
        const chofer = items[i];
        const estado = obtenerEstadoChoferOperativo(chofer);
        const botonAsignacion = chofer.asignado === true || licenciaEstaVencida(chofer.vencimiento)
            ? ""
            : '<button type="button" class="btn btn-outline-warning btn-sm js-cargar-chofer-asignacion" data-id="' + escaparHtml(String(chofer.id || "")) + '" title="Cargar este chofer libre en la asignacion de unidad">' +
                '<i class="fas fa-link"></i> Asignar unidad' +
              '</button>';
        const botonDesactivar = '<button type="button" class="btn btn-outline-danger btn-sm js-desactivar-chofer" data-id="' + escaparHtml(String(chofer.id || "")) + '" title="Desactivar este chofer del control operativo">' +
                '<i class="fas fa-user-slash"></i> Desactivar' +
              '</button>';

        contenedor.append(
            '<article class="operativo-card ' + estado.cardClass + '">' +
                '<div class="title-row">' +
                    '<div>' +
                        '<h6>' + escaparHtml(chofer.nombre_chofer || "Chofer") + '</h6>' +
                        '<div class="subtitle">' + escaparHtml(chofer.cedula || "Sin cedula") + '</div>' +
                    '</div>' +
                    '<span class="operativo-status-chip ' + estado.chipClass + '">' + escaparHtml(estado.label) + '</span>' +
                '</div>' +
                '<div class="details">' +
                    '<div class="detail"><small>Licencia</small><strong>' + escaparHtml(chofer.licencia || "Sin licencia") + '</strong></div>' +
                    '<div class="detail"><small>Categoria</small><strong>' + escaparHtml(chofer.categoria || "Sin categoria") + '</strong></div>' +
                    '<div class="detail"><small>Vencimiento</small><strong>' + escaparHtml(chofer.vencimiento || "Sin fecha") + '</strong></div>' +
                    '<div class="detail"><small>Unidad</small><strong>' + escaparHtml(chofer.codigo_unidad ? chofer.codigo_unidad + " / " + (chofer.placa || "") : "Sin unidad") + '</strong></div>' +
                    '<div class="detail"><small>Contacto</small><strong>' + escaparHtml(chofer.contacto_emergencia || "Sin contacto") + '</strong></div>' +
                    '<div class="detail"><small>Telefono</small><strong>' + escaparHtml(chofer.telefono_contacto_emergencia || "Sin telefono") + '</strong></div>' +
                '</div>' +
                '<div class="actions">' +
                    '<button type="button" class="btn btn-outline-primary btn-sm js-cargar-chofer-perfil" data-id="' + escaparHtml(String(chofer.id || "")) + '" title="Cargar este chofer en el formulario de perfil">' +
                        '<i class="fas fa-id-card"></i> Editar perfil' +
                    '</button>' +
                    botonDesactivar +
                    botonAsignacion +
                '</div>' +
            '</article>'
        );
    }

    activarTooltipsSeguridad();
}

function actualizarResumenOperativo() {
    if (!$("#operativoTotalUnidades").length) {
        return;
    }

    const totalUnidades = operativoUnidades.length;
    const fueraServicio = operativoUnidades.filter(function (item) {
        return item.estado_operativo === "FUERA_SERVICIO";
    }).length;
    const sinChofer = operativoUnidades.filter(function (item) {
        return item.estado_operativo !== "FUERA_SERVICIO" && !item.nombre_chofer;
    }).length;
    const listas = operativoUnidades.filter(function (item) {
        return item.estado_operativo === "DISPONIBLE" && item.nombre_chofer && !item.ticket_interno;
    }).length;
    const choferesSinUnidad = operativoChoferes.filter(function (item) {
        return item.asignado !== true;
    }).length;

    $("#operativoTotalUnidades").text(totalUnidades);
    $("#operativoUnidadesListas").text(listas);
    $("#operativoUnidadesSinChofer").text(sinChofer);
    $("#operativoChoferesSinUnidad").text(choferesSinUnidad);
    $("#operativoUnidadesFueraServicio").text(fueraServicio);
}

function obtenerEstadoUnidadOperativa(unidad) {
    if (unidad.estado_operativo === "FUERA_SERVICIO") {
        return { label: "Fuera de servicio", chipClass: "danger", cardClass: "unit-danger" };
    }
    if (!unidad.nombre_chofer) {
        return { label: "Sin chofer", chipClass: "warning", cardClass: "unit-warning" };
    }
    if (unidad.ticket_interno) {
        return { label: "Despachada", chipClass: "info", cardClass: "unit-info" };
    }
    return { label: "Lista para salida", chipClass: "ready", cardClass: "unit-ready" };
}

function obtenerEstadoChoferOperativo(chofer) {
    if (licenciaEstaVencida(chofer.vencimiento)) {
        return { label: "Licencia vencida", chipClass: "danger", cardClass: "driver-danger" };
    }
    if (chofer.asignado === true && chofer.ticket_interno) {
        return { label: "En despacho", chipClass: "info", cardClass: "driver-info" };
    }
    if (chofer.asignado === true) {
        return { label: "Con unidad", chipClass: "ready", cardClass: "driver-ready" };
    }
    return { label: "Sin unidad", chipClass: "warning", cardClass: "driver-warning" };
}

function guardarChoferOperativo() {
    const btnGuardar = $("#btnGuardarChoferOperativo");
    if (actualizarHintLicenciaVencida()) {
        mostrarAlertaSeguridad("warning", "La licencia del chofer se encuentra vencida. Registra una fecha vigente para continuar.");
        return;
    }

    btnGuardar.prop("disabled", true);

    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=guardarchofer",
        type: "POST",
        data: new FormData(document.getElementById("formularioChoferOperativo")),
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo guardar el chofer.");
                return;
            }

            $.when(cargarChoferesOperativos(), cargarOperativoUnidades(), cargarEmpleadosOperativos()).always(function () {
                $("#choferOperativoModal").modal("hide");
                mostrarAlertaSeguridad("success", response.msg || "Chofer guardado correctamente.");
                gestionarSugerenciaDespacho();
                cargarResumenSeguridad();
            });
        },
        error: function (xhr) {
            console.error("Error al guardar chofer:", xhr.responseText);
            mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function desactivarChoferOperativo(idChoferAmbulancia) {
    confirmarAccionSeguridad("Confirma que deseas desactivar este chofer operativo?", "Si, desactivar").then(function (resultado) {
        if (!confirmacionAceptadaSeguridad(resultado)) {
            return;
        }

        $.ajax({
            url: "../ajax/serviciosemergencia.php?op=desactivarchofer",
            type: "POST",
            dataType: "json",
            data: { id_chofer_ambulancia: idChoferAmbulancia },
            success: function (response) {
                if (!response || response.ok !== true) {
                    mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo desactivar el chofer.");
                    return;
                }

                $.when(cargarChoferesOperativos(), cargarOperativoUnidades(), cargarEmpleadosOperativos()).always(function () {
                    mostrarAlertaSeguridad("success", response.msg || "Chofer desactivado correctamente.");
                    gestionarSugerenciaDespacho();
                    cargarResumenSeguridad();
                });
            },
            error: function (xhr) {
                console.error("Error al desactivar chofer:", xhr.responseText);
                mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor.");
            }
        });
    });
}

function guardarControlUnidadOperativa() {
    const btnGuardar = $("#btnGuardarControlUnidad");
    btnGuardar.prop("disabled", true);

    $.ajax({
        url: "../ajax/serviciosemergencia.php?op=guardarunidadoperativa",
        type: "POST",
        data: new FormData(document.getElementById("formularioControlUnidad")),
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo guardar la unidad.");
                return;
            }

            $.when(cargarOperativoUnidades(), cargarChoferesOperativos()).always(function () {
                renderizarListaUnidadesControl(operativoUnidades);
                if (response.data && response.data.id_unidad) {
                    cargarUnidadEnFormulario(response.data.id_unidad, "unidad");
                } else {
                    prepararNuevaUnidadOperativa();
                }
                mostrarAlertaSeguridad("success", response.msg || "Unidad guardada correctamente.");
                gestionarSugerenciaDespacho();
                cargarResumenSeguridad();
            });
        },
        error: function (xhr) {
            console.error("Error al actualizar unidad operativa:", xhr.responseText);
            mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function cargarUnidadEnFormulario(idUnidad, panelDestino) {
    const unidad = operativoUnidades.find(function (item) {
        return String(item.id_unidad) === String(idUnidad || "");
    });

    if (!unidad) {
        return;
    }

    if (panelDestino === "unidad") {
        prepararNuevaUnidadOperativa();
        $("#id_unidad_control").val(String(unidad.id_unidad));
        $("#codigo_unidad_control").val(unidad.codigo_unidad || "");
        $("#descripcion_unidad_control").val(unidad.descripcion || "");
        $("#placa_unidad_control").val(unidad.placa || "");
        $("#estado_operativo_control").val(unidad.estado_operativo || "DISPONIBLE");
        $("#ubicacion_actual_control").val(unidad.ubicacion_actual || "");
        $("#referencia_actual_control").val(unidad.referencia_actual || "");
        $("#prioridad_despacho_control").val(String(unidad.prioridad_despacho || "1"));
        actualizarResumenUnidadControl(unidad);
        abrirModalControlUnidad(true);
        return;
    }

    resetFormularioChoferOperativo();
    $("#id_unidad_asignada_chofer").data("pendingValue", String(unidad.id_unidad || ""));
    cargarComboUnidadChoferOperativo(null, String(unidad.id_unidad || ""));
    actualizarHintUnidadChoferOperativo();
    abrirModalChoferOperativo(true);
}

function cargarChoferEnFormulario(idChofer) {
    const chofer = operativoChoferes.find(function (item) {
        return String(item.id) === String(idChofer || "");
    });

    if (!chofer) {
        return;
    }

    resetFormularioChoferOperativo();
    $("#id_empleado_operativo")
        .data("pendingValue", String(chofer.id_empleado || ""))
        .val(String(chofer.id_empleado || ""))
        .trigger("change.select2");
    $("#numero_licencia").val(chofer.licencia || "");
    $("#categoria_licencia").val(chofer.categoria || "");
    $("#vencimiento_licencia").val(chofer.vencimiento || "");
    $("#contacto_emergencia").val(chofer.contacto_emergencia || "");
    $("#telefono_contacto_emergencia").val(chofer.telefono_contacto_emergencia || "");
    $("#observaciones_chofer").val(chofer.observaciones || "");
    cargarComboUnidadChoferOperativo(chofer, chofer.id_unidad ? String(chofer.id_unidad) : "");
    actualizarHintLicenciaVencida();
    actualizarHintUnidadChoferOperativo();
    mostrarHintChoferExistente("Este empleado ya tiene un perfil operativo activo. Puedes modificar los datos y guardar para actualizarlos.", "primary");
    abrirModalChoferOperativo(true);
}

function cargarChoferEnAsignacion(idChofer) {
    cargarChoferEnFormulario(idChofer);
}

function actualizarResumenUnidadControl(unidadSeleccionada) {
    const unidad = unidadSeleccionada || obtenerUnidadOperativaPorId($("#id_unidad_control").val());
    const campoResumen = $("#codigo_estado_unidad_control");
    const hint = $("#unidadControlHint");
    if (!campoResumen.length || !hint.length) {
        return;
    }

    const estadoActual = $("#estado_operativo_control").val() || "DISPONIBLE";
    if (!unidad) {
        campoResumen.val("Nueva unidad");
        hint.addClass("d-none").text("");
        return;
    }

    campoResumen.val((unidad.codigo_unidad || "Unidad") + " - " + estadoActual.replace("_", " "));
    if (estadoActual === "FUERA_SERVICIO" && unidad.id_chofer_ambulancia && unidad.nombre_chofer) {
        hint.removeClass("d-none").html(
            "<strong>La unidad quedara fuera de servicio.</strong><br>" +
            "El chofer " + escaparHtml(unidad.nombre_chofer || "Sin nombre") + " sera liberado automaticamente para otra unidad."
        );
        return;
    }

    hint.addClass("d-none").text("");
}

function prepararNuevaUnidadOperativa() {
    if (!$("#formularioControlUnidad").length) {
        return;
    }

    $("#formularioControlUnidad")[0].reset();
    $("#id_unidad_control").val("");
    $("#prioridad_despacho_control").val("1");
    $("#estado_operativo_control").val("DISPONIBLE");
    $("#codigo_estado_unidad_control").val("Nueva unidad");
    $("#unidadControlHint").addClass("d-none").text("");
}

function cambiarEstadoSolicitud(idSeguridad, accion) {
    const confirmAction = accion === "anular" ? "eliminar esta solicitud" : "continuar";
    confirmarAccionSeguridad("Confirma que deseas " + confirmAction + "?", "Si, continuar").then(function (resultado) {
        if (!confirmacionAceptadaSeguridad(resultado)) {
            return;
        }

        $.ajax({
            url: "../ajax/serviciosemergencia.php?op=" + accion,
            type: "POST",
            dataType: "json",
            data: { id_seguridad: idSeguridad },
            success: function (response) {
                if (!response || response.ok !== true) {
                    mostrarAlertaSeguridad("error", response && response.msg ? response.msg : "No se pudo actualizar el estado.");
                    return;
                }

                recargarSeccionSeguridad();
                mostrarAlertaSeguridad("success", response.msg || "Estado actualizado correctamente.");

            },
            error: function (xhr) {
                console.error("Error al cambiar estado:", xhr.responseText);
                mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor.");
            }
        });
    });
}

function abrirReporteSolicitud(idSeguridad, idReporteSolicitud) {
    const id = Number(idSeguridad || 0);
    if (!id) {
        mostrarAlertaSeguridad("warning", "No se pudo identificar la solicitud para visualizar el reporte.");
        return;
    }

    let basePath = String(window.location.pathname || "").replace(/\\/g, "/");
    const idxVistas = basePath.indexOf("/vistas/");
    if (idxVistas >= 0) {
        basePath = basePath.substring(0, idxVistas);
    } else {
        basePath = basePath.replace(/\/[^\/]*$/, "");
    }
    if (basePath === "/") {
        basePath = "";
    }

    const idReporte = Number(idReporteSolicitud || 0);
    let url = window.location.origin + basePath + "/ajax/serviciosemergencia.php?op=verreporte&id_seguridad=" + encodeURIComponent(String(id));
    if (idReporte > 0) {
        url += "&id_reporte_solicitud=" + encodeURIComponent(String(idReporte));
    }

    const win = window.open(url, "_blank");
    if (!win) {
        mostrarAlertaSeguridad("warning", "No se pudo abrir la vista del reporte. Verifica el bloqueo de ventanas emergentes.");
    }
}

function notificarBeneficiarioWhatsappManual(urlWhatsapp) {
    confirmarYAbrirWhatsappManual(urlWhatsapp, "Notificar beneficiario por WhatsApp", "");
}

function reenviarReporteChoferDesdeLista(idSeguridad, idReporteSolicitud, tipoReporte, estadoEnvio) {
    const id = Number(idSeguridad || 0);
    const idReporte = Number(idReporteSolicitud || 0);
    if (!id || !idReporte) {
        mostrarAlertaSeguridad("warning", "No se pudo identificar el reporte para reenviar al chofer.");
        return;
    }

    const tipo = String(tipoReporte || "").toUpperCase() === "CIERRE" ? "CIERRE" : "REGISTRO";
    const estado = String(estadoEnvio || "").toUpperCase();
    const yaEnviado = estado === "ENVIADO";
    const textoTipo = tipo === "CIERRE" ? "de cierre de despacho" : "de registro de solicitud";

    Swal.fire({
        icon: "question",
        title: yaEnviado ? "Reenviar reporte al chofer" : "Enviar reporte al chofer",
        text: yaEnviado
            ? "Este reporte ya fue enviado anteriormente. Deseas reenviarlo al correo del chofer?"
            : "Deseas enviar ahora el reporte " + textoTipo + " al correo del chofer?",
        showCancelButton: true,
        confirmButtonText: yaEnviado ? "Si, reenviar" : "Si, enviar",
        cancelButtonText: "Cancelar",
        allowOutsideClick: false,
        allowEscapeKey: false,
        customClass: {
            confirmButton: "btn btn-primary mr-2",
            cancelButton: "btn btn-light"
        },
        buttonsStyling: false
    }).then(function (resultado) {
        if (!confirmacionAceptadaSeguridad(resultado)) {
            return;
        }

        mostrarCapaCargaCorreoSeguridad("Enviando reporte al correo del chofer...");
        $.ajax({
            url: "../ajax/serviciosemergencia.php?op=enviarreportechofer",
            type: "POST",
            dataType: "json",
            data: {
                id_seguridad: id,
                id_reporte_solicitud: idReporte
            },
            success: function (respuesta) {
                if (!respuesta || respuesta.ok !== true) {
                    mostrarAlertaSeguridad("error", respuesta && respuesta.msg ? respuesta.msg : "No se pudo enviar el reporte al correo del chofer.");
                    return;
                }

                recargarSeccionSeguridad();
                mostrarAlertaSeguridad("success", respuesta.msg || "Reporte enviado correctamente al correo del chofer.");
            },
            error: function (xhr) {
                console.error("Error al enviar reporte al chofer desde la tabla:", xhr.responseText);
                mostrarAlertaSeguridad("error", "Error de comunicacion con el servidor al enviar el correo del chofer.");
            },
            complete: function () {
                ocultarCapaCargaCorreoSeguridad();
            }
        });
    });
}

function sugerirNotificacionWhatsappDesdeResultado(data) {
    const payload = data && data.whatsapp ? data.whatsapp : null;
    if (!payload) {
        return;
    }

    if (payload.disponible !== true) {
        if (payload.motivo) {
            mostrarAlertaSeguridad("warning", payload.motivo);
        }
        return;
    }

    confirmarYAbrirWhatsappManual(
        payload.url || "",
        payload.titulo || "Notificar beneficiario por WhatsApp",
        payload.texto || ""
    );
}

function sugerirEnvioCorreoChoferDesdeResultado() {
    return new Promise(function (resolve) {
        resolve();
    });
}

function confirmarYAbrirWhatsappManual(urlWhatsapp, titulo, textoPlantilla) {
    const url = String(urlWhatsapp || "").trim();
    if (!url) {
        mostrarAlertaSeguridad("warning", "No se pudo preparar el mensaje de WhatsApp para esta solicitud.");
        return;
    }

    const texto = String(textoPlantilla || "").trim();
    const htmlPlantilla = texto
        ? "<p class='mb-2'>Se abrira WhatsApp con este mensaje:</p><div class='text-left border rounded p-2 bg-light' style='max-height:210px;overflow:auto;font-size:.85rem;line-height:1.25;'>" + escaparHtml(texto).replace(/\n/g, "<br>") + "</div>"
        : "<p class='mb-0'>Se abrira WhatsApp con el mensaje para envio manual al beneficiario.</p>";

    Swal.fire({
        icon: "question",
        title: titulo || "Notificar beneficiario por WhatsApp",
        html: htmlPlantilla,
        showCancelButton: true,
        confirmButtonText: "Abrir WhatsApp",
        cancelButtonText: "Cancelar",
        reverseButtons: true,
        customClass: {
            confirmButton: "btn btn-success mr-2",
            cancelButton: "btn btn-light"
        },
        buttonsStyling: false
    }).then(function (resultado) {
        if (!confirmacionAceptadaSeguridad(resultado)) {
            return;
        }

        const win = window.open(url, "_blank");
        if (!win) {
            mostrarAlertaSeguridad("warning", "No se pudo abrir WhatsApp. Verifica el bloqueo de ventanas emergentes.");
        }
    });
}

function generarReporteRapidoSeguridad() {
    if (!tablaSeguridad) {
        return;
    }

    const rows = tablaSeguridad.rows({ search: "applied" }).data().toArray();
    let html = "";
    for (let i = 0; i < rows.length; i += 1) {
        html += "<tr>";
        html += "<td>" + (rows[i].beneficiario || "") + "</td>";
        html += "<td>" + extraerTextoPlano(rows[i].estado_solicitud || "") + "</td>";
        html += "<td>" + (rows[i].tipo_seguridad || "") + "</td>";
        html += "<td>" + (rows[i].tipo_solicitud || "") + "</td>";
        html += "<td>" + (rows[i].fecha_seguridad || "") + "</td>";
        html += "<td>" + (rows[i].ticket_interno || "") + "</td>";
        html += "<td>" + extraerTextoPlano(rows[i].ambulancia || "") + "</td>";
        html += "<td>" + extraerTextoPlano(rows[i].chofer || "") + "</td>";
        html += "<td>" + extraerTextoPlano(rows[i].ubicacion_evento || "") + "</td>";
        html += "<td>" + extraerTextoPlano(rows[i].telefono || "") + "</td>";
        html += "</tr>";
    }

    const win = window.open("", "_blank");
    if (!win) {
        mostrarAlertaSeguridad("warning", "No se pudo abrir la ventana de impresion.");
        return;
    }

    win.document.write(
        "<html><head><title>Reporte Seguridad y Emergencia</title><style>" +
        "body{font-family:Arial,sans-serif;padding:20px;}h1{margin:0 0 14px;}table{width:100%;border-collapse:collapse;}" +
        "th,td{border:1px solid #d6dee8;padding:8px;font-size:12px;vertical-align:top;}th{background:#eff4fa;}" +
        "</style></head><body>" +
        "<h1>Reporte de seguridad y emergencia</h1>" +
        "<p>Total visible: " + rows.length + "</p>" +
        "<table><thead><tr><th>Beneficiario</th><th>Estado solicitud</th><th>Servicio</th><th>Solicitud</th><th>Fecha</th><th>Ticket</th><th>Ambulancia</th><th>Chofer</th><th>Ubicacion</th><th>Telefono</th></tr></thead><tbody>" +
        html +
        "</tbody></table></body></html>"
    );
    win.document.close();
    win.focus();
    win.print();
}

function construirMensajeAutoAsignacion(data) {
    const unidad = data && data.unidad ? data.unidad.codigo_unidad + " / " + data.unidad.placa : "unidad no disponible";
    const chofer = data && data.chofer ? data.chofer.nombre_chofer : "chofer no disponible";
    const ticket = data && data.ticket_interno ? data.ticket_interno : "sin ticket";
    return "Solicitud guardada con despacho automatico. Ticket: " + ticket + ". Unidad: " + unidad + ". Chofer: " + chofer + ".";
}

function construirMensajeReporteComplemento(data) {
    if (!data || data.reporte_generado !== true) {
        return "";
    }

    const envio = data.envio_reporte || null;
    let extra = " Reporte generado y almacenado en el sistema.";
    if (envio && envio.estado === "ENVIADO") {
        extra += " Correo enviado al chofer.";
    } else if (envio && envio.estado === "NO_APLICA") {
        extra += " Correo no enviado (no solicitado).";
    } else if (envio && envio.estado === "ERROR" && envio.detalle) {
        extra += " " + envio.detalle;
    }
    return extra;
}

function construirMensajeResultadoConReporte(mensajeBase, data) {
    const base = mensajeBase || "Operacion completada correctamente.";
    return base + construirMensajeReporteComplemento(data);
}

function limpiarFormulariosOperativos() {
    resetFormularioChoferOperativo();
    resetFormularioControlUnidad();
}

function resetFormularioChoferOperativo() {
    if (!$("#formularioChoferOperativo").length) {
        return;
    }

    $("#formularioChoferOperativo")[0].reset();
    $("#id_empleado_operativo").removeData("pendingValue").val("").trigger("change.select2");
    $("#id_unidad_asignada_chofer").removeData("pendingValue").prop("disabled", false).val("").trigger("change.select2");
    ocultarHintChoferExistente();
    ocultarHintUnidadChoferOperativo();
    $("#licenciaVencidaHint").addClass("d-none").text("");
    $("#vencimiento_licencia").removeClass("is-invalid");
    cargarComboUnidadChoferOperativo(null, "");
}

function resetFormularioControlUnidad() {
    if (!$("#formularioControlUnidad").length) {
        return;
    }

    prepararNuevaUnidadOperativa();
    $("#buscadorUnidadesControl").val("");
    renderizarListaUnidadesControl(operativoUnidades);
}

function extraerTextoPlano(html) {
    return $("<div>").html(html).text().trim();
}

function obtenerFechaHoraActualInput() {
    const fecha = new Date();
    const mes = String(fecha.getMonth() + 1).padStart(2, "0");
    const dia = String(fecha.getDate()).padStart(2, "0");
    const horas = String(fecha.getHours()).padStart(2, "0");
    const minutos = String(fecha.getMinutes()).padStart(2, "0");
    return fecha.getFullYear() + "-" + mes + "-" + dia + "T" + horas + ":" + minutos;
}

function escaparHtml(valor) {
    return $("<div>").text(valor || "").html();
}
