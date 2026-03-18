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

    $("#beneficiarioModal").on("hidden.bs.modal", function () {
        limpiarFormulario();
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
    let cuerpoTabla = "";

    for (let i = 0; i < rows.length; i += 1) {
        cuerpoTabla += "<tr>";
        cuerpoTabla += "<td>" + escaparHtmlReporteBeneficiarios(textoPlanoReporteBeneficiarios(rows[i].cedula_completa || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteBeneficiarios(textoPlanoReporteBeneficiarios(rows[i].nombre_beneficiario || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteBeneficiarios(textoPlanoReporteBeneficiarios(rows[i].telefono || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteBeneficiarios(textoPlanoReporteBeneficiarios(rows[i].comunidad || "")) + "</td>";
        cuerpoTabla += "<td>" + escaparHtmlReporteBeneficiarios(textoPlanoReporteBeneficiarios(rows[i].fecha_registro || "")) + "</td>";
        cuerpoTabla += "</tr>";
    }

    if (cuerpoTabla === "") {
        cuerpoTabla = '<tr><td colspan="5" class="reporte-vacio">No hay registros visibles para imprimir.</td></tr>';
    }

    const win = window.open("", "_blank");
    if (!win) {
        mostrarAlertaBeneficiarios("warning", "No se pudo abrir la ventana de impresion.");
        return;
    }

    const contexto = obtenerContextoReporteBeneficiarios();
    win.document.write(
        "<html><head><title>Reporte Beneficiarios</title><style>" + obtenerEstilosReporteBeneficiarios() + "</style></head><body>" +
        '<main class="reporte-doc">' +
        '<header class="reporte-header">' +
        '<div class="reporte-logo"><img src="' + contexto.logo + '" alt="Logo institucional" onerror="this.style.display=\'none\'"></div>' +
        '<div class="reporte-titulo">' +
        '<span class="reporte-linea">' + contexto.institucion + "</span>" +
        '<span class="reporte-linea">' + contexto.sistema + "</span>" +
        "<h1>Reporte rapido de beneficiarios</h1>" +
        "</div>" +
        "</header>" +
        '<section class="reporte-meta">' +
        '<div class="reporte-meta-item"><span>Fecha</span><strong>' + contexto.fecha + "</strong></div>" +
        '<div class="reporte-meta-item"><span>Hora</span><strong>' + contexto.hora + "</strong></div>" +
        '<div class="reporte-meta-item"><span>Generado por</span><strong>' + contexto.usuario + "</strong></div>" +
        '<div class="reporte-meta-item"><span>Total visible</span><strong>' + rows.length + "</strong></div>" +
        "</section>" +
        '<section class="reporte-tabla"><table><thead><tr><th>Cedula</th><th>Nombre</th><th>Telefono</th><th>Comunidad</th><th>Fecha</th></tr></thead><tbody>' +
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

function obtenerContextoReporteBeneficiarios() {
    const ahora = new Date();
    const ruta = window.location.pathname || "";
    const indiceVistas = ruta.indexOf("/vistas/");
    const base = indiceVistas >= 0 ? ruta.substring(0, indiceVistas) : "";
    const institucion = $(".header-brand-copy span").first().text().trim() || "Alcaldia Municipal";
    const sistema = $(".header-brand-copy strong").first().text().trim() || "Sala Situacional";
    const usuario = $(".header-user-chip span").last().text().trim() || "Usuario del sistema";

    return {
        logo: window.location.origin + base + "/assets/images/logo_login.png",
        institucion: escaparHtmlReporteBeneficiarios(institucion),
        sistema: escaparHtmlReporteBeneficiarios(sistema),
        usuario: escaparHtmlReporteBeneficiarios(usuario),
        fecha: escaparHtmlReporteBeneficiarios(ahora.toLocaleDateString("es-VE")),
        hora: escaparHtmlReporteBeneficiarios(ahora.toLocaleTimeString("es-VE", { hour: "2-digit", minute: "2-digit" }))
    };
}

function obtenerEstilosReporteBeneficiarios() {
    return "body{font-family:'Segoe UI',Tahoma,Arial,sans-serif;background:#f4f7fb;color:#1f2d3d;margin:0;padding:24px;}" +
        ".reporte-doc{max-width:1180px;margin:0 auto;background:#fff;border:1px solid #dce5f2;border-radius:14px;overflow:hidden;}" +
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

function textoPlanoReporteBeneficiarios(valor) {
    return $("<div>").html(valor || "").text().trim();
}

function escaparHtmlReporteBeneficiarios(valor) {
    return $("<div>").text(valor || "").html();
}

$(document).ready(function () {
    initBeneficiarios();
});
