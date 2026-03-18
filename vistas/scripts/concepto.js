function init() {
    cargarEstadisticas();
    setInterval(cargarEstadisticas, 30000);
}

function cargarEstadisticas() {
    $.ajax({
        url: "../ajax/concepto.php?op=estadisticas",
        type: "GET",
        dataType: "json",
        success: function (data) {
            $("#total-beneficiarios").text(data.total_beneficiarios || 0);
            $("#total-ayudas").text(data.total_ayudas || 0);
            $("#total-servicios").text(data.total_servicios || 0);
            $("#total-seguridad").text(data.total_seguridad || 0);

            $("#stat-beneficiarios").text(data.total_beneficiarios || 0);
            $("#stat-ayudas").text(data.total_ayudas || 0);
            $("#stat-servicios").text(data.total_servicios || 0);
            $("#stat-emergencias").text(data.total_seguridad || 0);

            animarNumeros();
        },
        error: function () {
            mostrarValoresPredeterminados();
        }
    });
}

function animarNumeros() {
    $(".small-box h3, .info-box-number").each(function () {
        const $this = $(this);
        const countTo = parseInt($this.text(), 10) || 0;

        if (countTo > 0) {
            $this.text(0);
            $this.css("opacity", "0");
            $this.animate({ opacity: 1 }, 500);

            $({ countNum: 0 }).animate(
                { countNum: countTo },
                {
                    duration: 1500,
                    easing: "swing",
                    step: function () {
                        $this.text(Math.ceil(this.countNum));
                    },
                    complete: function () {
                        $this.text(countTo);
                    }
                }
            );
        }
    });
}

function mostrarValoresPredeterminados() {
    const valores = {
        "total-beneficiarios": 0,
        "total-ayudas": 0,
        "total-servicios": 0,
        "total-seguridad": 0,
        "stat-beneficiarios": 0,
        "stat-ayudas": 0,
        "stat-servicios": 0,
        "stat-emergencias": 0
    };

    Object.keys(valores).forEach(function (id) {
        $("#" + id).text(valores[id]);
    });
}

$(document).on("mouseenter", ".small-box", function () {
    $(this).addClass("shadow-lg");
    $(this).css("transform", "translateY(-2px)");
    $(this).css("transition", "all 0.3s ease");
});

$(document).on("mouseleave", ".small-box", function () {
    $(this).removeClass("shadow-lg");
    $(this).css("transform", "translateY(0)");
});

$(document).on("mouseenter", ".info-box", function () {
    $(this).addClass("shadow");
    $(this).css("transform", "scale(1.02)");
    $(this).css("transition", "all 0.3s ease");
});

$(document).on("mouseleave", ".info-box", function () {
    $(this).removeClass("shadow");
    $(this).css("transform", "scale(1)");
});

init();
