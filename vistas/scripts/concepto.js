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
    total_usuarios_activos: 0
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
            mostrarEstadoError(!ok);
            actualizarBadgeActualizacion(data, !ok);
        })
        .fail(function () {
            renderizarEstadisticas(ESTADISTICAS_BASE);
            mostrarEstadoError(true);
            actualizarBadgeActualizacion(null, true);
        });
}

$(function () {
    cargarEstadisticasConcepto();
    setInterval(cargarEstadisticasConcepto, REFRESH_CONCEPTO_MS);
});
