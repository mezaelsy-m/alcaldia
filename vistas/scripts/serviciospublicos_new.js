let tablaServiciosPublicos = null;
let estadoFormularioServiciosPublicos = null;
let reabrirServiciosPublicosTrasBeneficiario = false;

function mostrarAlertaServiciosPublicos(icono, mensaje, titulo) {
    return Swal.fire({
        icon: icono,
        title: titulo || obtenerTituloSegunIconoServiciosPublicos(icono),
        text: mensaje || "Operacion completada.",
        confirmButtonText: "Aceptar",
        customClass: {
            confirmButton: "btn btn-primary"
        },
        buttonsStyling: false
    });
}

function confirmarAccionServiciosPublicos(mensaje) {
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

function obtenerTituloSegunIconoServiciosPublicos(icono) {
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

function confirmacionAceptadaServiciosPublicos(resultado) {
    return !!(resultado && (resultado.isConfirmed || resultado.value === true));
}

function formatearFechaEstadoTextoServiciosPublicos(valor) {
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

function limpiarAvisoSolicitudAtendidaServicio() {
    $("#avisoSolicitudAtendidaServicio").addClass("d-none");
    $("#mensajeSolicitudAtendidaServicio").text("");
}

function actualizarAvisoSolicitudAtendidaServicio(data) {
    limpiarAvisoSolicitudAtendidaServicio();

    if (!data || Number(data.es_atendida) !== 1) {
        return;
    }

    const fechaTexto = formatearFechaEstadoTextoServiciosPublicos(data.fecha_estado_solicitud || data.fecha_estado_solicitud_input || "");
    const mensaje = fechaTexto
        ? "De acuerdo al sistema, esta solicitud fue atendida el " + fechaTexto + "."
        : "De acuerdo al sistema, esta solicitud ya fue atendida.";
    const observacion = String(data.observacion_estado_solicitud || "").trim();

    $("#mensajeSolicitudAtendidaServicio").text(mensaje);
    $("#avisoSolicitudAtendidaServicio").removeClass("d-none");

   
}

function initServiciosPublicos() {
    inicializarSelectBeneficiariosServiciosPublicos();
    inicializarComboComunidadesServiciosPublicos();
    inicializarSelectTipoServicioPublico();
    inicializarSelectSolicitudServicioPublico();
    configurarTablaServiciosPublicos();
    configurarBuscadorServiciosPublicos();
    configurarEventosServiciosPublicos();
    cargarResumenServiciosPublicos();
}

function inicializarSelectBeneficiariosServiciosPublicos() {
    const combo = $("#id_beneficiario");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#servicioPublicoModal"),
        placeholder: combo.data("placeholder") || "Busque por cedula o nombre del beneficiario",
        allowClear: true,
        minimumInputLength: 0,
        ajax: {
            url: "../ajax/serviciospublicos.php?op=listarbeneficiarios",
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

function inicializarComboComunidadesServiciosPublicos() {
    const combo = $("#idcomunidadServiciosPublicos");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#beneficiarioServiciosPublicosModal"),
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

function inicializarSelectTipoServicioPublico() {
    const combo = $("#id_tipo_servicio_publico");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#servicioPublicoModal"),
        placeholder: combo.data("placeholder") || "Busque por codigo o nombre del servicio",
        allowClear: true,
        minimumInputLength: 0,
        ajax: {
            url: "../ajax/serviciospublicos.php?op=listartiposserviciospublicos",
            dataType: "json",
            delay: 180,
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
                return "Escribe para buscar servicios";
            },
            noResults: function () {
                return "No se encontraron servicios";
            },
            searching: function () {
                return "Buscando...";
            }
        }
    });
}

function inicializarSelectSolicitudServicioPublico() {
    const combo = $("#id_solicitud_servicio_publico");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#servicioPublicoModal"),
        placeholder: combo.data("placeholder") || "Busque por codigo o nombre del canal",
        allowClear: true,
        minimumInputLength: 0,
        ajax: {
            url: "../ajax/serviciospublicos.php?op=listarsolicitudesserviciospublicos",
            dataType: "json",
            delay: 180,
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
                return "Escribe para buscar solicitudes";
            },
            noResults: function () {
                return "No se encontraron solicitudes";
            },
            searching: function () {
                return "Buscando...";
            }
        }
    });
}

