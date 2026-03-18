<?php
require_once "../config/Conexion.php";

class Configuracion
{
    private $catalogos = array();
    private $grupos = array();
    private $columnasTablaCache = array();

    public function __construct()
    {
        $this->grupos = array(
            "comunidades" => array(
                "key" => "comunidades",
                "label" => "Comunidades",
                "icon" => "fas fa-map-marked-alt",
                "description" => "Gestiona las comunidades disponibles para el registro de beneficiarios."
            ),
            "ayuda_social" => array(
                "key" => "ayuda_social",
                "label" => "Ayuda Social",
                "icon" => "fas fa-hands-helping",
                "description" => "Administra tipos de ayuda y las solicitudes compartidas con Servicios Publicos.",
            ),
            "servicios_publicos" => array(
                "key" => "servicios_publicos",
                "label" => "Servicios Publicos",
                "icon" => "fas fa-building",
                "description" => "Administra los tipos del modulo. Las solicitudes se controlan desde el catalogo compartido.",
            ),
            "seguridad_emergencia" => array(
                "key" => "seguridad_emergencia",
                "label" => "Seguridad y Emergencia",
                "icon" => "fas fa-shield-alt",
                "description" => "Administra tipos del modulo de seguridad y emergencia. Las solicitudes se gestionan desde el catalogo compartido."
            ),
            "base_institucional" => array(
                "key" => "base_institucional",
                "label" => "Base Institucional",
                "icon" => "fas fa-university",
                "description" => "Controla estados generales, dependencias y permisos del sistema."
            )
        );

        $claseBadgeOptions = array(
            array("value" => "draft", "label" => "Borrador"),
            array("value" => "info", "label" => "Informativo"),
            array("value" => "active", "label" => "Activo"),
            array("value" => "warning", "label" => "Advertencia"),
            array("value" => "danger", "label" => "Critico"),
            array("value" => "inactive", "label" => "Inactivo"),
            array("value" => "secondary", "label" => "Secundario")
        );

        $booleanOptions = array(
            array("value" => "0", "label" => "No"),
            array("value" => "1", "label" => "Si")
        );

        $this->catalogos = array(
            "comunidades" => array(
                "key" => "comunidades",
                "group" => "comunidades",
                "title" => "Comunidades",
                "description" => "Catalogo maestro usado en Beneficiarios y en los modulos de gestion social.",
                "table" => "comunidades",
                "pk" => "id_comunidad",
                "display_field" => "nombre_comunidad",
                "state_field" => "estado",
                "order_by" => "nombre_comunidad ASC",
                "search_placeholder" => "Buscar comunidad por nombre",
                "fields" => array(
                    array(
                        "name" => "nombre_comunidad",
                        "label" => "Nombre de la comunidad",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 120,
                        "placeholder" => "Ej: Comunidad La Esperanza",
                        "help" => "Nombre visible de la comunidad en el sistema.",
                        "cast" => "string"
                    )
                ),
                "columns" => array(
                    array("key" => "nombre_comunidad", "label" => "Comunidad", "type" => "text"),
                    array("key" => "fecha_registro_formateada", "label" => "Registro", "type" => "text")
                ),
                "unique_fields" => array("nombre_comunidad")
            ),
            "tipos_ayuda_social" => array(
                "key" => "tipos_ayuda_social",
                "group" => "ayuda_social",
                "title" => "Tipos de ayuda",
                "description" => "Opciones maestras compartidas para el campo tipo de ayuda en todos los modulos.",
                "table" => "tipos_ayuda_social",
                "pk" => "id_tipo_ayuda_social",
                "display_field" => "nombre_tipo_ayuda",
                "state_field" => "estado",
                "order_by" => "nombre_tipo_ayuda ASC",
                "search_placeholder" => "Buscar tipo de ayuda",
                "fields" => array(
                    array(
                        "name" => "nombre_tipo_ayuda",
                        "label" => "Tipo de ayuda",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 120,
                        "placeholder" => "Ej: Medicas",
                        "help" => "Nombre del tipo de ayuda que usara el modulo.",
                        "cast" => "string"
                    ),
                    array(
                        "name" => "requiere_ambulancia",
                        "label" => "Requiere ambulancia?",
                        "type" => "select",
                        "required" => true,
                        "options" => $booleanOptions,
                        "help" => "Define si este tipo debe activar sugerencia y asignacion de ambulancia en Seguridad y Emergencia.",
                        "cast" => "bool"
                    )
                ),
                "columns" => array(
                    array("key" => "nombre_tipo_ayuda", "label" => "Tipo", "type" => "text"),
                    array("key" => "requiere_ambulancia", "label" => "Requiere ambulancia", "type" => "boolean"),
                    array("key" => "fecha_registro_formateada", "label" => "Registro", "type" => "text")
                ),
                "unique_fields" => array("nombre_tipo_ayuda")
            ),
            "solicitudes_generales" => array(
                "key" => "solicitudes_generales",
                "group" => "ayuda_social",
                "title" => "Solicitudes compartidas",
                "description" => "Origen o canal de solicitud usado tanto por Ayuda Social como por Servicios Publicos.",
                "table" => "solicitudes_generales",
                "pk" => "id_solicitud_general",
                "display_field" => "nombre_solicitud",
                "state_field" => "estado",
                "order_by" => "nombre_solicitud ASC",
                "search_placeholder" => "Buscar por codigo o nombre de solicitud",
                "fields" => array(
                    array(
                        "name" => "codigo_solicitud",
                        "label" => "Codigo",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 20,
                        "placeholder" => "Ej: SOL-ATC",
                        "help" => "Codigo corto unico del canal o tipo de solicitud.",
                        "cast" => "string",
                        "normalize" => "upper"
                    ),
                    array(
                        "name" => "nombre_solicitud",
                        "label" => "Tipo de solicitud",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 120,
                        "placeholder" => "Ej: Atencion al ciudadano",
                        "help" => "Nombre visible del canal o tipo de solicitud compartido.",
                        "cast" => "string"
                    )
                ),
                "columns" => array(
                    array("key" => "codigo_solicitud", "label" => "Codigo", "type" => "text"),
                    array("key" => "nombre_solicitud", "label" => "Solicitud", "type" => "text"),
                    array("key" => "fecha_registro_formateada", "label" => "Registro", "type" => "text")
                ),
                "unique_fields" => array("codigo_solicitud", "nombre_solicitud")
            ),
            "tipos_servicios_publicos" => array(
                "key" => "tipos_servicios_publicos",
                "group" => "servicios_publicos",
                "title" => "Tipos de servicios publicos",
                "description" => "Catalogo maestro del servicio publico solicitado.",
                "table" => "tipos_servicios_publicos",
                "pk" => "id_tipo_servicio_publico",
                "display_field" => "nombre_tipo_servicio",
                "state_field" => "estado",
                "order_by" => "nombre_tipo_servicio ASC",
                "search_placeholder" => "Buscar por codigo o nombre",
                "fields" => array(
                    array(
                        "name" => "codigo_tipo_servicio_publico",
                        "label" => "Codigo",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 20,
                        "placeholder" => "Ej: SP-AGU",
                        "help" => "Codigo corto unico del servicio publico.",
                        "cast" => "string",
                        "normalize" => "upper"
                    ),
                    array(
                        "name" => "nombre_tipo_servicio",
                        "label" => "Nombre del servicio",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 120,
                        "placeholder" => "Ej: Agua",
                        "help" => "Nombre visible del servicio publico.",
                        "cast" => "string"
                    )
                ),
                "columns" => array(
                    array("key" => "codigo_tipo_servicio_publico", "label" => "Codigo", "type" => "text"),
                    array("key" => "nombre_tipo_servicio", "label" => "Servicio", "type" => "text"),
                    array("key" => "fecha_registro_formateada", "label" => "Registro", "type" => "text")
                ),
                "unique_fields" => array("codigo_tipo_servicio_publico", "nombre_tipo_servicio")
            ),
            "tipos_seguridad_emergencia" => array(
                "key" => "tipos_seguridad_emergencia",
                "group" => "seguridad_emergencia",
                "title" => "Tipos de seguridad y emergencia",
                "description" => "Servicios disponibles para el registro de seguridad y emergencia.",
                "table" => "tipos_seguridad_emergencia",
                "pk" => "id_tipo_seguridad",
                "display_field" => "nombre_tipo",
                "state_field" => "estado",
                "order_by" => "nombre_tipo ASC",
                "search_placeholder" => "Buscar tipo de servicio",
                "fields" => array(
                    array(
                        "name" => "nombre_tipo",
                        "label" => "Nombre del servicio",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 120,
                        "placeholder" => "Ej: Atencion prehospitalaria",
                        "help" => "Nombre del servicio de seguridad o emergencia.",
                        "cast" => "string"
                    ),
                    array(
                        "name" => "requiere_ambulancia",
                        "label" => "Requiere ambulancia?",
                        "type" => "select",
                        "required" => true,
                        "options" => $booleanOptions,
                        "help" => "Define si este servicio exige sugerencia y asignacion de ambulancia.",
                        "cast" => "bool"
                    )
                ),
                "columns" => array(
                    array("key" => "nombre_tipo", "label" => "Servicio", "type" => "text"),
                    array("key" => "requiere_ambulancia", "label" => "Requiere ambulancia", "type" => "boolean"),
                    array("key" => "fecha_registro_formateada", "label" => "Registro", "type" => "text")
                ),
                "unique_fields" => array("nombre_tipo")
            ),
            "estados_solicitudes" => array(
                "key" => "estados_solicitudes",
                "group" => "base_institucional",
                "title" => "Estados generales de solicitudes",
                "description" => "Estados compartidos por Ayuda Social, Servicios Publicos y Seguridad.",
                "table" => "estados_solicitudes",
                "pk" => "id_estado_solicitud",
                "display_field" => "nombre_estado",
                "state_field" => "estado",
                "order_by" => "orden_visual ASC, nombre_estado ASC",
                "search_placeholder" => "Buscar por codigo o nombre del estado",
                "protected_codes" => array("REGISTRADA", "EN_GESTION", "ATENDIDA", "NO_ATENDIDA"),
                "locked_fields_when_protected" => array("codigo_estado", "es_atendida"),
                "fields" => array(
                    array(
                        "name" => "codigo_estado",
                        "label" => "Codigo interno",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 40,
                        "placeholder" => "Ej: EN_PROCESO",
                        "help" => "Codigo unico usado internamente por el sistema.",
                        "cast" => "string",
                        "normalize" => "upper"
                    ),
                    array(
                        "name" => "nombre_estado",
                        "label" => "Nombre del estado",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 80,
                        "placeholder" => "Ej: En proceso",
                        "help" => "Nombre visible del estado en los modulos.",
                        "cast" => "string"
                    ),
                    array(
                        "name" => "descripcion",
                        "label" => "Descripcion",
                        "type" => "textarea",
                        "required" => false,
                        "maxlength" => 190,
                        "placeholder" => "Descripcion breve del significado del estado",
                        "help" => "Texto corto que explica el uso del estado.",
                        "cast" => "string"
                    ),
                    array(
                        "name" => "clase_badge",
                        "label" => "Apariencia visual",
                        "type" => "select",
                        "required" => true,
                        "options" => $claseBadgeOptions,
                        "help" => "Estilo visual con el que se mostrara el estado.",
                        "cast" => "string"
                    ),
                    array(
                        "name" => "es_atendida",
                        "label" => "Marca de atencion",
                        "type" => "select",
                        "required" => true,
                        "options" => $booleanOptions,
                        "help" => "Indica si el estado debe considerarse como solicitud atendida.",
                        "cast" => "bool"
                    ),
                    array(
                        "name" => "orden_visual",
                        "label" => "Orden visual",
                        "type" => "number",
                        "required" => true,
                        "min" => 0,
                        "placeholder" => "Ej: 1",
                        "help" => "Orden en el que aparecera el estado en las listas.",
                        "cast" => "int"
                    )
                ),
                "columns" => array(
                    array("key" => "codigo_estado", "label" => "Codigo", "type" => "text"),
                    array("key" => "nombre_estado", "label" => "Estado", "type" => "text"),
                    array("key" => "badge_preview", "label" => "Vista previa", "type" => "badge_preview"),
                    array("key" => "es_atendida", "label" => "Atendida", "type" => "boolean"),
                    array("key" => "orden_visual", "label" => "Orden", "type" => "number")
                ),
                "unique_fields" => array("codigo_estado", "nombre_estado")
            ),
            "dependencias" => array(
                "key" => "dependencias",
                "group" => "base_institucional",
                "title" => "Dependencias",
                "description" => "Areas institucionales asociadas a usuarios y empleados.",
                "table" => "dependencias",
                "pk" => "id_dependencia",
                "display_field" => "nombre_dependencia",
                "state_field" => "estado",
                "order_by" => "nombre_dependencia ASC",
                "search_placeholder" => "Buscar dependencia",
                "fields" => array(
                    array(
                        "name" => "nombre_dependencia",
                        "label" => "Nombre de la dependencia",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 100,
                        "placeholder" => "Ej: Atencion al ciudadano",
                        "help" => "Nombre oficial del area o dependencia.",
                        "cast" => "string"
                    )
                ),
                "columns" => array(
                    array("key" => "nombre_dependencia", "label" => "Dependencia", "type" => "text")
                ),
                "unique_fields" => array("nombre_dependencia")
            ),
            "permisos" => array(
                "key" => "permisos",
                "group" => "base_institucional",
                "title" => "Permisos",
                "description" => "Catalogo institucional de permisos y accesos del sistema.",
                "table" => "permisos",
                "pk" => "id_permiso",
                "display_field" => "nombre_permiso",
                "state_field" => "estado",
                "order_by" => "nombre_permiso ASC",
                "search_placeholder" => "Buscar permiso",
                "read_only" => true,
                "fields" => array(
                    array(
                        "name" => "nombre_permiso",
                        "label" => "Nombre del permiso",
                        "type" => "text",
                        "required" => true,
                        "maxlength" => 100,
                        "placeholder" => "Ej: Configuracion",
                        "help" => "Nombre corto del permiso usado por el sistema.",
                        "cast" => "string"
                    ),
                    array(
                        "name" => "descripcion",
                        "label" => "Descripcion",
                        "type" => "textarea",
                        "required" => false,
                        "maxlength" => 255,
                        "placeholder" => "Describe para que sirve este permiso",
                        "help" => "Descripcion opcional del permiso.",
                        "cast" => "string"
                    )
                ),
                "columns" => array(
                    array("key" => "nombre_permiso", "label" => "Permiso", "type" => "text"),
                    array("key" => "descripcion", "label" => "Descripcion", "type" => "text")
                ),
                "unique_fields" => array("nombre_permiso")
            )
        );
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

    private function obtenerColumnasTabla($tabla)
    {
        $tabla = trim((string) $tabla);
        if ($tabla === "") {
            return array();
        }

        if (isset($this->columnasTablaCache[$tabla])) {
            return $this->columnasTablaCache[$tabla];
        }

        $sql = "SELECT COLUMN_NAME
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = '" . $this->esc($tabla) . "'
                ORDER BY ORDINAL_POSITION ASC";
        $rspta = ejecutarConsulta($sql);
        $columnas = array();

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $nombre = isset($row["COLUMN_NAME"]) ? trim((string) $row["COLUMN_NAME"]) : "";
                if ($nombre !== "") {
                    $columnas[] = $nombre;
                }
            }
        }

