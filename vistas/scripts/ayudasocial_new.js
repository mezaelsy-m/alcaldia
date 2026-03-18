let tablaAyudaSocial = null;
let estadoFormularioAyuda = null;
let reabrirAyudaTrasBeneficiario = false;

function mostrarAlertaAyuda(icono, mensaje, titulo) {
    const texto = mensaje || "Operacion completada.";
    return Swal.fire({
        icon: icono,
        title: titulo || obtenerTituloSegunIconoAyuda(icono),
        text: texto,
        confirmButtonText: "Aceptar",
        customClass: {
            confirmButton: "btn btn-primary"
        },
        buttonsStyling: false
    });
}

function confirmarAccionAyuda(mensaje) {
    return Swal.fire({
        icon: "question",
        title: "Confirmar accion",
        text: mensaje,
        showCancelButton: true,
        confirmButtonText: "Si, continuar",
        cancelButtonText: "Cancelar",
        reverseButtons: true,
        customClass: {
            confirmButton: "btn btn-primary mr-2",
            cancelButton: "btn btn-light"
        },
        buttonsStyling: false
    });
}

function obtenerTituloSegunIconoAyuda(icono) {
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

function confirmacionAceptadaAyuda(resultado) {
    return !!(resultado && (resultado.isConfirmed || resultado.value === true));
}

function formatearFechaEstadoTextoAyuda(valor) {
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

function limpiarAvisoSolicitudAtendidaAyuda() {
    $("#avisoSolicitudAtendidaAyuda").addClass("d-none");
    $("#mensajeSolicitudAtendidaAyuda").text("");
    $("#btnVerObservacionAtendidaAyuda").addClass("d-none").removeData("observacion");
}

function actualizarAvisoSolicitudAtendidaAyuda(data) {
    limpiarAvisoSolicitudAtendidaAyuda();

    if (!data || Number(data.es_atendida) !== 1) {
        return;
    }

    const fechaTexto = formatearFechaEstadoTextoAyuda(data.fecha_estado_solicitud || data.fecha_estado_solicitud_input || "");
    const mensaje = fechaTexto
        ? "De acuerdo al sistema, esta solicitud fue atendida el " + fechaTexto + "."
        : "De acuerdo al sistema, esta solicitud ya fue atendida.";
    const observacion = String(data.observacion_estado_solicitud || "").trim();

    $("#mensajeSolicitudAtendidaAyuda").text(mensaje);
    $("#avisoSolicitudAtendidaAyuda").removeClass("d-none");

    if (observacion) {
        $("#btnVerObservacionAtendidaAyuda").removeClass("d-none").data("observacion", observacion);
    }
}

function initAyudaSocial() {
    inicializarSelectBeneficiarios();
    inicializarComboComunidadesAyuda();
    inicializarComboCatalogoAyuda("#id_tipo_ayuda_social", "Busque o seleccione el tipo de ayuda");
    inicializarComboCatalogoAyuda("#id_solicitud_ayuda_social", "Busque o seleccione el tipo de solicitud");
    cargarCatalogosAyuda();
    configurarTabla();
    reubicarControlLongitudAyuda();
    configurarBuscadorListado();
    configurarEventos();
    cargarResumen();
}

function inicializarComboCatalogoAyuda(selector, placeholder) {
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
        dropdownParent: $("#ayudaSocialModal"),
        placeholder: combo.data("placeholder") || placeholder || "Seleccione una opcion",
        allowClear: true,
        minimumResultsForSearch: 0
    });
}

