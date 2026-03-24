<?php
require_once "../config/Conexion.php";

class Usuarios
{
    private $maxIntentosPermitidos = 3;
    private static $seguridadAccesoInicializada = false;

    public function __construct()
    {
        $this->asegurarTablaSeguridadAcceso();
    }

    private function db()
    {
        global $conexion;
        return $conexion;
    }

    private function esc($valor)
    {
        return mysqli_real_escape_string($this->db(), (string) $valor);
    }

    private function sqlNullableString($valor)
    {
        if ($valor === null) {
            return "NULL";
        }

        $valor = trim((string) $valor);
        if ($valor === "") {
            return "NULL";
        }

        return "'" . $this->esc($valor) . "'";
    }

    private function sqlNullableInt($valor)
    {
        $valor = (int) $valor;
        return $valor > 0 ? "'" . $valor . "'" : "NULL";
    }

    private function valorHtml($valor)
    {
        return htmlspecialchars((string) $valor, ENT_QUOTES, "UTF-8");
    }

    private function esCorreoValido($correo)
    {
        $correo = trim((string) $correo);
        return $correo !== "" && filter_var($correo, FILTER_VALIDATE_EMAIL);
    }

    private function obtenerIpActual()
    {
        return isset($_SERVER["REMOTE_ADDR"]) ? (string) $_SERVER["REMOTE_ADDR"] : "127.0.0.1";
    }

    private function registrarEventoAutenticacion($accion, $resumen, $detalle, $idUsuario = 0, $idRegistro = "")
    {
        $idRegistro = trim((string) $idRegistro);
        if ($idRegistro === "" && (int) $idUsuario > 0) {
            $idRegistro = (string) (int) $idUsuario;
        }

        $sql = "CALL sp_bitacora_registrar_autenticacion("
            . $this->sqlNullableInt($idUsuario) . ", "
            . $this->sqlNullableString($idRegistro) . ", "
            . $this->sqlNullableString(strtoupper(trim((string) $accion))) . ", "
            . $this->sqlNullableString($detalle !== "" ? $detalle : $resumen) . ", "
            . $this->sqlNullableString($this->obtenerIpActual())
            . ")";

        return ejecutarProcedimientoNoResultado($sql);
    }

