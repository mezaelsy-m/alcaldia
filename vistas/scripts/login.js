(function () {
    const form = document.getElementById("frmAcceso");
    const userInput = document.getElementById("logina");
    const passInput = document.getElementById("clavea");
    const togglePassword = document.getElementById("togglePassword");
    const btnLogin = document.getElementById("btnLogin");
    const messageBox = document.getElementById("loginMessage");
    const yearNow = document.getElementById("yearNow");

    const btnMostrarRecuperacion = document.getElementById("btnMostrarRecuperacion");
    const modalRecuperacion = document.getElementById("modalRecuperacion");
    const formRecuperacion = document.getElementById("frmRecuperacion");
    const usuarioRecuperacionInput = document.getElementById("usuarioRecuperacion");
    const cedulaRecuperacionInput = document.getElementById("cedulaRecuperacion");
    const btnRecuperarClave = document.getElementById("btnRecuperarClave");
    const btnCerrarRecuperacion = document.getElementById("btnCerrarRecuperacion");
    const btnCancelarRecuperacion = document.getElementById("btnCancelarRecuperacion");

    const modalPrimerUsuario = document.getElementById("modalPrimerUsuario");
    const formPrimerUsuario = document.getElementById("frmPrimerUsuario");
    const primerUsuarioInput = document.getElementById("primerUsuario");
    const primerCedulaInput = document.getElementById("primerCedula");
    const primerNombreInput = document.getElementById("primerNombre");
    const primerApellidoInput = document.getElementById("primerApellido");
    const primerCorreoInput = document.getElementById("primerCorreo");
    const primerDependenciaInput = document.getElementById("primerDependencia");
    const primerClaveInput = document.getElementById("primerClave");
    const primerClaveConfirmarInput = document.getElementById("primerClaveConfirmar");
    const btnCrearPrimerUsuario = document.getElementById("btnCrearPrimerUsuario");

    let registroInicialActivo = false;

    if (!form || !userInput || !passInput || !btnLogin || !messageBox) {
        return;
    }

    if (yearNow) {
        yearNow.textContent = new Date().getFullYear();
    }

    function setMessage(type, text) {
        messageBox.className = "login-message show " + type;
        messageBox.textContent = text;
    }

    function clearMessage() {
        messageBox.className = "login-message";
        messageBox.textContent = "";
    }

    function setLoading(isLoading) {
        btnLogin.disabled = isLoading || registroInicialActivo;
        btnLogin.classList.toggle("loading", isLoading);
    }

    function setLoadingRecuperacion(isLoading) {
        if (!btnRecuperarClave) {
            return;
        }

        btnRecuperarClave.disabled = isLoading;
        btnRecuperarClave.classList.toggle("loading", isLoading);
    }

    function setLoadingPrimerUsuario(isLoading) {
        if (!btnCrearPrimerUsuario) {
            return;
        }

        btnCrearPrimerUsuario.disabled = isLoading;
        btnCrearPrimerUsuario.classList.toggle("loading", isLoading);
    }

    function setLoginEnabled(enabled) {
        const permitir = !!enabled;
        form.classList.toggle("form-disabled", !permitir);
        userInput.disabled = !permitir;
        passInput.disabled = !permitir;
        btnLogin.disabled = !permitir;

        if (btnMostrarRecuperacion) {
            btnMostrarRecuperacion.disabled = !permitir;
            btnMostrarRecuperacion.style.display = permitir ? "inline-block" : "none";
        }
    }

    function mostrarModalRecuperacion(mostrar) {
        if (!modalRecuperacion) {
            return;
        }

        const visible = !!mostrar;
        modalRecuperacion.classList.toggle("is-open", visible);
        modalRecuperacion.setAttribute("aria-hidden", visible ? "false" : "true");
        document.body.classList.toggle("modal-lock", visible || (modalPrimerUsuario && modalPrimerUsuario.classList.contains("is-open")));

        if (visible && usuarioRecuperacionInput) {
            const loginUsuario = userInput.value.trim();
            if (loginUsuario && !usuarioRecuperacionInput.value.trim()) {
                usuarioRecuperacionInput.value = loginUsuario;
            }
            usuarioRecuperacionInput.focus();
        }
    }

    function mostrarModalPrimerUsuario(mostrar) {
        if (!modalPrimerUsuario) {
            return;
        }

        const visible = !!mostrar;
        modalPrimerUsuario.classList.toggle("is-open", visible);
        modalPrimerUsuario.setAttribute("aria-hidden", visible ? "false" : "true");
        document.body.classList.toggle("modal-lock", visible || (modalRecuperacion && modalRecuperacion.classList.contains("is-open")));

        if (visible && primerUsuarioInput) {
            primerUsuarioInput.focus();
        }
    }

    function activarRegistroInicial(msg) {
        registroInicialActivo = true;
        setLoginEnabled(false);
        setMessage("info", msg || "No hay usuarios registrados. Cree el primer usuario administrador.");
        mostrarModalPrimerUsuario(true);
    }

    function desactivarRegistroInicial() {
        registroInicialActivo = false;
        setLoginEnabled(true);
        mostrarModalPrimerUsuario(false);
    }

    function enviarAjax(url, data, onSuccess, onError, onComplete, method) {
        if (typeof window.jQuery === "undefined" || typeof window.jQuery.ajax !== "function") {
            if (typeof onError === "function") {
                onError();
            }
            if (typeof onComplete === "function") {
                onComplete();
            }
            return;
        }

        $.ajax({
            url: url,
            type: method || "POST",
            dataType: "json",
            data: data || {},
            success: function (response) {
                if (typeof onSuccess === "function") {
                    onSuccess(response);
                }
            },
            error: function () {
                if (typeof onError === "function") {
                    onError();
                }
            },
            complete: function () {
                if (typeof onComplete === "function") {
                    onComplete();
                }
            }
        });
    }

    function consultarEstadoInicial() {
        enviarAjax(
            "../ajax/usuarios.php?op=estadoinicial",
            {},
            function (data) {
                if (data && data.ok === true && data.requiere_registro_inicial === true) {
                    activarRegistroInicial(data.msg || "");
                    return;
                }

                desactivarRegistroInicial();
            },
            function () {
                setMessage("error", "No se pudo validar el estado inicial del sistema.");
            },
            null,
            "GET"
        );
    }

    if (togglePassword) {
        togglePassword.addEventListener("click", function () {
            const visible = passInput.type === "text";
            passInput.type = visible ? "password" : "text";
            togglePassword.innerHTML = visible
                ? '<i class="fas fa-eye"></i>'
                : '<i class="fas fa-eye-slash"></i>';
        });
    }

    if (btnMostrarRecuperacion) {
        btnMostrarRecuperacion.addEventListener("click", function () {
            mostrarModalRecuperacion(true);
        });
    }

    if (btnCerrarRecuperacion) {
        btnCerrarRecuperacion.addEventListener("click", function () {
            mostrarModalRecuperacion(false);
        });
    }

    if (btnCancelarRecuperacion) {
        btnCancelarRecuperacion.addEventListener("click", function () {
            mostrarModalRecuperacion(false);
        });
    }

    if (modalRecuperacion) {
        modalRecuperacion.addEventListener("click", function (event) {
            if (event.target === modalRecuperacion) {
                mostrarModalRecuperacion(false);
            }
        });
    }

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && modalRecuperacion && modalRecuperacion.classList.contains("is-open")) {
            mostrarModalRecuperacion(false);
        }
    });

    if (cedulaRecuperacionInput) {
        cedulaRecuperacionInput.addEventListener("input", function () {
            cedulaRecuperacionInput.value = cedulaRecuperacionInput.value.replace(/[^0-9]/g, "");
        });
    }

    if (primerCedulaInput) {
        primerCedulaInput.addEventListener("input", function () {
            primerCedulaInput.value = primerCedulaInput.value.replace(/[^0-9]/g, "");
        });
    }

    if (formRecuperacion) {
        formRecuperacion.addEventListener("submit", function (event) {
            event.preventDefault();
            clearMessage();

            const usuarioRecuperacion = usuarioRecuperacionInput ? usuarioRecuperacionInput.value.trim() : "";
            const cedulaRecuperacion = cedulaRecuperacionInput ? cedulaRecuperacionInput.value.trim() : "";

            if (!usuarioRecuperacion || !cedulaRecuperacion) {
                setMessage("error", "Debes indicar el usuario y la cedula para recuperar la contrasena.");
                return;
            }

            setLoadingRecuperacion(true);
            enviarAjax(
                "../ajax/usuarios.php?op=recuperarclave",
                {
                    usuario_recuperacion: usuarioRecuperacion,
                    cedula_recuperacion: cedulaRecuperacion
                },
                function (data) {
                    if (data && data.ok === true) {
                        setMessage("success", data.msg || "Se envio una clave temporal al correo registrado.");
                        passInput.value = "";
                        mostrarModalRecuperacion(false);
                        return;
                    }

                    setMessage("error", data && data.msg ? data.msg : "No se pudo completar la recuperacion de contrasena.");
                },
                function () {
                    setMessage("error", "No se pudo conectar con el servidor para recuperar la contrasena.");
                },
                function () {
                    setLoadingRecuperacion(false);
                }
            );
        });
    }

    if (formPrimerUsuario) {
        formPrimerUsuario.addEventListener("submit", function (event) {
            event.preventDefault();
            clearMessage();

            const usuario = primerUsuarioInput ? primerUsuarioInput.value.trim() : "";
            const cedula = primerCedulaInput ? primerCedulaInput.value.trim() : "";
            const nombre = primerNombreInput ? primerNombreInput.value.trim() : "";
            const apellido = primerApellidoInput ? primerApellidoInput.value.trim() : "";
            const correo = primerCorreoInput ? primerCorreoInput.value.trim() : "";
            const dependencia = primerDependenciaInput ? primerDependenciaInput.value.trim() : "";
            const password = primerClaveInput ? primerClaveInput.value : "";
            const passwordConfirm = primerClaveConfirmarInput ? primerClaveConfirmarInput.value : "";

            if (!usuario || !cedula || !nombre || !apellido || !password || !passwordConfirm) {
                setMessage("error", "Debe completar todos los datos obligatorios para crear el primer usuario.");
                return;
            }

            if (!/^[A-Za-z0-9._-]{4,50}$/.test(usuario)) {
                setMessage("error", "El usuario debe tener minimo 4 caracteres y solo usar letras, numeros, punto, guion o guion bajo.");
                return;
            }

            if (password.length < 8) {
                setMessage("error", "La contrasena debe tener al menos 8 caracteres.");
                return;
            }

            if (password !== passwordConfirm) {
                setMessage("error", "La confirmacion de contrasena no coincide.");
                return;
            }

            if (correo && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo)) {
                setMessage("error", "El correo indicado no es valido.");
                return;
            }

            setLoadingPrimerUsuario(true);
            enviarAjax(
                "../ajax/usuarios.php?op=registrarprimerusuario",
                {
                    usuario: usuario,
                    cedula: cedula,
                    nombre: nombre,
                    apellido: apellido,
                    correo: correo,
                    dependencia: dependencia,
                    password: password,
                    password_confirm: passwordConfirm
                },
                function (data) {
                    if (data && data.ok === true) {
                        setMessage("success", data.msg || "Primer usuario administrador creado. Redirigiendo...");
                        window.setTimeout(function () {
                            window.location.href = "concepto.php";
                        }, 700);
                        return;
                    }

                    setMessage("error", data && data.msg ? data.msg : "No se pudo crear el primer usuario administrador.");
                    consultarEstadoInicial();
                },
                function () {
                    setMessage("error", "No se pudo conectar con el servidor para crear el primer usuario.");
                },
                function () {
                    setLoadingPrimerUsuario(false);
                }
            );
        });
    }

    form.addEventListener("submit", function (event) {
        event.preventDefault();
        clearMessage();

        if (registroInicialActivo) {
            setMessage("info", "Debe crear primero el usuario administrador inicial del sistema.");
            mostrarModalPrimerUsuario(true);
            return;
        }

        const logina = userInput.value.trim();
        const clavea = passInput.value;

        if (!logina || !clavea) {
            setMessage("error", "Debes ingresar usuario y contrasena.");
            return;
        }

        if (typeof window.jQuery === "undefined" || typeof window.jQuery.ajax !== "function") {
            setMessage("error", "No se pudo cargar el modulo de autenticacion.");
            return;
        }

        setLoading(true);
        enviarAjax(
            "../ajax/usuarios.php?op=verificar",
            { logina: logina, clavea: clavea },
            function (data) {
                if (data && (data.ok === true || data.id_usuario)) {
                    const mensajeExito = data.msg || "Acceso autorizado. Redirigiendo...";
                    setMessage("success", mensajeExito);
                    window.setTimeout(function () {
                        window.location.href = "concepto.php";
                    }, 650);
                    return;
                }

                const codigo = data && data.codigo ? String(data.codigo) : "";
                if (codigo === "BLOQUEADO") {
                    setMessage("error", data.msg || "Usuario bloqueado por seguridad. Debe recuperar la contrasena.");
                    mostrarModalRecuperacion(true);
                    return;
                }

                if (codigo === "SETUP_REQUERIDO") {
                    activarRegistroInicial(data.msg || "Debe crear el primer usuario administrador.");
                    return;
                }

                setMessage("error", data && data.msg ? data.msg : "Usuario o contrasena invalida.");
            },
            function () {
                setMessage("error", "No se pudo conectar con el servidor.");
            },
            function () {
                setLoading(false);
            }
        );
    });

    consultarEstadoInicial();
})();
