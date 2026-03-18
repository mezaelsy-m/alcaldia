let tablaBeneficiarios = null;

function mostrarAlertaBeneficiarios(icono, mensaje, titulo) {
    const texto = mensaje || "Operacion completada.";
    return Swal.fire({
        icon: icono,
        title: titulo || obtenerTituloSegunIcono(icono),
        text: texto,
        confirmButtonText: "Aceptar",
        customClass: {
            confirmButton: "btn btn-primary"
        },
        buttonsStyling: false
    });
}

function confirmarAccionBeneficiarios(mensaje) {
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

function obtenerTituloSegunIcono(icono) {
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

function confirmacionAceptadaBeneficiarios(resultado) {
    return !!(resultado && (resultado.isConfirmed || resultado.value === true));
}

function initBeneficiarios() {
    inicializarComboComunidades();
    configurarTabla();
    reubicarControlLongitudBeneficiarios();
    configurarBuscadorListado();
    configurarEventos();
    cargarResumen();
}

function inicializarComboComunidades() {
    const combo = $("#idcomunidad");
    if (!combo.length || typeof $.fn.select2 !== "function") {
        return;
    }

    combo.select2({
        theme: "bootstrap4",
        width: "100%",
        dropdownParent: $("#beneficiarioModal"),
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

function configurarTabla() {
    tablaBeneficiarios = $("#tbllistado").DataTable({
        processing: true,
        serverSide: false,
        responsive: true,
        autoWidth: false,
        destroy: true,
        searching: true,
        dom: "lrtip",
        ajax: {
            url: "../ajax/beneficiarios.php?op=listar",
            type: "GET",
            dataType: "json",
            dataSrc: function (json) {
                return json && Array.isArray(json.aaData) ? json.aaData : [];
            },
            error: function (xhr) {
                console.error("Error al cargar beneficiarios:", xhr.responseText);
                mostrarAlertaBeneficiarios("error", "No se pudo cargar el listado de beneficiarios.");
            }
        },
        columns: [
            { data: "cedula_completa" },
            { data: "nombre_beneficiario" },
            { data: "telefono" },
            { data: "comunidad" },
            { data: "fecha_registro" },
            { data: "acciones", orderable: false, searchable: false, className: "text-nowrap text-right" }
        ],
        order: [[4, "desc"]],
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
    $("#buscadorBeneficiarios")
        .off(".beneficiarios")
        .on("input.beneficiarios search.beneficiarios", function () {
            if (!tablaBeneficiarios) {
                return;
            }

            tablaBeneficiarios.search($(this).val() || "").draw();
        });
}

function reubicarControlLongitudBeneficiarios() {
    const control = $("#tbllistado_wrapper .dataTables_length");
    const contenedor = $("#beneficiariosLengthContainer");

    if (!control.length || !contenedor.length) {
        return;
    }

    contenedor.empty().append(control);
}

function configurarEventos() {
    $("#btnNuevoBeneficiario").on("click", function () {
        abrirModalNuevo();
    });

    $("#btnRecargarListado").on("click", function () {
        recargarSeccion();
    });

    $("#btnReporte").on("click", function () {
        generarReporteRapido();
    });

    $("#formularioBeneficiario").on("submit", function (event) {
        event.preventDefault();
        guardarBeneficiario();
    });

    $("#tbllistado").on("click", ".js-editar", function () {
        const id = $(this).data("id");
        mostrarBeneficiario(id);
    });

    $("#tbllistado").on("click", ".js-eliminar", function () {
        const id = $(this).data("id");
        cambiarEstadoBeneficiario(id, "desactivar", "eliminar");
    });
}

function abrirModalNuevo() {
    limpiarFormulario();
    $("#beneficiarioModalLabel").text("Nuevo beneficiario");
    $("#beneficiarioModal").modal("show");
}

function mostrarBeneficiario(idBeneficiario) {
    $.ajax({
        url: "../ajax/beneficiarios.php?op=mostrar",
        type: "POST",
        dataType: "json",
        data: { idbeneficiarios: idBeneficiario },
        success: function (response) {
            if (!response || response.ok !== true || !response.data) {
                mostrarAlertaBeneficiarios("error", response && response.msg ? response.msg : "No se pudo cargar el beneficiario.");
                return;
            }

            const data = response.data;
            $("#idbeneficiarios").val(data.id_beneficiario);
            $("#nacionalidad").val(data.nacionalidad);
            $("#cedula").val(data.cedula);
            $("#nombrebeneficiario").val(data.nombre_beneficiario);
            $("#telefono").val(data.telefono);
            seleccionarComunidad(data.id_comunidad, data.comunidad);

            $("#beneficiarioModalLabel").text("Editar beneficiario");
            $("#beneficiarioModal").modal("show");
        },
        error: function (xhr) {
            console.error("Error al consultar beneficiario:", xhr.responseText);
            mostrarAlertaBeneficiarios("error", "No se pudo consultar el beneficiario.");
        }
    });
}

function guardarBeneficiario() {
    const btnGuardar = $("#btnGuardar");
    btnGuardar.prop("disabled", true);

    const formData = new FormData(document.getElementById("formularioBeneficiario"));

    $.ajax({
        url: "../ajax/beneficiarios.php?op=guardaryeditar",
        type: "POST",
        data: formData,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (response) {
            if (response && response.ok === true) {
                $("#beneficiarioModal").modal("hide");
                limpiarFormulario();
                recargarSeccion();
                mostrarAlertaBeneficiarios("success", response.msg || "Operacion realizada correctamente.");
            } else {
                mostrarAlertaBeneficiarios("error", response && response.msg ? response.msg : "No se pudo guardar el beneficiario.");
            }
        },
        error: function (xhr) {
            console.error("Error al guardar beneficiario:", xhr.responseText);
            mostrarAlertaBeneficiarios("error", "Error de comunicacion con el servidor.");
        },
        complete: function () {
            btnGuardar.prop("disabled", false);
        }
    });
}

function cambiarEstadoBeneficiario(idBeneficiario, operacion, accionTexto) {
    confirmarAccionBeneficiarios("Confirma que deseas " + accionTexto + " este beneficiario?").then(function (resultado) {
        if (!confirmacionAceptadaBeneficiarios(resultado)) {
            return;
        }

        $.ajax({
            url: "../ajax/beneficiarios.php?op=" + operacion,
            type: "POST",
            dataType: "json",
            data: { idbeneficiarios: idBeneficiario },
            success: function (response) {
                if (response && response.ok === true) {
                    recargarSeccion();
                    mostrarAlertaBeneficiarios("success", response.msg || "Operacion aplicada correctamente.");
                } else {
                    mostrarAlertaBeneficiarios("error", response && response.msg ? response.msg : "No se pudo actualizar el estado.");
                }
            },
            error: function (xhr) {
                console.error("Error al cambiar estado:", xhr.responseText);
                mostrarAlertaBeneficiarios("error", "Error de comunicacion con el servidor.");
            }
        });
    });
}

function recargarSeccion() {
    if (tablaBeneficiarios) {
        tablaBeneficiarios.ajax.reload(null, false);
    }
    cargarResumen();
}

function cargarResumen() {
    $.ajax({
        url: "../ajax/beneficiarios.php?op=resumen",
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (!response || response.ok !== true) {
                return;
            }

            $("#totalBeneficiarios").text(response.data.total || 0);
            $("#totalActivos").text(response.data.activos || 0);
            $("#totalInactivos").text(response.data.inactivos || 0);
        },
        error: function (xhr) {
            console.error("Error al cargar resumen:", xhr.responseText);
        }
    });
}

function limpiarFormulario() {
    $("#idbeneficiarios").val("");
    $("#nacionalidad").val("");
    $("#cedula").val("");
    $("#nombrebeneficiario").val("");
    $("#telefono").val("");
    $("#idcomunidad").val(null).trigger("change");
}

function seleccionarComunidad(idComunidad, nombreComunidad) {
    const combo = $("#idcomunidad");
    if (!combo.length) {
        return;
    }

    if (!idComunidad) {
        combo.val(null).trigger("change");
        return;
    }

    const idTexto = String(idComunidad);
    let opcion = combo.find("option[value='" + idTexto + "']");
    if (!opcion.length) {
        opcion = new Option(nombreComunidad || idTexto, idTexto, true, true);
        combo.append(opcion);
    }

    combo.val(idTexto).trigger("change");
}

function generarReporteRapido() {
    if (!tablaBeneficiarios) {
        return;
    }

    const rows = tablaBeneficiarios.rows({ search: "applied" }).data().toArray();
    let html = "";

    for (let i = 0; i < rows.length; i += 1) {
        html += "<tr>";
        html += "<td>" + (rows[i].cedula_completa || "") + "</td>";
        html += "<td>" + (rows[i].nombre_beneficiario || "") + "</td>";
        html += "<td>" + (rows[i].telefono || "") + "</td>";
        html += "<td>" + (rows[i].comunidad || "") + "</td>";
        html += "<td>" + (rows[i].fecha_registro || "") + "</td>";
        html += "</tr>";
    }

    const win = window.open("", "_blank");
    if (!win) {
        mostrarAlertaBeneficiarios("warning", "No se pudo abrir la ventana de impresion.");
        return;
    }

    win.document.write(
        "<html><head><title>Reporte Beneficiarios</title><style>" +
        "body{font-family:Arial,sans-serif;padding:20px;}h1{margin:0 0 14px;}table{width:100%;border-collapse:collapse;}" +
        "th,td{border:1px solid #d6dee8;padding:8px;font-size:12px;}th{background:#eff4fa;}" +
        "</style></head><body>" +
        "<h1>Reporte de beneficiarios</h1>" +
        "<p>Total visible: " + rows.length + "</p>" +
        "<table><thead><tr><th>Cedula</th><th>Nombre</th><th>Telefono</th><th>Comunidad</th><th>Fecha</th></tr></thead><tbody>" +
        html +
        "</tbody></table></body></html>"
    );
    win.document.close();
    win.focus();
    win.print();
}

$(document).ready(function () {
    initBeneficiarios();
});