    private function asegurarTablaSeguridadAcceso()
    {
        if (self::$seguridadAccesoInicializada) {
            return;
        }

        $sql = "CREATE TABLE IF NOT EXISTS usuarios_seguridad_acceso (
                    id_usuario INT(11) NOT NULL,
                    intentos_fallidos INT(11) NOT NULL DEFAULT 0,
                    bloqueado TINYINT(1) NOT NULL DEFAULT 0,
                    fecha_bloqueo DATETIME NULL,
                    password_temporal TINYINT(1) NOT NULL DEFAULT 0,
                    fecha_password_temporal DATETIME NULL,
                    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (id_usuario),
                    KEY idx_usuarios_seguridad_bloqueo (bloqueado, intentos_fallidos),
                    CONSTRAINT fk_usuarios_seguridad_usuario
                        FOREIGN KEY (id_usuario)
                        REFERENCES usuarios(id_usuario)
                        ON UPDATE CASCADE
                        ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";

        @ejecutarConsulta($sql);
        @ejecutarConsulta("INSERT IGNORE INTO usuarios_seguridad_acceso (id_usuario)
                           SELECT id_usuario
                           FROM usuarios");

        self::$seguridadAccesoInicializada = true;
    }

    private function asegurarRegistroSeguridadAcceso($idUsuario)
    {
        $idUsuario = (int) $idUsuario;
        if ($idUsuario <= 0) {
            return;
        }

        ejecutarConsulta("INSERT INTO usuarios_seguridad_acceso (id_usuario)
                          VALUES ('$idUsuario')
                          ON DUPLICATE KEY UPDATE id_usuario = id_usuario");
    }

    private function obtenerUsuarioPorLogin($usuario, $forUpdate = false)
    {
        $usuario = $this->esc($usuario);

        $sql = "SELECT u.id_usuario,
                       u.id_empleado,
                       u.usuario,
                       u.password,
                       u.rol,
                       IFNULL(u.estado, 1) AS estado,
                       IFNULL(usa.intentos_fallidos, 0) AS intentos_fallidos,
                       IFNULL(usa.bloqueado, 0) AS bloqueado,
                       IFNULL(usa.password_temporal, 0) AS password_temporal,
                       usa.fecha_bloqueo,
                       usa.fecha_password_temporal,
                       e.cedula,
                       e.correo,
                       CONCAT(TRIM(IFNULL(e.nombre, '')), ' ', TRIM(IFNULL(e.apellido, ''))) AS nombre_empleado
                FROM usuarios AS u
                LEFT JOIN usuarios_seguridad_acceso AS usa
                    ON usa.id_usuario = u.id_usuario
                LEFT JOIN empleados AS e
                    ON e.id_empleado = u.id_empleado
                WHERE u.usuario = '$usuario'
                  AND IFNULL(u.estado, 1) = 1
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    private function reiniciarSeguridadAcceso($idUsuario)
    {
        $idUsuario = (int) $idUsuario;
        return ejecutarProcedimientoNoResultado(
            "CALL sp_usuarios_reiniciar_seguridad_acceso('$idUsuario')"
        );
    }

    private function incrementarIntentoFallido($idUsuario)
    {
        $idUsuario = (int) $idUsuario;
        $this->asegurarRegistroSeguridadAcceso($idUsuario);

        if (!ejecutarProcedimientoNoResultado(
            "CALL sp_usuarios_incrementar_intento_fallido('$idUsuario')"
        )) {
            return array("ok" => false, "msg" => "No se pudo registrar el intento fallido.");
        }

        $fila = ejecutarConsultaSimpleFila(
            "SELECT intentos_fallidos,
                    bloqueado
             FROM usuarios_seguridad_acceso
             WHERE id_usuario = '$idUsuario'
             LIMIT 1
             FOR UPDATE"
        );

        if (!$fila) {
            return array("ok" => false, "msg" => "No se pudo consultar el estado de seguridad del usuario.");
        }

        $intentos = (int) $fila["intentos_fallidos"];
        $umbralBloqueo = $this->maxIntentosPermitidos + 1;
        $bloqueado = (int) $fila["bloqueado"] === 1;
        $justoBloqueado = false;

        if (!$bloqueado && $intentos >= $umbralBloqueo) {
            if (!ejecutarProcedimientoNoResultado(
                "CALL sp_usuarios_marcar_bloqueado('$idUsuario')"
            )) {
                return array("ok" => false, "msg" => "No se pudo bloquear el usuario tras los intentos fallidos.");
            }

            $bloqueado = true;
            $justoBloqueado = true;
        }

        return array(
            "ok" => true,
            "intentos" => $intentos,
            "restantes" => max(0, $umbralBloqueo - $intentos),
            "bloqueado" => $bloqueado,
            "justo_bloqueado" => $justoBloqueado
        );
    }

    private function desbloquearSeguridadAcceso($idUsuario, $idUsuarioAdmin = 0, $motivo = "")
    {
        $idUsuario = (int) $idUsuario;
        $idUsuarioAdmin = (int) $idUsuarioAdmin;

        if ($idUsuario <= 0) {
            return false;
        }

        return ejecutarProcedimientoNoResultado(
            "CALL sp_usuarios_desbloquear_manual("
            . "'" . $idUsuario . "', "
            . "'" . $idUsuarioAdmin . "', "
            . $this->sqlNullableString($motivo)
            . ")"
        );
    }

    private function obtenerConfiguracionSmtpActiva()
    {
        $sql = "SELECT host,
                       puerto,
                       usuario,
                       clave,
                       correo_remitente,
                       nombre_remitente,
                       IFNULL(usar_tls, 1) AS usar_tls
                FROM configuracion_smtp
                WHERE IFNULL(estado, 1) = 1
                ORDER BY id_configuracion_smtp DESC
                LIMIT 1";

        return ejecutarConsultaSimpleFila($sql);
    }

    private function smtpLeerRespuesta($socket)
    {
        $respuesta = "";
        while (!feof($socket)) {
            $linea = fgets($socket, 1024);
            if ($linea === false) {
                break;
            }

            $respuesta .= $linea;
            if (strlen($linea) < 4 || substr($linea, 3, 1) === " ") {
                break;
            }
        }

        return trim((string) $respuesta);
    }

    private function smtpEnviarComando($socket, $comando, $codigosEsperados)
    {
        if ($comando !== null) {
            if (@fwrite($socket, $comando . "\r\n") === false) {
                throw new Exception("No se pudo enviar un comando al servidor SMTP.");
            }
        }

        $respuesta = $this->smtpLeerRespuesta($socket);
        if (!preg_match('/^(\d{3})/', $respuesta, $match)) {
            throw new Exception("Respuesta SMTP invalida: " . $respuesta);
        }

        $codigo = (int) $match[1];
        if (!in_array($codigo, $codigosEsperados, true)) {
            throw new Exception("Error SMTP " . $codigo . ": " . $respuesta);
        }

        return $respuesta;
    }

    private function enviarCorreoSmtpHtml($config, $destinatario, $asunto, $mensajeHtml)
    {
        $host = trim((string) (isset($config["host"]) ? $config["host"] : ""));
        $puerto = isset($config["puerto"]) ? (int) $config["puerto"] : 0;
        $usuario = trim((string) (isset($config["usuario"]) ? $config["usuario"] : ""));
        $clave = (string) (isset($config["clave"]) ? $config["clave"] : "");
        $correoRemitente = trim((string) (isset($config["correo_remitente"]) ? $config["correo_remitente"] : ""));
        $nombreRemitente = trim((string) (isset($config["nombre_remitente"]) ? $config["nombre_remitente"] : ""));
        $usarTls = isset($config["usar_tls"]) && (int) $config["usar_tls"] === 1;

        if ($host === "" || $puerto <= 0 || $usuario === "" || trim($clave) === "" || !$this->esCorreoValido($correoRemitente)) {
            throw new Exception("La configuracion SMTP esta incompleta.");
        }

        $contexto = stream_context_create(array(
            "ssl" => array(
                "verify_peer" => false,
                "verify_peer_name" => false,
                "allow_self_signed" => true
            )
        ));

        $socket = @stream_socket_client(
            $host . ":" . $puerto,
            $errno,
            $error,
            20,
            STREAM_CLIENT_CONNECT,
            $contexto
        );

        if (!$socket) {
            throw new Exception("No se pudo conectar al servidor SMTP: " . $error);
        }

        stream_set_timeout($socket, 20);

        try {
            $this->smtpEnviarComando($socket, null, array(220));

            $heloHost = isset($_SERVER["SERVER_NAME"]) ? preg_replace('/[^A-Za-z0-9\.\-]/', '', (string) $_SERVER["SERVER_NAME"]) : "localhost";
            if (trim((string) $heloHost) === "") {
                $heloHost = "localhost";
            }

            $this->smtpEnviarComando($socket, "EHLO " . $heloHost, array(250));

            if ($usarTls) {
                $this->smtpEnviarComando($socket, "STARTTLS", array(220));
                $crypto = @stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT);
                if ($crypto !== true) {
                    throw new Exception("No se pudo habilitar STARTTLS con el servidor SMTP.");
                }
                $this->smtpEnviarComando($socket, "EHLO " . $heloHost, array(250));
            }

            $this->smtpEnviarComando($socket, "AUTH LOGIN", array(334));
            $this->smtpEnviarComando($socket, base64_encode($usuario), array(334));
            $this->smtpEnviarComando($socket, base64_encode($clave), array(235));
            $this->smtpEnviarComando($socket, "MAIL FROM:<" . $correoRemitente . ">", array(250));
            $this->smtpEnviarComando($socket, "RCPT TO:<" . $destinatario . ">", array(250, 251));
            $this->smtpEnviarComando($socket, "DATA", array(354));

            $asuntoCodificado = "=?UTF-8?B?" . base64_encode((string) $asunto) . "?=";
            $remitenteHeader = $correoRemitente;
            if ($nombreRemitente !== "") {
                $remitenteHeader = "=?UTF-8?B?" . base64_encode($nombreRemitente) . "?= <" . $correoRemitente . ">";
            }

            $cuerpoNormalizado = str_replace(array("\r\n", "\r"), "\n", (string) $mensajeHtml);
            $cuerpoNormalizado = str_replace("\n", "\r\n", $cuerpoNormalizado);
            $lineas = explode("\r\n", $cuerpoNormalizado);
            foreach ($lineas as &$linea) {
                if (isset($linea[0]) && $linea[0] === ".") {
                    $linea = "." . $linea;
                }
            }
            unset($linea);
            $cuerpoNormalizado = implode("\r\n", $lineas);

            $headers = array(
                "Date: " . date("r"),
                "From: " . $remitenteHeader,
                "To: <" . $destinatario . ">",
                "Subject: " . $asuntoCodificado,
                "MIME-Version: 1.0",
                "Content-Type: text/html; charset=UTF-8",
                "Content-Transfer-Encoding: 8bit"
            );

            $contenidoData = implode("\r\n", $headers) . "\r\n\r\n" . $cuerpoNormalizado;
            $contenidoData = str_replace(array("\r\n", "\r"), "\n", $contenidoData);
            $contenidoData = str_replace("\n", "\r\n", $contenidoData);
            $lineasData = explode("\r\n", $contenidoData);
            foreach ($lineasData as &$lineaData) {
                if (isset($lineaData[0]) && $lineaData[0] === ".") {
                    $lineaData = "." . $lineaData;
                }
            }
            unset($lineaData);

            $contenidoData = implode("\r\n", $lineasData) . "\r\n.";
            if (@fwrite($socket, $contenidoData . "\r\n") === false) {
                throw new Exception("No se pudo enviar el contenido del correo al servidor SMTP.");
            }

            $this->smtpEnviarComando($socket, null, array(250));
            $this->smtpEnviarComando($socket, "QUIT", array(221, 250));
        } finally {
            fclose($socket);
        }
    }

    private function plantillaCorreoBloqueo($filaUsuario)
    {
        $nombre = trim((string) (isset($filaUsuario["nombre_empleado"]) ? $filaUsuario["nombre_empleado"] : ""));
        if ($nombre === "") {
            $nombre = isset($filaUsuario["usuario"]) ? (string) $filaUsuario["usuario"] : "Usuario";
        }

        $usuario = isset($filaUsuario["usuario"]) ? (string) $filaUsuario["usuario"] : "";
        $fecha = date("d/m/Y h:i A");
        $sistema = defined("PRO_NOMBRE") && trim((string) PRO_NOMBRE) !== "" ? trim((string) PRO_NOMBRE) : "Sala Situacional";

        return "<!doctype html>
<html lang='es'>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>Alerta de bloqueo</title>
</head>
<body style='margin:0;padding:0;background:#edf3f9;font-family:Arial,Helvetica,sans-serif;color:#1c2f42;'>
    <table role='presentation' width='100%' cellpadding='0' cellspacing='0' style='background:#edf3f9;padding:24px 12px;'>
        <tr>
            <td align='center'>
                <table role='presentation' width='640' cellpadding='0' cellspacing='0' style='max-width:640px;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #d4e0ec;'>
                    <tr>
                        <td style='padding:22px 24px;background:linear-gradient(135deg,#0b4b75,#0a6ca4);color:#ffffff;'>
                            <h2 style='margin:0;font-size:22px;letter-spacing:.02em;'>Cuenta bloqueada por seguridad</h2>
                            <p style='margin:8px 0 0;font-size:14px;opacity:.92;'>Sistema " . $this->valorHtml($sistema) . "</p>
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:24px;'>
                            <p style='margin:0 0 12px;'>Hola <strong>" . $this->valorHtml($nombre) . "</strong>,</p>
                            <p style='margin:0 0 14px;line-height:1.55;'>Detectamos multiples intentos fallidos de inicio de sesion y la cuenta fue bloqueada de forma preventiva.</p>
                            <table role='presentation' width='100%' cellpadding='0' cellspacing='0' style='border:1px solid #d7e2ee;border-radius:10px;background:#f7fbff;margin:14px 0 18px;'>
                                <tr>
                                    <td style='padding:12px 14px;font-size:14px;line-height:1.6;'>
                                        <strong>Usuario:</strong> " . $this->valorHtml($usuario) . "<br>
                                        <strong>Fecha de bloqueo:</strong> " . $this->valorHtml($fecha) . "
                                    </td>
                                </tr>
                            </table>
                            <p style='margin:0 0 12px;line-height:1.55;'>Para desbloquearla, utilice la opcion de <strong>Recuperar contrasena</strong> en la pantalla de inicio de sesion e ingrese su usuario y cedula.</p>
                            <p style='margin:0;font-size:12px;color:#5d7287;'>Este correo se genero automaticamente. Si no reconoce esta actividad, notifiquelo al administrador del sistema.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
    }

    private function plantillaCorreoRecuperacion($filaUsuario, $claveTemporal)
    {
        $nombre = trim((string) (isset($filaUsuario["nombre_empleado"]) ? $filaUsuario["nombre_empleado"] : ""));
        if ($nombre === "") {
            $nombre = isset($filaUsuario["usuario"]) ? (string) $filaUsuario["usuario"] : "Usuario";
        }

        $usuario = isset($filaUsuario["usuario"]) ? (string) $filaUsuario["usuario"] : "";
        $cedula = isset($filaUsuario["cedula"]) ? (string) $filaUsuario["cedula"] : "";
        $fecha = date("d/m/Y h:i A");
        $sistema = defined("PRO_NOMBRE") && trim((string) PRO_NOMBRE) !== "" ? trim((string) PRO_NOMBRE) : "Sala Situacional";

        return "<!doctype html>
<html lang='es'>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>Recuperacion de contrasena</title>
</head>
<body style='margin:0;padding:0;background:#edf3f9;font-family:Arial,Helvetica,sans-serif;color:#1c2f42;'>
    <table role='presentation' width='100%' cellpadding='0' cellspacing='0' style='background:#edf3f9;padding:24px 12px;'>
        <tr>
            <td align='center'>
                <table role='presentation' width='640' cellpadding='0' cellspacing='0' style='max-width:640px;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #d4e0ec;'>
                    <tr>
                        <td style='padding:22px 24px;background:linear-gradient(135deg,#0f5b4f,#1b8a75);color:#ffffff;'>
                            <h2 style='margin:0;font-size:22px;letter-spacing:.02em;'>Recuperacion de contrasena</h2>
                            <p style='margin:8px 0 0;font-size:14px;opacity:.92;'>Sistema " . $this->valorHtml($sistema) . "</p>
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:24px;'>
                            <p style='margin:0 0 12px;'>Hola <strong>" . $this->valorHtml($nombre) . "</strong>,</p>
                            <p style='margin:0 0 14px;line-height:1.55;'>Se atendio una solicitud de recuperacion de contrasena para su cuenta. Esta es su clave temporal:</p>
                            <div style='margin:0 0 18px;padding:14px 16px;border:1px dashed #2a7d6f;border-radius:10px;background:#f0fbf8;font-size:22px;font-weight:700;letter-spacing:.08em;color:#0f5b4f;text-align:center;'>
                                " . $this->valorHtml($claveTemporal) . "
                            </div>
                            <table role='presentation' width='100%' cellpadding='0' cellspacing='0' style='border:1px solid #d7e2ee;border-radius:10px;background:#f7fbff;margin:14px 0 18px;'>
                                <tr>
                                    <td style='padding:12px 14px;font-size:14px;line-height:1.6;'>
                                        <strong>Usuario:</strong> " . $this->valorHtml($usuario) . "<br>
                                        <strong>Cedula:</strong> " . $this->valorHtml($cedula) . "<br>
                                        <strong>Fecha de emision:</strong> " . $this->valorHtml($fecha) . "
                                    </td>
                                </tr>
                            </table>
                            <p style='margin:0 0 10px;line-height:1.55;'><strong>Recomendacion:</strong> Inicie sesion con esta clave temporal y cambiela inmediatamente por una clave personal segura.</p>
                            <p style='margin:0;font-size:12px;color:#5d7287;'>Si usted no solicito esta recuperacion, contacte de inmediato al administrador del sistema.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
    }

    private function notificarBloqueoUsuario($filaUsuario)
    {
        $correo = trim((string) (isset($filaUsuario["correo"]) ? $filaUsuario["correo"] : ""));
        if (!$this->esCorreoValido($correo)) {
            return array("ok" => false, "msg" => "El usuario no posee un correo valido asociado.");
        }

        $config = $this->obtenerConfiguracionSmtpActiva();
        if (!$config) {
            return array("ok" => false, "msg" => "No hay configuracion SMTP activa para enviar la alerta de bloqueo.");
        }

        $asunto = "Alerta de seguridad: su cuenta fue bloqueada";
        $mensaje = $this->plantillaCorreoBloqueo($filaUsuario);

        try {
            $this->enviarCorreoSmtpHtml($config, $correo, $asunto, $mensaje);
            return array("ok" => true);
        } catch (Exception $exception) {
            return array("ok" => false, "msg" => "No se pudo enviar el correo de bloqueo: " . $exception->getMessage());
        }
    }

    private function generarClaveTemporal($longitud = 10)
    {
        $longitud = (int) $longitud;
        if ($longitud < 8) {
            $longitud = 8;
        }

        $alfabeto = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789@#$%";
        $max = strlen($alfabeto) - 1;
        $clave = "";

        for ($i = 0; $i < $longitud; $i++) {
            $indice = function_exists("random_int")
                ? random_int(0, $max)
                : mt_rand(0, $max);
            $clave .= $alfabeto[$indice];
        }

        return $clave;
    }

    private function construirUsuarioSesion($fila)
    {
        $nombreEmpleado = trim((string) (isset($fila["nombre_empleado"]) ? $fila["nombre_empleado"] : ""));
        if ($nombreEmpleado === "") {
            $nombreEmpleado = (string) $fila["usuario"];
        }

        return array(
            "id_usuario" => (int) $fila["id_usuario"],
            "usuario" => (string) $fila["usuario"],
            "rol" => (string) $fila["rol"],
            "nombre_empleado" => $nombreEmpleado,
            "password_temporal" => isset($fila["password_temporal"]) ? (int) $fila["password_temporal"] : 0
        );
    }

    private function obtenerUsuarioPorId($idUsuario, $forUpdate = false)
    {
        $idUsuario = (int) $idUsuario;
        if ($idUsuario <= 0) {
            return null;
        }

        $sql = "SELECT u.id_usuario,
                       u.id_empleado,
                       u.usuario,
                       u.password,
                       u.rol,
                       IFNULL(u.estado, 1) AS estado,
                       IFNULL(usa.intentos_fallidos, 0) AS intentos_fallidos,
                       IFNULL(usa.bloqueado, 0) AS bloqueado,
                       IFNULL(usa.password_temporal, 0) AS password_temporal,
                       usa.fecha_bloqueo,
                       usa.fecha_password_temporal,
                       e.cedula,
                       e.correo,
                       CONCAT(TRIM(IFNULL(e.nombre, '')), ' ', TRIM(IFNULL(e.apellido, ''))) AS nombre_empleado
                FROM usuarios AS u
                LEFT JOIN usuarios_seguridad_acceso AS usa
                    ON usa.id_usuario = u.id_usuario
                LEFT JOIN empleados AS e
                    ON e.id_empleado = u.id_empleado
                WHERE u.id_usuario = '$idUsuario'
                  AND IFNULL(u.estado, 1) = 1
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    public function existenUsuariosRegistrados()
    {
        $row = ejecutarConsultaSimpleFila("SELECT COUNT(*) AS total FROM usuarios");
        return $row && (int) $row["total"] > 0;
    }

    public function obtenerEstadoInicialAcceso()
    {
        $requiereRegistroInicial = !$this->existenUsuariosRegistrados();
        return array(
            "ok" => true,
            "requiere_registro_inicial" => $requiereRegistroInicial,
            "msg" => $requiereRegistroInicial
                ? "No hay usuarios registrados. Debe crear el primer usuario administrador."
                : "El sistema ya posee usuarios registrados."
        );
    }

    private function validarDatosPrimerUsuario($data)
    {
        $usuario = trim((string) (isset($data["usuario"]) ? $data["usuario"] : ""));
        $password = (string) (isset($data["password"]) ? $data["password"] : "");
        $passwordConfirm = (string) (isset($data["password_confirm"]) ? $data["password_confirm"] : "");
        $cedula = preg_replace('/[^0-9]/', '', (string) (isset($data["cedula"]) ? $data["cedula"] : ""));
        $nombre = trim((string) (isset($data["nombre"]) ? $data["nombre"] : ""));
        $apellido = trim((string) (isset($data["apellido"]) ? $data["apellido"] : ""));
        $correo = trim((string) (isset($data["correo"]) ? $data["correo"] : ""));
        $dependencia = trim((string) (isset($data["dependencia"]) ? $data["dependencia"] : ""));

        if ($usuario === "" || $password === "" || $passwordConfirm === "" || $cedula === "" || $nombre === "" || $apellido === "") {
            return array("ok" => false, "msg" => "Debe completar todos los datos obligatorios del primer usuario.");
        }

        if (!preg_match('/^[A-Za-z0-9._-]{4,50}$/', $usuario)) {
            return array("ok" => false, "msg" => "El usuario solo puede contener letras, numeros, punto, guion o guion bajo (minimo 4 caracteres).");
        }

        if (strlen($password) < 8) {
            return array("ok" => false, "msg" => "La contrasena del primer usuario debe tener al menos 8 caracteres.");
        }

        if (!hash_equals($password, $passwordConfirm)) {
            return array("ok" => false, "msg" => "La confirmacion de la contrasena no coincide.");
        }

        if (strlen($cedula) < 6 || strlen($cedula) > 10) {
            return array("ok" => false, "msg" => "La cedula indicada no es valida.");
        }

        if ($correo !== "" && !$this->esCorreoValido($correo)) {
            return array("ok" => false, "msg" => "El correo del primer usuario no es valido.");
        }

        if ($dependencia === "") {
            $dependencia = "Direccion General";
        }

        return array(
            "ok" => true,
            "data" => array(
                "usuario" => $usuario,
                "password" => $password,
                "cedula" => (int) $cedula,
                "nombre" => $nombre,
                "apellido" => $apellido,
                "correo" => $correo,
                "dependencia" => $dependencia
            )
        );
    }

    private function obtenerOCrearDependenciaInicial($nombreDependencia)
    {
        $nombreDependencia = trim((string) $nombreDependencia);
        if ($nombreDependencia === "") {
            $nombreDependencia = "Direccion General";
        }

        $escNombre = $this->esc($nombreDependencia);
        $existente = ejecutarConsultaSimpleFila(
            "SELECT id_dependencia, IFNULL(estado, 1) AS estado
             FROM dependencias
             WHERE UPPER(TRIM(nombre_dependencia)) = UPPER(TRIM('" . $escNombre . "'))
             LIMIT 1"
        );
        if ($existente) {
            $idDependencia = (int) $existente["id_dependencia"];
            if ((int) $existente["estado"] !== 1) {
                ejecutarConsulta("UPDATE dependencias SET estado = 1 WHERE id_dependencia = '$idDependencia'");
            }
            return $idDependencia;
        }

        $sqlInsertDependencia = "INSERT INTO dependencias (nombre_dependencia, estado)
                                 VALUES ('" . $escNombre . "', 1)";
        $idInsertado = ejecutarConsulta_retornarID($sqlInsertDependencia);
        if ((int) $idInsertado > 0) {
            return (int) $idInsertado;
        }

        $retry = ejecutarConsultaSimpleFila(
            "SELECT id_dependencia
             FROM dependencias
             WHERE UPPER(TRIM(nombre_dependencia)) = UPPER(TRIM('" . $escNombre . "'))
             LIMIT 1"
        );

        return $retry ? (int) $retry["id_dependencia"] : 0;
    }

    private function obtenerOCrearPermisoAccesoTotal()
    {
        $permiso = ejecutarConsultaSimpleFila(
            "SELECT id_permiso
             FROM permisos
             WHERE UPPER(TRIM(nombre_permiso)) IN ('ACCESO TOTAL DEL SISTEMA', 'ACCESO TOTAL SISTEMA')
             LIMIT 1"
        );
        if ($permiso) {
            $idPermiso = (int) $permiso["id_permiso"];
            ejecutarConsulta("UPDATE permisos SET estado = 1 WHERE id_permiso = '$idPermiso'");
            return $idPermiso;
        }

        $sqlInsertPermiso = "INSERT INTO permisos (nombre_permiso, descripcion, estado)
                             VALUES (
                                 'Acceso total del sistema',
                                 'Otorga acceso completo a todos los modulos y acciones del sistema.',
                                 1
                             )";
        $idInsertado = ejecutarConsulta_retornarID($sqlInsertPermiso);
        if ((int) $idInsertado > 0) {
            return (int) $idInsertado;
        }

        $retry = ejecutarConsultaSimpleFila(
            "SELECT id_permiso
             FROM permisos
             WHERE UPPER(TRIM(nombre_permiso)) IN ('ACCESO TOTAL DEL SISTEMA', 'ACCESO TOTAL SISTEMA')
             LIMIT 1"
        );

        return $retry ? (int) $retry["id_permiso"] : 0;
    }

    public function registrarPrimerUsuarioInicial($data)
    {
        $validacion = $this->validarDatosPrimerUsuario($data);
        if (!$validacion["ok"]) {
            return array("ok" => false, "codigo" => "DATOS_INVALIDOS", "msg" => $validacion["msg"]);
        }

        $payload = $validacion["data"];
        $lockKey = "bootstrap_primer_usuario_sala";
        $lock = ejecutarConsultaSimpleFila("SELECT GET_LOCK('" . $this->esc($lockKey) . "', 10) AS lock_ok");
        if (!$lock || (int) $lock["lock_ok"] !== 1) {
            return array(
                "ok" => false,
                "codigo" => "LOCK_NO_DISPONIBLE",
                "msg" => "No se pudo reservar el proceso de configuracion inicial. Intente nuevamente."
            );
        }

        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $totalUsuarios = ejecutarConsultaSimpleFila("SELECT COUNT(*) AS total FROM usuarios");
            if ($totalUsuarios && (int) $totalUsuarios["total"] > 0) {
                throw new Exception("El sistema ya tiene usuarios registrados. No se puede crear un primer usuario.");
            }

            $duplicadoUsuario = ejecutarConsultaSimpleFila(
                "SELECT id_usuario
                 FROM usuarios
                 WHERE UPPER(TRIM(usuario)) = UPPER(TRIM('" . $this->esc($payload["usuario"]) . "'))
                 LIMIT 1"
            );
            if ($duplicadoUsuario) {
                throw new Exception("El nombre de usuario indicado ya existe.");
            }

            $duplicadoCedula = ejecutarConsultaSimpleFila(
                "SELECT id_empleado
                 FROM empleados
                 WHERE cedula = '" . (int) $payload["cedula"] . "'
                 LIMIT 1"
            );
            if ($duplicadoCedula) {
                throw new Exception("La cedula indicada ya esta asociada a un empleado.");
            }

            $idDependencia = $this->obtenerOCrearDependenciaInicial($payload["dependencia"]);
            if ($idDependencia <= 0) {
                throw new Exception("No se pudo preparar la dependencia inicial del sistema.");
            }

            $sqlEmpleado = "INSERT INTO empleados (
                                cedula,
                                nombre,
                                apellido,
                                id_dependencia,
                                telefono,
                                correo,
                                direccion,
                                estado
                            ) VALUES (
                                '" . (int) $payload["cedula"] . "',
                                '" . $this->esc($payload["nombre"]) . "',
                                '" . $this->esc($payload["apellido"]) . "',
                                '" . (int) $idDependencia . "',
                                NULL,
                                " . ($payload["correo"] !== "" ? "'" . $this->esc($payload["correo"]) . "'" : "NULL") . ",
                                NULL,
                                1
                            )";
            $idEmpleado = ejecutarConsulta_retornarID($sqlEmpleado);
            if ((int) $idEmpleado <= 0) {
                throw new Exception("No se pudo crear el empleado para el usuario inicial.");
            }

            $hash = hash("sha256", (string) $payload["password"]);
            $sqlUsuario = "INSERT INTO usuarios (
                               id_empleado,
                               usuario,
                               password,
                               rol,
                               estado
                           ) VALUES (
                               '" . (int) $idEmpleado . "',
                               '" . $this->esc($payload["usuario"]) . "',
                               '" . $this->esc($hash) . "',
                               'ADMIN',
                               1
                           )";
            $idUsuario = ejecutarConsulta_retornarID($sqlUsuario);
            if ((int) $idUsuario <= 0) {
                throw new Exception("No se pudo crear el primer usuario del sistema.");
            }

            $this->asegurarRegistroSeguridadAcceso((int) $idUsuario);
            ejecutarConsulta(
                "UPDATE usuarios_seguridad_acceso
                 SET intentos_fallidos = 0,
                     bloqueado = 0,
                     fecha_bloqueo = NULL,
                     password_temporal = 0,
                     fecha_password_temporal = NULL
                 WHERE id_usuario = '" . (int) $idUsuario . "'"
            );

            $idPermisoAccesoTotal = $this->obtenerOCrearPermisoAccesoTotal();

            $idsPermisos = array();
            $rsPermisos = ejecutarConsulta(
                "SELECT id_permiso
                 FROM permisos
                 WHERE IFNULL(estado, 1) = 1
                 ORDER BY id_permiso ASC"
            );
            if ($rsPermisos) {
                while ($permiso = $rsPermisos->fetch_assoc()) {
                    $idsPermisos[] = (int) $permiso["id_permiso"];
                }
            }

            if ($idPermisoAccesoTotal > 0 && !in_array((int) $idPermisoAccesoTotal, $idsPermisos, true)) {
                $idsPermisos[] = (int) $idPermisoAccesoTotal;
            }

            $idsPermisos = array_values(array_unique(array_filter($idsPermisos)));
            foreach ($idsPermisos as $idPermiso) {
                ejecutarConsulta(
                    "INSERT INTO usuario_permisos (id_usuario, id_permiso, estado)
                     VALUES ('" . (int) $idUsuario . "', '" . (int) $idPermiso . "', 1)
                     ON DUPLICATE KEY UPDATE estado = 1"
                );
            }

            $filaUsuario = $this->obtenerUsuarioPorId((int) $idUsuario, true);
            if (!$filaUsuario) {
                throw new Exception("No se pudo consultar el usuario inicial creado.");
            }

            $conexion->commit();
            return array(
                "ok" => true,
                "codigo" => "PRIMER_USUARIO_CREADO",
                "msg" => "Primer usuario administrador creado correctamente.",
                "usuario" => $this->construirUsuarioSesion($filaUsuario)
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array(
                "ok" => false,
                "codigo" => "ERROR_CONFIGURACION_INICIAL",
                "msg" => $exception->getMessage()
            );
        } finally {
            ejecutarConsultaSimpleFila("SELECT RELEASE_LOCK('" . $this->esc($lockKey) . "')");
        }
    }

    public function verificarAcceso($usuario, $password)
    {
        $usuario = trim((string) $usuario);
        $password = (string) $password;

        if (!$this->existenUsuariosRegistrados()) {
            return array(
                "ok" => false,
                "codigo" => "SETUP_REQUERIDO",
                "msg" => "No hay usuarios registrados. Debe crear el primer usuario administrador."
            );
        }

        if ($usuario === "" || $password === "") {
            return array(
                "ok" => false,
                "codigo" => "DATOS_INCOMPLETOS",
                "msg" => "Debe indicar usuario y contrasena."
            );
        }

        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $fila = $this->obtenerUsuarioPorLogin($usuario, true);
            if (!$fila) {
                $conexion->rollback();
                $this->registrarEventoAutenticacion(
                    "LOGIN_FAIL",
                    "Intento fallido de inicio de sesion",
                    "Intento fallido para el usuario '" . $usuario . "'. Usuario o contrasena invalida.",
                    0,
                    $usuario
                );
                return array(
                    "ok" => false,
                    "codigo" => "CREDENCIALES_INVALIDAS",
                    "msg" => "Usuario o contrasena invalida."
                );
            }

            $idUsuario = (int) $fila["id_usuario"];
            $this->asegurarRegistroSeguridadAcceso($idUsuario);
            $fila = $this->obtenerUsuarioPorLogin($usuario, true);
            if (!$fila) {
                throw new Exception("No se pudo consultar el usuario para autenticacion.");
            }

            if ((int) $fila["bloqueado"] === 1) {
                $conexion->commit();
                $this->registrarEventoAutenticacion(
                    "LOGIN_FAIL",
                    "Intento fallido de inicio de sesion",
                    "Intento de acceso rechazado para el usuario '" . $fila["usuario"] . "' porque la cuenta ya se encuentra bloqueada.",
                    $idUsuario,
                    $fila["usuario"]
                );
                return array(
                    "ok" => false,
                    "codigo" => "BLOQUEADO",
                    "requiere_recuperacion" => true,
                    "msg" => "El usuario fue bloqueado por seguridad. Debe recuperar la contrasena desde el inicio de sesion."
                );
            }

            $hash = hash("sha256", $password);
            $hashGuardado = strtolower((string) $fila["password"]);
            if (hash_equals($hashGuardado, strtolower($hash))) {
                if (!$this->reiniciarSeguridadAcceso($idUsuario)) {
                    throw new Exception("No se pudo reiniciar el estado de seguridad del usuario.");
                }

                $conexion->commit();
                $usuarioSesion = $this->construirUsuarioSesion($fila);
                $msg = (int) $usuarioSesion["password_temporal"] === 1
                    ? "Acceso autorizado con clave temporal. Cambie su contrasena al iniciar sesion."
                    : "Acceso autorizado.";
                $detalleLogin = "Inicio de sesion exitoso para el usuario '" . $fila["usuario"] . "'.";
                if ((int) $usuarioSesion["password_temporal"] === 1) {
                    $detalleLogin .= " El acceso se realizo con una clave temporal.";
                }
                $this->registrarEventoAutenticacion(
                    "LOGIN_OK",
                    "Inicio de sesion exitoso",
                    $detalleLogin,
                    $idUsuario,
                    $fila["usuario"]
                );

                return array(
                    "ok" => true,
                    "msg" => $msg,
                    "usuario" => $usuarioSesion
                );
            }

            $resultadoIntento = $this->incrementarIntentoFallido($idUsuario);
            if (!$resultadoIntento["ok"]) {
                throw new Exception($resultadoIntento["msg"]);
            }

            $conexion->commit();
            $detalleIntentoFallido = "Intento fallido para el usuario '" . $fila["usuario"] . "'. Intentos acumulados: " . (int) $resultadoIntento["intentos"] . ".";
            if (!empty($resultadoIntento["bloqueado"])) {
                $detalleIntentoFallido .= " La cuenta fue bloqueada automaticamente.";
            } else {
                $detalleIntentoFallido .= " Intentos restantes antes del bloqueo: " . (int) $resultadoIntento["restantes"] . ".";
            }
            $this->registrarEventoAutenticacion(
                "LOGIN_FAIL",
                "Intento fallido de inicio de sesion",
                $detalleIntentoFallido,
                $idUsuario,
                $fila["usuario"]
            );

            if ($resultadoIntento["bloqueado"]) {
                $this->registrarEventoAutenticacion(
                    "BLOQUEO_USUARIO",
                    "Usuario bloqueado por seguridad",
                    "El usuario '" . $fila["usuario"] . "' fue bloqueado despues de " . (int) $resultadoIntento["intentos"] . " intentos fallidos.",
                    $idUsuario,
                    $fila["usuario"]
                );
                $resultadoCorreo = $this->notificarBloqueoUsuario($fila);
                $mensajeBloqueo = "El usuario fue bloqueado por seguridad al superar " . $this->maxIntentosPermitidos . " intentos fallidos. Debe recuperar la contrasena.";
                if (!$resultadoCorreo["ok"]) {
                    $mensajeBloqueo .= " " . $resultadoCorreo["msg"];
                }

                return array(
                    "ok" => false,
                    "codigo" => "BLOQUEADO",
                    "requiere_recuperacion" => true,
                    "msg" => $mensajeBloqueo
                );
            }

            return array(
                "ok" => false,
                "codigo" => "CREDENCIALES_INVALIDAS",
                "intentos_restantes" => (int) $resultadoIntento["restantes"],
                "msg" => "Usuario o contrasena invalida. Intentos restantes antes de bloqueo: " . (int) $resultadoIntento["restantes"] . "."
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            registrarFallaSistema("AUTH_LOGIN", "No se pudo validar el acceso.", array(
                "usuario" => $usuario,
                "error" => $exception->getMessage()
            ));
            return array(
                "ok" => false,
                "codigo" => "ERROR",
                "msg" => "No se pudo validar el acceso: " . $exception->getMessage()
            );
        }
    }

    public function solicitarRecuperacionClave($usuario, $cedula)
    {
        $usuario = trim((string) $usuario);
        $cedula = preg_replace('/[^0-9]/', '', (string) $cedula);

        if ($usuario === "" || $cedula === "") {
            return array(
                "ok" => false,
                "codigo" => "DATOS_INCOMPLETOS",
                "msg" => "Debe indicar el usuario y la cedula para recuperar la contrasena."
            );
        }

        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $fila = $this->obtenerUsuarioPorLogin($usuario, true);
            if (!$fila) {
                throw new Exception("No existe un usuario activo con los datos indicados.");
            }

            $cedulaUsuario = preg_replace('/[^0-9]/', '', (string) (isset($fila["cedula"]) ? $fila["cedula"] : ""));
            if ($cedulaUsuario === "" || $cedulaUsuario !== $cedula) {
                throw new Exception("La cedula no coincide con el usuario indicado.");
            }

            $correo = trim((string) (isset($fila["correo"]) ? $fila["correo"] : ""));
            if (!$this->esCorreoValido($correo)) {
                throw new Exception("El empleado asociado al usuario no tiene un correo valido registrado.");
            }

            $config = $this->obtenerConfiguracionSmtpActiva();
            if (!$config) {
                throw new Exception("No hay configuracion SMTP activa para enviar la recuperacion.");
            }

            $idUsuario = (int) $fila["id_usuario"];
            $claveTemporal = $this->generarClaveTemporal(10);
            $hash = hash("sha256", $claveTemporal);

            if (!ejecutarConsulta(
                "UPDATE usuarios
                 SET password = '" . $this->esc($hash) . "'
                 WHERE id_usuario = '$idUsuario'
                 LIMIT 1"
            )) {
                throw new Exception("No se pudo actualizar la clave temporal del usuario.");
            }

            $this->asegurarRegistroSeguridadAcceso($idUsuario);
            if (!$this->desbloquearSeguridadAcceso($idUsuario, 0, "Recuperacion de clave temporal")) {
                throw new Exception("No se pudo restablecer el acceso del usuario.");
            }

            if (!ejecutarConsulta(
                "UPDATE usuarios_seguridad_acceso
                 SET password_temporal = 1,
                     fecha_password_temporal = NOW()
                 WHERE id_usuario = '$idUsuario'"
            )) {
                throw new Exception("No se pudo actualizar el estado de seguridad del usuario.");
            }

            $asunto = "Recuperacion de contrasena - clave temporal";
            $mensaje = $this->plantillaCorreoRecuperacion($fila, $claveTemporal);
            $this->enviarCorreoSmtpHtml($config, $correo, $asunto, $mensaje);

            $conexion->commit();
            return array(
                "ok" => true,
                "codigo" => "RECUPERACION_ENVIADA",
                "msg" => "Se envio una clave temporal al correo registrado del empleado asociado al usuario."
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            registrarFallaSistema("AUTH_RECOVERY", "No se pudo procesar la recuperacion de clave.", array(
                "usuario" => $usuario,
                "error" => $exception->getMessage()
            ));
            return array(
                "ok" => false,
                "codigo" => "ERROR_RECUPERACION",
                "msg" => $exception->getMessage()
            );
        }
    }

    public function listarPermisosActivos()
    {
        $sql = "SELECT id_permiso, nombre_permiso
                FROM permisos
                WHERE IFNULL(estado, 1) = 1
                ORDER BY id_permiso ASC";
        $rspta = ejecutarConsulta($sql);
        $items = array();

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $items[] = array(
                    "id_permiso" => (int) $row["id_permiso"],
                    "nombre_permiso" => (string) $row["nombre_permiso"]
                );
            }
        }