function inicializarSelectBeneficiarios() {
    const combo = $("#id_beneficiario");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#ayudaSocialModal"),
        placeholder: combo.data("placeholder") || "Busque o seleccione un beneficiario",
        allowClear: true,
        minimumInputLength: 0,
        ajax: {
            url: "../ajax/ayudasocial.php?op=listarbeneficiarios",
            dataType: "json",
            delay: 220,
            data: function (params) {
                return { term: params.term || "" };
            },
            processResults: function (response) {
                const items = response && Array.isArray(response.items) ? response.items : [];
                return { results: items };
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

function inicializarComboComunidadesAyuda() {
    const combo = $("#idcomunidadAyuda");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#beneficiarioAyudaModal"),
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
                const items = response && Array.isArray(response.items) ? response.items : [];
                return { results: items };
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

function cargarCatalogosAyuda() {
    cargarTiposAyuda();
    cargarSolicitudesAyuda();
}

function cargarTiposAyuda(valorSeleccionado) {
    return $.ajax({
        url: "../ajax/ayudasocial.php?op=listartiposayuda",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const combo = $("#id_tipo_ayuda_social");
        const items = response && Array.isArray(response.items) ? response.items : [];

        combo.empty().append('<option value="">Seleccione el tipo de ayuda</option>');
        for (let i = 0; i < items.length; i += 1) {
            combo.append(new Option(items[i].text, items[i].id));
        }

        if (valorSeleccionado) {
            combo.val(String(valorSeleccionado));
        }

        combo.trigger("change.select2");
    });
}

function cargarSolicitudesAyuda(valorSeleccionado) {
    return $.ajax({
        url: "../ajax/ayudasocial.php?op=listarsolicitudesayuda",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const combo = $("#id_solicitud_ayuda_social");
        const items = response && Array.isArray(response.items) ? response.items : [];

        combo.empty().append('<option value="">Seleccione el tipo de solicitud</option>');
        for (let i = 0; i < items.length; i += 1) {
            combo.append(new Option(items[i].text, items[i].id));
        }

        if (valorSeleccionado) {
            combo.val(String(valorSeleccionado));
        }

        combo.trigger("change.select2");
    });
}

function configurarTabla() {
    tablaAyudaSocial = $("#tbllistado").DataTable({
        processing: true,
        serverSide: false,
        responsive: true,
        autoWidth: false,
        destroy: true,
        searching: true,
        dom: "lrtip",
        ajax: {
            url: "../ajax/ayudasocial.php?op=listar",
            type: "GET",
            dataType: "json",
            dataSrc: function (json) {
                return json && Array.isArray(json.aaData) ? json.aaData : [];
            },
            error: function (xhr) {
                console.error("Error al cargar ayuda social:", xhr.responseText);
                mostrarAlertaAyuda("error", "No se pudo cargar el listado de ayudas sociales.");
            }
        },
        columns: [
            { data: "beneficiario" },
            { data: "tipo_ayuda" },
            { data: "solicitud_ayuda" },
            { data: "fecha_ayuda" },
            { data: "ticket_interno" },
            { data: "descripcion" },
            { data: "telefono" },
            { data: "estado_solicitud", className: "help-align-right text-nowrap" },
            { data: "acciones", orderable: false, searchable: false, className: "help-align-right text-nowrap" }
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
            search: "Buscar:",
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

function configurarBuscadorListado() {
    $("#buscadorAyudaSocial")
        .off(".ayuda")
        .on("input.ayuda search.ayuda", function () {
            if (!tablaAyudaSocial) {
                return;
            }

            tablaAyudaSocial.search($(this).val() || "").draw();
        });
}

function reubicarControlLongitudAyuda() {
    const control = $("#tbllistado_wrapper .dataTables_length");
    const contenedor = $("#ayudaSocialLengthContainer");

    if (!control.length || !contenedor.length) {
        return;
    }

    contenedor.empty().append(control);
}

function configurarEventos() {
    $("#btnNuevaAyuda").on("click", function () {
        abrirModalNuevo();
    });

    $("#btnRecargarAyuda").on("click", function () {
        recargarSeccion();
    });

    $("#btnReporteAyuda").on("click", function () {
        generarReporteRapido();
    });

    $("#btnRegistrarBeneficiarioAyuda").on("click", function () {
        abrirModalBeneficiarioDesdeAyuda();
    });

    $("#formularioAyudaSocial").on("submit", function (event) {
        event.preventDefault();
        guardarAyudaSocial();
    });

    $("#formularioBeneficiarioAyuda").on("submit", function (event) {
        event.preventDefault();
        guardarBeneficiarioDesdeAyuda();
    });

    $("#formularioEstadoSolicitudAyuda").on("submit", function (event) {
        event.preventDefault();
        guardarEstadoSolicitudAyuda();
    });

    $("#btnVerObservacionAtendidaAyuda").on("click", function () {
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

    $("#tbllistado").on("click", ".js-editar", function () {
        const id = $(this).data("id");
        mostrarAyudaSocial(id);
    });

    $("#tbllistado").on("click", ".js-gestionar-estado", function () {
        abrirModalEstadoSolicitudAyuda($(this).data("id"));
    });

    $("#tbllistado").on("click", ".js-eliminar", function () {
        cambiarEstadoAyuda($(this).data("id"), "desactivar", "eliminar");
    });

    $("#beneficiarioAyudaModal").on("hidden.bs.modal", function () {
        limpiarFormularioBeneficiarioAyuda();

        if (reabrirAyudaTrasBeneficiario) {
            reabrirAyudaTrasBeneficiario = false;
            restaurarFormularioAyuda();
            $("#ayudaSocialModal").modal("show");
        }
    });

    $("#estadoSolicitudAyudaModal").on("hidden.bs.modal", function () {
        limpiarFormularioEstadoAyuda();
    });
}

function abrirModalNuevo() {
    limpiarFormulario();
    $("#fecha_ayuda").val(obtenerFechaActual());
    $("#ayudaSocialModalLabel").text("Registrar solicitud de ayuda");
    $("#ayudaSocialModal").modal("show");
}

function mostrarAyudaSocial(idAyuda) {
    $.ajax({
        url: "../ajax/ayudasocial.php?op=mostrar",
        type: "POST",
        dataType: "json",
        data: { idayuda: idAyuda },
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaAyuda("error", response && response.msg ? response.msg : "No se pudo cargar la solicitud.");
                return;
            }

            const data = response.data;
            $.when(
                cargarTiposAyuda(data.id_tipo_ayuda_social),
                cargarSolicitudesAyuda(data.id_solicitud_ayuda_social)
            ).always(function () {
                $("#idayuda").val(data.id_ayuda);
                $("#fecha_ayuda").val(data.fecha_ayuda || "");
                $("#ticket_interno").val(data.ticket_interno || "");
                $("#descripcion").val(data.descripcion || "");
                seleccionarBeneficiario(data.id_beneficiario, data.beneficiario);

                $("#ayudaSocialModalLabel").text("Editar solicitud de ayuda");
                $("#ayudaSocialModal").modal("show");
            });
        },
        error: function (xhr) {
            console.error("Error al consultar ayuda social:", xhr.responseText);
            mostrarAlertaAyuda("error", "No se pudo consultar la solicitud.");
        }
    });
}

function guardarAyudaSocial() {
    const btnGuardar = $("#btnGuardarAyuda");
    btnGuardar.prop("disabled", true);

    const formData = new FormData(document.getElementById("formularioAyudaSocial"));

    $.ajax({
        url: "../ajax/ayudasocial.php?op=guardaryeditar",
        type: "POST",
        data: formData,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (response && response.ok === true) {
                $("#ayudaSocialModal").modal("hide");
                limpiarFormulario();
                recargarSeccion();
                mostrarAlertaAyuda("success", response.msg || "Operacion realizada correctamente.");
            } else {
                mostrarAlertaAyuda("error", response && response.msg ? response.msg : "No se pudo guardar la solicitud.");
            }
        },
        error: function (xhr) {
            console.error("Error al guardar ayuda social:", xhr.responseText);
            mostrarAlertaAyuda("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function cargarEstadosSolicitudAyuda(valorSeleccionado) {
    return $.ajax({
        url: "../ajax/ayudasocial.php?op=listarestadossolicitud",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const combo = $("#id_estado_solicitud_ayuda");
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

function abrirModalEstadoSolicitudAyuda(idAyuda) {
    $.ajax({
        url: "../ajax/ayudasocial.php?op=mostrar",
        type: "POST",
        dataType: "json",
        data: { idayuda: idAyuda },
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaAyuda("error", response && response.msg ? response.msg : "No se pudo cargar la solicitud.");
                return;
            }

            const data = response.data;
            cargarEstadosSolicitudAyuda(data.id_estado_solicitud).always(function () {
                $("#id_ayuda_estado").val(data.id_ayuda || "");
                $("#ticket_interno_estado_ayuda").val(data.ticket_interno || "");
                $("#estado_actual_ayuda").val(data.estado_solicitud || "");
                $("#fecha_estado_solicitud_ayuda").val(data.fecha_estado_solicitud_input || obtenerFechaHoraActualAyuda());
                $("#observacion_estado_solicitud_ayuda").val(data.observacion_estado_solicitud || "");
                actualizarAvisoSolicitudAtendidaAyuda(data);
                $("#estadoSolicitudAyudaModal").modal("show");
            });
        },
        error: function (xhr) {
            console.error("Error al cargar estado de ayuda social:", xhr.responseText);
            mostrarAlertaAyuda("error", "No se pudo preparar la gestion del estado.");
        }
    });
}

function guardarEstadoSolicitudAyuda() {
    const btnGuardar = $("#btnGuardarEstadoAyuda");
    btnGuardar.prop("disabled", true);

    const formData = new FormData(document.getElementById("formularioEstadoSolicitudAyuda"));
    $.ajax({
        url: "../ajax/ayudasocial.php?op=actualizarestadosolicitud",
        type: "POST",
        data: formData,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaAyuda("error", response && response.msg ? response.msg : "No se pudo actualizar el estado de la solicitud.");
                return;
            }

            limpiarFormularioEstadoAyuda();
            $("#estadoSolicitudAyudaModal").modal("hide");
            recargarSeccion();
            mostrarAlertaAyuda("success", response.msg || "Estado de solicitud actualizado correctamente.");
        },
        error: function (xhr) {
            console.error("Error al guardar estado de ayuda social:", xhr.responseText);
            mostrarAlertaAyuda("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function abrirModalBeneficiarioDesdeAyuda() {
    estadoFormularioAyuda = obtenerEstadoFormularioAyuda();
    reabrirAyudaTrasBeneficiario = true;
    limpiarFormularioBeneficiarioAyuda();
    $("#ayudaSocialModal").modal("hide");

    setTimeout(function () {
        $("#beneficiarioAyudaModal").modal("show");
    }, 180);
}

function guardarBeneficiarioDesdeAyuda() {
    const btnGuardar = $("#btnGuardarBeneficiarioAyuda");
    btnGuardar.prop("disabled", true);

    const formData = new FormData(document.getElementById("formularioBeneficiarioAyuda"));

    $.ajax({
        url: "../ajax/beneficiarios.php?op=guardaryeditar",
        type: "POST",
        data: formData,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data || !response.data.id_beneficiario) {
                mostrarAlertaAyuda("error", response && response.msg ? response.msg : "No se pudo registrar el beneficiario.");
                return;
            }

            if (!estadoFormularioAyuda) {
                estadoFormularioAyuda = obtenerEstadoFormularioAyuda();
            }

            estadoFormularioAyuda.id_beneficiario = String(response.data.id_beneficiario);
            estadoFormularioAyuda.texto_beneficiario = response.data.beneficiario || construirTextoBeneficiarioDesdeFormulario();

            if (response.data.existente === true) {
                mostrarAlertaAyuda("success", response.msg || "El beneficiario ya existia y fue seleccionado.");
            } else {
                mostrarAlertaAyuda("success", response.msg || "Beneficiario registrado correctamente.");
            }

            limpiarFormularioBeneficiarioAyuda();
            $("#beneficiarioAyudaModal").modal("hide");
        },
        error: function (xhr) {
            console.error("Error al guardar beneficiario desde ayuda:", xhr.responseText);
            mostrarAlertaAyuda("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function cambiarEstadoAyuda(idAyuda, operacion, accionTexto) {
    confirmarAccionAyuda("Confirma que deseas " + accionTexto + " esta solicitud?").then(function (resultado) {
        if (!confirmacionAceptadaAyuda(resultado)) {
            return;
        }

        $.ajax({
            url: "../ajax/ayudasocial.php?op=" + operacion,
            type: "POST",
            dataType: "json",
            data: { idayuda: idAyuda },
            success: function (response) {
                if (response && response.ok === true) {
                    recargarSeccion();
                    mostrarAlertaAyuda("success", response.msg || "Operacion aplicada correctamente.");
                } else {
                    mostrarAlertaAyuda("error", response && response.msg ? response.msg : "No se pudo actualizar el estado.");
                }
            },
            error: function (xhr) {
                console.error("Error al cambiar estado:", xhr.responseText);
                mostrarAlertaAyuda("error", "Error de comunicacion con el servidor.");
            }
        });
    });
}

function cargarResumen() {
    $.ajax({
        url: "../ajax/ayudasocial.php?op=resumen",
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                return;
            }

            $("#totalSolicitudesAyuda").text(response.data.total || 0);
            $("#totalAtendidasAyuda").text(response.data.atendidas || 0);
            $("#totalPendientesAyuda").text(response.data.no_atendidas || 0);
        },
        error: function (xhr) {
            console.error("Error al cargar resumen de ayuda social:", xhr.responseText);
        }
    });
}

function recargarSeccion() {
    if (tablaAyudaSocial) {
        tablaAyudaSocial.ajax.reload(null, false);
    }
    cargarResumen();
}

function limpiarFormulario() {
    $("#idayuda").val("");
    $("#id_tipo_ayuda_social").val("");
    $("#id_solicitud_ayuda_social").val("");
    $("#fecha_ayuda").val("");
    $("#ticket_interno").val("");
    $("#descripcion").val("");
    $("#id_beneficiario").val(null).trigger("change");
    estadoFormularioAyuda = null;
}

function limpiarFormularioEstadoAyuda() {
    $("#id_ayuda_estado").val("");
    $("#ticket_interno_estado_ayuda").val("");
    $("#estado_actual_ayuda").val("");
    $("#id_estado_solicitud_ayuda").val("");
    $("#fecha_estado_solicitud_ayuda").val("");
    $("#observacion_estado_solicitud_ayuda").val("");
    limpiarAvisoSolicitudAtendidaAyuda();
}

function limpiarFormularioBeneficiarioAyuda() {
    $("#idbeneficiariosAyuda").val("");
    $("#nacionalidadAyuda").val("");
    $("#cedulaAyuda").val("");
    $("#telefonoAyuda").val("");
    $("#nombrebeneficiarioAyuda").val("");
    $("#idcomunidadAyuda").val(null).trigger("change");
}

function obtenerEstadoFormularioAyuda() {
    const combo = $("#id_beneficiario");
    const opcion = combo.find("option:selected");

    return {
        idayuda: $("#idayuda").val() || "",
        id_beneficiario: combo.val() || "",
        texto_beneficiario: opcion.length ? opcion.text() : "",
        id_tipo_ayuda_social: $("#id_tipo_ayuda_social").val() || "",
        id_solicitud_ayuda_social: $("#id_solicitud_ayuda_social").val() || "",
        fecha_ayuda: $("#fecha_ayuda").val() || "",
        ticket_interno: $("#ticket_interno").val() || "",
        descripcion: $("#descripcion").val() || ""
    };
}

function restaurarFormularioAyuda() {
    if (!estadoFormularioAyuda) {
        return;
    }

    $("#idayuda").val(estadoFormularioAyuda.idayuda || "");
    $("#id_tipo_ayuda_social").val(estadoFormularioAyuda.id_tipo_ayuda_social || "");
    $("#id_solicitud_ayuda_social").val(estadoFormularioAyuda.id_solicitud_ayuda_social || "");
    $("#fecha_ayuda").val(estadoFormularioAyuda.fecha_ayuda || "");
    $("#ticket_interno").val(estadoFormularioAyuda.ticket_interno || "");
    $("#descripcion").val(estadoFormularioAyuda.descripcion || "");

    if (estadoFormularioAyuda.id_beneficiario) {
        seleccionarBeneficiario(estadoFormularioAyuda.id_beneficiario, estadoFormularioAyuda.texto_beneficiario);
    }
}

function seleccionarBeneficiario(idBeneficiario, textoBeneficiario) {
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

function construirTextoBeneficiarioDesdeFormulario() {
    const nacionalidad = $("#nacionalidadAyuda").val() || "";
    const cedula = $("#cedulaAyuda").val() || "";
    const nombre = $("#nombrebeneficiarioAyuda").val() || "";
    return (nacionalidad ? nacionalidad + "-" : "") + cedula + (nombre ? " " + nombre : "");
}

function generarReporteRapido() {
    if (!tablaAyudaSocial) {
        return;
    }

    const rows = tablaAyudaSocial.rows({ search: "applied" }).data().toArray();
    let cuerpoTabla = "";

    for (let i = 0; i < rows.length; i += 1) {
        cuerpoTabla += "<tr>";
        cuerpoTabla += "<td>" + escaparHtmlReporteAyuda(extraerTextoPlano(rows[i].beneficiario || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteAyuda(extraerTextoPlano(rows[i].tipo_ayuda || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteAyuda(extraerTextoPlano(rows[i].solicitud_ayuda || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteAyuda(extraerTextoPlano(rows[i].fecha_ayuda || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteAyuda(extraerTextoPlano(rows[i].ticket_interno || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteAyuda(extraerTextoPlano(rows[i].descripcion || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteAyuda(extraerTextoPlano(rows[i].telefono || "")) + "</td>";
        cuerpoTabla += "</tr>";
    }

    if (cuerpoTabla === "") {
        cuerpoTabla = '<tr><td colspan="7" class="reporte-vacio">No hay registros visibles para imprimir.</td></tr>';
    }

    const win = window.open("", "_blank");
    if (!win) {
        mostrarAlertaAyuda("warning", "No se pudo abrir la ventana de impresion.");
        return;
    }

    const contexto = obtenerContextoReporteAyuda();
    win.document.write(
        "<html><head><title>Reporte Ayuda Social</title><style>" + obtenerEstilosReporteAyuda() + "</style></head><body>" +
        '<main class="reporte-doc">' +
        '<header class="reporte-header">' +
        '<div class="reporte-logo"><img src="' + contexto.logo + '" alt="Logo institucional" onerror="this.style.display=\'none\'"></div>' +
        '<div class="reporte-titulo">' +
        '<span class="reporte-linea">' + contexto.institucion + "</span>" +
        '<span class="reporte-linea">' + contexto.sistema + "</span>" +
        "<h1>Reporte rapido de ayuda social</h1>" +
        "</div>" +
        "</header>" +
        '<section class="reporte-meta">' +
        '<div class="reporte-meta-item"><span>Fecha</span><strong>' + contexto.fecha + "</strong></div>" +
        '<div class="reporte-meta-item"><span>Hora</span><strong>' + contexto.hora + "</strong></div>" +
        '<div class="reporte-meta-item"><span>Generado por</span><strong>' + contexto.usuario + "</strong></div>" +
        '<div class="reporte-meta-item"><span>Total visible</span><strong>' + rows.length + "</strong></div>" +
        "</section>" +
        '<section class="reporte-tabla"><table><thead><tr><th>Beneficiario</th><th>Tipo</th><th>Solicitud</th><th>Fecha</th><th>Ticket interno</th><th>Descripcion</th><th>Telefono</th></tr></thead><tbody>' +
        cuerpoTabla +
        "</tbody></table></section>" +
        '<footer class="reporte-footer">Documento generado automaticamente por el sistema.</footer>' +
        "</main>" +
        "</body></html>"
    );
    win.document.close();
    win.onload = function () {
        win.focus();
        win.print();
    };
}

function obtenerContextoReporteAyuda() {
    const ahora = new Date();
    const ruta = window.location.pathname || "";
    const indiceVistas = ruta.indexOf("/vistas/");
    const base = indiceVistas >= 0 ? ruta.substring(0, indiceVistas) : "";
    const institucion = $(".header-brand-copy span").first().text().trim() || "Alcaldia Municipal";
    const sistema = $(".header-brand-copy strong").first().text().trim() || "Sala Situacional";
    const usuario = $(".header-user-chip span").last().text().trim() || "Usuario del sistema";

    return {
        logo: window.location.origin + base + "/assets/images/logo_login.png",
        institucion: escaparHtmlReporteAyuda(institucion),
        sistema: escaparHtmlReporteAyuda(sistema),
        usuario: escaparHtmlReporteAyuda(usuario),
        fecha: escaparHtmlReporteAyuda(ahora.toLocaleDateString("es-VE")),
        hora: escaparHtmlReporteAyuda(ahora.toLocaleTimeString("es-VE", { hour: "2-digit", minute: "2-digit" }))
    };
}

function obtenerEstilosReporteAyuda() {
    return "body{font-family:'Segoe UI',Tahoma,Arial,sans-serif;background:#f4f7fb;color:#1f2d3d;margin:0;padding:24px;}" +
        ".reporte-doc{max-width:1260px;margin:0 auto;background:#fff;border:1px solid #dce5f2;border-radius:14px;overflow:hidden;}" +
        ".reporte-header{display:flex;gap:16px;align-items:center;padding:18px 22px;background:linear-gradient(120deg,#f8fbff,#edf4ff);border-bottom:2px solid #dce8fb;}" +
        ".reporte-logo{width:74px;height:74px;border:1px solid #d9e3f2;border-radius:12px;background:#fff;display:flex;align-items:center;justify-content:center;overflow:hidden;flex-shrink:0;}" +
        ".reporte-logo img{max-width:100%;max-height:100%;}" +
        ".reporte-linea{display:block;font-size:12px;color:#5e6e86;line-height:1.35;}" +
        ".reporte-titulo h1{margin:6px 0 0;font-size:20px;line-height:1.2;color:#1d2a3f;}" +
        ".reporte-meta{display:grid;grid-template-columns:repeat(4,minmax(120px,1fr));gap:10px;padding:14px 22px;background:#fff;border-bottom:1px solid #e6edf8;}" +
        ".reporte-meta-item{border:1px solid #e2eaf6;border-radius:10px;padding:8px 10px;background:#f9fbff;}" +
        ".reporte-meta-item span{display:block;font-size:11px;color:#677a95;text-transform:uppercase;letter-spacing:.04em;}" +
        ".reporte-meta-item strong{display:block;font-size:13px;color:#1f2d3d;margin-top:3px;}" +
        ".reporte-tabla{padding:14px 22px 8px;}" +
        ".reporte-tabla table{width:100%;border-collapse:collapse;}" +
        ".reporte-tabla th,.reporte-tabla td{border:1px solid #d7e1ef;padding:8px;font-size:12px;vertical-align:top;text-align:left;}" +
        ".reporte-tabla th{background:#eef4fd;color:#21324b;font-weight:600;}" +
        ".reporte-vacio{text-align:center;font-style:italic;color:#7a879b;}" +
        ".reporte-footer{padding:10px 22px 16px;font-size:11px;color:#71829d;}" +
        "@media print{body{background:#fff;padding:0;} .reporte-doc{border:none;border-radius:0;}}";
}

function escaparHtmlReporteAyuda(valor) {
    return $("<div>").text(valor || "").html();
}

function obtenerFechaHoraActualAyuda() {
    const ahora = new Date();
    const anio = ahora.getFullYear();
    const mes = String(ahora.getMonth() + 1).padStart(2, "0");
    const dia = String(ahora.getDate()).padStart(2, "0");
    const horas = String(ahora.getHours()).padStart(2, "0");
    const minutos = String(ahora.getMinutes()).padStart(2, "0");
    return anio + "-" + mes + "-" + dia + "T" + horas + ":" + minutos;
}

function extraerTextoPlano(html) {
    return $("<div>").html(html).text().trim();
}

function obtenerFechaActual() {
    const fecha = new Date();
    const mes = String(fecha.getMonth() + 1).padStart(2, "0");
    const dia = String(fecha.getDate()).padStart(2, "0");
    return fecha.getFullYear() + "-" + mes + "-" + dia;
}

$(document).ready(function () {
    initAyudaSocial();
});