        $this->columnasTablaCache[$tabla] = $columnas;
        return $columnas;
    }

    private function obtenerListaColumnasSelect($tabla, $alias = "")
    {
        $columnas = $this->obtenerColumnasTabla($tabla);
        if (empty($columnas)) {
            return "";
        }

        $prefijo = trim((string) $alias);
        if ($prefijo !== "") {
            $prefijo = "`" . $prefijo . "`.";
        }

        $items = array();
        foreach ($columnas as $columna) {
            $items[] = $prefijo . "`" . $columna . "`";
        }

        return implode(",\n                       ", $items);
    }

    private function obtenerCatalogo($catalogo)
    {
        return isset($this->catalogos[$catalogo]) ? $this->catalogos[$catalogo] : null;
    }

    private function catalogoEsSoloLectura($config)
    {
        return is_array($config) && !empty($config["read_only"]);
    }

    private function obtenerCampo($config, $campo)
    {
        if (!isset($config["fields"]) || !is_array($config["fields"])) {
            return null;
        }

        foreach ($config["fields"] as $field) {
            if ($field["name"] === $campo) {
                return $field;
            }
        }

        return null;
    }

    private function longitudTexto($texto)
    {
        if (function_exists("mb_strlen")) {
            return mb_strlen((string) $texto, "UTF-8");
        }

        return strlen((string) $texto);
    }

    private function normalizarValorCampo($field, $valor)
    {
        $valor = is_string($valor) ? trim($valor) : $valor;
        $cast = isset($field["cast"]) ? $field["cast"] : "string";

        if ($cast === "int") {
            return (int) $valor;
        }

        if ($cast === "bool") {
            return (string) $valor === "1" ? 1 : 0;
        }

        $valor = (string) $valor;
        if (isset($field["normalize"]) && $field["normalize"] === "upper") {
            $valor = strtoupper($valor);
        }

        return $valor;
    }

    private function validarCampos($config, $data)
    {
        $limpios = array();
        $errores = array();

        foreach ($config["fields"] as $field) {
            $name = $field["name"];
            $raw = isset($data[$name]) ? $data[$name] : "";
            $valor = $this->normalizarValorCampo($field, $raw);
            $esVacio = $valor === "" || $valor === null;

            if (!empty($field["required"]) && $esVacio && $valor !== 0) {
                $errores[] = "Debe completar el campo " . $field["label"] . ".";
                continue;
            }

            if (!$esVacio && isset($field["maxlength"]) && $this->longitudTexto($valor) > (int) $field["maxlength"]) {
                $errores[] = "El campo " . $field["label"] . " excede la longitud permitida.";
                continue;
            }

            if (isset($field["type"]) && $field["type"] === "number" && isset($field["min"]) && $valor < (int) $field["min"]) {
                $errores[] = "El campo " . $field["label"] . " debe ser mayor o igual a " . (int) $field["min"] . ".";
                continue;
            }

            if (isset($field["options"]) && is_array($field["options"]) && !$esVacio) {
                $permitidos = array();
                foreach ($field["options"] as $option) {
                    $permitidos[] = (string) $option["value"];
                }

                if (!in_array((string) $valor, $permitidos, true)) {
                    $errores[] = "El campo " . $field["label"] . " contiene un valor no permitido.";
                    continue;
                }
            }

            $limpios[$name] = $valor;
        }

        if (!empty($errores)) {
            return array("ok" => false, "msg" => $errores[0]);
        }

        return array("ok" => true, "data" => $limpios);
    }

    private function compararCampoSql($field, $valor)
    {
        $cast = isset($field["cast"]) ? $field["cast"] : "string";
        $nombreCampo = "`" . $field["name"] . "`";

        if ($cast === "int" || $cast === "bool") {
            return $nombreCampo . " = '" . (int) $valor . "'";
        }

        return "UPPER(TRIM(" . $nombreCampo . ")) = UPPER(TRIM('" . $this->esc($valor) . "'))";
    }

    private function obtenerCoincidenciasUnicas($config, $data, $excludeId)
    {
        $pk = $config["pk"];
        $tabla = $config["table"];
        $coincidencias = array();
        $ids = array();

        if (!isset($config["unique_fields"]) || !is_array($config["unique_fields"])) {
            return array("matches" => $coincidencias, "ids" => $ids);
        }

        foreach ($config["unique_fields"] as $uniqueField) {
            $field = $this->obtenerCampo($config, $uniqueField);
            if (!$field || !isset($data[$uniqueField])) {
                continue;
            }

            $valor = $data[$uniqueField];
            if ($valor === "" || $valor === null) {
                continue;
            }

            $sql = "SELECT `" . $pk . "`,
                           `" . $uniqueField . "`
                    FROM `" . $tabla . "`
                    WHERE " . $this->compararCampoSql($field, $valor);
            if ((int) $excludeId > 0) {
                $sql .= " AND `" . $pk . "` <> '" . (int) $excludeId . "'";
            }
            $sql .= " LIMIT 1";

            $row = ejecutarConsultaSimpleFila($sql);
            if ($row) {
                $coincidencias[$uniqueField] = $row;
                $ids[(int) $row[$pk]] = true;
            }
        }

        return array("matches" => $coincidencias, "ids" => array_keys($ids));
    }

    private function obtenerTextoCampo($config, $fieldName)
    {
        $field = $this->obtenerCampo($config, $fieldName);
        return $field ? $field["label"] : $fieldName;
    }

    private function resolverConflictoDuplicados($config, $matches, $ids)
    {
        if (count($ids) <= 1) {
            return array("ok" => true);
        }

        $campos = array();
        foreach ($matches as $fieldName => $row) {
            $campos[] = $this->obtenerTextoCampo($config, $fieldName);
        }

        return array(
            "ok" => false,
                "msg" => "Los valores ingresados coinciden con registros distintos en los campos " . implode(", ", $campos) . ". Revise la informacion antes de guardar."
        );
    }

    private function obtenerRegistroPorId($config, $id, $forUpdate = false)
    {
        $tabla = $config["table"];
        $pk = $config["pk"];
        $columnasSelect = $this->obtenerListaColumnasSelect($tabla);
        if ($columnasSelect === "") {
            return null;
        }

        $sql = "SELECT " . $columnasSelect . "
                FROM `" . $tabla . "`
                WHERE `" . $pk . "` = '" . (int) $id . "'
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    private function normalizarTextoComparable($texto)
    {
        $texto = trim((string) $texto);
        if ($texto === "") {
            return "";
        }

        $texto = strtr($texto, array(
            "á" => "a",
            "à" => "a",
            "ä" => "a",
            "â" => "a",
            "Á" => "A",
            "À" => "A",
            "Ä" => "A",
            "Â" => "A",
            "é" => "e",
            "è" => "e",
            "ë" => "e",
            "ê" => "e",
            "É" => "E",
            "È" => "E",
            "Ë" => "E",
            "Ê" => "E",
            "í" => "i",
            "ì" => "i",
            "ï" => "i",
            "î" => "i",
            "Í" => "I",
            "Ì" => "I",
            "Ï" => "I",
            "Î" => "I",
            "ó" => "o",
            "ò" => "o",
            "ö" => "o",
            "ô" => "o",
            "Ó" => "O",
            "Ò" => "O",
            "Ö" => "O",
            "Ô" => "O",
            "ú" => "u",
            "ù" => "u",
            "ü" => "u",
            "û" => "u",
            "Ú" => "U",
            "Ù" => "U",
            "Ü" => "U",
            "Û" => "U",
            "ñ" => "n",
            "Ñ" => "N"
        ));

        if (function_exists("mb_strtoupper")) {
            $texto = mb_strtoupper($texto, "UTF-8");
        } else {
            $texto = strtoupper($texto);
        }

        $texto = strtr($texto, array(
            "Á" => "A",
            "À" => "A",
            "Ä" => "A",
            "Â" => "A",
            "É" => "E",
            "È" => "E",
            "Ë" => "E",
            "Ê" => "E",
            "Í" => "I",
            "Ì" => "I",
            "Ï" => "I",
            "Î" => "I",
            "Ó" => "O",
            "Ò" => "O",
            "Ö" => "O",
            "Ô" => "O",
            "Ú" => "U",
            "Ù" => "U",
            "Ü" => "U",
            "Û" => "U",
            "Ñ" => "N"
        ));

        $texto = preg_replace('/[^A-Z0-9 ]+/u', ' ', $texto);
        $texto = preg_replace('/\s+/', ' ', $texto);
        return trim((string) $texto);
    }

    private function esNombreDependenciaDireccionGeneral($nombreDependencia)
    {
        return $this->normalizarTextoComparable($nombreDependencia) === "DIRECCION GENERAL";
    }

    private function mensajeRegistroProtegido($config, $row = null)
    {
        if (isset($config["key"]) && (string) $config["key"] === "dependencias") {
            return "La dependencia Direccion General es base del sistema y no puede modificarse ni eliminarse.";
        }

        return "Este registro es base del sistema y no puede desactivarse.";
    }

    private function obtenerIdDependenciaDireccionGeneral($excludeId = 0)
    {
        if (!$this->existeTabla("dependencias")) {
            return 0;
        }

        $sql = "SELECT id_dependencia, nombre_dependencia
                FROM dependencias";
        if ((int) $excludeId > 0) {
            $sql .= " WHERE id_dependencia <> '" . (int) $excludeId . "'";
        }

        $rspta = ejecutarConsulta($sql);
        if (!$rspta) {
            return 0;
        }

        while ($row = $rspta->fetch_assoc()) {
            $nombre = isset($row["nombre_dependencia"]) ? $row["nombre_dependencia"] : "";
            if ($this->esNombreDependenciaDireccionGeneral($nombre)) {
                return isset($row["id_dependencia"]) ? (int) $row["id_dependencia"] : 0;
            }
        }

        return 0;
    }

    private function registroProtegidoBloqueaEdicionCompleta($config, $row = null)
    {
        return isset($config["key"]) && (string) $config["key"] === "dependencias";
    }

    private function esRegistroProtegido($config, $row)
    {
        if (!$row || !is_array($config)) {
            return false;
        }

        if (isset($config["key"]) && (string) $config["key"] === "dependencias") {
            $nombre = isset($row["nombre_dependencia"]) ? $row["nombre_dependencia"] : "";
            return $this->esNombreDependenciaDireccionGeneral($nombre);
        }

        if (!isset($config["protected_codes"]) || !is_array($config["protected_codes"]) || !isset($row["codigo_estado"])) {
            return false;
        }

        return in_array((string) $row["codigo_estado"], $config["protected_codes"], true);
    }

    private function obtenerBloqueosRegistro($config, $row)
    {
        $locks = array();
        if ($this->esRegistroProtegido($config, $row) && !empty($config["locked_fields_when_protected"])) {
            foreach ($config["locked_fields_when_protected"] as $fieldName) {
                $locks[$fieldName] = true;
            }
        }

        return $locks;
    }

    private function formatearFecha($valor)
    {
        $valor = trim((string) $valor);
        if ($valor === "" || $valor === "0000-00-00 00:00:00" || $valor === "0000-00-00") {
            return "";
        }

        $timestamp = strtotime($valor);
        if ($timestamp === false) {
            return $valor;
        }

        return date("d/m/Y h:i A", $timestamp);
    }

    private function prepararFilaListado($config, $row)
    {
        $row[$config["pk"]] = isset($row[$config["pk"]]) ? (int) $row[$config["pk"]] : 0;
        $row["estado"] = isset($row[$config["state_field"]]) ? (int) $row[$config["state_field"]] : 0;
        $row["estado_texto"] = $row["estado"] === 1 ? "Activo" : "Inactivo";
        $row["estado_badge"] = $row["estado"] === 1 ? "active" : "inactive";
        $row["fecha_registro_formateada"] = isset($row["fecha_registro"]) ? $this->formatearFecha($row["fecha_registro"]) : "";
        $row["fecha_actualizacion_formateada"] = isset($row["fecha_actualizacion"]) ? $this->formatearFecha($row["fecha_actualizacion"]) : "";
        $row["registro_protegido"] = $this->esRegistroProtegido($config, $row);
        $row["puede_desactivar"] = $row["estado"] === 1 && !$row["registro_protegido"];
        $row["motivo_bloqueo"] = $row["registro_protegido"]
            ? $this->mensajeRegistroProtegido($config, $row)
            : "";

        if ($this->catalogoEsSoloLectura($config)) {
            $row["registro_protegido"] = true;
            $row["puede_desactivar"] = false;
            $row["motivo_bloqueo"] = "Este catalogo es fijo del sistema y no admite cambios.";
        }

        if ($config["key"] === "tipos_seguridad_emergencia" || $config["key"] === "tipos_ayuda_social") {
                $row["requiere_ambulancia_texto"] = !empty($row["requiere_ambulancia"]) ? "Si" : "No";
        }

        if ($config["key"] === "estados_solicitudes") {
            $row["badge_preview"] = $row["nombre_estado"];
                $row["es_atendida_texto"] = !empty($row["es_atendida"]) ? "Si" : "No";
        }

        return $row;
    }

    private function valorSql($field, $valor)
    {
        $cast = isset($field["cast"]) ? $field["cast"] : "string";

        if ($valor === "" && empty($field["required"]) && $cast === "string") {
            return "NULL";
        }

        if ($cast === "int" || $cast === "bool") {
            return "'" . (int) $valor . "'";
        }

        return "'" . $this->esc($valor) . "'";
    }

    private function construirSetCampos($config, $data, $locks)
    {
        $set = array();

        foreach ($config["fields"] as $field) {
            $name = $field["name"];
            if (!array_key_exists($name, $data) || isset($locks[$name])) {
                continue;
            }

            $set[] = "`" . $name . "` = " . $this->valorSql($field, $data[$name]);
        }

        return $set;
    }

    public function obtenerMetadatosUI()
    {
        $groups = array();
        foreach ($this->grupos as $groupKey => $group) {
            $groups[$groupKey] = array(
                "key" => $group["key"],
                "label" => $group["label"],
                "icon" => $group["icon"],
                "description" => $group["description"],
                "catalogs" => array()
            );
        }

        foreach ($this->catalogos as $catalogKey => $catalog) {
            $groups[$catalog["group"]]["catalogs"][] = array(
                "key" => $catalog["key"],
                "title" => $catalog["title"],
                "description" => $catalog["description"],
                "pk" => $catalog["pk"],
                "search_placeholder" => $catalog["search_placeholder"],
                "read_only" => !empty($catalog["read_only"]),
                "columns" => $catalog["columns"],
                "fields" => $catalog["fields"]
            );
        }

        return array("groups" => array_values($groups));
    }

    public function listar($catalogo, $estadoFiltro = "activos")
    {
        $config = $this->obtenerCatalogo($catalogo);
        if (!$config) {
            return array("ok" => false, "msg" => "Catalogo no soportado.");
        }

        $columnasSelect = $this->obtenerListaColumnasSelect($config["table"]);
        if ($columnasSelect === "") {
            return array("ok" => false, "msg" => "No se pudieron obtener columnas para el catalogo seleccionado.");
        }

        $where = "";
        if ($estadoFiltro === "activos") {
            $where = "WHERE `" . $config["state_field"] . "` = 1";
        } elseif ($estadoFiltro === "inactivos") {
            $where = "WHERE `" . $config["state_field"] . "` = 0";
        }

        $sql = "SELECT " . $columnasSelect . "
                FROM `" . $config["table"] . "`
                " . $where . "
                ORDER BY " . $config["order_by"];
        $rspta = ejecutarConsulta($sql);
        $items = array();

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $items[] = $this->prepararFilaListado($config, $row);
            }
        }

        $resumen = ejecutarConsultaSimpleFila("SELECT COUNT(*) AS total,
                                                      SUM(CASE WHEN `" . $config["state_field"] . "` = 1 THEN 1 ELSE 0 END) AS activos,
                                                      SUM(CASE WHEN `" . $config["state_field"] . "` = 0 THEN 1 ELSE 0 END) AS inactivos
                                               FROM `" . $config["table"] . "`");

        return array(
            "ok" => true,
            "msg" => "Listado cargado correctamente.",
            "items" => $items,
            "resumen" => array(
                "total" => isset($resumen["total"]) ? (int) $resumen["total"] : 0,
                "activos" => isset($resumen["activos"]) ? (int) $resumen["activos"] : 0,
                "inactivos" => isset($resumen["inactivos"]) ? (int) $resumen["inactivos"] : 0
            )
        );
    }

    public function mostrar($catalogo, $idRegistro)
    {
        $config = $this->obtenerCatalogo($catalogo);
        if (!$config) {
            return array("ok" => false, "msg" => "Catalogo no soportado.");
        }

        $row = $this->obtenerRegistroPorId($config, $idRegistro, false);
        if (!$row) {
            return array("ok" => false, "msg" => "Registro no encontrado.");
        }

        $row = $this->prepararFilaListado($config, $row);
        $locks = $this->obtenerBloqueosRegistro($config, $row);
        $notice = "";

        if ($this->catalogoEsSoloLectura($config)) {
            $notice = "Este catalogo es fijo del sistema y solo permite consulta.";
        } elseif ($row["registro_protegido"]) {
            if ($this->registroProtegidoBloqueaEdicionCompleta($config, $row)) {
                $notice = $this->mensajeRegistroProtegido($config, $row);
            } else {
                $notice = "Este registro es base del sistema. Solo puedes editar nombre, descripcion, apariencia visual y orden.";
            }
        }

        return array(
            "ok" => true,
            "msg" => "Registro cargado correctamente.",
            "item" => $row,
            "locks" => $locks,
            "notice" => $notice
        );
    }

    public function guardaryeditar($catalogo, $idRegistro, $data)
    {
        $config = $this->obtenerCatalogo($catalogo);
        if (!$config) {
            return array("ok" => false, "msg" => "Catalogo no soportado.");
        }
        if ($this->catalogoEsSoloLectura($config)) {
            return array("ok" => false, "msg" => "El catalogo " . $config["title"] . " es fijo del sistema y no admite creacion ni edicion.");
        }

        $validacion = $this->validarCampos($config, $data);
        if (!$validacion["ok"]) {
            return $validacion;
        }

        $payload = $validacion["data"];
        $esCatalogoDependencias = isset($config["key"]) && (string) $config["key"] === "dependencias";
        $conexion = $this->db();
        $pk = $config["pk"];
        $tabla = $config["table"];
        $idRegistro = (int) $idRegistro;

        $conexion->begin_transaction();

        try {
            if (
                $esCatalogoDependencias &&
                isset($payload["nombre_dependencia"]) &&
                $this->esNombreDependenciaDireccionGeneral($payload["nombre_dependencia"])
            ) {
                $idBaseExistente = $this->obtenerIdDependenciaDireccionGeneral($idRegistro);
                if ($idBaseExistente > 0) {
                    throw new Exception("La dependencia Direccion General ya existe y es unica en el sistema.");
                }
            }

            if ($idRegistro > 0) {
                $actual = $this->obtenerRegistroPorId($config, $idRegistro, true);
                if (!$actual) {
                    throw new Exception("Registro no encontrado.");
                }

                $locks = $this->obtenerBloqueosRegistro($config, $actual);
                if ($this->esRegistroProtegido($config, $actual)) {
                    if ($this->registroProtegidoBloqueaEdicionCompleta($config, $actual)) {
                        throw new Exception($this->mensajeRegistroProtegido($config, $actual));
                    }

                    foreach ($locks as $lockedField => $flag) {
                        if (!array_key_exists($lockedField, $payload)) {
                            continue;
                        }

                        $valorActual = isset($actual[$lockedField]) ? (string) $actual[$lockedField] : "";
                        $valorNuevo = (string) $payload[$lockedField];
                        if ($valorActual !== $valorNuevo) {
                    throw new Exception("El campo " . $this->obtenerTextoCampo($config, $lockedField) . " esta protegido para este registro.");
                        }
                    }
                }

                $coincidencias = $this->obtenerCoincidenciasUnicas($config, $payload, $idRegistro);
                $conflicto = $this->resolverConflictoDuplicados($config, $coincidencias["matches"], $coincidencias["ids"]);
                if (!$conflicto["ok"]) {
                    throw new Exception($conflicto["msg"]);
                }

                if (count($coincidencias["ids"]) === 1) {
                throw new Exception("Ya existe otro registro con el mismo valor unico. Revise codigo o nombre.");
                }

                $set = $this->construirSetCampos($config, $payload, $locks);
                if (empty($set)) {
                    throw new Exception("No hay cambios disponibles para guardar.");
                }

                $sql = "UPDATE `" . $tabla . "`
                        SET " . implode(", ", $set) . "
                        WHERE `" . $pk . "` = '" . $idRegistro . "'";
                if (!ejecutarConsulta($sql)) {
                    throw new Exception("No se pudo actualizar el registro.");
                }

                $conexion->commit();
                return array(
                    "ok" => true,
                    "msg" => "Registro actualizado correctamente.",
                    "id_registro" => $idRegistro
                );
            }

            $coincidencias = $this->obtenerCoincidenciasUnicas($config, $payload, 0);
            $conflicto = $this->resolverConflictoDuplicados($config, $coincidencias["matches"], $coincidencias["ids"]);
            if (!$conflicto["ok"]) {
                throw new Exception($conflicto["msg"]);
            }

            if (count($coincidencias["ids"]) === 1) {
                $registroCoincidente = reset($coincidencias["matches"]);
                $idCoincidente = (int) $registroCoincidente[$pk];

                if ((int) $registroCoincidente[$config["state_field"]] === 1) {
                    throw new Exception("Ya existe un registro activo con esos datos.");
                }

                $set = $this->construirSetCampos($config, $payload, array());
                $set[] = "`" . $config["state_field"] . "` = 1";

                $sql = "UPDATE `" . $tabla . "`
                        SET " . implode(", ", $set) . "
                        WHERE `" . $pk . "` = '" . $idCoincidente . "'";
                if (!ejecutarConsulta($sql)) {
                    throw new Exception("El registro existia, pero no se pudo reactivar.");
                }

                $conexion->commit();
                return array(
                    "ok" => true,
                    "msg" => "El registro ya existia y fue reactivado correctamente.",
                    "id_registro" => $idCoincidente,
                    "reactivado" => true
                );
            }

            $columnas = array();
            $valores = array();
            foreach ($config["fields"] as $field) {
                $name = $field["name"];
                if (!array_key_exists($name, $payload)) {
                    continue;
                }

                $columnas[] = "`" . $name . "`";
                $valores[] = $this->valorSql($field, $payload[$name]);
            }

            $columnas[] = "`" . $config["state_field"] . "`";
            $valores[] = "1";

            $sql = "INSERT INTO `" . $tabla . "` (" . implode(", ", $columnas) . ")
                    VALUES (" . implode(", ", $valores) . ")";
            $idInsertado = ejecutarConsulta_retornarID($sql);
            if ((int) $idInsertado <= 0) {
                throw new Exception("No se pudo registrar el catalogo.");
            }

            $conexion->commit();
            return array(
                "ok" => true,
                "msg" => "Registro creado correctamente.",
                "id_registro" => (int) $idInsertado
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function desactivar($catalogo, $idRegistro)
    {
        $config = $this->obtenerCatalogo($catalogo);
        if (!$config) {
            return array("ok" => false, "msg" => "Catalogo no soportado.");
        }
        if ($this->catalogoEsSoloLectura($config)) {
            return array("ok" => false, "msg" => "El catalogo " . $config["title"] . " es fijo del sistema y no admite desactivacion.");
        }

        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $row = $this->obtenerRegistroPorId($config, $idRegistro, true);
            if (!$row) {
                throw new Exception("Registro no encontrado.");
            }

            if ((int) $row[$config["state_field"]] !== 1) {
                throw new Exception("El registro ya se encuentra inactivo.");
            }

            if ($this->esRegistroProtegido($config, $row)) {
                throw new Exception($this->mensajeRegistroProtegido($config, $row));
            }

            $sql = "UPDATE `" . $config["table"] . "`
                    SET `" . $config["state_field"] . "` = 0
                    WHERE `" . $config["pk"] . "` = '" . (int) $idRegistro . "'";
            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo desactivar el registro.");
            }

            $conexion->commit();
            return array("ok" => true, "msg" => "Registro desactivado correctamente.");
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function reactivar($catalogo, $idRegistro)
    {
        $config = $this->obtenerCatalogo($catalogo);
        if (!$config) {
            return array("ok" => false, "msg" => "Catalogo no soportado.");
        }

        if ($this->catalogoEsSoloLectura($config)) {
            return array("ok" => false, "msg" => "El catalogo " . $config["title"] . " es fijo del sistema y no admite reactivacion.");
        }
        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $row = $this->obtenerRegistroPorId($config, $idRegistro, true);
            if (!$row) {
                throw new Exception("Registro no encontrado.");
            }

            if ($this->esRegistroProtegido($config, $row)) {
                throw new Exception($this->mensajeRegistroProtegido($config, $row));
            }

            if ((int) $row[$config["state_field"]] === 1) {
                throw new Exception("El registro ya se encuentra activo.");
            }

            $sql = "UPDATE `" . $config["table"] . "`
                    SET `" . $config["state_field"] . "` = 1
                    WHERE `" . $config["pk"] . "` = '" . (int) $idRegistro . "'";
            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo reactivar el registro.");
            }

            $conexion->commit();
            return array("ok" => true, "msg" => "Registro reactivado correctamente.");
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    private function existeTabla($tabla)
    {
        $tabla = trim((string) $tabla);
        if ($tabla === "") {
            return false;
        }

        $row = ejecutarConsultaSimpleFila(
            "SELECT COUNT(*) AS total
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = '" . $this->esc($tabla) . "'
             LIMIT 1"
        );

        return $row && (int) $row["total"] > 0;
    }

    private function existeColumna($tabla, $columna)
    {
        $tabla = trim((string) $tabla);
        $columna = trim((string) $columna);
        if ($tabla === "" || $columna === "") {
            return false;
        }

        $row = ejecutarConsultaSimpleFila(
            "SELECT COUNT(*) AS total
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = '" . $this->esc($tabla) . "'
               AND column_name = '" . $this->esc($columna) . "'
             LIMIT 1"
        );

        return $row && (int) $row["total"] > 0;
    }

    private function validarEsquemaEmpleados()
    {
        if (!$this->existeTabla("empleados")) {
            return array("ok" => false, "msg" => "No se encontro la tabla empleados. Ejecute la migracion de empleados.");
        }

        $columnasRequeridas = array("id_dependencia", "correo", "estado");
        foreach ($columnasRequeridas as $columna) {
            if (!$this->existeColumna("empleados", $columna)) {
                return array(
                    "ok" => false,
                    "msg" => "Falta la columna " . $columna . " en empleados. Ejecute la migracion de empleados."
                );
            }
        }

        return array("ok" => true);
    }

    private function validarEsquemaSmtp()
    {
        if (!$this->existeTabla("configuracion_smtp")) {
            return array("ok" => false, "msg" => "No se encontro la tabla de configuracion SMTP. Ejecute la migracion correspondiente.");
        }

        $columnasRequeridas = array(
            "host",
            "puerto",
            "usuario",
            "clave",
            "correo_remitente",
            "nombre_remitente",
            "usar_tls",
            "estado",
            "id_usuario_actualiza",
            "fecha_registro",
            "fecha_actualizacion"
        );
        foreach ($columnasRequeridas as $columna) {
            if (!$this->existeColumna("configuracion_smtp", $columna)) {
                return array(
                    "ok" => false,
                    "msg" => "Falta la columna " . $columna . " en configuracion_smtp. Ejecute la migracion correspondiente."
                );
            }
        }

        return array("ok" => true);
    }

    private function obtenerDetalleEmpleadoBase($idEmpleado, $forUpdate = false)
    {
        $sql = "SELECT e.id_empleado,
                       e.cedula,
                       e.nombre,
                       e.apellido,
                       e.id_dependencia,
                       e.telefono,
                       e.correo,
                       e.direccion,
                       IFNULL(e.estado, 1) AS estado,
                       d.nombre_dependencia,
                       (
                           SELECT COUNT(*)
                           FROM usuarios u
                           WHERE u.id_empleado = e.id_empleado
                             AND IFNULL(u.estado, 1) = 1
                       ) AS total_usuarios_activos
                FROM empleados e
                LEFT JOIN dependencias d
                    ON d.id_dependencia = e.id_dependencia
                WHERE e.id_empleado = '" . (int) $idEmpleado . "'
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    private function formatearFilaEmpleado($row)
    {
        $row["id_empleado"] = isset($row["id_empleado"]) ? (int) $row["id_empleado"] : 0;
        $row["id_dependencia"] = isset($row["id_dependencia"]) ? (int) $row["id_dependencia"] : 0;
        $row["cedula"] = isset($row["cedula"]) ? (string) $row["cedula"] : "";
        $row["nombre"] = isset($row["nombre"]) ? trim((string) $row["nombre"]) : "";
        $row["apellido"] = isset($row["apellido"]) ? trim((string) $row["apellido"]) : "";
        $row["empleado"] = trim($row["nombre"] . " " . $row["apellido"]);
        $row["telefono"] = isset($row["telefono"]) ? (string) $row["telefono"] : "";
        $row["correo"] = isset($row["correo"]) ? (string) $row["correo"] : "";
        $row["direccion"] = isset($row["direccion"]) ? (string) $row["direccion"] : "";
        $row["dependencia"] = isset($row["nombre_dependencia"]) && trim((string) $row["nombre_dependencia"]) !== ""
            ? (string) $row["nombre_dependencia"]
            : "Sin dependencia";
        $row["estado"] = isset($row["estado"]) ? (int) $row["estado"] : 0;
        $row["estado_texto"] = $row["estado"] === 1 ? "Activo" : "Inactivo";
        $row["estado_badge"] = $row["estado"] === 1 ? "active" : "inactive";
        $row["total_usuarios_activos"] = isset($row["total_usuarios_activos"]) ? (int) $row["total_usuarios_activos"] : 0;
        $row["puede_desactivar"] = $row["estado"] === 1 && $row["total_usuarios_activos"] === 0;
        $row["motivo_bloqueo"] = $row["total_usuarios_activos"] > 0
            ? "Este empleado tiene usuarios activos asociados."
            : "";

        return $row;
    }

    private function validarCamposEmpleadoSistema($data, $idEmpleadoEditar = 0)
    {
        $cedula = isset($data["cedula"]) ? (int) $data["cedula"] : 0;
        $nombre = trim((string) (isset($data["nombre"]) ? $data["nombre"] : ""));
        $apellido = trim((string) (isset($data["apellido"]) ? $data["apellido"] : ""));
        $idDependencia = isset($data["id_dependencia"]) ? (int) $data["id_dependencia"] : 0;
        $telefono = trim((string) (isset($data["telefono"]) ? $data["telefono"] : ""));
        $correo = trim((string) (isset($data["correo"]) ? $data["correo"] : ""));
        $direccion = trim((string) (isset($data["direccion"]) ? $data["direccion"] : ""));

        if ($cedula <= 0) {
            return array("ok" => false, "msg" => "Debe indicar una cedula valida.");
        }

        if ($nombre === "") {
            return array("ok" => false, "msg" => "Debe indicar el nombre del empleado.");
        }

        if ($this->longitudTexto($nombre) > 100) {
            return array("ok" => false, "msg" => "El nombre excede la longitud permitida.");
        }

        if ($apellido === "") {
            return array("ok" => false, "msg" => "Debe indicar el apellido del empleado.");
        }

        if ($this->longitudTexto($apellido) > 100) {
            return array("ok" => false, "msg" => "El apellido excede la longitud permitida.");
        }

        if ($idDependencia <= 0) {
            return array("ok" => false, "msg" => "Debe seleccionar una dependencia.");
        }

        $dependencia = ejecutarConsultaSimpleFila(
            "SELECT id_dependencia
             FROM dependencias
             WHERE id_dependencia = '" . $idDependencia . "'
               AND IFNULL(estado, 1) = 1
             LIMIT 1"
        );
        if (!$dependencia) {
            return array("ok" => false, "msg" => "La dependencia seleccionada no esta disponible.");
        }

        if ($telefono !== "" && $this->longitudTexto($telefono) > 20) {
            return array("ok" => false, "msg" => "El telefono excede la longitud permitida.");
        }

        if ($correo !== "") {
            if ($this->longitudTexto($correo) > 150) {
                return array("ok" => false, "msg" => "El correo excede la longitud permitida.");
            }

            if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
                return array("ok" => false, "msg" => "El correo indicado no es valido.");
            }
        }

        if ($direccion !== "" && $this->longitudTexto($direccion) > 255) {
            return array("ok" => false, "msg" => "La direccion excede la longitud permitida.");
        }

        $duplicadoCedula = ejecutarConsultaSimpleFila(
            "SELECT id_empleado
             FROM empleados
             WHERE cedula = '" . $cedula . "'
               AND id_empleado <> '" . (int) $idEmpleadoEditar . "'
             LIMIT 1"
        );
        if ($duplicadoCedula) {
            return array("ok" => false, "msg" => "Ya existe otro empleado con la misma cedula.");
        }

        return array(
            "ok" => true,
            "data" => array(
                "cedula" => $cedula,
                "nombre" => $nombre,
                "apellido" => $apellido,
                "id_dependencia" => $idDependencia,
                "telefono" => $telefono,
                "correo" => $correo,
                "direccion" => $direccion
            )
        );
    }

    public function obtenerMetadatosEmpleadosUI()
    {
        $esquema = $this->validarEsquemaEmpleados();
        if (!$esquema["ok"]) {
            return array("dependencias" => array(), "warning" => $esquema["msg"]);
        }

        return array(
            "dependencias" => $this->obtenerOpcionesDependenciasUsuarios()
        );
    }

    public function listarEmpleadosSistema($estadoFiltro = "activos")
    {
        $esquema = $this->validarEsquemaEmpleados();
        if (!$esquema["ok"]) {
            return $esquema;
        }

        $where = "";
        if ($estadoFiltro === "activos") {
            $where = "WHERE IFNULL(e.estado, 1) = 1";
        } elseif ($estadoFiltro === "inactivos") {
            $where = "WHERE IFNULL(e.estado, 1) = 0";
        }

        $sql = "SELECT e.id_empleado,
                       e.cedula,
                       e.nombre,
                       e.apellido,
                       e.id_dependencia,
                       e.telefono,
                       e.correo,
                       e.direccion,
                       IFNULL(e.estado, 1) AS estado,
                       d.nombre_dependencia,
                       (
                           SELECT COUNT(*)
                           FROM usuarios u
                           WHERE u.id_empleado = e.id_empleado
                             AND IFNULL(u.estado, 1) = 1
                       ) AS total_usuarios_activos
                FROM empleados e
                LEFT JOIN dependencias d
                    ON d.id_dependencia = e.id_dependencia
                " . $where . "
                ORDER BY e.apellido ASC, e.nombre ASC";

        $rspta = ejecutarConsulta($sql);
        $items = array();
        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $items[] = $this->formatearFilaEmpleado($row);
            }
        }

        $resumen = ejecutarConsultaSimpleFila(
            "SELECT COUNT(*) AS total,
                    SUM(CASE WHEN IFNULL(estado, 1) = 1 THEN 1 ELSE 0 END) AS activos,
                    SUM(CASE WHEN IFNULL(estado, 1) = 0 THEN 1 ELSE 0 END) AS inactivos,
                    SUM(CASE WHEN TRIM(IFNULL(correo, '')) <> '' THEN 1 ELSE 0 END) AS con_correo
             FROM empleados"
        );

        return array(
            "ok" => true,
            "msg" => "Listado de empleados cargado correctamente.",
            "items" => $items,
            "resumen" => array(
                "total" => isset($resumen["total"]) ? (int) $resumen["total"] : 0,
                "activos" => isset($resumen["activos"]) ? (int) $resumen["activos"] : 0,
                "inactivos" => isset($resumen["inactivos"]) ? (int) $resumen["inactivos"] : 0,
                "con_correo" => isset($resumen["con_correo"]) ? (int) $resumen["con_correo"] : 0
            )
        );
    }

    public function mostrarEmpleadoSistema($idEmpleado)
    {
        $esquema = $this->validarEsquemaEmpleados();
        if (!$esquema["ok"]) {
            return $esquema;
        }

        $row = $this->obtenerDetalleEmpleadoBase($idEmpleado, false);
        if (!$row) {
            return array("ok" => false, "msg" => "Empleado no encontrado.");
        }

        $item = $this->formatearFilaEmpleado($row);
        $notice = $item["total_usuarios_activos"] > 0
            ? "Este empleado tiene usuarios activos vinculados. Si deseas desactivarlo, primero desactiva esas cuentas."
            : "";

        return array(
            "ok" => true,
            "msg" => "Empleado cargado correctamente.",
            "item" => $item,
            "notice" => $notice
        );
    }

    public function guardaryeditarEmpleadoSistema($idEmpleadoEditar, $data, $idUsuarioSesion = 0)
    {
        $esquema = $this->validarEsquemaEmpleados();
        if (!$esquema["ok"]) {
            return $esquema;
        }

        $idEmpleadoEditar = (int) $idEmpleadoEditar;
        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $empleadoActual = null;
            if ($idEmpleadoEditar > 0) {
                $empleadoActual = $this->obtenerDetalleEmpleadoBase($idEmpleadoEditar, true);
                if (!$empleadoActual) {
                    throw new Exception("Empleado no encontrado.");
                }
            }

            $validacion = $this->validarCamposEmpleadoSistema($data, $idEmpleadoEditar);
            if (!$validacion["ok"]) {
                throw new Exception($validacion["msg"]);
            }
            $payload = $validacion["data"];

            $telefonoSql = $payload["telefono"] !== "" ? "'" . $this->esc($payload["telefono"]) . "'" : "NULL";
            $correoSql = $payload["correo"] !== "" ? "'" . $this->esc($payload["correo"]) . "'" : "NULL";
            $direccionSql = $payload["direccion"] !== "" ? "'" . $this->esc($payload["direccion"]) . "'" : "NULL";

            if ($idEmpleadoEditar > 0) {
                $sql = "UPDATE empleados
                        SET cedula = '" . (int) $payload["cedula"] . "',
                            nombre = '" . $this->esc($payload["nombre"]) . "',
                            apellido = '" . $this->esc($payload["apellido"]) . "',
                            id_dependencia = '" . (int) $payload["id_dependencia"] . "',
                            telefono = " . $telefonoSql . ",
                            correo = " . $correoSql . ",
                            direccion = " . $direccionSql . "
                        WHERE id_empleado = '" . $idEmpleadoEditar . "'";
                if (!ejecutarConsulta($sql)) {
                    throw new Exception("No se pudo actualizar el empleado.");
                }

                $conexion->commit();
                return array(
                    "ok" => true,
                    "msg" => "Empleado actualizado correctamente.",
                    "id_registro" => $idEmpleadoEditar
                );
            }

            $coincidenciaCedula = ejecutarConsultaSimpleFila(
                "SELECT id_empleado, IFNULL(estado, 1) AS estado
                 FROM empleados
                 WHERE cedula = '" . (int) $payload["cedula"] . "'
                 LIMIT 1"
            );

            if ($coincidenciaCedula) {
                if ((int) $coincidenciaCedula["estado"] === 1) {
                    throw new Exception("Ya existe un empleado activo con esa cedula.");
                }

                $idReactivado = (int) $coincidenciaCedula["id_empleado"];
                $sqlReactivar = "UPDATE empleados
                                 SET cedula = '" . (int) $payload["cedula"] . "',
                                     nombre = '" . $this->esc($payload["nombre"]) . "',
                                     apellido = '" . $this->esc($payload["apellido"]) . "',
                                     id_dependencia = '" . (int) $payload["id_dependencia"] . "',
                                     telefono = " . $telefonoSql . ",
                                     correo = " . $correoSql . ",
                                     direccion = " . $direccionSql . ",
                                     estado = 1
                                 WHERE id_empleado = '" . $idReactivado . "'";
                if (!ejecutarConsulta($sqlReactivar)) {
                    throw new Exception("No se pudo reactivar el empleado existente.");
                }

                $conexion->commit();
                return array(
                    "ok" => true,
                    "msg" => "El empleado ya existia y fue reactivado correctamente.",
                    "id_registro" => $idReactivado,
                    "reactivado" => true
                );
            }

            $sqlInsert = "INSERT INTO empleados (
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
                                '" . (int) $payload["id_dependencia"] . "',
                                " . $telefonoSql . ",
                                " . $correoSql . ",
                                " . $direccionSql . ",
                                1
                           )";
            $idInsertado = ejecutarConsulta_retornarID($sqlInsert);
            if ((int) $idInsertado <= 0) {
                throw new Exception("No se pudo crear el empleado.");
            }

            $conexion->commit();
            return array(
                "ok" => true,
                "msg" => "Empleado creado correctamente.",
                "id_registro" => (int) $idInsertado
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function cambiarEstadoEmpleadoSistema($idEmpleado, $activar)
    {
        $esquema = $this->validarEsquemaEmpleados();
        if (!$esquema["ok"]) {
            return $esquema;
        }

        $idEmpleado = (int) $idEmpleado;
        $activar = (bool) $activar;
        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $row = $this->obtenerDetalleEmpleadoBase($idEmpleado, true);
            if (!$row) {
                throw new Exception("Empleado no encontrado.");
            }

            if ($activar && (int) $row["estado"] === 1) {
                throw new Exception("El empleado ya se encuentra activo.");
            }

            if (!$activar && (int) $row["estado"] === 0) {
                throw new Exception("El empleado ya se encuentra inactivo.");
            }

            if (!$activar && isset($row["total_usuarios_activos"]) && (int) $row["total_usuarios_activos"] > 0) {
                throw new Exception("No puedes desactivar este empleado porque tiene usuarios activos asociados.");
            }

            $sql = "UPDATE empleados
                    SET estado = '" . ($activar ? 1 : 0) . "'
                    WHERE id_empleado = '" . $idEmpleado . "'";
            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo actualizar el estado del empleado.");
            }

            $conexion->commit();
            return array(
                "ok" => true,
                "msg" => $activar
                    ? "Empleado reactivado correctamente."
                    : "Empleado desactivado correctamente."
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    private function obtenerConfiguracionSmtpFila($forUpdate = false)
    {
        $sql = "SELECT cs.id_configuracion_smtp,
                       cs.host,
                       cs.puerto,
                       cs.usuario,
                       cs.clave,
                       cs.correo_remitente,
                       cs.nombre_remitente,
                       IFNULL(cs.usar_tls, 1) AS usar_tls,
                       IFNULL(cs.estado, 1) AS estado,
                       cs.id_usuario_actualiza,
                       cs.fecha_registro,
                       cs.fecha_actualizacion,
                       u.usuario AS usuario_actualiza
                FROM configuracion_smtp cs
                LEFT JOIN usuarios u
                    ON u.id_usuario = cs.id_usuario_actualiza
                WHERE IFNULL(cs.estado, 1) = 1
                ORDER BY cs.id_configuracion_smtp DESC
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    public function obtenerConfiguracionSmtp()
    {
        $esquema = $this->validarEsquemaSmtp();
        if (!$esquema["ok"]) {
            return $esquema;
        }

        $row = $this->obtenerConfiguracionSmtpFila(false);
        if (!$row) {
            $row = array(
                "id_configuracion_smtp" => 0,
                "host" => "smtp.gmail.com",
                "puerto" => 587,
                "usuario" => "",
                "clave" => "",
                "correo_remitente" => "",
                "nombre_remitente" => "",
                "usar_tls" => 1,
                "fecha_actualizacion" => "",
                "usuario_actualiza" => ""
            );
        }

        return array(
            "ok" => true,
            "msg" => "Configuracion SMTP cargada correctamente.",
            "item" => array(
                "id_configuracion_smtp" => isset($row["id_configuracion_smtp"]) ? (int) $row["id_configuracion_smtp"] : 0,
                "host" => isset($row["host"]) ? (string) $row["host"] : "smtp.gmail.com",
                "puerto" => isset($row["puerto"]) ? (int) $row["puerto"] : 587,
                "usuario" => isset($row["usuario"]) ? (string) $row["usuario"] : "",
                "correo_remitente" => isset($row["correo_remitente"]) ? (string) $row["correo_remitente"] : "",
                "nombre_remitente" => isset($row["nombre_remitente"]) ? (string) $row["nombre_remitente"] : "",
                "usar_tls" => isset($row["usar_tls"]) ? (int) $row["usar_tls"] : 1,
                "tiene_clave" => isset($row["clave"]) && trim((string) $row["clave"]) !== "",
                "fecha_actualizacion_formateada" => isset($row["fecha_actualizacion"]) ? $this->formatearFecha($row["fecha_actualizacion"]) : "",
                "usuario_actualiza" => isset($row["usuario_actualiza"]) ? (string) $row["usuario_actualiza"] : ""
            )
        );
    }

    private function validarCamposConfiguracionSmtp($data, $filaActual = null)
    {
        $host = trim((string) (isset($data["host"]) ? $data["host"] : ""));
        $puerto = isset($data["puerto"]) ? (int) $data["puerto"] : 0;
        $usuario = trim((string) (isset($data["usuario"]) ? $data["usuario"] : ""));
        $clave = (string) (isset($data["clave"]) ? $data["clave"] : "");
        $correoRemitente = trim((string) (isset($data["correo_remitente"]) ? $data["correo_remitente"] : ""));
        $nombreRemitente = trim((string) (isset($data["nombre_remitente"]) ? $data["nombre_remitente"] : ""));
        $usarTls = isset($data["usar_tls"]) && (int) $data["usar_tls"] === 0 ? 0 : 1;

        if ($host === "") {
            return array("ok" => false, "msg" => "Debe indicar el servidor SMTP.");
        }

        if ($this->longitudTexto($host) > 150) {
            return array("ok" => false, "msg" => "El servidor SMTP excede la longitud permitida.");
        }

        if ($puerto <= 0 || $puerto > 65535) {
            return array("ok" => false, "msg" => "Debe indicar un puerto SMTP valido.");
        }

        if ($usuario === "") {
            return array("ok" => false, "msg" => "Debe indicar el usuario SMTP.");
        }

        if ($this->longitudTexto($usuario) > 150) {
            return array("ok" => false, "msg" => "El usuario SMTP excede la longitud permitida.");
        }

        if ($correoRemitente === "") {
            return array("ok" => false, "msg" => "Debe indicar el correo remitente.");
        }

        if ($this->longitudTexto($correoRemitente) > 150) {
            return array("ok" => false, "msg" => "El correo remitente excede la longitud permitida.");
        }

        if (!filter_var($correoRemitente, FILTER_VALIDATE_EMAIL)) {
            return array("ok" => false, "msg" => "El correo remitente no es valido.");
        }

        if ($nombreRemitente !== "" && $this->longitudTexto($nombreRemitente) > 150) {
            return array("ok" => false, "msg" => "El nombre remitente excede la longitud permitida.");
        }

        $claveActual = $filaActual && isset($filaActual["clave"]) ? (string) $filaActual["clave"] : "";
        $claveFinal = trim($clave) !== "" ? $clave : $claveActual;
        if (trim((string) $claveFinal) === "") {
            return array("ok" => false, "msg" => "Debe indicar la clave SMTP.");
        }

        return array(
            "ok" => true,
            "data" => array(
                "host" => $host,
                "puerto" => $puerto,
                "usuario" => $usuario,
                "clave" => $claveFinal,
                "correo_remitente" => $correoRemitente,
                "nombre_remitente" => $nombreRemitente,
                "usar_tls" => $usarTls
            )
        );
    }

    public function guardarConfiguracionSmtp($data, $idUsuarioSesion)
    {
        $esquema = $this->validarEsquemaSmtp();
        if (!$esquema["ok"]) {
            return $esquema;
        }

        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $filaActual = $this->obtenerConfiguracionSmtpFila(true);
            $validacion = $this->validarCamposConfiguracionSmtp($data, $filaActual);
            if (!$validacion["ok"]) {
                throw new Exception($validacion["msg"]);
            }
            $payload = $validacion["data"];

            if ($filaActual) {
                $sql = "UPDATE configuracion_smtp
                        SET host = '" . $this->esc($payload["host"]) . "',
                            puerto = '" . (int) $payload["puerto"] . "',
                            usuario = '" . $this->esc($payload["usuario"]) . "',
                            clave = '" . $this->esc($payload["clave"]) . "',
                            correo_remitente = '" . $this->esc($payload["correo_remitente"]) . "',
                            nombre_remitente = " . ($payload["nombre_remitente"] !== "" ? "'" . $this->esc($payload["nombre_remitente"]) . "'" : "NULL") . ",
                            usar_tls = '" . (int) $payload["usar_tls"] . "',
                            estado = 1,
                            id_usuario_actualiza = '" . (int) $idUsuarioSesion . "'
                        WHERE id_configuracion_smtp = '" . (int) $filaActual["id_configuracion_smtp"] . "'";
                if (!ejecutarConsulta($sql)) {
                    throw new Exception("No se pudo actualizar la configuracion SMTP.");
                }

                $idRegistro = (int) $filaActual["id_configuracion_smtp"];
            } else {
                $sql = "INSERT INTO configuracion_smtp (
                                    host,
                                    puerto,
                                    usuario,
                                    clave,
                                    correo_remitente,
                                    nombre_remitente,
                                    usar_tls,
                                    estado,
                                    id_usuario_actualiza
                               ) VALUES (
                                    '" . $this->esc($payload["host"]) . "',
                                    '" . (int) $payload["puerto"] . "',
                                    '" . $this->esc($payload["usuario"]) . "',
                                    '" . $this->esc($payload["clave"]) . "',
                                    '" . $this->esc($payload["correo_remitente"]) . "',
                                    " . ($payload["nombre_remitente"] !== "" ? "'" . $this->esc($payload["nombre_remitente"]) . "'" : "NULL") . ",
                                    '" . (int) $payload["usar_tls"] . "',
                                    1,
                                    '" . (int) $idUsuarioSesion . "'
                               )";
                $idRegistro = ejecutarConsulta_retornarID($sql);
                if ((int) $idRegistro <= 0) {
                    throw new Exception("No se pudo guardar la configuracion SMTP.");
                }
            }

            $conexion->commit();
            return array(
                "ok" => true,
                "msg" => "Configuracion SMTP guardada correctamente.",
                "id_registro" => (int) $idRegistro
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
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

    private function enviarCorreoViaSmtp($config, $destinatario, $asunto, $mensajeHtml)
    {
        $host = trim((string) (isset($config["host"]) ? $config["host"] : ""));
        $puerto = isset($config["puerto"]) ? (int) $config["puerto"] : 0;
        $usuario = trim((string) (isset($config["usuario"]) ? $config["usuario"] : ""));
        $clave = (string) (isset($config["clave"]) ? $config["clave"] : "");
        $correoRemitente = trim((string) (isset($config["correo_remitente"]) ? $config["correo_remitente"] : ""));
        $nombreRemitente = trim((string) (isset($config["nombre_remitente"]) ? $config["nombre_remitente"] : ""));
        $usarTls = isset($config["usar_tls"]) && (int) $config["usar_tls"] === 1;

        if ($host === "" || $puerto <= 0 || $usuario === "" || trim($clave) === "" || $correoRemitente === "") {
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

            $contenidoData = implode("\r\n", $headers) . "\r\n\r\n" . $cuerpoNormalizado . "\r\n.";
            if (@fwrite($socket, $contenidoData . "\r\n") === false) {
                throw new Exception("No se pudo enviar el contenido del correo al servidor SMTP.");
            }

            $this->smtpEnviarComando($socket, null, array(250));
            $this->smtpEnviarComando($socket, "QUIT", array(221, 250));
        } finally {
            fclose($socket);
        }
    }

    public function enviarPruebaSmtp($destinatario, $idUsuarioSesion = 0)
    {
        $esquema = $this->validarEsquemaSmtp();
        if (!$esquema["ok"]) {
            return $esquema;
        }

        $destinatario = trim((string) $destinatario);
        if ($destinatario === "") {
            return array("ok" => false, "msg" => "Debe indicar un correo destino para la prueba.");
        }

        if (!filter_var($destinatario, FILTER_VALIDATE_EMAIL)) {
            return array("ok" => false, "msg" => "El correo destino no es valido.");
        }

        $config = $this->obtenerConfiguracionSmtpFila(false);
        if (!$config) {
            return array("ok" => false, "msg" => "No hay configuracion SMTP activa.");
        }

        $asunto = "Prueba SMTP - Sala Situacional";
        $mensaje = "<h3>Prueba de configuracion SMTP</h3>"
            . "<p>Este correo confirma que la configuracion SMTP se encuentra operativa.</p>"
            . "<p><strong>Fecha:</strong> " . date("d/m/Y h:i A") . "</p>";

        try {
            $this->enviarCorreoViaSmtp($config, $destinatario, $asunto, $mensaje);
            return array("ok" => true, "msg" => "Correo de prueba enviado correctamente a " . $destinatario . ".");
        } catch (Exception $exception) {
            return array("ok" => false, "msg" => "Fallo el envio SMTP: " . $exception->getMessage());
        }
    }
    private function obtenerPermisoAccesoTotal()
    {
        $sql = "SELECT id_permiso, nombre_permiso
                FROM permisos
                WHERE IFNULL(estado, 1) = 1
                  AND (
                    id_permiso = 99
                    OR UPPER(TRIM(nombre_permiso)) IN ('ACCESO TOTAL DEL SISTEMA', 'ACCESO TOTAL SISTEMA')
                  )
                ORDER BY CASE WHEN id_permiso = 99 THEN 0 ELSE 1 END, id_permiso ASC
                LIMIT 1";
        $row = ejecutarConsultaSimpleFila($sql);

        if ($row) {
            return array(
                "id_permiso" => (int) $row["id_permiso"],
                "nombre_permiso" => (string) $row["nombre_permiso"]
            );
        }

        return array(
            "id_permiso" => 0,
            "nombre_permiso" => "Acceso total del sistema"
        );
    }

    private function obtenerDetalleUsuarioBase($idUsuario, $forUpdate = false)
    {
        $sql = "SELECT u.id_usuario,
                       u.id_empleado,
                       e.id_dependencia,
                       u.usuario,
                       u.password,
                       u.rol,
                       u.estado,
                       e.cedula,
                       TRIM(CONCAT(COALESCE(e.nombre, ''), ' ', COALESCE(e.apellido, ''))) AS empleado,
                       d.nombre_dependencia
                FROM usuarios u
                INNER JOIN empleados e ON e.id_empleado = u.id_empleado
                LEFT JOIN dependencias d ON d.id_dependencia = e.id_dependencia
                WHERE u.id_usuario = '" . (int) $idUsuario . "'
                LIMIT 1";

        if ($forUpdate) {
            $sql .= " FOR UPDATE";
        }

        return ejecutarConsultaSimpleFila($sql);
    }

    private function esUsuarioAdministrador($idUsuario)
    {
        $row = ejecutarConsultaSimpleFila("SELECT rol, estado
                                           FROM usuarios
                                           WHERE id_usuario = '" . (int) $idUsuario . "'
                                           LIMIT 1");

        return $row
            && (int) $row["estado"] === 1
            && strtoupper((string) $row["rol"]) === "ADMIN";
    }

    private function obtenerRolesDisponiblesUsuarios($puedeGestionarAdministradores)
    {
        return array(
            array("value" => "OPERADOR", "label" => "Operador"),
            array("value" => "CONSULTOR", "label" => "Consultor")
        );
    }

    private function normalizarIdsEnteros($valores)
    {
        if (!is_array($valores)) {
            if ($valores === null || $valores === "") {
                return array();
            }

            $valores = explode(",", (string) $valores);
        }

        $ids = array();
        foreach ($valores as $valor) {
            $id = (int) $valor;
            if ($id > 0) {
                $ids[$id] = $id;
            }
        }

        return array_values($ids);
    }

    private function obtenerPermisosAsignadosUsuario($idUsuario)
    {
        $permisoAccesoTotal = $this->obtenerPermisoAccesoTotal();
        $sql = "SELECT p.id_permiso,
                       p.nombre_permiso,
                       COALESCE(p.descripcion, '') AS descripcion
                FROM usuario_permisos up
                INNER JOIN permisos p ON p.id_permiso = up.id_permiso
                WHERE up.id_usuario = '" . (int) $idUsuario . "'
                  AND IFNULL(up.estado, 1) = 1
                  AND IFNULL(p.estado, 1) = 1
                ORDER BY p.nombre_permiso ASC";

        $rspta = ejecutarConsulta($sql);
        $regulares = array();
        $regularesIds = array();
        $tieneAccesoTotal = false;

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $idPermiso = (int) $row["id_permiso"];
                if ($permisoAccesoTotal["id_permiso"] > 0 && $idPermiso === (int) $permisoAccesoTotal["id_permiso"]) {
                    $tieneAccesoTotal = true;
                    continue;
                }

                $regulares[] = array(
                    "id_permiso" => $idPermiso,
                    "nombre_permiso" => (string) $row["nombre_permiso"],
                    "descripcion" => (string) $row["descripcion"]
                );
                $regularesIds[] = $idPermiso;
            }
        }

        return array(
            "regulares" => $regulares,
            "regulares_ids" => $regularesIds,
            "tiene_acceso_total" => $tieneAccesoTotal,
            "permiso_acceso_total" => $permisoAccesoTotal
        );
    }

    private function usuarioTieneAccesoTotalActivo($idUsuario, $permisoAccesoTotal = null)
    {
        $idUsuario = (int) $idUsuario;
        if ($idUsuario <= 0) {
            return false;
        }

        if (!$permisoAccesoTotal || !isset($permisoAccesoTotal["id_permiso"])) {
            $permisoAccesoTotal = $this->obtenerPermisoAccesoTotal();
        }

        $idPermisoAccesoTotal = isset($permisoAccesoTotal["id_permiso"]) ? (int) $permisoAccesoTotal["id_permiso"] : 0;
        if ($idPermisoAccesoTotal <= 0) {
            return false;
        }

        $row = ejecutarConsultaSimpleFila(
            "SELECT id_usuario_permiso
             FROM usuario_permisos
             WHERE id_usuario = '" . $idUsuario . "'
               AND id_permiso = '" . $idPermisoAccesoTotal . "'
               AND IFNULL(estado, 1) = 1
             LIMIT 1"
        );

        return !empty($row);
    }

    private function formatearFilaUsuario($row, $idUsuarioSesion)
    {
        $permisos = $this->obtenerPermisosAsignadosUsuario((int) $row["id_usuario"]);
        $permisosNombres = array();

        foreach ($permisos["regulares"] as $permiso) {
            $permisosNombres[] = $permiso["nombre_permiso"];
        }

        $row["id_usuario"] = (int) $row["id_usuario"];
        $row["id_empleado"] = (int) $row["id_empleado"];
        $row["id_dependencia"] = (int) $row["id_dependencia"];
        $row["cedula"] = isset($row["cedula"]) ? (string) $row["cedula"] : "";
        $row["estado"] = isset($row["estado"]) ? (int) $row["estado"] : 0;
        $row["estado_texto"] = $row["estado"] === 1 ? "Activo" : "Inactivo";
        $row["estado_badge"] = $row["estado"] === 1 ? "active" : "inactive";
        $row["rol"] = strtoupper((string) $row["rol"]);
        $row["rol_texto"] = ucfirst(strtolower($row["rol"]));
        $row["empleado"] = trim((string) $row["empleado"]);
        $row["empleado_label"] = trim($row["cedula"] . " - " . $row["empleado"]);
        $row["dependencia"] = isset($row["nombre_dependencia"]) && trim((string) $row["nombre_dependencia"]) !== ""
            ? (string) $row["nombre_dependencia"]
            : "Sin dependencia";
        $row["permisos_regulares"] = $permisos["regulares"];
        $row["id_permisos"] = $permisos["regulares_ids"];
        $row["permisos_regulares_nombres"] = $permisosNombres;
        $row["permisos_regulares_texto"] = !empty($permisosNombres)
            ? implode(", ", $permisosNombres)
            : "Sin permisos regulares";
        $row["tiene_acceso_total"] = !empty($permisos["tiene_acceso_total"]);
        $row["acceso_total_texto"] = $row["tiene_acceso_total"] ? "Habilitado" : "No asignado";
        $row["acceso_total_badge"] = $row["tiene_acceso_total"] ? "active" : "secondary";
        $row["es_usuario_actual"] = $row["id_usuario"] === (int) $idUsuarioSesion;
        $row["es_admin"] = $row["rol"] === "ADMIN";
        $row["puede_desactivar"] = $row["estado"] === 1 && !$row["es_usuario_actual"];
        $row["motivo_bloqueo"] = $row["es_usuario_actual"]
            ? "No puedes desactivar el usuario con la sesion actual."
            : "";

        return $row;
    }
    private function obtenerOpcionesDependenciasUsuarios()
    {
        $sql = "SELECT id_dependencia, nombre_dependencia
                FROM dependencias
                WHERE IFNULL(estado, 1) = 1
                ORDER BY nombre_dependencia ASC";
        $rspta = ejecutarConsulta($sql);
        $items = array();

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $items[] = array(
                    "id_dependencia" => (int) $row["id_dependencia"],
                    "nombre_dependencia" => (string) $row["nombre_dependencia"]
                );
            }
        }

        return $items;
    }

    private function obtenerOpcionesEmpleadosUsuarios()
    {
        $sql = "SELECT e.id_empleado,
                       e.cedula,
                       e.id_dependencia,
                       d.nombre_dependencia,
                       TRIM(CONCAT(COALESCE(e.nombre, ''), ' ', COALESCE(e.apellido, ''))) AS empleado,
                       u.id_usuario AS usuario_activo_id,
                       u.usuario AS usuario_activo
                FROM empleados e
                LEFT JOIN dependencias d
                    ON d.id_dependencia = e.id_dependencia
                LEFT JOIN usuarios u
                    ON u.id_empleado = e.id_empleado
                   AND u.estado = 1
                WHERE IFNULL(e.estado, 1) = 1
                ORDER BY empleado ASC";
        $rspta = ejecutarConsulta($sql);
        $items = array();

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $items[] = array(
                    "id_empleado" => (int) $row["id_empleado"],
                    "cedula" => (string) $row["cedula"],
                    "id_dependencia" => isset($row["id_dependencia"]) ? (int) $row["id_dependencia"] : 0,
                    "nombre_dependencia" => isset($row["nombre_dependencia"]) ? (string) $row["nombre_dependencia"] : "Sin dependencia",
                    "empleado" => (string) $row["empleado"],
                    "label" => trim((string) $row["cedula"] . " - " . (string) $row["empleado"]),
                    "usuario_activo_id" => isset($row["usuario_activo_id"]) ? (int) $row["usuario_activo_id"] : 0,
                    "usuario_activo" => isset($row["usuario_activo"]) ? (string) $row["usuario_activo"] : ""
                );
            }
        }

        return $items;
    }

    private function obtenerOpcionesPermisosUsuarios()
    {
        $permisoAccesoTotal = $this->obtenerPermisoAccesoTotal();
        $sql = "SELECT id_permiso, nombre_permiso, COALESCE(descripcion, '') AS descripcion
                FROM permisos
                WHERE IFNULL(estado, 1) = 1";

        if ((int) $permisoAccesoTotal["id_permiso"] > 0) {
            $sql .= " AND id_permiso <> '" . (int) $permisoAccesoTotal["id_permiso"] . "'";
        }

        $sql .= " ORDER BY nombre_permiso ASC";

        $rspta = ejecutarConsulta($sql);
        $items = array();

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $items[] = array(
                    "id_permiso" => (int) $row["id_permiso"],
                    "nombre_permiso" => (string) $row["nombre_permiso"],
                    "descripcion" => (string) $row["descripcion"]
                );
            }
        }

        return $items;
    }

    public function obtenerMetadatosUsuariosUI($idUsuarioSesion)
    {
        $permisoAccesoTotal = $this->obtenerPermisoAccesoTotal();
        $puedeGestionarAccesoTotal = $this->esUsuarioAdministrador($idUsuarioSesion);

        return array(
            "roles" => $this->obtenerRolesDisponiblesUsuarios($puedeGestionarAccesoTotal),
            "empleados" => $this->obtenerOpcionesEmpleadosUsuarios(),
            "permisos" => $this->obtenerOpcionesPermisosUsuarios(),
            "permiso_acceso_total" => array(
                "id_permiso" => (int) $permisoAccesoTotal["id_permiso"],
                "nombre_permiso" => (string) $permisoAccesoTotal["nombre_permiso"]
            ),
            "puede_gestionar_acceso_total" => $puedeGestionarAccesoTotal,
            "usuario_actual_id" => (int) $idUsuarioSesion
        );
    }

    public function listarUsuariosSistema($estadoFiltro, $idUsuarioSesion)
    {
        $where = "";
        if ($estadoFiltro === "activos") {
            $where = "WHERE u.estado = 1";
        } elseif ($estadoFiltro === "inactivos") {
            $where = "WHERE u.estado = 0";
        }

        $sql = "SELECT u.id_usuario,
                       u.id_empleado,
                       e.id_dependencia,
                       u.usuario,
                       u.rol,
                       u.estado,
                       e.cedula,
                       TRIM(CONCAT(COALESCE(e.nombre, ''), ' ', COALESCE(e.apellido, ''))) AS empleado,
                       d.nombre_dependencia
                FROM usuarios u
                INNER JOIN empleados e ON e.id_empleado = u.id_empleado
                LEFT JOIN dependencias d ON d.id_dependencia = e.id_dependencia
                " . $where . "
                ORDER BY u.usuario ASC";

        $rspta = ejecutarConsulta($sql);
        $items = array();

        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $items[] = $this->formatearFilaUsuario($row, $idUsuarioSesion);
            }
        }

        $permisoAccesoTotal = $this->obtenerPermisoAccesoTotal();
        $resumen = ejecutarConsultaSimpleFila(
            "SELECT COUNT(*) AS total,
                    SUM(CASE WHEN estado = 1 THEN 1 ELSE 0 END) AS activos,
                    SUM(CASE WHEN estado = 0 THEN 1 ELSE 0 END) AS inactivos,
                    SUM(CASE WHEN rol = 'ADMIN' AND estado = 1 THEN 1 ELSE 0 END) AS administradores
             FROM usuarios"
        );
        $conAccesoTotal = 0;
        if ((int) $permisoAccesoTotal["id_permiso"] > 0) {
            $rowAcceso = ejecutarConsultaSimpleFila(
                "SELECT COUNT(*) AS total
                 FROM usuario_permisos
                 WHERE id_permiso = '" . (int) $permisoAccesoTotal["id_permiso"] . "'
                   AND IFNULL(estado, 1) = 1"
            );
            $conAccesoTotal = isset($rowAcceso["total"]) ? (int) $rowAcceso["total"] : 0;
        }

        return array(
            "ok" => true,
            "msg" => "Listado de usuarios cargado correctamente.",
            "items" => $items,
            "resumen" => array(
                "total" => isset($resumen["total"]) ? (int) $resumen["total"] : 0,
                "activos" => isset($resumen["activos"]) ? (int) $resumen["activos"] : 0,
                "inactivos" => isset($resumen["inactivos"]) ? (int) $resumen["inactivos"] : 0,
                "administradores" => isset($resumen["administradores"]) ? (int) $resumen["administradores"] : 0,
                "con_acceso_total" => $conAccesoTotal
            )
        );
    }

    public function mostrarUsuarioSistema($idUsuario, $idUsuarioSesion)
    {
        $sessionEsAdmin = $this->esUsuarioAdministrador($idUsuarioSesion);
        $row = $this->obtenerDetalleUsuarioBase($idUsuario, false);

        if (!$row) {
            return array("ok" => false, "msg" => "Usuario no encontrado.");
        }

        if (!$sessionEsAdmin && strtoupper((string) $row["rol"]) === "ADMIN") {
            return array("ok" => false, "msg" => "Solo un administrador puede editar cuentas administrativas.");
        }

        $item = $this->formatearFilaUsuario($row, $idUsuarioSesion);
        $notice = $item["tiene_acceso_total"]
            ? "Este usuario ya cuenta con acceso total del sistema. Solo un administrador puede cambiar ese permiso."
            : "";

        return array(
            "ok" => true,
            "msg" => "Usuario cargado correctamente.",
            "item" => $item,
            "notice" => $notice
        );
    }
    private function validarCamposUsuarioSistema($data, $idUsuarioSesion, $idUsuarioEditar, $usuarioActual = null)
    {
        $sessionEsAdmin = $this->esUsuarioAdministrador($idUsuarioSesion);
        $idEmpleado = isset($data["id_empleado"]) ? (int) $data["id_empleado"] : 0;
        $usuario = trim((string) (isset($data["usuario"]) ? $data["usuario"] : ""));
        $rol = strtoupper(trim((string) (isset($data["rol"]) ? $data["rol"] : "")));
        $password = (string) (isset($data["password"]) ? $data["password"] : "");
        $confirmacion = (string) (isset($data["confirmar_password"]) ? $data["confirmar_password"] : "");
        $permisos = $this->normalizarIdsEnteros(isset($data["id_permisos"]) ? $data["id_permisos"] : array());

        if ($idEmpleado <= 0) {
            return array("ok" => false, "msg" => "Debe seleccionar el empleado asociado al usuario.");
        }

        if ($usuario === "") {
            return array("ok" => false, "msg" => "Debe indicar el nombre de usuario.");
        }

        if ($this->longitudTexto($usuario) > 50) {
            return array("ok" => false, "msg" => "El nombre de usuario excede la longitud permitida.");
        }

        $permisoAccesoTotal = $this->obtenerPermisoAccesoTotal();
        $usuarioEditaConAccesoTotal = (int) $idUsuarioEditar > 0
            ? $this->usuarioTieneAccesoTotalActivo((int) $idUsuarioEditar, $permisoAccesoTotal)
            : false;

        if (!in_array($rol, array("OPERADOR", "CONSULTOR", "ADMIN"), true)) {
            return array("ok" => false, "msg" => "El rol seleccionado no esta permitido para tu cuenta.");
        }

        if ($usuarioEditaConAccesoTotal && $rol !== "ADMIN") {
            return array("ok" => false, "msg" => "El usuario con acceso total debe conservar el rol Administrador.");
        }

        if (!$usuarioEditaConAccesoTotal && $rol === "ADMIN") {
            return array("ok" => false, "msg" => "El rol Administrador esta reservado para el usuario con acceso total del sistema.");
        }

        if ((int) $idUsuarioEditar > 0 && $usuarioActual && !$sessionEsAdmin && strtoupper((string) $usuarioActual["rol"]) === "ADMIN") {
            return array("ok" => false, "msg" => "Solo un administrador puede modificar cuentas administrativas.");
        }

        if ((int) $idUsuarioEditar <= 0 && $password === "") {
            return array("ok" => false, "msg" => "Debe indicar una clave para el nuevo usuario.");
        }

        if ($password !== "" && strlen($password) < 6) {
            return array("ok" => false, "msg" => "La clave debe tener al menos 6 caracteres.");
        }

        if ($password !== "" && $password !== $confirmacion) {
            return array("ok" => false, "msg" => "La confirmacion de la clave no coincide.");
        }

        $empleado = ejecutarConsultaSimpleFila(
            "SELECT e.id_empleado,
                    IFNULL(e.estado, 1) AS estado_empleado,
                    e.id_dependencia,
                    IFNULL(d.estado, 1) AS estado_dependencia,
                    d.nombre_dependencia
             FROM empleados e
             LEFT JOIN dependencias d
                ON d.id_dependencia = e.id_dependencia
             WHERE e.id_empleado = '" . $idEmpleado . "'
             LIMIT 1"
        );
        if (!$empleado) {
            return array("ok" => false, "msg" => "El empleado seleccionado no existe.");
        }

        if ((int) $empleado["estado_empleado"] !== 1) {
            return array("ok" => false, "msg" => "El empleado seleccionado se encuentra inactivo.");
        }

        $idDependencia = isset($empleado["id_dependencia"]) ? (int) $empleado["id_dependencia"] : 0;
        if ($idDependencia <= 0) {
            return array("ok" => false, "msg" => "El empleado seleccionado no tiene dependencia asignada.");
        }

        if ((int) $empleado["estado_dependencia"] !== 1) {
            return array("ok" => false, "msg" => "La dependencia asociada al empleado no esta disponible.");
        }

        $usuarioSeraActivo = (int) $idUsuarioEditar > 0
            ? ($usuarioActual && isset($usuarioActual["estado"]) && (int) $usuarioActual["estado"] === 1)
            : true;

        if ($usuarioSeraActivo && $this->esNombreDependenciaDireccionGeneral(isset($empleado["nombre_dependencia"]) ? $empleado["nombre_dependencia"] : "")) {
            $usuarioDireccionGeneral = ejecutarConsultaSimpleFila(
                "SELECT u.id_usuario,
                        u.usuario
                 FROM usuarios u
                 INNER JOIN empleados e
                    ON e.id_empleado = u.id_empleado
                 WHERE IFNULL(u.estado, 1) = 1
                   AND IFNULL(e.estado, 1) = 1
                   AND e.id_dependencia = '" . $idDependencia . "'
                   AND u.id_usuario <> '" . (int) $idUsuarioEditar . "'
                 LIMIT 1"
            );

            if ($usuarioDireccionGeneral) {
                return array("ok" => false, "msg" => "La dependencia Direccion General solo puede tener un usuario activo.");
            }
        }

        $permisosFiltrados = array();
        foreach ($permisos as $idPermiso) {
            if ((int) $permisoAccesoTotal["id_permiso"] > 0 && (int) $idPermiso === (int) $permisoAccesoTotal["id_permiso"]) {
                continue;
            }

            $permisosFiltrados[] = (int) $idPermiso;
        }

        if (!empty($permisosFiltrados)) {
            $sqlPermisos = "SELECT COUNT(*) AS total
                            FROM permisos
                            WHERE IFNULL(estado, 1) = 1
                              AND id_permiso IN (" . implode(", ", $permisosFiltrados) . ")";
            $rowPermisos = ejecutarConsultaSimpleFila($sqlPermisos);
            if ((int) $rowPermisos["total"] !== count($permisosFiltrados)) {
                return array("ok" => false, "msg" => "La lista de permisos contiene valores no validos.");
            }
        }

        return array(
            "ok" => true,
            "data" => array(
                "id_empleado" => $idEmpleado,
                "id_dependencia" => $idDependencia,
                "usuario" => $usuario,
                "rol" => $rol,
                "password" => $password,
                "id_permisos" => $permisosFiltrados
            )
        );
    }

    private function sincronizarPermisosRegularesUsuario($idUsuario, $idsPermisos)
    {
        $permisoAccesoTotal = $this->obtenerPermisoAccesoTotal();
        $idsPermisos = $this->normalizarIdsEnteros($idsPermisos);
        $seleccionados = array();
        foreach ($idsPermisos as $idPermiso) {
            $seleccionados[(int) $idPermiso] = true;
        }

        $sql = "SELECT id_usuario_permiso, id_permiso, IFNULL(estado, 1) AS estado
                FROM usuario_permisos
                WHERE id_usuario = '" . (int) $idUsuario . "'";
        if ((int) $permisoAccesoTotal["id_permiso"] > 0) {
            $sql .= " AND id_permiso <> '" . (int) $permisoAccesoTotal["id_permiso"] . "'";
        }

        $actuales = array();
        $rspta = ejecutarConsulta($sql);
        if ($rspta) {
            while ($row = $rspta->fetch_assoc()) {
                $actuales[(int) $row["id_permiso"]] = array(
                    "id_usuario_permiso" => (int) $row["id_usuario_permiso"],
                    "estado" => (int) $row["estado"]
                );
            }
        }

        foreach ($actuales as $idPermiso => $info) {
            $debeEstarActivo = isset($seleccionados[$idPermiso]);
            $estadoNuevo = $debeEstarActivo ? 1 : 0;
            if ((int) $info["estado"] === $estadoNuevo) {
                continue;
            }

            $sqlUpdate = "UPDATE usuario_permisos
                          SET estado = '" . $estadoNuevo . "'
                          WHERE id_usuario_permiso = '" . (int) $info["id_usuario_permiso"] . "'";
            if (!ejecutarConsulta($sqlUpdate)) {
                throw new Exception("No se pudo actualizar la relacion de permisos del usuario.");
            }
        }

        foreach ($idsPermisos as $idPermiso) {
            if (isset($actuales[(int) $idPermiso])) {
                continue;
            }

            $sqlInsert = "INSERT INTO usuario_permisos (id_usuario, id_permiso, estado)
                          VALUES ('" . (int) $idUsuario . "', '" . (int) $idPermiso . "', 1)";
            if (!ejecutarConsulta($sqlInsert)) {
                throw new Exception("No se pudo asignar uno de los permisos seleccionados.");
            }
        }
    }
    public function guardaryeditarUsuarioSistema($idUsuarioEditar, $data, $idUsuarioSesion)
    {
        $idUsuarioEditar = (int) $idUsuarioEditar;
        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $usuarioActual = null;
            if ($idUsuarioEditar > 0) {
                $usuarioActual = $this->obtenerDetalleUsuarioBase($idUsuarioEditar, true);
                if (!$usuarioActual) {
                    throw new Exception("Usuario no encontrado.");
                }
            }

            $validacion = $this->validarCamposUsuarioSistema($data, $idUsuarioSesion, $idUsuarioEditar, $usuarioActual);
            if (!$validacion["ok"]) {
                throw new Exception($validacion["msg"]);
            }

            $payload = $validacion["data"];
            $passwordHash = $payload["password"] !== "" ? hash("sha256", $payload["password"]) : "";

            if ($idUsuarioEditar > 0) {
                $duplicadoUsuario = ejecutarConsultaSimpleFila(
                    "SELECT id_usuario
                     FROM usuarios
                     WHERE UPPER(TRIM(usuario)) = UPPER(TRIM('" . $this->esc($payload["usuario"]) . "'))
                       AND id_usuario <> '" . $idUsuarioEditar . "'
                     LIMIT 1"
                );
                if ($duplicadoUsuario) {
                    throw new Exception("Ya existe otro usuario con el mismo nombre.");
                }

                $duplicadoEmpleado = ejecutarConsultaSimpleFila(
                    "SELECT id_usuario
                     FROM usuarios
                     WHERE id_empleado = '" . (int) $payload["id_empleado"] . "'
                       AND id_usuario <> '" . $idUsuarioEditar . "'
                     LIMIT 1"
                );
                if ($duplicadoEmpleado) {
                    throw new Exception("El empleado seleccionado ya tiene otra cuenta de usuario.");
                }

                $set = array(
                    "id_empleado = '" . (int) $payload["id_empleado"] . "'",
                    "usuario = '" . $this->esc($payload["usuario"]) . "'",
                    "rol = '" . $this->esc($payload["rol"]) . "'"
                );
                if ($passwordHash !== "") {
                    $set[] = "password = '" . $this->esc($passwordHash) . "'";
                }

                $sqlUpdate = "UPDATE usuarios
                              SET " . implode(", ", $set) . "
                              WHERE id_usuario = '" . $idUsuarioEditar . "'";
                if (!ejecutarConsulta($sqlUpdate)) {
                    throw new Exception("No se pudo actualizar el usuario.");
                }

                $this->sincronizarPermisosRegularesUsuario($idUsuarioEditar, $payload["id_permisos"]);
                $conexion->commit();

                return array(
                    "ok" => true,
                    "msg" => "Usuario actualizado correctamente.",
                    "id_registro" => $idUsuarioEditar
                );
            }

            $coincidenciaUsuario = ejecutarConsultaSimpleFila(
                "SELECT id_usuario, estado, rol
                 FROM usuarios
                 WHERE UPPER(TRIM(usuario)) = UPPER(TRIM('" . $this->esc($payload["usuario"]) . "'))
                 LIMIT 1"
            );
            $coincidenciaEmpleado = ejecutarConsultaSimpleFila(
                "SELECT id_usuario, estado, rol
                 FROM usuarios
                 WHERE id_empleado = '" . (int) $payload["id_empleado"] . "'
                 LIMIT 1"
            );

            $idsCoincidentes = array();
            if ($coincidenciaUsuario) {
                $idsCoincidentes[(int) $coincidenciaUsuario["id_usuario"]] = $coincidenciaUsuario;
            }
            if ($coincidenciaEmpleado) {
                $idsCoincidentes[(int) $coincidenciaEmpleado["id_usuario"]] = $coincidenciaEmpleado;
            }

            if (count($idsCoincidentes) > 1) {
                throw new Exception("Los datos coinciden con usuarios distintos. Revise el empleado y el nombre de usuario.");
            }

            if (count($idsCoincidentes) === 1) {
                $reactivar = reset($idsCoincidentes);
                if ((int) $reactivar["estado"] === 1) {
                    throw new Exception("Ya existe un usuario activo con esos datos.");
                }

                if (!$this->esUsuarioAdministrador($idUsuarioSesion) && strtoupper((string) $reactivar["rol"]) === "ADMIN") {
                    throw new Exception("Solo un administrador puede reactivar cuentas administrativas.");
                }

                $set = array(
                    "id_empleado = '" . (int) $payload["id_empleado"] . "'",
                    "usuario = '" . $this->esc($payload["usuario"]) . "'",
                    "rol = '" . $this->esc($payload["rol"]) . "'",
                    "estado = 1"
                );
                if ($passwordHash !== "") {
                    $set[] = "password = '" . $this->esc($passwordHash) . "'";
                }

                $idReactivado = (int) $reactivar["id_usuario"];
                $sqlReactivar = "UPDATE usuarios
                                 SET " . implode(", ", $set) . "
                                 WHERE id_usuario = '" . $idReactivado . "'";
                if (!ejecutarConsulta($sqlReactivar)) {
                    throw new Exception("No se pudo reactivar el usuario existente.");
                }

                $this->sincronizarPermisosRegularesUsuario($idReactivado, $payload["id_permisos"]);
                $conexion->commit();

                return array(
                    "ok" => true,
                    "msg" => "El usuario ya existia y fue reactivado correctamente.",
                    "id_registro" => $idReactivado,
                    "reactivado" => true
                );
            }

            $sqlInsert = "INSERT INTO usuarios (
                                id_empleado,
                                usuario,
                                password,
                                rol,
                                estado
                           ) VALUES (
                                '" . (int) $payload["id_empleado"] . "',
                                '" . $this->esc($payload["usuario"]) . "',
                                '" . $this->esc($passwordHash) . "',
                                '" . $this->esc($payload["rol"]) . "',
                                1
                           )";
            $idInsertado = ejecutarConsulta_retornarID($sqlInsert);
            if ((int) $idInsertado <= 0) {
                throw new Exception("No se pudo crear el usuario.");
            }

            $this->sincronizarPermisosRegularesUsuario((int) $idInsertado, $payload["id_permisos"]);
            $conexion->commit();

            return array(
                "ok" => true,
                "msg" => "Usuario creado correctamente.",
                "id_registro" => (int) $idInsertado
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function cambiarEstadoUsuarioSistema($idUsuarioObjetivo, $activar, $idUsuarioSesion)
    {
        $idUsuarioObjetivo = (int) $idUsuarioObjetivo;
        $activar = (bool) $activar;
        $sessionEsAdmin = $this->esUsuarioAdministrador($idUsuarioSesion);
        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $row = $this->obtenerDetalleUsuarioBase($idUsuarioObjetivo, true);
            if (!$row) {
                throw new Exception("Usuario no encontrado.");
            }

            if (!$sessionEsAdmin && strtoupper((string) $row["rol"]) === "ADMIN") {
                throw new Exception("Solo un administrador puede gestionar cuentas administrativas.");
            }

            if (!$activar && (int) $idUsuarioObjetivo === (int) $idUsuarioSesion) {
                throw new Exception("No puedes desactivar el usuario de la sesion actual.");
            }

            if ($activar && (int) $row["estado"] === 1) {
                throw new Exception("El usuario ya se encuentra activo.");
            }

            if (!$activar && (int) $row["estado"] === 0) {
                throw new Exception("El usuario ya se encuentra inactivo.");
            }

            if ($activar && $this->esNombreDependenciaDireccionGeneral(isset($row["nombre_dependencia"]) ? $row["nombre_dependencia"] : "")) {
                $usuarioDireccionGeneral = ejecutarConsultaSimpleFila(
                    "SELECT u.id_usuario
                     FROM usuarios u
                     INNER JOIN empleados e
                        ON e.id_empleado = u.id_empleado
                     WHERE IFNULL(u.estado, 1) = 1
                       AND IFNULL(e.estado, 1) = 1
                       AND e.id_dependencia = '" . (int) $row["id_dependencia"] . "'
                       AND u.id_usuario <> '" . $idUsuarioObjetivo . "'
                     LIMIT 1"
                );
                if ($usuarioDireccionGeneral) {
                    throw new Exception("La dependencia Direccion General solo puede tener un usuario activo.");
                }
            }

            $sql = "UPDATE usuarios
                    SET estado = '" . ($activar ? 1 : 0) . "'
                    WHERE id_usuario = '" . $idUsuarioObjetivo . "'";
            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo actualizar el estado del usuario.");
            }

            $conexion->commit();
            return array(
                "ok" => true,
                "msg" => $activar
                    ? "Usuario reactivado correctamente."
                    : "Usuario desactivado correctamente."
            );
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }

    public function cambiarAccesoTotalUsuario($idUsuarioObjetivo, $otorgar, $idUsuarioSesion)
    {
        $idUsuarioObjetivo = (int) $idUsuarioObjetivo;
        $otorgar = (bool) $otorgar;
        $idUsuarioSesion = (int) $idUsuarioSesion;
        if (!$this->esUsuarioAdministrador($idUsuarioSesion)) {
            return array("ok" => false, "msg" => "Solo un administrador puede transferir el acceso total del sistema.");
        }

        $permisoAccesoTotal = $this->obtenerPermisoAccesoTotal();
        if ((int) $permisoAccesoTotal["id_permiso"] <= 0) {
            return array("ok" => false, "msg" => "No se encontro el permiso especial de acceso total.");
        }

        $conexion = $this->db();
        $conexion->begin_transaction();

        try {
            $row = $this->obtenerDetalleUsuarioBase($idUsuarioObjetivo, true);
            if (!$row) {
                throw new Exception("Usuario no encontrado.");
            }

            if ((int) $row["estado"] !== 1) {
                throw new Exception("Solo puedes cambiar el acceso total de usuarios activos.");
            }

            $relacion = ejecutarConsultaSimpleFila(
                "SELECT id_usuario_permiso, IFNULL(estado, 1) AS estado
                 FROM usuario_permisos
                 WHERE id_usuario = '" . $idUsuarioObjetivo . "'
                   AND id_permiso = '" . (int) $permisoAccesoTotal["id_permiso"] . "'
                 LIMIT 1"
            );
            $relacionSesion = ejecutarConsultaSimpleFila(
                "SELECT id_usuario_permiso, IFNULL(estado, 1) AS estado
                 FROM usuario_permisos
                 WHERE id_usuario = '" . $idUsuarioSesion . "'
                   AND id_permiso = '" . (int) $permisoAccesoTotal["id_permiso"] . "'
                 LIMIT 1"
            );

            if ($otorgar) {
                $objetivoYaActivo = $relacion && (int) $relacion["estado"] === 1;

                if (!$objetivoYaActivo) {
                    if ($relacion) {
                        $sql = "UPDATE usuario_permisos
                                SET estado = 1
                                WHERE id_usuario_permiso = '" . (int) $relacion["id_usuario_permiso"] . "'";
                    } else {
                        $sql = "INSERT INTO usuario_permisos (id_usuario, id_permiso, estado)
                                VALUES ('" . $idUsuarioObjetivo . "', '" . (int) $permisoAccesoTotal["id_permiso"] . "', 1)";
                    }

                    if (!ejecutarConsulta($sql)) {
                        throw new Exception("No se pudo otorgar el acceso total.");
                    }
                }

                $transferenciaAplicada = false;
                if ($idUsuarioObjetivo !== $idUsuarioSesion && $relacionSesion && (int) $relacionSesion["estado"] === 1) {
                    $sqlTransferir = "UPDATE usuario_permisos
                                      SET estado = 0
                                      WHERE id_usuario_permiso = '" . (int) $relacionSesion["id_usuario_permiso"] . "'";
                    if (!ejecutarConsulta($sqlTransferir)) {
                        throw new Exception("No se pudo transferir el acceso total.");
                    }

                    $transferenciaAplicada = true;
                }

                if ($objetivoYaActivo && !$transferenciaAplicada) {
                    throw new Exception("El usuario ya cuenta con acceso total del sistema.");
                }

                $sqlPromoverObjetivo = "UPDATE usuarios
                                        SET rol = 'ADMIN'
                                        WHERE id_usuario = '" . $idUsuarioObjetivo . "'
                                          AND UPPER(TRIM(rol)) <> 'ADMIN'";
                if (!ejecutarConsulta($sqlPromoverObjetivo)) {
                    throw new Exception("No se pudo sincronizar el rol administrativo del usuario.");
                }

                $sqlRebajarOtros = "UPDATE usuarios
                                    SET rol = 'OPERADOR'
                                    WHERE estado = 1
                                      AND id_usuario <> '" . $idUsuarioObjetivo . "'
                                      AND UPPER(TRIM(rol)) = 'ADMIN'";
                if (!ejecutarConsulta($sqlRebajarOtros)) {
                    throw new Exception("No se pudo sincronizar los roles administrativos.");
                }

                $conexion->commit();
                return array(
                    "ok" => true,
                    "msg" => $transferenciaAplicada
                        ? "Acceso total transferido correctamente."
                        : "Acceso total otorgado correctamente."
                );
            }

            if ($idUsuarioObjetivo === $idUsuarioSesion) {
                throw new Exception("No puedes retirar tu propio acceso total. Debes otorgarlo a otro usuario para transferirlo.");
            }

            if (!$relacion || (int) $relacion["estado"] !== 1) {
                throw new Exception("El usuario no tiene acceso total asignado.");
            }

            $sql = "UPDATE usuario_permisos
                    SET estado = 0
                    WHERE id_usuario_permiso = '" . (int) $relacion["id_usuario_permiso"] . "'";
            if (!ejecutarConsulta($sql)) {
                throw new Exception("No se pudo retirar el acceso total.");
            }

            $sqlRebajarObjetivo = "UPDATE usuarios
                                   SET rol = 'OPERADOR'
                                   WHERE id_usuario = '" . $idUsuarioObjetivo . "'
                                     AND UPPER(TRIM(rol)) = 'ADMIN'";
            if (!ejecutarConsulta($sqlRebajarObjetivo)) {
                throw new Exception("No se pudo sincronizar el rol del usuario.");
            }

            $conexion->commit();
            return array("ok" => true, "msg" => "Acceso total retirado correctamente.");
        } catch (Exception $exception) {
            $conexion->rollback();
            return array("ok" => false, "msg" => $exception->getMessage());
        }
    }
}
?>
