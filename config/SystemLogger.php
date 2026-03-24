<?php
if (!defined("SYSTEM_FAILURE_LOG")) {
    define(
        "SYSTEM_FAILURE_LOG",
        dirname(__DIR__) . DIRECTORY_SEPARATOR . "storage" . DIRECTORY_SEPARATOR . "logs" . DIRECTORY_SEPARATOR . "system_failures.log"
    );
}

if (!function_exists("bootstrapSystemLogger")) {
    function bootstrapSystemLogger()
    {
        $logFile = SYSTEM_FAILURE_LOG;
        $logDir = dirname($logFile);

        if (!is_dir($logDir)) {
            @mkdir($logDir, 0777, true);
        }

        if (!file_exists($logFile)) {
            @touch($logFile);
        }

        @ini_set("log_errors", "1");
        @ini_set("error_log", $logFile);

        return is_file($logFile);
    }
}

if (!function_exists("resumirConsultaSistema")) {
    function resumirConsultaSistema($sql)
    {
        $sql = preg_replace('/\s+/', ' ', trim((string) $sql));
        if ($sql === "") {
            return "SQL vacio";
        }

        $patrones = array(
            '/^(SELECT)\s+.*?\s+(FROM)\s+`?([A-Za-z0-9_]+)`?/i' => '$1 $2 $3',
            '/^(INSERT\s+INTO)\s+`?([A-Za-z0-9_]+)`?/i' => '$1 $2',
            '/^(UPDATE)\s+`?([A-Za-z0-9_]+)`?/i' => '$1 $2',
            '/^(DELETE\s+FROM)\s+`?([A-Za-z0-9_]+)`?/i' => '$1 $2',
            '/^(CALL)\s+`?([A-Za-z0-9_]+)`?/i' => '$1 $2'
        );

        foreach ($patrones as $patron => $reemplazo) {
            if (preg_match($patron, $sql)) {
                return preg_replace($patron, $reemplazo, $sql);
            }
        }

        return strlen($sql) > 160 ? substr($sql, 0, 160) . "..." : $sql;
    }
}

if (!function_exists("obtenerOrigenFallaSistema")) {
    function obtenerOrigenFallaSistema()
    {
        $trace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 8);
        foreach ($trace as $frame) {
            $archivo = isset($frame["file"]) ? (string) $frame["file"] : "";
            if ($archivo === "") {
                continue;
            }

            if (substr($archivo, -strlen("SystemLogger.php")) === "SystemLogger.php") {
                continue;
            }

            $linea = isset($frame["line"]) ? (int) $frame["line"] : 0;
            return $archivo . ($linea > 0 ? ":" . $linea : "");
        }

        return "origen_desconocido";
    }
}

if (!function_exists("registrarFallaSistema")) {
    function registrarFallaSistema($contexto, $mensaje, $detalles = array())
    {
        bootstrapSystemLogger();

        $contexto = strtoupper(trim((string) $contexto));
        if ($contexto === "") {
            $contexto = "SISTEMA";
        }

        $payload = array();
        if (is_array($detalles)) {
            foreach ($detalles as $clave => $valor) {
                if ($valor === null || $valor === "") {
                    continue;
                }

                if (is_scalar($valor)) {
                    $payload[$clave] = $valor;
                    continue;
                }

                $payload[$clave] = json_encode($valor, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            }
        }

        if (!isset($payload["origen"])) {
            $payload["origen"] = obtenerOrigenFallaSistema();
        }

        if (!isset($payload["ip"])) {
            $payload["ip"] = isset($_SERVER["REMOTE_ADDR"]) ? (string) $_SERVER["REMOTE_ADDR"] : "CLI";
        }

        $linea = "[" . date("Y-m-d H:i:s") . "] " . $contexto . " | " . trim((string) $mensaje);
        if (!empty($payload)) {
            $linea .= " | " . json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }

        @error_log($linea . PHP_EOL, 3, SYSTEM_FAILURE_LOG);
    }
}
?>