function configurarTablaServiciosPublicos() {
    tablaServiciosPublicos = $("#tbllistado").DataTable({
        processing: true,
        serverSide: false,
        responsive: true,
        autoWidth: false,
        destroy: true,
        searching: true,
        dom: "lrtip",
        ajax: {
            url: "../ajax/serviciospublicos.php?op=listar",
            type: "GET",
            dataType: "json",
            dataSrc: function (json) {
                return json && Array.isArray(json.aaData) ? json.aaData : [];
            },
            error: function (xhr) {
                console.error("Error al cargar servicios publicos:", xhr.responseText);
                mostrarAlertaServiciosPublicos("error", "No se pudo cargar el listado de servicios publicos.");
            }
        },
        columns: [
            { data: "beneficiario" },
            { data: "tipo_servicio" },
            { data: "solicitud_servicio" },
            { data: "fecha_servicio" },
            { data: "ticket_interno" },
            { data: "descripcion" },
            { data: "telefono" },
            { data: "estado_solicitud", className: "public-service-align-right text-nowrap" },
            { data: "acciones", orderable: false, searchable: false, className: "public-service-align-right text-nowrap" }
        ],
        order: [],
        pageLength: 10,
        initComplete: function () {
            reubicarControlLongitudServiciosPublicos();
        },
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

function configurarBuscadorServiciosPublicos() {
    $("#buscadorServiciosPublicos")
        .off(".serviciospublicos")
        .on("input.serviciospublicos search.serviciospublicos", function () {
            if (!tablaServiciosPublicos) {
                return;
            }

            tablaServiciosPublicos.search($(this).val() || "").draw();
        });
}

function reubicarControlLongitudServiciosPublicos() {
    const control = $("#tbllistado_wrapper .dataTables_length");
    const contenedor = $("#serviciosPublicosLengthContainer");

    if (!control.length || !contenedor.length) {
        return;
    }

    contenedor.empty().append(control);
}

function configurarEventosServiciosPublicos() {
    $("#btnNuevoServicioPublico").on("click", function () {
        abrirModalNuevoServicioPublico();
    });

    $("#btnRecargarServiciosPublicos").on("click", function () {
        recargarSeccionServiciosPublicos();
    });

    $("#btnReporteServiciosPublicos").on("click", function () {
        generarReporteRapidoServiciosPublicos();
    });

    $("#btnRegistrarBeneficiarioServiciosPublicos").on("click", function () {
        abrirModalBeneficiarioDesdeServiciosPublicos();
    });

    $("#formularioServicioPublico").on("submit", function (event) {
        event.preventDefault();
        guardarServicioPublico();
    });

    $("#formularioBeneficiarioServiciosPublicos").on("submit", function (event) {
        event.preventDefault();
        guardarBeneficiarioDesdeServiciosPublicos();
    });

    $("#formularioEstadoSolicitudServicio").on("submit", function (event) {
        event.preventDefault();
        guardarEstadoSolicitudServicio();
    });

   

    $("#tbllistado").on("click", ".js-editar", function () {
        const id = $(this).data("id");
        mostrarServicioPublico(id);
    });

    $("#tbllistado").on("click", ".js-gestionar-estado", function () {
        abrirModalEstadoSolicitudServicio($(this).data("id"));
    });

    $("#tbllistado").on("click", ".js-eliminar", function () {
        cambiarEstadoServicioPublico($(this).data("id"), "desactivar", "eliminar");
    });

    $("#beneficiarioServiciosPublicosModal").on("hidden.bs.modal", function () {
        limpiarFormularioBeneficiarioServiciosPublicos();

        if (reabrirServiciosPublicosTrasBeneficiario) {
            reabrirServiciosPublicosTrasBeneficiario = false;
            restaurarFormularioServiciosPublicos();
            $("#servicioPublicoModal").modal("show");
        }
    });

    $("#estadoSolicitudServicioModal").on("hidden.bs.modal", function () {
        limpiarFormularioEstadoServicio();
    });
}

function abrirModalNuevoServicioPublico() {
    limpiarFormularioServicioPublico();
    $("#fecha_servicio").val(obtenerFechaActualServiciosPublicos());
    $("#servicioPublicoModalLabel").text("Registrar solicitud de servicio publico");
    $("#servicioPublicoModal").modal("show");
}

function mostrarServicioPublico(idServicio) {
    $.ajax({
        url: "../ajax/serviciospublicos.php?op=mostrar",
        type: "POST",
        dataType: "json",
        data: { id_servicio: idServicio },
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaServiciosPublicos("error", response && response.msg ? response.msg : "No se pudo cargar la solicitud.");
                return;
            }

            const data = response.data;
            $("#id_servicio").val(data.id_servicio || "");
            $("#fecha_servicio").val(data.fecha_servicio || "");
            $("#ticket_interno").val(data.ticket_interno || "");
            $("#descripcion").val(data.descripcion || "");

            seleccionarOpcionRemota("#id_beneficiario", data.id_beneficiario, data.beneficiario);
            seleccionarOpcionRemota("#id_tipo_servicio_publico", data.id_tipo_servicio_publico, data.tipo_servicio_texto);
            seleccionarOpcionRemota("#id_solicitud_servicio_publico", data.id_solicitud_servicio_publico, data.solicitud_servicio_texto);

            $("#servicioPublicoModalLabel").text("Editar solicitud de servicio publico");
            $("#servicioPublicoModal").modal("show");
        },
        error: function (xhr) {
            console.error("Error al consultar servicios publicos:", xhr.responseText);
            mostrarAlertaServiciosPublicos("error", "No se pudo consultar la solicitud.");
        }
    });
}

function guardarServicioPublico() {
    const btnGuardar = $("#btnGuardarServicioPublico");
    btnGuardar.prop("disabled", true);

    const formData = new FormData(document.getElementById("formularioServicioPublico"));

    $.ajax({
        url: "../ajax/serviciospublicos.php?op=guardaryeditar",
        type: "POST",
        data: formData,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (response && response.ok === true) {
                $("#servicioPublicoModal").modal("hide");
                limpiarFormularioServicioPublico();
                recargarSeccionServiciosPublicos();
                mostrarAlertaServiciosPublicos("success", response.msg || "Operacion realizada correctamente.");
                return;
            }

            mostrarAlertaServiciosPublicos("error", response && response.msg ? response.msg : "No se pudo guardar la solicitud.");
        },
        error: function (xhr) {
            console.error("Error al guardar servicios publicos:", xhr.responseText);
            mostrarAlertaServiciosPublicos("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function cargarEstadosSolicitudServicio(valorSeleccionado) {
    return $.ajax({
        url: "../ajax/serviciospublicos.php?op=listarestadossolicitud",
        type: "GET",
        dataType: "json"
    }).done(function (response) {
        const combo = $("#id_estado_solicitud_servicio");
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

function abrirModalEstadoSolicitudServicio(idServicio) {
    $.ajax({
        url: "../ajax/serviciospublicos.php?op=mostrar",
        type: "POST",
        dataType: "json",
        data: { id_servicio: idServicio },
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaServiciosPublicos("error", response && response.msg ? response.msg : "No se pudo cargar la solicitud.");
                return;
            }

            const data = response.data;
            cargarEstadosSolicitudServicio(data.id_estado_solicitud).always(function () {
                $("#id_servicio_estado").val(data.id_servicio || "");
                $("#ticket_interno_estado_servicio").val(data.ticket_interno || "");
                $("#estado_actual_servicio").val(data.estado_solicitud || "");
                $("#fecha_estado_solicitud_servicio").val(data.fecha_estado_solicitud_input || obtenerFechaHoraActualServiciosPublicos());
                $("#observacion_estado_solicitud_servicio").val(data.observacion_estado_solicitud || "");
                actualizarAvisoSolicitudAtendidaServicio(data);
                $("#estadoSolicitudServicioModal").modal("show");
            });
        },
        error: function (xhr) {
            console.error("Error al cargar estado de servicios publicos:", xhr.responseText);
            mostrarAlertaServiciosPublicos("error", "No se pudo preparar la gestion del estado.");
        }
    });
}

function guardarEstadoSolicitudServicio() {
    const btnGuardar = $("#btnGuardarEstadoServicio");
    btnGuardar.prop("disabled", true);

    const formData = new FormData(document.getElementById("formularioEstadoSolicitudServicio"));
    $.ajax({
        url: "../ajax/serviciospublicos.php?op=actualizarestadosolicitud",
        type: "POST",
        data: formData,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true) {
                mostrarAlertaServiciosPublicos("error", response && response.msg ? response.msg : "No se pudo actualizar el estado de la solicitud.");
                return;
            }

            $("#estadoSolicitudServicioModal").modal("hide");
            recargarSeccionServiciosPublicos();
            mostrarAlertaServiciosPublicos("success", response.msg || "Estado de solicitud actualizado correctamente.");
        },
        error: function (xhr) {
            console.error("Error al guardar estado de servicios publicos:", xhr.responseText);
            mostrarAlertaServiciosPublicos("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function abrirModalBeneficiarioDesdeServiciosPublicos() {
    estadoFormularioServiciosPublicos = obtenerEstadoFormularioServiciosPublicos();
    reabrirServiciosPublicosTrasBeneficiario = true;
    limpiarFormularioBeneficiarioServiciosPublicos();
    $("#servicioPublicoModal").modal("hide");

    setTimeout(function () {
        $("#beneficiarioServiciosPublicosModal").modal("show");
    }, 180);
}

function guardarBeneficiarioDesdeServiciosPublicos() {
    const btnGuardar = $("#btnGuardarBeneficiarioServiciosPublicos");
    btnGuardar.prop("disabled", true);

    const formData = new FormData(document.getElementById("formularioBeneficiarioServiciosPublicos"));

    $.ajax({
        url: "../ajax/beneficiarios.php?op=guardaryeditar",
        type: "POST",
        data: formData,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data || !response.data.id_beneficiario) {
                mostrarAlertaServiciosPublicos("error", response && response.msg ? response.msg : "No se pudo registrar el beneficiario.");
                return;
            }

            if (!estadoFormularioServiciosPublicos) {
                estadoFormularioServiciosPublicos = obtenerEstadoFormularioServiciosPublicos();
            }

            estadoFormularioServiciosPublicos.id_beneficiario = String(response.data.id_beneficiario);
            estadoFormularioServiciosPublicos.texto_beneficiario = response.data.beneficiario || construirTextoBeneficiarioServiciosPublicos();

            if (response.data.existente === true) {
                mostrarAlertaServiciosPublicos("success", response.msg || "El beneficiario ya existia y fue seleccionado.");
            } else {
                mostrarAlertaServiciosPublicos("success", response.msg || "Beneficiario registrado correctamente.");
            }

            $("#beneficiarioServiciosPublicosModal").modal("hide");
        },
        error: function (xhr) {
            console.error("Error al guardar beneficiario desde servicios publicos:", xhr.responseText);
            mostrarAlertaServiciosPublicos("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function cambiarEstadoServicioPublico(idServicio, operacion, accionTexto) {
    confirmarAccionServiciosPublicos("Confirma que deseas " + accionTexto + " esta solicitud?").then(function (resultado) {
        if (!confirmacionAceptadaServiciosPublicos(resultado)) {
            return;
        }

        $.ajax({
            url: "../ajax/serviciospublicos.php?op=" + operacion,
            type: "POST",
            dataType: "json",
            data: { id_servicio: idServicio },
            success: function (response) {
                if (response && response.ok === true) {
                    recargarSeccionServiciosPublicos();
                    mostrarAlertaServiciosPublicos("success", response.msg || "Operacion aplicada correctamente.");
                    return;
                }

                mostrarAlertaServiciosPublicos("error", response && response.msg ? response.msg : "No se pudo actualizar el estado.");
            },
            error: function (xhr) {
                console.error("Error al cambiar estado en servicios publicos:", xhr.responseText);
                mostrarAlertaServiciosPublicos("error", "Error de comunicacion con el servidor.");
            }
        });
    });
}

function cargarResumenServiciosPublicos() {
    $.ajax({
        url: "../ajax/serviciospublicos.php?op=resumen",
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                return;
            }

            $("#totalServiciosPublicos").text(response.data.total || 0);
            $("#totalServiciosAtendidos").text(response.data.atendidas || 0);
            $("#totalServiciosPendientes").text(response.data.pendientes || 0);
        },
        error: function (xhr) {
            console.error("Error al cargar resumen de servicios publicos:", xhr.responseText);
        }
    });
}

function recargarSeccionServiciosPublicos() {
    if (tablaServiciosPublicos) {
        tablaServiciosPublicos.ajax.reload(null, false);
    }
    cargarResumenServiciosPublicos();
}

function limpiarFormularioServicioPublico() {
    $("#id_servicio").val("");
    $("#fecha_servicio").val("");
    $("#ticket_interno").val("");
    $("#descripcion").val("");
    limpiarSelect2Remoto("#id_beneficiario");
    limpiarSelect2Remoto("#id_tipo_servicio_publico");
    limpiarSelect2Remoto("#id_solicitud_servicio_publico");
    estadoFormularioServiciosPublicos = null;
}

function limpiarFormularioEstadoServicio() {
    $("#id_servicio_estado").val("");
    $("#ticket_interno_estado_servicio").val("");
    $("#estado_actual_servicio").val("");
    $("#id_estado_solicitud_servicio").val("");
    $("#fecha_estado_solicitud_servicio").val("");
    $("#observacion_estado_solicitud_servicio").val("");
    limpiarAvisoSolicitudAtendidaServicio();
}

function limpiarFormularioBeneficiarioServiciosPublicos() {
    $("#idbeneficiariosServiciosPublicos").val("");
    $("#nacionalidadServiciosPublicos").val("");
    $("#cedulaServiciosPublicos").val("");
    $("#telefonoServiciosPublicos").val("");
    $("#nombrebeneficiarioServiciosPublicos").val("");
    limpiarSelect2Remoto("#idcomunidadServiciosPublicos");
}

function limpiarSelect2Remoto(selector) {
    const combo = $(selector);
    combo.val(null).trigger("change");
    combo.find("option[data-dinamica='1']").remove();
}

function seleccionarOpcionRemota(selector, valor, texto) {
    const combo = $(selector);
    if (!combo.length) {
        return;
    }

    const idTexto = valor ? String(valor) : "";
    if (idTexto === "") {
        limpiarSelect2Remoto(selector);
        return;
    }

    let opcion = combo.find("option[value='" + idTexto + "']");
    if (!opcion.length) {
        opcion = new Option(texto || idTexto, idTexto, true, true);
        $(opcion).attr("data-dinamica", "1");
        combo.append(opcion);
    } else {
        opcion.prop("selected", true);
    }

    combo.val(idTexto).trigger("change");
}

function obtenerEstadoFormularioServiciosPublicos() {
    return {
        id_servicio: $("#id_servicio").val() || "",
        id_beneficiario: $("#id_beneficiario").val() || "",
        texto_beneficiario: obtenerTextoOpcionSeleccionada("#id_beneficiario"),
        id_tipo_servicio_publico: $("#id_tipo_servicio_publico").val() || "",
        texto_tipo_servicio_publico: obtenerTextoOpcionSeleccionada("#id_tipo_servicio_publico"),
        id_solicitud_servicio_publico: $("#id_solicitud_servicio_publico").val() || "",
        texto_solicitud_servicio_publico: obtenerTextoOpcionSeleccionada("#id_solicitud_servicio_publico"),
        fecha_servicio: $("#fecha_servicio").val() || "",
        ticket_interno: $("#ticket_interno").val() || "",
        descripcion: $("#descripcion").val() || ""
    };
}

function restaurarFormularioServiciosPublicos() {
    if (!estadoFormularioServiciosPublicos) {
        return;
    }

    $("#id_servicio").val(estadoFormularioServiciosPublicos.id_servicio || "");
    $("#fecha_servicio").val(estadoFormularioServiciosPublicos.fecha_servicio || "");
    $("#ticket_interno").val(estadoFormularioServiciosPublicos.ticket_interno || "");
    $("#descripcion").val(estadoFormularioServiciosPublicos.descripcion || "");

    if (estadoFormularioServiciosPublicos.id_beneficiario) {
        seleccionarOpcionRemota(
            "#id_beneficiario",
            estadoFormularioServiciosPublicos.id_beneficiario,
            estadoFormularioServiciosPublicos.texto_beneficiario
        );
    }

    if (estadoFormularioServiciosPublicos.id_tipo_servicio_publico) {
        seleccionarOpcionRemota(
            "#id_tipo_servicio_publico",
            estadoFormularioServiciosPublicos.id_tipo_servicio_publico,
            estadoFormularioServiciosPublicos.texto_tipo_servicio_publico
        );
    }

    if (estadoFormularioServiciosPublicos.id_solicitud_servicio_publico) {
        seleccionarOpcionRemota(
            "#id_solicitud_servicio_publico",
            estadoFormularioServiciosPublicos.id_solicitud_servicio_publico,
            estadoFormularioServiciosPublicos.texto_solicitud_servicio_publico
        );
    }
}

function obtenerTextoOpcionSeleccionada(selector) {
    const combo = $(selector);
    const opcion = combo.find("option:selected");
    return opcion.length ? opcion.text() : "";
}

function construirTextoBeneficiarioServiciosPublicos() {
    const nacionalidad = $("#nacionalidadServiciosPublicos").val() || "";
    const cedula = $("#cedulaServiciosPublicos").val() || "";
    const nombre = $("#nombrebeneficiarioServiciosPublicos").val() || "";

    return (nacionalidad ? nacionalidad + "-" : "") + cedula + (nombre ? " " + nombre : "");
}

function generarReporteRapidoServiciosPublicos() {
    if (!tablaServiciosPublicos) {
        return;
    }

    const rows = tablaServiciosPublicos.rows({ search: "applied" }).data().toArray();
    let html = "";

    for (let i = 0; i < rows.length; i += 1) {
        html += "<tr>";
        html += "<td>" + (rows[i].beneficiario || "") + "</td>";
        html += "<td>" + (rows[i].tipo_servicio || "") + "</td>";
        html += "<td>" + (rows[i].solicitud_servicio || "") + "</td>";
        html += "<td>" + (rows[i].fecha_servicio || "") + "</td>";
        html += "<td>" + (rows[i].ticket_interno || "") + "</td>";
        html += "<td>" + (rows[i].descripcion || "") + "</td>";
        html += "<td>" + extraerTextoPlanoServiciosPublicos(rows[i].telefono || "") + "</td>";
        html += "</tr>";
    }

    const win = window.open("", "_blank");
    if (!win) {
        mostrarAlertaServiciosPublicos("warning", "No se pudo abrir la ventana de impresion.");
        return;
    }

    win.document.write(
        "<html><head><title>Reporte Servicios Publicos</title><style>" +
        "body{font-family:Arial,sans-serif;padding:20px;}h1{margin:0 0 14px;}table{width:100%;border-collapse:collapse;}" +
        "th,td{border:1px solid #d6dee8;padding:8px;font-size:12px;vertical-align:top;}th{background:#eff4fa;}" +
        "</style></head><body>" +
        "<h1>Reporte de servicios publicos</h1>" +
        "<p>Total visible: " + rows.length + "</p>" +
        "<table><thead><tr><th>Beneficiario</th><th>Servicio</th><th>Solicitud</th><th>Fecha</th><th>Ticket interno</th><th>Descripcion</th><th>Telefono</th></tr></thead><tbody>" +
        html +
        "</tbody></table></body></html>"
    );
    win.document.close();
    win.focus();
    win.print();
}

function obtenerFechaHoraActualServiciosPublicos() {
    const ahora = new Date();
    const anio = ahora.getFullYear();
    const mes = String(ahora.getMonth() + 1).padStart(2, "0");
    const dia = String(ahora.getDate()).padStart(2, "0");
    const horas = String(ahora.getHours()).padStart(2, "0");
    const minutos = String(ahora.getMinutes()).padStart(2, "0");
    return anio + "-" + mes + "-" + dia + "T" + horas + ":" + minutos;
}

function extraerTextoPlanoServiciosPublicos(html) {
    return $("<div>").html(html).text().trim();
}

function obtenerFechaActualServiciosPublicos() {
    const fecha = new Date();
    const mes = String(fecha.getMonth() + 1).padStart(2, "0");
    const dia = String(fecha.getDate()).padStart(2, "0");
    return fecha.getFullYear() + "-" + mes + "-" + dia;
}

$(document).ready(function () {
    initServiciosPublicos();
});
