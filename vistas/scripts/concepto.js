const REFRESH_CONCEPTO_MS = 45000;

const ESTADISTICAS_BASE = {
    total_beneficiarios: 0,
    total_ayudas: 0,
    total_servicios: 0,
    total_seguridad: 0,
    total_atendidos: 0,
    total_pendientes: 0,
    total_registros_mes: 0,
    total_traslados: 0,
    unidades_disponibles: 0,
    porcentaje_atencion: 0,
    total_usuarios_activos: 0,
    total_usuarios_bloqueados: 0,
    ultimos_casos: [],
    bitacora_respaldo_total: 0,
    bitacora_respaldo_eventos_criticos: 0,
    bitacora_respaldo_ultimo: "",
    bitacora_respaldo_estado: "SIN_DATOS"
};

function numeroSeguro(valor) {
    const numero = Number(valor);
    return Number.isFinite(numero) ? numero : 0;
}

function formatearNumero(valor, suffix) {
    const numero = numeroSeguro(valor);
    const esPorcentaje = String(suffix || "") === "%";
    const opciones = esPorcentaje
        ? { minimumFractionDigits: 1, maximumFractionDigits: 1 }
        : { maximumFractionDigits: 0 };

    return numero.toLocaleString("es-VE", opciones) + (suffix || "");
}

function escapeHtmlConcepto(valor) {
    return String(valor == null ? "" : valor)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

function obtenerClaseModuloConcepto(modulo) {
    switch (String(modulo || "").toUpperCase()) {
        case "AYUDA_SOCIAL":
            return "badge-success";
        case "SERVICIOS_PUBLICOS":
            return "badge-warning";
        case "SEGURIDAD_EMERGENCIA":
            return "badge-danger";
        default:
            return "badge-secondary";
    }
}

function renderizarEstadisticas(data) {
    const payload = Object.assign({}, ESTADISTICAS_BASE, data || {});

    $("[data-stat]").each(function () {
        const $el = $(this);
        const key = String($el.data("stat") || "");
        const suffix = String($el.data("suffix") || "");
        const value = numeroSeguro(payload[key]);
        $el.text(formatearNumero(value, suffix));
    });
}

function renderizarCasosRecientes(data) {
    const $contenedor = $("#concepto-casos-recientes");
    if ($contenedor.length === 0) {
        return;
    }

    const items = Array.isArray(data && data.ultimos_casos) ? data.ultimos_casos : [];
    if (!items.length) {
        $contenedor.html('<div class="list-group-item text-muted">No hay casos recientes para mostrar.</div>');
        return;
    }

    const html = items.map(function (item) {
        const modulo = String(item.modulo || "");
        const ticket = item.ticket_interno ? "Ticket " + String(item.ticket_interno) : "Sin ticket";

        return '' +
            '<div class="list-group-item">' +
            '   <div class="d-flex justify-content-between align-items-start flex-wrap">' +
            '       <div class="pr-3">' +
            '           <div class="mb-1"><span class="badge ' + obtenerClaseModuloConcepto(modulo) + '">' + escapeHtmlConcepto(modulo.replace(/_/g, " ")) + '</span></div>' +
            '           <strong class="d-block">' + escapeHtmlConcepto(item.beneficiario || "Sin beneficiario") + '</strong>' +
            '           <span class="d-block text-muted">' + escapeHtmlConcepto(item.tipo_registro || "Sin tipo") + ' | ' + escapeHtmlConcepto(item.estado_solicitud || "Sin estado") + '</span>' +
            '       </div>' +
            '       <div class="text-right text-muted small">' +
            '           <div>' + escapeHtmlConcepto(ticket) + '</div>' +
            '           <div>' + escapeHtmlConcepto(item.fecha_evento_formateada || "") + '</div>' +
            '       </div>' +
            '   </div>' +
            '</div>';
    }).join("");

    $contenedor.html(html);
}

function renderizarEstadoRespaldo(data) {
    const $contenedor = $("#concepto-respaldo-bitacora");
    if ($contenedor.length === 0) {
        return;
    }

    const payload = Object.assign({}, ESTADISTICAS_BASE, data || {});
    const claseEstado = String(payload.bitacora_respaldo_estado || "").toUpperCase() === "OK"
        ? "badge-success"
        : "badge-warning";

    const html = '' +
        '<div class="d-flex justify-content-between align-items-center mb-3">' +
        '   <span class="text-muted">Estado actual</span>' +
        '   <span class="badge ' + claseEstado + '">' + escapeHtmlConcepto(payload.bitacora_respaldo_estado || "SIN_DATOS") + '</span>' +
        '</div>' +
        '<div class="mb-2"><strong>' + formatearNumero(payload.bitacora_respaldo_total) + '</strong> registros respaldados</div>' +
        '<div class="mb-2"><strong>' + formatearNumero(payload.bitacora_respaldo_eventos_criticos) + '</strong> eventos criticos detectados</div>' +
        '<div class="text-muted small">Ultimo respaldo: ' + escapeHtmlConcepto(payload.bitacora_respaldo_ultimo || "Sin informacion") + '</div>';

    $contenedor.html(html);
}

function actualizarBadgeActualizacion(data, error) {
    const $badge = $("#concepto-actualizado");
    if ($badge.length === 0) {
        return;
    }

    if (error) {
        $badge.removeClass("badge-light").addClass("badge-warning");
        $badge.text("Sin conexion con estadisticas");
        return;
    }

    const fechaLocal = new Date();
    const texto = "Actualizado: " + fechaLocal.toLocaleTimeString("es-VE", { hour: "2-digit", minute: "2-digit" });

    $badge.removeClass("badge-warning").addClass("badge-light");
    $badge.text(texto);
}

function mostrarEstadoError(visible) {
    const $error = $("#concepto-error");
    if ($error.length === 0) {
        return;
    }

    if (visible) {
        $error.removeClass("d-none");
        return;
    }

    $error.addClass("d-none");
}

function cargarEstadisticasConcepto() {
    $.ajax({
        url: "../ajax/concepto.php?op=estadisticas",
        type: "GET",
        dataType: "json",
        cache: false
    })
        .done(function (data) {
            const ok = data && data.ok !== false;
            renderizarEstadisticas(ok ? data : ESTADISTICAS_BASE);
            renderizarCasosRecientes(ok ? data : ESTADISTICAS_BASE);
            renderizarEstadoRespaldo(ok ? data : ESTADISTICAS_BASE);
            mostrarEstadoError(!ok);
            actualizarBadgeActualizacion(data, !ok);
        })
        .fail(function () {
            renderizarEstadisticas(ESTADISTICAS_BASE);
            renderizarCasosRecientes(ESTADISTICAS_BASE);
            renderizarEstadoRespaldo(ESTADISTICAS_BASE);
            mostrarEstadoError(true);
            actualizarBadgeActualizacion(null, true);
        });
}

$(function () {
    cargarEstadisticasConcepto();
    setInterval(cargarEstadisticasConcepto, REFRESH_CONCEPTO_MS);
});