        return $items;
    }

    public function listarPermisosAsignadosUsuario($idUsuario)
    {
        $sql = "SELECT p.id_permiso, p.nombre_permiso
                FROM usuario_permisos up
                INNER JOIN permisos p ON p.id_permiso = up.id_permiso
                WHERE up.id_usuario = '" . (int) $idUsuario . "'
                  AND IFNULL(up.estado, 1) = 1
                  AND IFNULL(p.estado, 1) = 1
                ORDER BY p.id_permiso ASC";
        $rspta = ejecutarConsulta($sql);
        $items = array();

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $items[] = array(
                    "id_permiso" => (int) $row["id_permiso"],
                    "nombre_permiso" => (string) $row["nombre_permiso"]
                );
            }
        }

        return $items;
    }

    public function obtenerPermisosSesion($idUsuario, $rol)
    {
        $permisosActivos = $this->listarPermisosActivos();
        $permisosAsignados = $this->listarPermisosAsignadosUsuario($idUsuario);
        $permisosSesion = array();
        $tieneAccesoTotal = false;

        foreach ($permisosActivos as $permiso) {
            $permisosSesion[$permiso["nombre_permiso"]] = 0;
        }

        foreach ($permisosAsignados as $permiso) {
            $nombre = strtoupper(trim((string) $permiso["nombre_permiso"]));
            if ($permiso["id_permiso"] === 99 || $nombre === "ACCESO TOTAL DEL SISTEMA" || $nombre === "ACCESO TOTAL SISTEMA") {
                $tieneAccesoTotal = true;
            }

            $permisosSesion[$permiso["nombre_permiso"]] = 1;
        }

        if (strtoupper((string) $rol) === "ADMIN" || $tieneAccesoTotal) {
            foreach ($permisosActivos as $permiso) {
                $permisosSesion[$permiso["nombre_permiso"]] = 1;
            }
        }

        return $permisosSesion;
    }

    public function registrarCierreSesion($idUsuario, $usuario = "")
    {
        $idUsuario = (int) $idUsuario;
        if ($idUsuario <= 0) {
            return false;
        }

        $usuario = trim((string) $usuario);
        $detalle = "Cierre de sesion del usuario";
        if ($usuario !== "") {
            $detalle .= " '" . $usuario . "'";
        }
        $detalle .= ".";

        return $this->registrarEventoAutenticacion(
            "LOGOUT",
            "Cierre de sesion",
            $detalle,
            $idUsuario,
            $usuario
        );
    }
}
?>
