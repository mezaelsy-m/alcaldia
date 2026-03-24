-- ============================================================
-- INSTALADOR FINAL UNIFICADO - ALCALDIA / SALA SITUACIONAL
-- Generado a partir de los dumps actualizados de:
--   * sala_situacional (1).sql
--   * sala_situacional_respaldo_bitacora (1).sql
--
-- NOTA IMPORTANTE:
-- Las contraseñas se conservaron exactamente como fueron enviadas,
-- incluyendo espacios en las claves donde venían escritos.
--
-- El script intenta ser tolerante con la sección de seguridad:
-- si el usuario que importa no posee CREATE USER / CREATE ROLE /
-- GRANT / SET GLOBAL, esa sección no detiene la importación.
-- ============================================================

SET @OLD_SQL_MODE := @@SQL_MODE;
SET @OLD_FOREIGN_KEY_CHECKS := @@FOREIGN_KEY_CHECKS;
SET @OLD_UNIQUE_CHECKS := @@UNIQUE_CHECKS;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET time_zone = '+00:00';
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS `sala_situacional` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE DATABASE IF NOT EXISTS `sala_situacional_respaldo_bitacora` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- ============================================================
-- ESQUEMA PRINCIPAL: sala_situacional
-- ============================================================
USE `sala_situacional`;

DROP PROCEDURE IF EXISTS `sp_drop_view_or_table_if_exists`;
DELIMITER $$
CREATE PROCEDURE `sp_drop_view_or_table_if_exists`(IN p_object_name VARCHAR(64))
BEGIN
    DECLARE v_table_type VARCHAR(20) DEFAULT NULL;
    SELECT TABLE_TYPE INTO v_table_type
      FROM information_schema.TABLES
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = p_object_name
     LIMIT 1;

    IF v_table_type = 'VIEW' THEN
        SET @sql_drop = CONCAT('DROP VIEW IF EXISTS `', REPLACE(p_object_name, '`', '``'), '`');
        PREPARE stmt_drop FROM @sql_drop;
        EXECUTE stmt_drop;
        DEALLOCATE PREPARE stmt_drop;
    ELSEIF v_table_type = 'BASE TABLE' THEN
        SET @sql_drop = CONCAT('DROP TABLE IF EXISTS `', REPLACE(p_object_name, '`', '``'), '`');
        PREPARE stmt_drop FROM @sql_drop;
        EXECUTE stmt_drop;
        DEALLOCATE PREPARE stmt_drop;
    END IF;
END$$
DELIMITER ;

CALL `sp_drop_view_or_table_if_exists`('vw_bitacora_sistema');
CALL `sp_drop_view_or_table_if_exists`('vw_bitacora_autenticacion');
CALL `sp_drop_view_or_table_if_exists`('vw_seguridad_operativa');
CALL `sp_drop_view_or_table_if_exists`('vw_solicitudes_ciudadanas');
CALL `sp_drop_view_or_table_if_exists`('vw_unidades_operativas_actuales');
CALL `sp_drop_view_or_table_if_exists`('vw_usuarios_estado_acceso');
DROP PROCEDURE IF EXISTS `sp_drop_view_or_table_if_exists`;
DROP PROCEDURE IF EXISTS `sp_bitacora_registrar_evento`;
DROP PROCEDURE IF EXISTS `sp_bitacora_registrar_autenticacion`;
DROP PROCEDURE IF EXISTS `sp_bitacora_consultar_autenticacion`;
DROP PROCEDURE IF EXISTS `sp_dashboard_resumen_general`;
DROP PROCEDURE IF EXISTS `sp_usuarios_incrementar_intento_fallido`;
DROP PROCEDURE IF EXISTS `sp_usuarios_marcar_bloqueado`;
DROP PROCEDURE IF EXISTS `sp_usuarios_reiniciar_seguridad_acceso`;
DROP PROCEDURE IF EXISTS `sp_usuarios_desbloquear_manual`;
DROP TABLE IF EXISTS `usuario_permisos`;
DROP TABLE IF EXISTS `usuarios_seguridad_acceso`;
DROP TABLE IF EXISTS `usuarios`;
DROP TABLE IF EXISTS `unidades`;
DROP TABLE IF EXISTS `tipos_servicios_publicos`;
DROP TABLE IF EXISTS `tipos_seguridad_emergencia`;
DROP TABLE IF EXISTS `tipos_ayuda_social`;
DROP TABLE IF EXISTS `solicitudes_generales`;
DROP TABLE IF EXISTS `servicios_publicos`;
DROP TABLE IF EXISTS `seguridad`;
DROP TABLE IF EXISTS `seguimientos_solicitudes`;
DROP TABLE IF EXISTS `reportes_traslado`;
DROP TABLE IF EXISTS `reportes_solicitudes_ambulancia`;
DROP TABLE IF EXISTS `permisos`;
DROP TABLE IF EXISTS `estados_solicitudes`;
DROP TABLE IF EXISTS `empleados`;
DROP TABLE IF EXISTS `despachos_unidades`;
DROP TABLE IF EXISTS `dependencias`;
DROP TABLE IF EXISTS `configuracion_smtp`;
DROP TABLE IF EXISTS `comunidades`;
DROP TABLE IF EXISTS `choferes_ambulancia`;
DROP TABLE IF EXISTS `bitacora`;
DROP TABLE IF EXISTS `beneficiarios`;
DROP TABLE IF EXISTS `ayuda_social`;
DROP TABLE IF EXISTS `asignaciones_unidades_choferes`;

CREATE TABLE `asignaciones_unidades_choferes` (
  `id_asignacion_unidad_chofer` int(11) NOT NULL COMMENT 'Campo id_asignacion_unidad_chofer de la tabla asignaciones_unidades_choferes.',
  `id_unidad` int(11) NOT NULL COMMENT 'Campo id_unidad de la tabla asignaciones_unidades_choferes.',
  `id_chofer_ambulancia` int(11) NOT NULL COMMENT 'Campo id_chofer_ambulancia de la tabla asignaciones_unidades_choferes.',
  `fecha_inicio` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_inicio de la tabla asignaciones_unidades_choferes.',
  `fecha_fin` datetime DEFAULT NULL COMMENT 'Campo fecha_fin de la tabla asignaciones_unidades_choferes.',
  `observaciones` text DEFAULT NULL COMMENT 'Campo observaciones de la tabla asignaciones_unidades_choferes.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla asignaciones_unidades_choferes.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla asignaciones_unidades_choferes.',
  `fecha_actualizacion` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Campo fecha_actualizacion de la tabla asignaciones_unidades_choferes.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `ayuda_social` (
  `id_ayuda` int(11) NOT NULL COMMENT 'Número correlativo de la solicitud',
  `ticket_interno` varchar(20) DEFAULT NULL COMMENT 'Campo ticket_interno de la tabla ayuda_social.',
  `id_beneficiario` int(11) NOT NULL COMMENT 'FK: Enlace con los datos personales del solicitante',
  `id_usuario` int(11) DEFAULT NULL COMMENT 'Campo id_usuario de la tabla ayuda_social.',
  `id_tipo_ayuda_social` int(11) DEFAULT NULL COMMENT 'Campo id_tipo_ayuda_social de la tabla ayuda_social.',
  `id_solicitud_ayuda_social` int(11) DEFAULT NULL COMMENT 'Campo id_solicitud_ayuda_social de la tabla ayuda_social.',
  `id_estado_solicitud` int(11) DEFAULT NULL COMMENT 'Campo id_estado_solicitud de la tabla ayuda_social.',
  `tipo_ayuda` varchar(100) DEFAULT NULL COMMENT 'Campo tipo_ayuda de la tabla ayuda_social.',
  `solicitud_ayuda` varchar(100) DEFAULT NULL COMMENT 'Estado administrativo: PENDIENTE, ENTREGADO, EN ESPERA',
  `fecha_ayuda` date DEFAULT NULL COMMENT 'Campo fecha_ayuda de la tabla ayuda_social.',
  `descripcion` text DEFAULT NULL COMMENT 'Campo descripcion de la tabla ayuda_social.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla ayuda_social.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `beneficiarios` (
  `id_beneficiario` int(11) NOT NULL COMMENT 'Campo id_beneficiario de la tabla beneficiarios.',
  `nacionalidad` enum('V','E') DEFAULT 'V' COMMENT 'Campo nacionalidad de la tabla beneficiarios.',
  `cedula` int(11) NOT NULL COMMENT 'Campo cedula de la tabla beneficiarios.',
  `nombre_beneficiario` varchar(150) NOT NULL COMMENT 'Campo nombre_beneficiario de la tabla beneficiarios.',
  `telefono` varchar(20) DEFAULT NULL COMMENT 'Campo telefono de la tabla beneficiarios.',
  `id_comunidad` int(11) NOT NULL COMMENT 'Campo id_comunidad de la tabla beneficiarios.',
  `comunidad` varchar(100) DEFAULT NULL COMMENT 'Campo comunidad de la tabla beneficiarios.',
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla beneficiarios.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla beneficiarios.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `bitacora` (
  `id_bitacora` int(11) NOT NULL COMMENT 'Campo id_bitacora de la tabla bitacora.',
  `id_usuario` int(11) DEFAULT NULL COMMENT 'Campo id_usuario de la tabla bitacora.',
  `tabla_afectada` varchar(64) DEFAULT NULL COMMENT 'Campo tabla_afectada de la tabla bitacora.',
  `accion` varchar(20) NOT NULL DEFAULT 'LEGACY' COMMENT 'Campo accion de la tabla bitacora.',
  `id_registro` varchar(64) DEFAULT NULL COMMENT 'Campo id_registro de la tabla bitacora.',
  `resumen` varchar(100) NOT NULL COMMENT 'Descripción breve de la acción realizada por el usuario',
  `detalle` text DEFAULT NULL COMMENT 'Campo detalle de la tabla bitacora.',
  `datos_antes` longtext DEFAULT NULL COMMENT 'Campo datos_antes de la tabla bitacora.',
  `datos_despues` longtext DEFAULT NULL COMMENT 'Campo datos_despues de la tabla bitacora.',
  `usuario_bd` varchar(100) DEFAULT NULL COMMENT 'Campo usuario_bd de la tabla bitacora.',
  `ipaddr` varchar(45) DEFAULT '127.0.0.1' COMMENT 'Dirección IP desde donde se realizó la operación',
  `moment` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Campo moment de la tabla bitacora.',
  `fecha_evento` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_evento de la tabla bitacora.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla bitacora.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `choferes_ambulancia` (
  `id_chofer_ambulancia` int(11) NOT NULL COMMENT 'Campo id_chofer_ambulancia de la tabla choferes_ambulancia.',
  `id_empleado` int(11) NOT NULL COMMENT 'Campo id_empleado de la tabla choferes_ambulancia.',
  `numero_licencia` varchar(60) DEFAULT NULL COMMENT 'Campo numero_licencia de la tabla choferes_ambulancia.',
  `categoria_licencia` varchar(40) DEFAULT NULL COMMENT 'Campo categoria_licencia de la tabla choferes_ambulancia.',
  `vencimiento_licencia` date DEFAULT NULL COMMENT 'Campo vencimiento_licencia de la tabla choferes_ambulancia.',
  `contacto_emergencia` varchar(120) DEFAULT NULL COMMENT 'Campo contacto_emergencia de la tabla choferes_ambulancia.',
  `telefono_contacto_emergencia` varchar(30) DEFAULT NULL COMMENT 'Campo telefono_contacto_emergencia de la tabla choferes_ambulancia.',
  `observaciones` text DEFAULT NULL COMMENT 'Campo observaciones de la tabla choferes_ambulancia.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla choferes_ambulancia.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla choferes_ambulancia.',
  `fecha_actualizacion` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Campo fecha_actualizacion de la tabla choferes_ambulancia.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `comunidades` (
  `id_comunidad` int(11) NOT NULL COMMENT 'Campo id_comunidad de la tabla comunidades.',
  `nombre_comunidad` varchar(120) NOT NULL COMMENT 'Campo nombre_comunidad de la tabla comunidades.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla comunidades.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla comunidades.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `configuracion_smtp` (
  `id_configuracion_smtp` int(11) NOT NULL COMMENT 'Campo id_configuracion_smtp de la tabla configuracion_smtp.',
  `host` varchar(150) NOT NULL DEFAULT 'smtp.gmail.com' COMMENT 'Campo host de la tabla configuracion_smtp.',
  `puerto` int(11) NOT NULL DEFAULT 587 COMMENT 'Campo puerto de la tabla configuracion_smtp.',
  `usuario` varchar(150) NOT NULL COMMENT 'Campo usuario de la tabla configuracion_smtp.',
  `clave` varchar(255) NOT NULL COMMENT 'Campo clave de la tabla configuracion_smtp.',
  `correo_remitente` varchar(150) NOT NULL COMMENT 'Campo correo_remitente de la tabla configuracion_smtp.',
  `nombre_remitente` varchar(150) DEFAULT NULL COMMENT 'Campo nombre_remitente de la tabla configuracion_smtp.',
  `usar_tls` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo usar_tls de la tabla configuracion_smtp.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla configuracion_smtp.',
  `id_usuario_actualiza` int(11) DEFAULT NULL COMMENT 'Campo id_usuario_actualiza de la tabla configuracion_smtp.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla configuracion_smtp.',
  `fecha_actualizacion` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Campo fecha_actualizacion de la tabla configuracion_smtp.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `dependencias` (
  `id_dependencia` int(11) NOT NULL COMMENT 'Campo id_dependencia de la tabla dependencias.',
  `nombre_dependencia` varchar(100) NOT NULL COMMENT 'Campo nombre_dependencia de la tabla dependencias.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla dependencias.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `despachos_unidades` (
  `id_despacho_unidad` int(11) NOT NULL COMMENT 'Campo id_despacho_unidad de la tabla despachos_unidades.',
  `id_seguridad` int(11) NOT NULL COMMENT 'Campo id_seguridad de la tabla despachos_unidades.',
  `id_unidad` int(11) NOT NULL COMMENT 'Campo id_unidad de la tabla despachos_unidades.',
  `id_chofer_ambulancia` int(11) NOT NULL COMMENT 'Campo id_chofer_ambulancia de la tabla despachos_unidades.',
  `id_usuario_asigna` int(11) DEFAULT NULL COMMENT 'Campo id_usuario_asigna de la tabla despachos_unidades.',
  `modo_asignacion` enum('AUTO','MANUAL') NOT NULL DEFAULT 'AUTO' COMMENT 'Campo modo_asignacion de la tabla despachos_unidades.',
  `estado_despacho` enum('ACTIVO','CERRADO','CANCELADO') NOT NULL DEFAULT 'ACTIVO' COMMENT 'Campo estado_despacho de la tabla despachos_unidades.',
  `fecha_asignacion` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_asignacion de la tabla despachos_unidades.',
  `fecha_cierre` datetime DEFAULT NULL COMMENT 'Campo fecha_cierre de la tabla despachos_unidades.',
  `ubicacion_salida` varchar(190) DEFAULT NULL COMMENT 'Campo ubicacion_salida de la tabla despachos_unidades.',
  `ubicacion_evento` varchar(190) DEFAULT NULL COMMENT 'Campo ubicacion_evento de la tabla despachos_unidades.',
  `ubicacion_cierre` varchar(190) DEFAULT NULL COMMENT 'Campo ubicacion_cierre de la tabla despachos_unidades.',
  `observaciones` text DEFAULT NULL COMMENT 'Campo observaciones de la tabla despachos_unidades.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla despachos_unidades.',
  `fecha_actualizacion` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Campo fecha_actualizacion de la tabla despachos_unidades.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `empleados` (
  `id_empleado` int(11) NOT NULL COMMENT 'Campo id_empleado de la tabla empleados.',
  `cedula` int(11) NOT NULL COMMENT 'Campo cedula de la tabla empleados.',
  `nombre` varchar(100) NOT NULL COMMENT 'Campo nombre de la tabla empleados.',
  `apellido` varchar(100) NOT NULL COMMENT 'Campo apellido de la tabla empleados.',
  `id_dependencia` int(11) NOT NULL COMMENT 'Campo id_dependencia de la tabla empleados.',
  `telefono` varchar(20) DEFAULT NULL COMMENT 'Campo telefono de la tabla empleados.',
  `correo` varchar(150) DEFAULT NULL COMMENT 'Campo correo de la tabla empleados.',
  `direccion` varchar(255) DEFAULT NULL COMMENT 'Campo direccion de la tabla empleados.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla empleados.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `estados_solicitudes` (
  `id_estado_solicitud` int(11) NOT NULL COMMENT 'Campo id_estado_solicitud de la tabla estados_solicitudes.',
  `codigo_estado` varchar(40) NOT NULL COMMENT 'Campo codigo_estado de la tabla estados_solicitudes.',
  `nombre_estado` varchar(80) NOT NULL COMMENT 'Campo nombre_estado de la tabla estados_solicitudes.',
  `descripcion` varchar(190) DEFAULT NULL COMMENT 'Campo descripcion de la tabla estados_solicitudes.',
  `clase_badge` varchar(30) NOT NULL DEFAULT 'draft' COMMENT 'Campo clase_badge de la tabla estados_solicitudes.',
  `es_atendida` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Campo es_atendida de la tabla estados_solicitudes.',
  `orden_visual` tinyint(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Campo orden_visual de la tabla estados_solicitudes.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla estados_solicitudes.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `permisos` (
  `id_permiso` int(11) NOT NULL COMMENT 'Campo id_permiso de la tabla permisos.',
  `nombre_permiso` varchar(100) NOT NULL COMMENT 'Campo nombre_permiso de la tabla permisos.',
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Campo descripcion de la tabla permisos.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla permisos.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `reportes_solicitudes_ambulancia` (
  `id_reporte_solicitud` int(11) NOT NULL COMMENT 'Campo id_reporte_solicitud de la tabla reportes_solicitudes_ambulancia.',
  `id_seguridad` int(11) NOT NULL COMMENT 'Campo id_seguridad de la tabla reportes_solicitudes_ambulancia.',
  `id_despacho_unidad` int(11) DEFAULT NULL COMMENT 'Campo id_despacho_unidad de la tabla reportes_solicitudes_ambulancia.',
  `tipo_reporte` enum('REGISTRO','CIERRE') NOT NULL DEFAULT 'REGISTRO' COMMENT 'Campo tipo_reporte de la tabla reportes_solicitudes_ambulancia.',
  `nombre_archivo` varchar(180) NOT NULL COMMENT 'Campo nombre_archivo de la tabla reportes_solicitudes_ambulancia.',
  `ruta_archivo` varchar(255) NOT NULL COMMENT 'Campo ruta_archivo de la tabla reportes_solicitudes_ambulancia.',
  `estado_envio` enum('NO_APLICA','PENDIENTE','ENVIADO','ERROR') NOT NULL DEFAULT 'NO_APLICA' COMMENT 'Campo estado_envio de la tabla reportes_solicitudes_ambulancia.',
  `correo_destino` varchar(150) DEFAULT NULL COMMENT 'Campo correo_destino de la tabla reportes_solicitudes_ambulancia.',
  `fecha_envio` datetime DEFAULT NULL COMMENT 'Campo fecha_envio de la tabla reportes_solicitudes_ambulancia.',
  `detalle_envio` text DEFAULT NULL COMMENT 'Campo detalle_envio de la tabla reportes_solicitudes_ambulancia.',
  `id_usuario_genera` int(11) DEFAULT NULL COMMENT 'Campo id_usuario_genera de la tabla reportes_solicitudes_ambulancia.',
  `fecha_generacion` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_generacion de la tabla reportes_solicitudes_ambulancia.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla reportes_solicitudes_ambulancia.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `reportes_traslado` (
  `id_reporte` int(11) NOT NULL COMMENT 'Campo id_reporte de la tabla reportes_traslado.',
  `id_ayuda` int(11) DEFAULT NULL COMMENT 'Campo id_ayuda de la tabla reportes_traslado.',
  `id_seguridad` int(11) DEFAULT NULL COMMENT 'Campo id_seguridad de la tabla reportes_traslado.',
  `id_despacho_unidad` int(11) DEFAULT NULL COMMENT 'Campo id_despacho_unidad de la tabla reportes_traslado.',
  `id_usuario_operador` int(11) NOT NULL COMMENT 'Campo id_usuario_operador de la tabla reportes_traslado.',
  `id_empleado_chofer` int(11) NOT NULL COMMENT 'Campo id_empleado_chofer de la tabla reportes_traslado.',
  `id_unidad` int(11) NOT NULL COMMENT 'Campo id_unidad de la tabla reportes_traslado.',
  `ticket_interno` varchar(20) NOT NULL COMMENT 'Campo ticket_interno de la tabla reportes_traslado.',
  `fecha_hora` datetime DEFAULT current_timestamp() COMMENT 'Campo fecha_hora de la tabla reportes_traslado.',
  `diagnostico_paciente` text DEFAULT NULL COMMENT 'Campo diagnostico_paciente de la tabla reportes_traslado.',
  `foto_evidencia` varchar(255) DEFAULT NULL COMMENT 'Campo foto_evidencia de la tabla reportes_traslado.',
  `km_salida` int(11) DEFAULT NULL COMMENT 'Campo km_salida de la tabla reportes_traslado.',
  `km_llegada` int(11) DEFAULT NULL COMMENT 'Campo km_llegada de la tabla reportes_traslado.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla reportes_traslado.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `seguimientos_solicitudes` (
  `id_seguimiento_solicitud` int(11) NOT NULL COMMENT 'Campo id_seguimiento_solicitud de la tabla seguimientos_solicitudes.',
  `modulo` enum('AYUDA_SOCIAL','SEGURIDAD','SERVICIOS_PUBLICOS') NOT NULL COMMENT 'Campo modulo de la tabla seguimientos_solicitudes.',
  `id_referencia` int(11) NOT NULL COMMENT 'Campo id_referencia de la tabla seguimientos_solicitudes.',
  `id_estado_solicitud` int(11) NOT NULL COMMENT 'Campo id_estado_solicitud de la tabla seguimientos_solicitudes.',
  `id_usuario` int(11) DEFAULT NULL COMMENT 'Campo id_usuario de la tabla seguimientos_solicitudes.',
  `fecha_gestion` datetime NOT NULL COMMENT 'Campo fecha_gestion de la tabla seguimientos_solicitudes.',
  `observacion` text DEFAULT NULL COMMENT 'Campo observacion de la tabla seguimientos_solicitudes.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla seguimientos_solicitudes.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `seguridad` (
  `id_seguridad` int(11) NOT NULL COMMENT 'Campo id_seguridad de la tabla seguridad.',
  `ticket_interno` varchar(20) DEFAULT NULL COMMENT 'Campo ticket_interno de la tabla seguridad.',
  `id_beneficiario` int(11) NOT NULL COMMENT 'Campo id_beneficiario de la tabla seguridad.',
  `id_usuario` int(11) DEFAULT NULL COMMENT 'Campo id_usuario de la tabla seguridad.',
  `id_tipo_seguridad` int(11) DEFAULT NULL COMMENT 'Campo id_tipo_seguridad de la tabla seguridad.',
  `id_solicitud_seguridad` int(11) DEFAULT NULL COMMENT 'Campo id_solicitud_seguridad de la tabla seguridad.',
  `id_estado_solicitud` int(11) DEFAULT NULL COMMENT 'Campo id_estado_solicitud de la tabla seguridad.',
  `tipo_seguridad` varchar(100) DEFAULT NULL COMMENT 'Campo tipo_seguridad de la tabla seguridad.',
  `tipo_solicitud` varchar(100) DEFAULT NULL COMMENT 'Campo tipo_solicitud de la tabla seguridad.',
  `fecha_seguridad` datetime DEFAULT NULL COMMENT 'Campo fecha_seguridad de la tabla seguridad.',
  `descripcion` text DEFAULT NULL COMMENT 'Campo descripcion de la tabla seguridad.',
  `estado_atencion` enum('REGISTRADO','PENDIENTE_UNIDAD','DESPACHADO','FINALIZADO','ANULADO') NOT NULL DEFAULT 'REGISTRADO' COMMENT 'Campo estado_atencion de la tabla seguridad.',
  `ubicacion_evento` varchar(190) DEFAULT NULL COMMENT 'Campo ubicacion_evento de la tabla seguridad.',
  `referencia_evento` varchar(190) DEFAULT NULL COMMENT 'Campo referencia_evento de la tabla seguridad.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla seguridad.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `servicios_publicos` (
  `id_servicio` int(11) NOT NULL COMMENT 'Campo id_servicio de la tabla servicios_publicos.',
  `ticket_interno` varchar(20) DEFAULT NULL COMMENT 'Campo ticket_interno de la tabla servicios_publicos.',
  `id_beneficiario` int(11) NOT NULL COMMENT 'Campo id_beneficiario de la tabla servicios_publicos.',
  `id_usuario` int(11) DEFAULT NULL COMMENT 'Campo id_usuario de la tabla servicios_publicos.',
  `id_tipo_servicio_publico` int(11) DEFAULT NULL COMMENT 'Campo id_tipo_servicio_publico de la tabla servicios_publicos.',
  `id_solicitud_servicio_publico` int(11) DEFAULT NULL COMMENT 'Campo id_solicitud_servicio_publico de la tabla servicios_publicos.',
  `id_estado_solicitud` int(11) DEFAULT NULL COMMENT 'Campo id_estado_solicitud de la tabla servicios_publicos.',
  `tipo_servicio` varchar(100) DEFAULT NULL COMMENT 'Campo tipo_servicio de la tabla servicios_publicos.',
  `solicitud_servicio` varchar(100) DEFAULT NULL COMMENT 'Campo solicitud_servicio de la tabla servicios_publicos.',
  `fecha_servicio` date DEFAULT NULL COMMENT 'Campo fecha_servicio de la tabla servicios_publicos.',
  `descripcion` text DEFAULT NULL COMMENT 'Campo descripcion de la tabla servicios_publicos.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla servicios_publicos.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `solicitudes_generales` (
  `id_solicitud_general` int(11) NOT NULL COMMENT 'Campo id_solicitud_general de la tabla solicitudes_generales.',
  `codigo_solicitud` varchar(20) NOT NULL COMMENT 'Campo codigo_solicitud de la tabla solicitudes_generales.',
  `nombre_solicitud` varchar(120) NOT NULL COMMENT 'Campo nombre_solicitud de la tabla solicitudes_generales.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla solicitudes_generales.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla solicitudes_generales.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `tipos_ayuda_social` (
  `id_tipo_ayuda_social` int(11) NOT NULL COMMENT 'Campo id_tipo_ayuda_social de la tabla tipos_ayuda_social.',
  `nombre_tipo_ayuda` varchar(120) NOT NULL COMMENT 'Campo nombre_tipo_ayuda de la tabla tipos_ayuda_social.',
  `requiere_ambulancia` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Campo requiere_ambulancia de la tabla tipos_ayuda_social.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla tipos_ayuda_social.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla tipos_ayuda_social.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `tipos_seguridad_emergencia` (
  `id_tipo_seguridad` int(11) NOT NULL COMMENT 'Campo id_tipo_seguridad de la tabla tipos_seguridad_emergencia.',
  `nombre_tipo` varchar(120) NOT NULL COMMENT 'Campo nombre_tipo de la tabla tipos_seguridad_emergencia.',
  `requiere_ambulancia` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Campo requiere_ambulancia de la tabla tipos_seguridad_emergencia.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla tipos_seguridad_emergencia.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla tipos_seguridad_emergencia.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `tipos_servicios_publicos` (
  `id_tipo_servicio_publico` int(11) NOT NULL COMMENT 'Campo id_tipo_servicio_publico de la tabla tipos_servicios_publicos.',
  `codigo_tipo_servicio_publico` varchar(20) NOT NULL COMMENT 'Campo codigo_tipo_servicio_publico de la tabla tipos_servicios_publicos.',
  `nombre_tipo_servicio` varchar(120) NOT NULL COMMENT 'Campo nombre_tipo_servicio de la tabla tipos_servicios_publicos.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla tipos_servicios_publicos.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla tipos_servicios_publicos.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `unidades` (
  `id_unidad` int(11) NOT NULL COMMENT 'Campo id_unidad de la tabla unidades.',
  `codigo_unidad` varchar(20) NOT NULL COMMENT 'Campo codigo_unidad de la tabla unidades.',
  `descripcion` varchar(100) DEFAULT NULL COMMENT 'Campo descripcion de la tabla unidades.',
  `placa` varchar(15) NOT NULL COMMENT 'Campo placa de la tabla unidades.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla unidades.',
  `estado_operativo` enum('DISPONIBLE','EN_SERVICIO','FUERA_SERVICIO') NOT NULL DEFAULT 'DISPONIBLE' COMMENT 'Campo estado_operativo de la tabla unidades.',
  `ubicacion_actual` varchar(190) DEFAULT NULL COMMENT 'Campo ubicacion_actual de la tabla unidades.',
  `referencia_actual` varchar(190) DEFAULT NULL COMMENT 'Campo referencia_actual de la tabla unidades.',
  `prioridad_despacho` int(11) NOT NULL DEFAULT 100 COMMENT 'Campo prioridad_despacho de la tabla unidades.',
  `fecha_actualizacion_operativa` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_actualizacion_operativa de la tabla unidades.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL COMMENT 'Clave primaria: Identificador único del sistema',
  `id_empleado` int(11) NOT NULL COMMENT 'Campo id_empleado de la tabla usuarios.',
  `usuario` varchar(50) NOT NULL COMMENT 'Campo usuario de la tabla usuarios.',
  `password` varchar(64) NOT NULL COMMENT 'Campo password de la tabla usuarios.',
  `rol` enum('ADMIN','OPERADOR','CONSULTOR') DEFAULT 'OPERADOR' COMMENT 'Nivel de acceso: ADMIN(Total), OPERADOR(Escritura), CONSULTOR(Lectura)',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla usuarios.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `usuarios_seguridad_acceso` (
  `id_usuario` int(11) NOT NULL COMMENT 'Campo id_usuario de la tabla usuarios_seguridad_acceso.',
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0 COMMENT 'Campo intentos_fallidos de la tabla usuarios_seguridad_acceso.',
  `bloqueado` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Campo bloqueado de la tabla usuarios_seguridad_acceso.',
  `fecha_bloqueo` datetime DEFAULT NULL COMMENT 'Campo fecha_bloqueo de la tabla usuarios_seguridad_acceso.',
  `password_temporal` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Campo password_temporal de la tabla usuarios_seguridad_acceso.',
  `fecha_password_temporal` datetime DEFAULT NULL COMMENT 'Campo fecha_password_temporal de la tabla usuarios_seguridad_acceso.',
  `fecha_actualizacion` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Campo fecha_actualizacion de la tabla usuarios_seguridad_acceso.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `usuario_permisos` (
  `id_usuario_permiso` int(11) NOT NULL COMMENT 'Campo id_usuario_permiso de la tabla usuario_permisos.',
  `id_usuario` int(11) NOT NULL COMMENT 'Campo id_usuario de la tabla usuario_permisos.',
  `id_permiso` int(11) NOT NULL COMMENT 'Campo id_permiso de la tabla usuario_permisos.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla usuario_permisos.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `asignaciones_unidades_choferes` (`id_asignacion_unidad_chofer`, `id_unidad`, `id_chofer_ambulancia`, `fecha_inicio`, `fecha_fin`, `observaciones`, `estado`, `fecha_registro`, `fecha_actualizacion`) VALUES
(1, 1, 1, '2026-02-25 07:00:00', NULL, 'Guardia activa en hospital de referencia.', 1, '2026-02-25 07:00:00', '2026-03-22 20:22:00'),
(2, 2, 2, '2026-02-25 07:15:00', NULL, 'Guardia activa en eje Pocaterra.', 1, '2026-02-25 07:15:00', '2026-03-23 14:50:00'),
(3, 3, 3, '2026-02-26 07:00:00', NULL, 'Guardia diurna en base central.', 1, '2026-02-26 07:00:00', '2026-03-21 09:40:00'),
(4, 4, 4, '2026-02-26 07:10:00', NULL, 'Guardia mixta para cobertura comunitaria.', 1, '2026-02-26 07:10:00', '2026-03-20 16:30:00'),
(5, 5, 5, '2026-02-26 07:20:00', NULL, 'Cobertura preventiva en parroquia Independencia.', 1, '2026-02-26 07:20:00', '2026-03-18 11:20:00'),
(6, 6, 6, '2026-02-20 08:00:00', '2026-03-01 17:30:00', 'Unidad retirada temporalmente por mantenimiento preventivo.', 0, '2026-02-20 08:00:00', '2026-03-01 17:30:00'),
(7, 3, 6, '2026-02-18 07:30:00', '2026-02-24 18:00:00', 'Asignacion previa cerrada por relevo operativo.', 0, '2026-02-18 07:30:00', '2026-02-24 18:00:00');

INSERT INTO `ayuda_social` (`id_ayuda`, `ticket_interno`, `id_beneficiario`, `id_usuario`, `id_tipo_ayuda_social`, `id_solicitud_ayuda_social`, `id_estado_solicitud`, `tipo_ayuda`, `solicitud_ayuda`, `fecha_ayuda`, `descripcion`, `estado`) VALUES
(1, 'AYU-20260218-000001', 1, 1, 1, 2, 3, 'Medicas', 'Atencion al ciudadano', '2026-02-18', 'Apoyo con medicamentos antihipertensivos para adulto mayor en control regular.', 1),
(2, 'AYU-20260220-000002', 2, 2, 2, 1, 2, 'Tecnicas', '1X10', '2026-02-20', 'Solicitud de silla de ruedas para paciente con movilidad reducida.', 1),
(3, 'AYU-20260222-000003', 3, 3, 3, 3, 1, 'Sociales', 'Redes sociales', '2026-02-22', 'Apoyo alimentario temporal para nucleo familiar afectado por perdida de empleo.', 1),
(4, 'AYU-20260224-000004', 4, 1, 6, 2, 3, 'Traslado', 'Atencion al ciudadano', '2026-02-24', 'Coordinacion de traslado programado para consulta especializada en Valencia.', 1),
(5, 'AYU-20260226-000005', 5, 2, 7, 1, 2, 'Atencion prehospitalaria', '1X10', '2026-02-26', 'Seguimiento para paciente cronico con necesidad de evaluacion domiciliaria.', 1),
(6, 'AYU-20260228-000006', 6, 3, 14, 3, 3, 'Reubicacion de insectos', 'Redes sociales', '2026-02-28', 'Atencion por enjambre detectado en vivienda cercana a escuela basica.', 1),
(7, 'AYU-20260302-000007', 7, 1, 1, 2, 4, 'Medicas', 'Atencion al ciudadano', '2026-03-02', 'Solicitud de tensiometro digital sin disponibilidad inmediata en inventario.', 1),
(8, 'AYU-20260304-000008', 8, 2, 2, 1, 3, 'Tecnicas', '1X10', '2026-03-04', 'Entrega de colchon antiescaras para adulto mayor encamado.', 1),
(9, 'AYU-20260306-000009', 9, 3, 3, 3, 2, 'Sociales', 'Redes sociales', '2026-03-06', 'Evaluacion socioeconomica para apoyo con canastilla y articulos de primera necesidad.', 1),
(10, 'AYU-20260308-000010', 10, 1, 6, 2, 3, 'Traslado', 'Atencion al ciudadano', '2026-03-08', 'Solicitud de traslado para paciente oncologico a jornada de quimioterapia.', 1),
(11, 'AYU-20260310-000011', 11, 2, 1, 1, 1, 'Medicas', '1X10', '2026-03-10', 'Requerimiento de nebulizador y medicinas para control respiratorio.', 1),
(12, 'AYU-20260312-000012', 12, 3, 2, 3, 3, 'Tecnicas', 'Redes sociales', '2026-03-12', 'Suministro de muletas para joven lesionado en accidente domestico.', 1),
(13, 'AYU-20260314-000013', 13, 1, 3, 2, 3, 'Sociales', 'Atencion al ciudadano', '2026-03-14', 'Canalizacion de apoyo para familia afectada por incendio parcial de vivienda.', 1),
(14, 'AYU-20260316-000014', 14, 2, 7, 1, 4, 'Atencion prehospitalaria', '1X10', '2026-03-16', 'Caso referido a red regional por requerir cobertura externa al municipio.', 1),
(15, 'AYU-20260318-000015', 15, 3, 14, 3, 2, 'Reubicacion de insectos', 'Redes sociales', '2026-03-18', 'Reporte de colmena en techo de casa de cuidado infantil.', 1),
(16, 'AYU-20260320-000016', 16, 1, 1, 2, 3, 'Medicas', 'Atencion al ciudadano', '2026-03-20', 'Entrega de kit de curas para paciente con ulceras por presion.', 1),
(17, 'AYU-20260322-000017', 17, 2, 2, 1, 1, 'Tecnicas', '1X10', '2026-03-22', 'Solicitud de baston de cuatro puntas para persona adulta mayor.', 1),
(18, 'AYU-20260324-000018', 18, 3, 3, 3, 3, 'Sociales', 'Redes sociales', '2026-03-24', 'Apoyo con alimentos y agua potable a familia afectada por colapso de tuberia.', 1);

INSERT INTO `beneficiarios` (`id_beneficiario`, `nacionalidad`, `cedula`, `nombre_beneficiario`, `telefono`, `id_comunidad`, `comunidad`, `fecha_registro`, `estado`) VALUES
(1, 'E', 15234000, 'Maria Fernanda Rojas', '0412-5100000', 1, 'Casco Comercial de Tocuyito', '2026-02-15 12:00:00', 1),
(2, 'V', 15234431, 'Jose Gregorio Navas', '0414-5100137', 2, 'Urbanizacion Valles de San Francisco', '2026-02-16 12:00:00', 1),
(3, 'V', 15234862, 'Carmen Elena Perez', '0424-5100274', 3, 'Conjunto Residencial Los Trescientos', '2026-02-17 12:00:00', 1),
(4, 'V', 15235293, 'Luis Alberto Romero', '0426-5100411', 4, 'Urbanizacion Jose Rafael Pocaterra', '2026-02-18 12:00:00', 1),
(5, 'V', 15235724, 'Ana Karina Salcedo', '0412-5100548', 5, 'Centro Penitenciario Tocuyito', '2026-02-19 12:00:00', 1),
(6, 'V', 15236155, 'Pedro Antonio Marquez', '0414-5100685', 6, 'Santa Eduviges', '2026-02-20 12:00:00', 1),
(7, 'V', 15236586, 'Yelitza Carolina Gil', '0424-5100822', 7, 'Bella Vista', '2026-02-21 12:00:00', 1),
(8, 'V', 15237017, 'Ramon Eduardo Suarez', '0426-5100959', 8, 'Los Mangos', '2026-02-22 12:00:00', 1),
(9, 'V', 15237448, 'Andreina del Valle Medina', '0412-5101096', 9, 'La Herrerena', '2026-02-23 12:00:00', 1),
(10, 'E', 15237879, 'Carlos Andres Sequera', '0414-5101233', 10, 'Urbanizacion La Esperanza', '2026-02-24 12:00:00', 1),
(11, 'V', 15238310, 'Beatriz Elena Farias', '0424-5101370', 11, 'Triangulo El Oasis', '2026-02-25 12:00:00', 1),
(12, 'V', 15238741, 'Juan Pablo Ortega', '0426-5101507', 12, 'Hacienda Juana Paula', '2026-02-26 12:00:00', 1),
(13, 'V', 15239172, 'Norelys Alexandra Pino', '0412-5101644', 13, 'Encrucijada de Carabobo', '2026-02-27 12:00:00', 1),
(14, 'V', 15239603, 'Daniel Enrique Salazar', '0414-5101781', 14, 'Urbanizacion Santa Paula', '2026-02-28 12:00:00', 1),
(15, 'V', 15240034, 'Gledys Carolina Rivas', '0424-5101918', 15, 'Hacienda La Trinidad', '2026-03-01 12:00:00', 1),
(16, 'V', 15240465, 'Victor Manuel Carvajal', '0426-5102055', 16, 'Hacienda El Rosario', '2026-03-02 12:00:00', 1),
(17, 'V', 15240896, 'Yusmary del Carmen Flores', '0412-5102192', 17, 'El Rosario', '2026-03-03 12:00:00', 1),
(18, 'V', 15241327, 'Julio Cesar Mendez', '0414-5102329', 18, 'El Rosal', '2026-03-04 12:00:00', 1),
(19, 'E', 15241758, 'Adriana Paola Infante', '0424-5102466', 19, 'Los Rosales', '2026-03-05 12:00:00', 1),
(20, 'V', 15242189, 'Wilmer Antonio Silva', '0426-5102603', 20, 'Colinas del Rosario', '2026-03-06 12:00:00', 1),
(21, 'V', 15242620, 'Lisbeth Coromoto Barrios', '0412-5102740', 21, 'Barrio La Trinidad', '2026-03-07 12:00:00', 1),
(22, 'V', 15243051, 'Hector Jose Villarroel', '0414-5102877', 22, 'Zanjon Dulce', '2026-03-08 12:00:00', 1),
(23, 'V', 15243482, 'Damaris Elena Cabrera', '0424-5103014', 23, 'Escuela de Cadafe', '2026-03-09 12:00:00', 1),
(24, 'V', 15243913, 'Franklin Javier Lozada', '0426-5103151', 24, '12 de Octubre', '2026-03-10 12:00:00', 1),
(25, 'V', 15244344, 'Marisela Josefina Quero', '0412-5103288', 1, 'Casco Comercial de Tocuyito', '2026-03-11 12:00:00', 1),
(26, 'V', 15244775, 'Nelson David Zambrano', '0414-5103425', 2, 'Urbanizacion Valles de San Francisco', '2026-03-12 12:00:00', 1),
(27, 'V', 15245206, 'Rosangelica Soto', '0424-5103562', 3, 'Conjunto Residencial Los Trescientos', '2026-03-13 12:00:00', 1),
(28, 'E', 15245637, 'Reinaldo Antonio Acosta', '0426-5103699', 4, 'Urbanizacion Jose Rafael Pocaterra', '2026-03-14 12:00:00', 1),
(29, 'V', 15246068, 'Marianela Torres', '0412-5103836', 5, 'Centro Penitenciario Tocuyito', '2026-03-15 12:00:00', 1),
(30, 'V', 15246499, 'Edgar Rafael Villalobos', '0414-5103973', 6, 'Santa Eduviges', '2026-03-16 12:00:00', 1),
(31, 'V', 15246930, 'Yajaira Perez', '0424-5104110', 7, 'Bella Vista', '2026-03-17 12:00:00', 1),
(32, 'V', 15247361, 'Alvaro Jose Pacheco', '0426-5104247', 8, 'Los Mangos', '2026-03-18 12:00:00', 1),
(33, 'V', 15247792, 'Mireya del Carmen Ochoa', '0412-5104384', 9, 'La Herrerena', '2026-03-19 12:00:00', 1),
(34, 'V', 15248223, 'Henry Alexander Briceno', '0414-5104521', 10, 'Urbanizacion La Esperanza', '2026-03-20 12:00:00', 1),
(35, 'V', 15248654, 'Marlenis Tovar', '0424-5104658', 11, 'Triangulo El Oasis', '2026-03-21 12:00:00', 1),
(36, 'V', 15249085, 'Jesus Alberto Moreno', '0426-5104795', 12, 'Hacienda Juana Paula', '2026-03-22 12:00:00', 1);

INSERT INTO `bitacora` (`id_bitacora`, `id_usuario`, `tabla_afectada`, `accion`, `id_registro`, `resumen`, `detalle`, `datos_antes`, `datos_despues`, `usuario_bd`, `ipaddr`, `moment`, `fecha_evento`, `estado`) VALUES
(1, NULL, 'empleados', 'INSERT', '4', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 4, \"cedula\": 30124567, \"nombre\": \"Jose Gregorio\", \"apellido\": \"Carrasco\", \"id_dependencia\": 4, \"telefono\": \"0412-5503412\", \"correo\": \"jose.carrasco@situacional.demo\", \"direccion\": \"Tocuyito, sector centro\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(2, NULL, 'empleados', 'INSERT', '5', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 5, \"cedula\": 28455102, \"nombre\": \"Maria Alejandra\", \"apellido\": \"Perez\", \"id_dependencia\": 2, \"telefono\": \"0414-5503413\", \"correo\": \"maria.perez@situacional.demo\", \"direccion\": \"Tocuyito, casco central\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(3, NULL, 'empleados', 'INSERT', '6', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 6, \"cedula\": 26789012, \"nombre\": \"Luis Alberto\", \"apellido\": \"Romero\", \"id_dependencia\": 7, \"telefono\": \"0424-5503414\", \"correo\": \"luis.romero@situacional.demo\", \"direccion\": \"Parroquia Independencia\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(4, NULL, 'empleados', 'INSERT', '7', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 7, \"cedula\": 19654321, \"nombre\": \"Carmen Elena\", \"apellido\": \"Vargas\", \"id_dependencia\": 4, \"telefono\": \"0416-5503415\", \"correo\": \"carmen.vargas@situacional.demo\", \"direccion\": \"Barrio El Oasis\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(5, NULL, 'empleados', 'INSERT', '8', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 8, \"cedula\": 21567890, \"nombre\": \"Pedro Antonio\", \"apellido\": \"Rivas\", \"id_dependencia\": 2, \"telefono\": \"0412-5503416\", \"correo\": \"pedro.rivas@situacional.demo\", \"direccion\": \"Urbanizacion La Esperanza\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(6, NULL, 'empleados', 'INSERT', '9', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 9, \"cedula\": 18345678, \"nombre\": \"Ana Beatriz\", \"apellido\": \"Salazar\", \"id_dependencia\": 4, \"telefono\": \"0414-5503417\", \"correo\": \"ana.salazar@situacional.demo\", \"direccion\": \"Santa Eduviges\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(7, NULL, 'empleados', 'INSERT', '10', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 10, \"cedula\": 25432109, \"nombre\": \"Ramon Eduardo\", \"apellido\": \"Suarez\", \"id_dependencia\": 3, \"telefono\": \"0424-5503418\", \"correo\": \"ramon.suarez@situacional.demo\", \"direccion\": \"Comunidad Bicentenario\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(8, NULL, 'usuarios', 'INSERT', '2', 'INSERT en usuarios', 'Se inserto un registro en usuarios', NULL, '{\"id_usuario\": 2, \"id_empleado\": 4, \"usuario\": \"operador.sala\", \"password\": \"163c228e938c409a30b29992fe3cf9856c4b8480af5b0900c9d384d541566888\", \"rol\": \"OPERADOR\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(9, NULL, 'usuarios_seguridad_acceso', 'UPDATE', '2', 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 21:22:18\"}', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-20 08:00:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(10, NULL, 'usuario_permisos', 'INSERT', '10', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 10, \"id_usuario\": 2, \"id_permiso\": 1, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(11, NULL, 'usuario_permisos', 'INSERT', '11', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 11, \"id_usuario\": 2, \"id_permiso\": 2, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(12, NULL, 'usuario_permisos', 'INSERT', '12', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 12, \"id_usuario\": 2, \"id_permiso\": 3, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(13, NULL, 'usuario_permisos', 'INSERT', '13', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 13, \"id_usuario\": 2, \"id_permiso\": 4, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(14, NULL, 'usuario_permisos', 'INSERT', '14', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 14, \"id_usuario\": 2, \"id_permiso\": 5, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(15, NULL, 'usuario_permisos', 'INSERT', '15', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 15, \"id_usuario\": 2, \"id_permiso\": 7, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(16, NULL, 'usuario_permisos', 'INSERT', '16', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 16, \"id_usuario\": 2, \"id_permiso\": 8, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(17, NULL, 'usuarios', 'INSERT', '3', 'INSERT en usuarios', 'Se inserto un registro en usuarios', NULL, '{\"id_usuario\": 3, \"id_empleado\": 5, \"usuario\": \"atencion.ciudadana\", \"password\": \"163c228e938c409a30b29992fe3cf9856c4b8480af5b0900c9d384d541566888\", \"rol\": \"OPERADOR\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(18, NULL, 'usuarios_seguridad_acceso', 'INSERT', '3', 'INSERT en usuarios_seguridad_acceso', 'Se inserto un registro en usuarios_seguridad_acceso', NULL, '{\"id_usuario\": 3, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-20 08:05:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(19, NULL, 'usuario_permisos', 'INSERT', '17', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 17, \"id_usuario\": 3, \"id_permiso\": 1, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(20, NULL, 'usuario_permisos', 'INSERT', '18', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 18, \"id_usuario\": 3, \"id_permiso\": 3, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(21, NULL, 'usuario_permisos', 'INSERT', '19', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 19, \"id_usuario\": 3, \"id_permiso\": 5, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(22, NULL, 'usuarios', 'INSERT', '4', 'INSERT en usuarios', 'Se inserto un registro en usuarios', NULL, '{\"id_usuario\": 4, \"id_empleado\": 6, \"usuario\": \"consulta.tribunal\", \"password\": \"163c228e938c409a30b29992fe3cf9856c4b8480af5b0900c9d384d541566888\", \"rol\": \"CONSULTOR\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(23, NULL, 'usuarios_seguridad_acceso', 'INSERT', '4', 'INSERT en usuarios_seguridad_acceso', 'Se inserto un registro en usuarios_seguridad_acceso', NULL, '{\"id_usuario\": 4, \"intentos_fallidos\": 1, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-21 10:00:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(24, NULL, 'usuario_permisos', 'INSERT', '20', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 20, \"id_usuario\": 4, \"id_permiso\": 2, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(25, NULL, 'usuario_permisos', 'INSERT', '21', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 21, \"id_usuario\": 4, \"id_permiso\": 7, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(26, NULL, 'beneficiarios', 'INSERT', '1', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 1, \"nacionalidad\": \"E\", \"cedula\": 15234000, \"nombre_beneficiario\": \"Maria Fernanda Rojas\", \"telefono\": \"0412-5100000\", \"id_comunidad\": 1, \"comunidad\": \"Casco Comercial de Tocuyito\", \"fecha_registro\": \"2026-02-15 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(27, NULL, 'beneficiarios', 'INSERT', '2', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 2, \"nacionalidad\": \"V\", \"cedula\": 15234431, \"nombre_beneficiario\": \"Jose Gregorio Navas\", \"telefono\": \"0414-5100137\", \"id_comunidad\": 2, \"comunidad\": \"Urbanizacion Valles de San Francisco\", \"fecha_registro\": \"2026-02-16 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(28, NULL, 'beneficiarios', 'INSERT', '3', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 3, \"nacionalidad\": \"V\", \"cedula\": 15234862, \"nombre_beneficiario\": \"Carmen Elena Perez\", \"telefono\": \"0424-5100274\", \"id_comunidad\": 3, \"comunidad\": \"Conjunto Residencial Los Trescientos\", \"fecha_registro\": \"2026-02-17 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(29, NULL, 'beneficiarios', 'INSERT', '4', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 4, \"nacionalidad\": \"V\", \"cedula\": 15235293, \"nombre_beneficiario\": \"Luis Alberto Romero\", \"telefono\": \"0426-5100411\", \"id_comunidad\": 4, \"comunidad\": \"Urbanizacion Jose Rafael Pocaterra\", \"fecha_registro\": \"2026-02-18 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(30, NULL, 'beneficiarios', 'INSERT', '5', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 5, \"nacionalidad\": \"V\", \"cedula\": 15235724, \"nombre_beneficiario\": \"Ana Karina Salcedo\", \"telefono\": \"0412-5100548\", \"id_comunidad\": 5, \"comunidad\": \"Centro Penitenciario Tocuyito\", \"fecha_registro\": \"2026-02-19 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(31, NULL, 'beneficiarios', 'INSERT', '6', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 6, \"nacionalidad\": \"V\", \"cedula\": 15236155, \"nombre_beneficiario\": \"Pedro Antonio Marquez\", \"telefono\": \"0414-5100685\", \"id_comunidad\": 6, \"comunidad\": \"Santa Eduviges\", \"fecha_registro\": \"2026-02-20 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(32, NULL, 'beneficiarios', 'INSERT', '7', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 7, \"nacionalidad\": \"V\", \"cedula\": 15236586, \"nombre_beneficiario\": \"Yelitza Carolina Gil\", \"telefono\": \"0424-5100822\", \"id_comunidad\": 7, \"comunidad\": \"Bella Vista\", \"fecha_registro\": \"2026-02-21 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(33, NULL, 'beneficiarios', 'INSERT', '8', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 8, \"nacionalidad\": \"V\", \"cedula\": 15237017, \"nombre_beneficiario\": \"Ramon Eduardo Suarez\", \"telefono\": \"0426-5100959\", \"id_comunidad\": 8, \"comunidad\": \"Los Mangos\", \"fecha_registro\": \"2026-02-22 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(34, NULL, 'beneficiarios', 'INSERT', '9', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 9, \"nacionalidad\": \"V\", \"cedula\": 15237448, \"nombre_beneficiario\": \"Andreina del Valle Medina\", \"telefono\": \"0412-5101096\", \"id_comunidad\": 9, \"comunidad\": \"La Herrerena\", \"fecha_registro\": \"2026-02-23 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(35, NULL, 'beneficiarios', 'INSERT', '10', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 10, \"nacionalidad\": \"E\", \"cedula\": 15237879, \"nombre_beneficiario\": \"Carlos Andres Sequera\", \"telefono\": \"0414-5101233\", \"id_comunidad\": 10, \"comunidad\": \"Urbanizacion La Esperanza\", \"fecha_registro\": \"2026-02-24 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(36, NULL, 'beneficiarios', 'INSERT', '11', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 11, \"nacionalidad\": \"V\", \"cedula\": 15238310, \"nombre_beneficiario\": \"Beatriz Elena Farias\", \"telefono\": \"0424-5101370\", \"id_comunidad\": 11, \"comunidad\": \"Triangulo El Oasis\", \"fecha_registro\": \"2026-02-25 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(37, NULL, 'beneficiarios', 'INSERT', '12', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 12, \"nacionalidad\": \"V\", \"cedula\": 15238741, \"nombre_beneficiario\": \"Juan Pablo Ortega\", \"telefono\": \"0426-5101507\", \"id_comunidad\": 12, \"comunidad\": \"Hacienda Juana Paula\", \"fecha_registro\": \"2026-02-26 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(38, NULL, 'beneficiarios', 'INSERT', '13', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 13, \"nacionalidad\": \"V\", \"cedula\": 15239172, \"nombre_beneficiario\": \"Norelys Alexandra Pino\", \"telefono\": \"0412-5101644\", \"id_comunidad\": 13, \"comunidad\": \"Encrucijada de Carabobo\", \"fecha_registro\": \"2026-02-27 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(39, NULL, 'beneficiarios', 'INSERT', '14', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 14, \"nacionalidad\": \"V\", \"cedula\": 15239603, \"nombre_beneficiario\": \"Daniel Enrique Salazar\", \"telefono\": \"0414-5101781\", \"id_comunidad\": 14, \"comunidad\": \"Urbanizacion Santa Paula\", \"fecha_registro\": \"2026-02-28 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(40, NULL, 'beneficiarios', 'INSERT', '15', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 15, \"nacionalidad\": \"V\", \"cedula\": 15240034, \"nombre_beneficiario\": \"Gledys Carolina Rivas\", \"telefono\": \"0424-5101918\", \"id_comunidad\": 15, \"comunidad\": \"Hacienda La Trinidad\", \"fecha_registro\": \"2026-03-01 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(41, NULL, 'beneficiarios', 'INSERT', '16', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 16, \"nacionalidad\": \"V\", \"cedula\": 15240465, \"nombre_beneficiario\": \"Victor Manuel Carvajal\", \"telefono\": \"0426-5102055\", \"id_comunidad\": 16, \"comunidad\": \"Hacienda El Rosario\", \"fecha_registro\": \"2026-03-02 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(42, NULL, 'beneficiarios', 'INSERT', '17', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 17, \"nacionalidad\": \"V\", \"cedula\": 15240896, \"nombre_beneficiario\": \"Yusmary del Carmen Flores\", \"telefono\": \"0412-5102192\", \"id_comunidad\": 17, \"comunidad\": \"El Rosario\", \"fecha_registro\": \"2026-03-03 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(43, NULL, 'beneficiarios', 'INSERT', '18', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 18, \"nacionalidad\": \"V\", \"cedula\": 15241327, \"nombre_beneficiario\": \"Julio Cesar Mendez\", \"telefono\": \"0414-5102329\", \"id_comunidad\": 18, \"comunidad\": \"El Rosal\", \"fecha_registro\": \"2026-03-04 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(44, NULL, 'beneficiarios', 'INSERT', '19', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 19, \"nacionalidad\": \"E\", \"cedula\": 15241758, \"nombre_beneficiario\": \"Adriana Paola Infante\", \"telefono\": \"0424-5102466\", \"id_comunidad\": 19, \"comunidad\": \"Los Rosales\", \"fecha_registro\": \"2026-03-05 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(45, NULL, 'beneficiarios', 'INSERT', '20', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 20, \"nacionalidad\": \"V\", \"cedula\": 15242189, \"nombre_beneficiario\": \"Wilmer Antonio Silva\", \"telefono\": \"0426-5102603\", \"id_comunidad\": 20, \"comunidad\": \"Colinas del Rosario\", \"fecha_registro\": \"2026-03-06 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(46, NULL, 'beneficiarios', 'INSERT', '21', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 21, \"nacionalidad\": \"V\", \"cedula\": 15242620, \"nombre_beneficiario\": \"Lisbeth Coromoto Barrios\", \"telefono\": \"0412-5102740\", \"id_comunidad\": 21, \"comunidad\": \"Barrio La Trinidad\", \"fecha_registro\": \"2026-03-07 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(47, NULL, 'beneficiarios', 'INSERT', '22', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 22, \"nacionalidad\": \"V\", \"cedula\": 15243051, \"nombre_beneficiario\": \"Hector Jose Villarroel\", \"telefono\": \"0414-5102877\", \"id_comunidad\": 22, \"comunidad\": \"Zanjon Dulce\", \"fecha_registro\": \"2026-03-08 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(48, NULL, 'beneficiarios', 'INSERT', '23', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 23, \"nacionalidad\": \"V\", \"cedula\": 15243482, \"nombre_beneficiario\": \"Damaris Elena Cabrera\", \"telefono\": \"0424-5103014\", \"id_comunidad\": 23, \"comunidad\": \"Escuela de Cadafe\", \"fecha_registro\": \"2026-03-09 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(49, NULL, 'beneficiarios', 'INSERT', '24', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 24, \"nacionalidad\": \"V\", \"cedula\": 15243913, \"nombre_beneficiario\": \"Franklin Javier Lozada\", \"telefono\": \"0426-5103151\", \"id_comunidad\": 24, \"comunidad\": \"12 de Octubre\", \"fecha_registro\": \"2026-03-10 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(50, NULL, 'beneficiarios', 'INSERT', '25', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 25, \"nacionalidad\": \"V\", \"cedula\": 15244344, \"nombre_beneficiario\": \"Marisela Josefina Quero\", \"telefono\": \"0412-5103288\", \"id_comunidad\": 1, \"comunidad\": \"Casco Comercial de Tocuyito\", \"fecha_registro\": \"2026-03-11 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(51, NULL, 'beneficiarios', 'INSERT', '26', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 26, \"nacionalidad\": \"V\", \"cedula\": 15244775, \"nombre_beneficiario\": \"Nelson David Zambrano\", \"telefono\": \"0414-5103425\", \"id_comunidad\": 2, \"comunidad\": \"Urbanizacion Valles de San Francisco\", \"fecha_registro\": \"2026-03-12 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(52, NULL, 'beneficiarios', 'INSERT', '27', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 27, \"nacionalidad\": \"V\", \"cedula\": 15245206, \"nombre_beneficiario\": \"Rosangelica Soto\", \"telefono\": \"0424-5103562\", \"id_comunidad\": 3, \"comunidad\": \"Conjunto Residencial Los Trescientos\", \"fecha_registro\": \"2026-03-13 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(53, NULL, 'beneficiarios', 'INSERT', '28', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 28, \"nacionalidad\": \"E\", \"cedula\": 15245637, \"nombre_beneficiario\": \"Reinaldo Antonio Acosta\", \"telefono\": \"0426-5103699\", \"id_comunidad\": 4, \"comunidad\": \"Urbanizacion Jose Rafael Pocaterra\", \"fecha_registro\": \"2026-03-14 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(54, NULL, 'beneficiarios', 'INSERT', '29', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 29, \"nacionalidad\": \"V\", \"cedula\": 15246068, \"nombre_beneficiario\": \"Marianela Torres\", \"telefono\": \"0412-5103836\", \"id_comunidad\": 5, \"comunidad\": \"Centro Penitenciario Tocuyito\", \"fecha_registro\": \"2026-03-15 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(55, NULL, 'beneficiarios', 'INSERT', '30', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 30, \"nacionalidad\": \"V\", \"cedula\": 15246499, \"nombre_beneficiario\": \"Edgar Rafael Villalobos\", \"telefono\": \"0414-5103973\", \"id_comunidad\": 6, \"comunidad\": \"Santa Eduviges\", \"fecha_registro\": \"2026-03-16 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(56, NULL, 'beneficiarios', 'INSERT', '31', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 31, \"nacionalidad\": \"V\", \"cedula\": 15246930, \"nombre_beneficiario\": \"Yajaira Perez\", \"telefono\": \"0424-5104110\", \"id_comunidad\": 7, \"comunidad\": \"Bella Vista\", \"fecha_registro\": \"2026-03-17 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(57, NULL, 'beneficiarios', 'INSERT', '32', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 32, \"nacionalidad\": \"V\", \"cedula\": 15247361, \"nombre_beneficiario\": \"Alvaro Jose Pacheco\", \"telefono\": \"0426-5104247\", \"id_comunidad\": 8, \"comunidad\": \"Los Mangos\", \"fecha_registro\": \"2026-03-18 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(58, NULL, 'beneficiarios', 'INSERT', '33', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 33, \"nacionalidad\": \"V\", \"cedula\": 15247792, \"nombre_beneficiario\": \"Mireya del Carmen Ochoa\", \"telefono\": \"0412-5104384\", \"id_comunidad\": 9, \"comunidad\": \"La Herrerena\", \"fecha_registro\": \"2026-03-19 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(59, NULL, 'beneficiarios', 'INSERT', '34', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 34, \"nacionalidad\": \"V\", \"cedula\": 15248223, \"nombre_beneficiario\": \"Henry Alexander Briceno\", \"telefono\": \"0414-5104521\", \"id_comunidad\": 10, \"comunidad\": \"Urbanizacion La Esperanza\", \"fecha_registro\": \"2026-03-20 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(60, NULL, 'beneficiarios', 'INSERT', '35', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 35, \"nacionalidad\": \"V\", \"cedula\": 15248654, \"nombre_beneficiario\": \"Marlenis Tovar\", \"telefono\": \"0424-5104658\", \"id_comunidad\": 11, \"comunidad\": \"Triangulo El Oasis\", \"fecha_registro\": \"2026-03-21 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(61, NULL, 'beneficiarios', 'INSERT', '36', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 36, \"nacionalidad\": \"V\", \"cedula\": 15249085, \"nombre_beneficiario\": \"Jesus Alberto Moreno\", \"telefono\": \"0426-5104795\", \"id_comunidad\": 12, \"comunidad\": \"Hacienda Juana Paula\", \"fecha_registro\": \"2026-03-22 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(62, NULL, 'ayuda_social', 'INSERT', '1', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 1, \"ticket_interno\": \"AYU-20260218-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 1, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Medicas\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-02-18\", \"descripcion\": \"Apoyo con medicamentos antihipertensivos para adulto mayor en control regular.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(63, NULL, 'seguimientos_solicitudes', 'INSERT', '1', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 1, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 1, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-18 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(64, NULL, 'seguimientos_solicitudes', 'INSERT', '2', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 2, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 1, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-20 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(65, NULL, 'ayuda_social', 'INSERT', '2', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 2, \"ticket_interno\": \"AYU-20260220-000002\", \"id_beneficiario\": 2, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 2, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 2, \"tipo_ayuda\": \"Tecnicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-02-20\", \"descripcion\": \"Solicitud de silla de ruedas para paciente con movilidad reducida.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(66, NULL, 'seguimientos_solicitudes', 'INSERT', '3', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 3, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 2, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-20 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(67, NULL, 'seguimientos_solicitudes', 'INSERT', '4', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 4, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 2, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-20 11:30:00\", \"observacion\": \"Caso canalizado a la dependencia social para seguimiento.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(68, NULL, 'ayuda_social', 'INSERT', '3', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 3, \"ticket_interno\": \"AYU-20260222-000003\", \"id_beneficiario\": 3, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 3, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Sociales\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-02-22\", \"descripcion\": \"Apoyo alimentario temporal para nucleo familiar afectado por perdida de empleo.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(69, NULL, 'seguimientos_solicitudes', 'INSERT', '5', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 5, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 3, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-22 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(70, NULL, 'ayuda_social', 'INSERT', '4', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 4, \"ticket_interno\": \"AYU-20260224-000004\", \"id_beneficiario\": 4, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 6, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Traslado\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-02-24\", \"descripcion\": \"Coordinacion de traslado programado para consulta especializada en Valencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(71, NULL, 'seguimientos_solicitudes', 'INSERT', '6', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 6, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 4, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-24 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(72, NULL, 'seguimientos_solicitudes', 'INSERT', '7', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 7, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 4, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-26 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(73, NULL, 'ayuda_social', 'INSERT', '5', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 5, \"ticket_interno\": \"AYU-20260226-000005\", \"id_beneficiario\": 5, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 7, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 2, \"tipo_ayuda\": \"Atencion prehospitalaria\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-02-26\", \"descripcion\": \"Seguimiento para paciente cronico con necesidad de evaluacion domiciliaria.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(74, NULL, 'seguimientos_solicitudes', 'INSERT', '8', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 8, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 5, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-26 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(75, NULL, 'seguimientos_solicitudes', 'INSERT', '9', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 9, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 5, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-26 11:30:00\", \"observacion\": \"Caso canalizado a la dependencia social para seguimiento.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(76, NULL, 'ayuda_social', 'INSERT', '6', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 6, \"ticket_interno\": \"AYU-20260228-000006\", \"id_beneficiario\": 6, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 14, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Reubicacion de insectos\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-02-28\", \"descripcion\": \"Atencion por enjambre detectado en vivienda cercana a escuela basica.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(77, NULL, 'seguimientos_solicitudes', 'INSERT', '10', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 10, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 6, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-28 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(78, NULL, 'seguimientos_solicitudes', 'INSERT', '11', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 11, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 6, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-02 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(79, NULL, 'ayuda_social', 'INSERT', '7', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 7, \"ticket_interno\": \"AYU-20260302-000007\", \"id_beneficiario\": 7, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 1, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 4, \"tipo_ayuda\": \"Medicas\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-02\", \"descripcion\": \"Solicitud de tensiometro digital sin disponibilidad inmediata en inventario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(80, NULL, 'seguimientos_solicitudes', 'INSERT', '12', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 12, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 7, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-02 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(81, NULL, 'seguimientos_solicitudes', 'INSERT', '13', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 13, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 7, \"id_estado_solicitud\": 4, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-05 16:00:00\", \"observacion\": \"Solicitud cerrada sin disponibilidad operativa inmediata.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(82, NULL, 'ayuda_social', 'INSERT', '8', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 8, \"ticket_interno\": \"AYU-20260304-000008\", \"id_beneficiario\": 8, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 2, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Tecnicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-04\", \"descripcion\": \"Entrega de colchon antiescaras para adulto mayor encamado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(83, NULL, 'seguimientos_solicitudes', 'INSERT', '14', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 14, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 8, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-04 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(84, NULL, 'seguimientos_solicitudes', 'INSERT', '15', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 15, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 8, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-06 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(85, NULL, 'ayuda_social', 'INSERT', '9', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 9, \"ticket_interno\": \"AYU-20260306-000009\", \"id_beneficiario\": 9, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 3, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 2, \"tipo_ayuda\": \"Sociales\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-03-06\", \"descripcion\": \"Evaluacion socioeconomica para apoyo con canastilla y articulos de primera necesidad.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(86, NULL, 'seguimientos_solicitudes', 'INSERT', '16', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 16, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 9, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-06 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(87, NULL, 'seguimientos_solicitudes', 'INSERT', '17', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 17, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 9, \"id_estado_solicitud\": 2, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-06 11:30:00\", \"observacion\": \"Caso canalizado a la dependencia social para seguimiento.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(88, NULL, 'ayuda_social', 'INSERT', '10', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 10, \"ticket_interno\": \"AYU-20260308-000010\", \"id_beneficiario\": 10, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 6, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Traslado\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-08\", \"descripcion\": \"Solicitud de traslado para paciente oncologico a jornada de quimioterapia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(89, NULL, 'seguimientos_solicitudes', 'INSERT', '18', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 18, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 10, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-08 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(90, NULL, 'seguimientos_solicitudes', 'INSERT', '19', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 19, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 10, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-10 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(91, NULL, 'ayuda_social', 'INSERT', '11', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 11, \"ticket_interno\": \"AYU-20260310-000011\", \"id_beneficiario\": 11, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 1, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Medicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-10\", \"descripcion\": \"Requerimiento de nebulizador y medicinas para control respiratorio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(92, NULL, 'seguimientos_solicitudes', 'INSERT', '20', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 20, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 11, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-10 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(93, NULL, 'ayuda_social', 'INSERT', '12', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 12, \"ticket_interno\": \"AYU-20260312-000012\", \"id_beneficiario\": 12, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 2, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Tecnicas\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-03-12\", \"descripcion\": \"Suministro de muletas para joven lesionado en accidente domestico.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(94, NULL, 'seguimientos_solicitudes', 'INSERT', '21', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 21, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 12, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-12 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(95, NULL, 'seguimientos_solicitudes', 'INSERT', '22', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 22, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 12, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-14 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(96, NULL, 'ayuda_social', 'INSERT', '13', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 13, \"ticket_interno\": \"AYU-20260314-000013\", \"id_beneficiario\": 13, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 3, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Sociales\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-14\", \"descripcion\": \"Canalizacion de apoyo para familia afectada por incendio parcial de vivienda.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(97, NULL, 'seguimientos_solicitudes', 'INSERT', '23', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 23, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 13, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-14 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(98, NULL, 'seguimientos_solicitudes', 'INSERT', '24', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 24, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 13, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-16 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(99, NULL, 'ayuda_social', 'INSERT', '14', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 14, \"ticket_interno\": \"AYU-20260316-000014\", \"id_beneficiario\": 14, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 7, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 4, \"tipo_ayuda\": \"Atencion prehospitalaria\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-16\", \"descripcion\": \"Caso referido a red regional por requerir cobertura externa al municipio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(100, NULL, 'seguimientos_solicitudes', 'INSERT', '25', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 25, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 14, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-16 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(101, NULL, 'seguimientos_solicitudes', 'INSERT', '26', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 26, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 14, \"id_estado_solicitud\": 4, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-19 16:00:00\", \"observacion\": \"Solicitud cerrada sin disponibilidad operativa inmediata.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(102, NULL, 'ayuda_social', 'INSERT', '15', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 15, \"ticket_interno\": \"AYU-20260318-000015\", \"id_beneficiario\": 15, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 14, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 2, \"tipo_ayuda\": \"Reubicacion de insectos\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-03-18\", \"descripcion\": \"Reporte de colmena en techo de casa de cuidado infantil.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(103, NULL, 'seguimientos_solicitudes', 'INSERT', '27', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 27, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 15, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-18 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(104, NULL, 'seguimientos_solicitudes', 'INSERT', '28', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 28, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 15, \"id_estado_solicitud\": 2, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-18 11:30:00\", \"observacion\": \"Caso canalizado a la dependencia social para seguimiento.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1);

INSERT INTO `bitacora` (`id_bitacora`, `id_usuario`, `tabla_afectada`, `accion`, `id_registro`, `resumen`, `detalle`, `datos_antes`, `datos_despues`, `usuario_bd`, `ipaddr`, `moment`, `fecha_evento`, `estado`) VALUES
(105, NULL, 'ayuda_social', 'INSERT', '16', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 16, \"ticket_interno\": \"AYU-20260320-000016\", \"id_beneficiario\": 16, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 1, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Medicas\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-20\", \"descripcion\": \"Entrega de kit de curas para paciente con ulceras por presion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(106, NULL, 'seguimientos_solicitudes', 'INSERT', '29', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 29, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 16, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-20 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(107, NULL, 'seguimientos_solicitudes', 'INSERT', '30', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 30, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 16, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-22 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(108, NULL, 'ayuda_social', 'INSERT', '17', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 17, \"ticket_interno\": \"AYU-20260322-000017\", \"id_beneficiario\": 17, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 2, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Tecnicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-22\", \"descripcion\": \"Solicitud de baston de cuatro puntas para persona adulta mayor.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(109, NULL, 'seguimientos_solicitudes', 'INSERT', '31', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 31, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 17, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-22 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(110, NULL, 'ayuda_social', 'INSERT', '18', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 18, \"ticket_interno\": \"AYU-20260324-000018\", \"id_beneficiario\": 18, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 3, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Sociales\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-03-24\", \"descripcion\": \"Apoyo con alimentos y agua potable a familia afectada por colapso de tuberia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(111, NULL, 'seguimientos_solicitudes', 'INSERT', '32', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 32, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 18, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-24 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(112, NULL, 'seguimientos_solicitudes', 'INSERT', '33', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 33, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 18, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-26 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(113, NULL, 'servicios_publicos', 'INSERT', '1', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 1, \"ticket_interno\": \"SPU-20260219-000001\", \"id_beneficiario\": 6, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 1, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Agua\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-02-19\", \"descripcion\": \"Fuga de agua blanca en tuberia principal cercana a la escuela del sector.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(114, NULL, 'seguimientos_solicitudes', 'INSERT', '34', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 34, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 1, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-19 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(115, NULL, 'seguimientos_solicitudes', 'INSERT', '35', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 35, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 1, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-20 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(116, NULL, 'servicios_publicos', 'INSERT', '2', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 2, \"ticket_interno\": \"SPU-20260221-000002\", \"id_beneficiario\": 7, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 2, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 2, \"tipo_servicio\": \"Aguas Negras\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-02-21\", \"descripcion\": \"Desborde de aguas negras en calle ciega con afectacion de varias viviendas.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(117, NULL, 'seguimientos_solicitudes', 'INSERT', '36', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 36, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 2, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-21 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(118, NULL, 'seguimientos_solicitudes', 'INSERT', '37', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 37, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 2, \"id_estado_solicitud\": 2, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-21 10:45:00\", \"observacion\": \"Solicitud remitida a cuadrilla operativa para programacion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(119, NULL, 'servicios_publicos', 'INSERT', '3', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 3, \"ticket_interno\": \"SPU-20260223-000003\", \"id_beneficiario\": 8, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 3, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Alumbrado Publico\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-02-23\", \"descripcion\": \"Luminarias apagadas en corredor peatonal de alta circulacion nocturna.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(120, NULL, 'seguimientos_solicitudes', 'INSERT', '38', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 38, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 3, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-23 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(121, NULL, 'seguimientos_solicitudes', 'INSERT', '39', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 39, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 3, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-24 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(122, NULL, 'servicios_publicos', 'INSERT', '4', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 4, \"ticket_interno\": \"SPU-20260225-000004\", \"id_beneficiario\": 9, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 4, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 1, \"tipo_servicio\": \"Ambiente\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-02-25\", \"descripcion\": \"Acumulacion de desechos vegetales en espacio comunal.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(123, NULL, 'seguimientos_solicitudes', 'INSERT', '40', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 40, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 4, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-25 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(124, NULL, 'servicios_publicos', 'INSERT', '5', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 5, \"ticket_interno\": \"SPU-20260227-000005\", \"id_beneficiario\": 10, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 5, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 2, \"tipo_servicio\": \"Asfaltado\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-02-27\", \"descripcion\": \"Bache de gran tamano en vialidad principal con riesgo para motorizados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(125, NULL, 'seguimientos_solicitudes', 'INSERT', '41', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 41, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 5, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-27 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(126, NULL, 'seguimientos_solicitudes', 'INSERT', '42', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 42, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 5, \"id_estado_solicitud\": 2, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-27 10:45:00\", \"observacion\": \"Solicitud remitida a cuadrilla operativa para programacion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(127, NULL, 'servicios_publicos', 'INSERT', '6', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 6, \"ticket_interno\": \"SPU-20260301-000006\", \"id_beneficiario\": 11, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 6, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Canos y Embaulamiento\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-01\", \"descripcion\": \"Limpieza y desobstruccion de cano lateral antes del periodo de lluvias.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(128, NULL, 'seguimientos_solicitudes', 'INSERT', '43', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 43, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 6, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-01 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(129, NULL, 'seguimientos_solicitudes', 'INSERT', '44', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 44, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 6, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-02 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(130, NULL, 'servicios_publicos', 'INSERT', '7', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 7, \"ticket_interno\": \"SPU-20260303-000007\", \"id_beneficiario\": 12, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 7, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 4, \"tipo_servicio\": \"Energia\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-03-03\", \"descripcion\": \"Variacion de voltaje reportada en manzana con transformador sobrecargado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(131, NULL, 'seguimientos_solicitudes', 'INSERT', '45', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 45, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 7, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-03 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(132, NULL, 'seguimientos_solicitudes', 'INSERT', '46', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 46, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 7, \"id_estado_solicitud\": 4, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-06 17:00:00\", \"observacion\": \"Solicitud cerrada por falta de disponibilidad presupuestaria.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(133, NULL, 'servicios_publicos', 'INSERT', '8', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 8, \"ticket_interno\": \"SPU-20260305-000008\", \"id_beneficiario\": 13, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 8, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Infraestructura\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-05\", \"descripcion\": \"Reparacion de filtracion en techo de modulo comunal.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(134, NULL, 'seguimientos_solicitudes', 'INSERT', '47', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 47, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 8, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-05 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(135, NULL, 'seguimientos_solicitudes', 'INSERT', '48', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 48, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 8, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-06 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(136, NULL, 'servicios_publicos', 'INSERT', '9', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 9, \"ticket_interno\": \"SPU-20260307-000009\", \"id_beneficiario\": 14, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 9, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 2, \"tipo_servicio\": \"Pica y Poda\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-07\", \"descripcion\": \"Ramas sobre tendido electrico con riesgo de caida por vientos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(137, NULL, 'seguimientos_solicitudes', 'INSERT', '49', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 49, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 9, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-07 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(138, NULL, 'seguimientos_solicitudes', 'INSERT', '50', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 50, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 9, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-07 10:45:00\", \"observacion\": \"Solicitud remitida a cuadrilla operativa para programacion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(139, NULL, 'servicios_publicos', 'INSERT', '10', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 10, \"ticket_interno\": \"SPU-20260309-000010\", \"id_beneficiario\": 15, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 10, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Vial\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-03-09\", \"descripcion\": \"Se requiere demarcacion y reparacion parcial de paso peatonal.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(140, NULL, 'seguimientos_solicitudes', 'INSERT', '51', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 51, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 10, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-09 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(141, NULL, 'seguimientos_solicitudes', 'INSERT', '52', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 52, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 10, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-10 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(142, NULL, 'servicios_publicos', 'INSERT', '11', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 11, \"ticket_interno\": \"SPU-20260311-000011\", \"id_beneficiario\": 16, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 1, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 1, \"tipo_servicio\": \"Agua\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-11\", \"descripcion\": \"Baja presion de agua en zona alta de la comunidad durante la tarde.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(143, NULL, 'seguimientos_solicitudes', 'INSERT', '53', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 53, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 11, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-11 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(144, NULL, 'servicios_publicos', 'INSERT', '12', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 12, \"ticket_interno\": \"SPU-20260313-000012\", \"id_beneficiario\": 17, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 3, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Alumbrado Publico\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-13\", \"descripcion\": \"Reposicion de reflector en cancha multiple para jornada nocturna.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(145, NULL, 'seguimientos_solicitudes', 'INSERT', '54', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 54, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 12, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-13 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(146, NULL, 'seguimientos_solicitudes', 'INSERT', '55', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 55, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 12, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-14 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(147, NULL, 'servicios_publicos', 'INSERT', '13', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 13, \"ticket_interno\": \"SPU-20260315-000013\", \"id_beneficiario\": 18, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 5, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Asfaltado\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-03-15\", \"descripcion\": \"Hundimiento de calzada cerca de parada de transporte publico.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(148, NULL, 'seguimientos_solicitudes', 'INSERT', '56', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 56, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 13, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-15 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(149, NULL, 'seguimientos_solicitudes', 'INSERT', '57', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 57, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 13, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-16 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(150, NULL, 'servicios_publicos', 'INSERT', '14', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 14, \"ticket_interno\": \"SPU-20260317-000014\", \"id_beneficiario\": 19, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 8, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 4, \"tipo_servicio\": \"Infraestructura\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-17\", \"descripcion\": \"Solicitud de rehabilitacion integral de plaza sin presupuesto asignado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(151, NULL, 'seguimientos_solicitudes', 'INSERT', '58', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 58, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 14, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-17 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(152, NULL, 'seguimientos_solicitudes', 'INSERT', '59', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 59, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 14, \"id_estado_solicitud\": 4, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-20 17:00:00\", \"observacion\": \"Solicitud cerrada por falta de disponibilidad presupuestaria.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(153, NULL, 'servicios_publicos', 'INSERT', '15', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 15, \"ticket_interno\": \"SPU-20260319-000015\", \"id_beneficiario\": 20, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 9, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Pica y Poda\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-19\", \"descripcion\": \"Poda preventiva de arboles frente a preescolar municipal.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(154, NULL, 'seguimientos_solicitudes', 'INSERT', '60', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 60, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 15, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-19 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(155, NULL, 'seguimientos_solicitudes', 'INSERT', '61', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 61, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 15, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-20 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(156, NULL, 'servicios_publicos', 'INSERT', '16', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 16, \"ticket_interno\": \"SPU-20260321-000016\", \"id_beneficiario\": 21, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 6, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 2, \"tipo_servicio\": \"Canos y Embaulamiento\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-03-21\", \"descripcion\": \"Sedimentacion en embaulamiento con necesidad de maquinaria liviana.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(157, NULL, 'seguimientos_solicitudes', 'INSERT', '62', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 62, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 16, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-21 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(158, NULL, 'seguimientos_solicitudes', 'INSERT', '63', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 63, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 16, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-21 10:45:00\", \"observacion\": \"Solicitud remitida a cuadrilla operativa para programacion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(159, NULL, 'servicios_publicos', 'INSERT', '17', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 17, \"ticket_interno\": \"SPU-20260323-000017\", \"id_beneficiario\": 22, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 7, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Energia\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-23\", \"descripcion\": \"Reposicion de fusible y chequeo de acometida en sector residencial.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(160, NULL, 'seguimientos_solicitudes', 'INSERT', '64', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 64, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 17, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-23 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(161, NULL, 'seguimientos_solicitudes', 'INSERT', '65', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 65, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 17, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-24 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(162, NULL, 'servicios_publicos', 'INSERT', '18', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 18, \"ticket_interno\": \"SPU-20260325-000018\", \"id_beneficiario\": 23, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 10, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 1, \"tipo_servicio\": \"Vial\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-25\", \"descripcion\": \"Solicitud de reductores de velocidad frente a centro educativo.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(163, NULL, 'seguimientos_solicitudes', 'INSERT', '66', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 66, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 18, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-25 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(164, NULL, 'unidades', 'INSERT', '1', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"Ambulancia Ford Transit\", \"placa\": \"AB7C21D\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"Hospital de Tocuyito\", \"referencia_actual\": \"Area de urgencias\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-22 20:22:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(165, NULL, 'unidades', 'INSERT', '2', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"Ambulancia Toyota Hiace\", \"placa\": \"AC4G91M\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"Urbanizacion Jose Rafael Pocaterra\", \"referencia_actual\": \"Frente al modulo policial\", \"prioridad_despacho\": 2, \"fecha_actualizacion_operativa\": \"2026-03-23 14:50:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(166, NULL, 'unidades', 'INSERT', '3', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 3, \"codigo_unidad\": \"AMB-003\", \"descripcion\": \"Ambulancia Iveco Daily\", \"placa\": \"AD2L44R\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"Base central\", \"referencia_actual\": \"Patio operacional\", \"prioridad_despacho\": 3, \"fecha_actualizacion_operativa\": \"2026-03-21 09:40:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(167, NULL, 'unidades', 'INSERT', '4', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 4, \"codigo_unidad\": \"AMB-004\", \"descripcion\": \"Ambulancia Mercedes Sprinter\", \"placa\": \"AE6J12K\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"CDI El Oasis\", \"referencia_actual\": \"Area de espera\", \"prioridad_despacho\": 4, \"fecha_actualizacion_operativa\": \"2026-03-20 16:30:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(168, NULL, 'unidades', 'INSERT', '5', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 5, \"codigo_unidad\": \"AMB-005\", \"descripcion\": \"Ambulancia Chevrolet Express\", \"placa\": \"AF8P33T\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"Parroquia Independencia\", \"referencia_actual\": \"Puesto sanitario movil\", \"prioridad_despacho\": 5, \"fecha_actualizacion_operativa\": \"2026-03-18 11:20:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(169, NULL, 'unidades', 'INSERT', '6', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 6, \"codigo_unidad\": \"AMB-006\", \"descripcion\": \"Unidad de respuesta rapida\", \"placa\": \"AG1N58Q\", \"estado\": 1, \"estado_operativo\": \"FUERA_SERVICIO\", \"ubicacion_actual\": \"Taller municipal\", \"referencia_actual\": \"Revision de frenos\", \"prioridad_despacho\": 6, \"fecha_actualizacion_operativa\": \"2026-03-17 08:10:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(170, NULL, 'choferes_ambulancia', 'INSERT', '1', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 1, \"id_empleado\": 1, \"numero_licencia\": \"LIC-14382513\", \"categoria_licencia\": \"5to grado\", \"vencimiento_licencia\": \"2030-08-14\", \"contacto_emergencia\": \"Andres Aguilar\", \"telefono_contacto_emergencia\": \"0412-7001122\", \"observaciones\": \"Chofer principal de guardia nocturna.\", \"estado\": 1, \"fecha_registro\": \"2026-02-14 07:10:00\", \"fecha_actualizacion\": \"2026-03-22 20:22:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(171, NULL, 'choferes_ambulancia', 'INSERT', '2', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 2, \"id_empleado\": 2, \"numero_licencia\": \"LIC-24329534\", \"categoria_licencia\": \"5to grado\", \"vencimiento_licencia\": \"2031-04-09\", \"contacto_emergencia\": \"Maria Franco\", \"telefono_contacto_emergencia\": \"0424-7012233\", \"observaciones\": \"Disponible para turnos rotativos y traslados largos.\", \"estado\": 1, \"fecha_registro\": \"2026-02-14 07:20:00\", \"fecha_actualizacion\": \"2026-03-23 14:50:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(172, NULL, 'choferes_ambulancia', 'INSERT', '3', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 3, \"id_empleado\": 7, \"numero_licencia\": \"LIC-19654321\", \"categoria_licencia\": \"5to grado\", \"vencimiento_licencia\": \"2032-01-18\", \"contacto_emergencia\": \"Julio Vargas\", \"telefono_contacto_emergencia\": \"0416-7023344\", \"observaciones\": \"Resguardo de unidad para operativos especiales.\", \"estado\": 1, \"fecha_registro\": \"2026-02-15 08:00:00\", \"fecha_actualizacion\": \"2026-03-21 09:40:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(173, NULL, 'choferes_ambulancia', 'INSERT', '4', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 4, \"id_empleado\": 8, \"numero_licencia\": \"LIC-21567890\", \"categoria_licencia\": \"4to grado\", \"vencimiento_licencia\": \"2031-11-02\", \"contacto_emergencia\": \"Laura Rivas\", \"telefono_contacto_emergencia\": \"0412-7034455\", \"observaciones\": \"Apoyo en guardias diurnas y relevo de ambulancias.\", \"estado\": 1, \"fecha_registro\": \"2026-02-15 08:15:00\", \"fecha_actualizacion\": \"2026-03-20 16:30:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(174, NULL, 'choferes_ambulancia', 'INSERT', '5', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 5, \"id_empleado\": 9, \"numero_licencia\": \"LIC-18345678\", \"categoria_licencia\": \"4to grado\", \"vencimiento_licencia\": \"2030-09-27\", \"contacto_emergencia\": \"Jose Salazar\", \"telefono_contacto_emergencia\": \"0414-7045566\", \"observaciones\": \"Conductora asignada a guardias comunitarias.\", \"estado\": 1, \"fecha_registro\": \"2026-02-16 09:00:00\", \"fecha_actualizacion\": \"2026-03-18 11:20:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(175, NULL, 'choferes_ambulancia', 'INSERT', '6', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 6, \"id_empleado\": 10, \"numero_licencia\": \"LIC-25432109\", \"categoria_licencia\": \"4to grado\", \"vencimiento_licencia\": \"2031-06-30\", \"contacto_emergencia\": \"Nelly Suarez\", \"telefono_contacto_emergencia\": \"0424-7056677\", \"observaciones\": \"Chofer de reserva para unidades en mantenimiento.\", \"estado\": 1, \"fecha_registro\": \"2026-02-16 09:20:00\", \"fecha_actualizacion\": \"2026-03-17 08:10:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(176, NULL, 'asignaciones_unidades_choferes', 'INSERT', '1', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 1, \"id_unidad\": 1, \"id_chofer_ambulancia\": 1, \"fecha_inicio\": \"2026-02-25 07:00:00\", \"fecha_fin\": null, \"observaciones\": \"Guardia activa en hospital de referencia.\", \"estado\": 1, \"fecha_registro\": \"2026-02-25 07:00:00\", \"fecha_actualizacion\": \"2026-03-22 20:22:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(177, NULL, 'asignaciones_unidades_choferes', 'INSERT', '2', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 2, \"id_unidad\": 2, \"id_chofer_ambulancia\": 2, \"fecha_inicio\": \"2026-02-25 07:15:00\", \"fecha_fin\": null, \"observaciones\": \"Guardia activa en eje Pocaterra.\", \"estado\": 1, \"fecha_registro\": \"2026-02-25 07:15:00\", \"fecha_actualizacion\": \"2026-03-23 14:50:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(178, NULL, 'asignaciones_unidades_choferes', 'INSERT', '3', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 3, \"id_unidad\": 3, \"id_chofer_ambulancia\": 3, \"fecha_inicio\": \"2026-02-26 07:00:00\", \"fecha_fin\": null, \"observaciones\": \"Guardia diurna en base central.\", \"estado\": 1, \"fecha_registro\": \"2026-02-26 07:00:00\", \"fecha_actualizacion\": \"2026-03-21 09:40:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(179, NULL, 'asignaciones_unidades_choferes', 'INSERT', '4', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 4, \"id_unidad\": 4, \"id_chofer_ambulancia\": 4, \"fecha_inicio\": \"2026-02-26 07:10:00\", \"fecha_fin\": null, \"observaciones\": \"Guardia mixta para cobertura comunitaria.\", \"estado\": 1, \"fecha_registro\": \"2026-02-26 07:10:00\", \"fecha_actualizacion\": \"2026-03-20 16:30:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(180, NULL, 'asignaciones_unidades_choferes', 'INSERT', '5', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 5, \"id_unidad\": 5, \"id_chofer_ambulancia\": 5, \"fecha_inicio\": \"2026-02-26 07:20:00\", \"fecha_fin\": null, \"observaciones\": \"Cobertura preventiva en parroquia Independencia.\", \"estado\": 1, \"fecha_registro\": \"2026-02-26 07:20:00\", \"fecha_actualizacion\": \"2026-03-18 11:20:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(181, NULL, 'asignaciones_unidades_choferes', 'INSERT', '6', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 6, \"id_unidad\": 6, \"id_chofer_ambulancia\": 6, \"fecha_inicio\": \"2026-02-20 08:00:00\", \"fecha_fin\": \"2026-03-01 17:30:00\", \"observaciones\": \"Unidad retirada temporalmente por mantenimiento preventivo.\", \"estado\": 0, \"fecha_registro\": \"2026-02-20 08:00:00\", \"fecha_actualizacion\": \"2026-03-01 17:30:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(182, NULL, 'asignaciones_unidades_choferes', 'INSERT', '7', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 7, \"id_unidad\": 3, \"id_chofer_ambulancia\": 6, \"fecha_inicio\": \"2026-02-18 07:30:00\", \"fecha_fin\": \"2026-02-24 18:00:00\", \"observaciones\": \"Asignacion previa cerrada por relevo operativo.\", \"estado\": 0, \"fecha_registro\": \"2026-02-18 07:30:00\", \"fecha_actualizacion\": \"2026-02-24 18:00:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(183, NULL, 'seguridad', 'INSERT', '1', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260303-000001\", \"id_beneficiario\": 1, \"id_usuario\": 2, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-03 08:20:00\", \"descripcion\": \"Paciente femenina de 67 anos con crisis hipertensiva y mareos persistentes.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Sector 12 de Octubre, calle principal\", \"referencia_evento\": \"Frente al ambulatorio popular\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(184, NULL, 'seguimientos_solicitudes', 'INSERT', '67', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 67, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 1, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-03 08:20:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(185, NULL, 'despachos_unidades', 'INSERT', '1', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 1, \"id_seguridad\": 1, \"id_unidad\": 3, \"id_chofer_ambulancia\": 3, \"id_usuario_asigna\": 2, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"CERRADO\", \"fecha_asignacion\": \"2026-03-03 08:28:00\", \"fecha_cierre\": \"2026-03-03 10:10:00\", \"ubicacion_salida\": \"Base central\", \"ubicacion_evento\": \"Sector 12 de Octubre, calle principal\", \"ubicacion_cierre\": \"Hospital de Tocuyito\", \"observaciones\": \"Traslado estabilizado sin novedades durante el recorrido.\", \"fecha_registro\": \"2026-03-03 08:28:00\", \"fecha_actualizacion\": \"2026-03-03 10:10:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(186, NULL, 'seguimientos_solicitudes', 'INSERT', '68', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 68, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 1, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-03 08:28:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(187, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '1', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 1, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260303-000001_registro_20260303_082800_0001.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260303-000001_registro_20260303_082800_0001.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"carmen.vargas@situacional.demo\", \"fecha_envio\": \"2026-03-03 08:30:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-03 08:28:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(188, NULL, 'seguimientos_solicitudes', 'INSERT', '69', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 69, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 1, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-03 10:10:00\", \"observacion\": \"Solicitud finalizada con cierre operativo y traslado documentado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(189, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '2', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 2, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"tipo_reporte\": \"CIERRE\", \"nombre_archivo\": \"SEG-20260303-000001_cierre_20260303_101000_0001.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260303-000001_cierre_20260303_101000_0001.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"carmen.vargas@situacional.demo\", \"fecha_envio\": \"2026-03-03 10:14:00\", \"detalle_envio\": \"Reporte de cierre enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-03 10:10:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(190, NULL, 'reportes_traslado', 'INSERT', '1', 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, '{\"id_reporte\": 1, \"id_ayuda\": null, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"id_usuario_operador\": 2, \"id_empleado_chofer\": 7, \"id_unidad\": 3, \"ticket_interno\": \"SEG-20260303-000001\", \"fecha_hora\": \"2026-03-03 10:10:00\", \"diagnostico_paciente\": \"Paciente estabilizada y entregada en urgencias con signos vitales compensados.\", \"foto_evidencia\": \"uploads/reportes_traslado/seguridad_20260303_101000_0001.jpg\", \"km_salida\": 24120, \"km_llegada\": 24138, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1);

INSERT INTO `bitacora` (`id_bitacora`, `id_usuario`, `tabla_afectada`, `accion`, `id_registro`, `resumen`, `detalle`, `datos_antes`, `datos_despues`, `usuario_bd`, `ipaddr`, `moment`, `fecha_evento`, `estado`) VALUES
(191, NULL, 'seguridad', 'INSERT', '2', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260305-000002\", \"id_beneficiario\": 6, \"id_usuario\": 1, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-05 18:05:00\", \"descripcion\": \"Adulto masculino lesionado por caida de moto con dolor en hombro y escoriaciones.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Avenida principal de La Honda\", \"referencia_evento\": \"Cerca del puente peatonal\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(192, NULL, 'seguimientos_solicitudes', 'INSERT', '70', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 70, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 2, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-05 18:05:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(193, NULL, 'despachos_unidades', 'INSERT', '2', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 2, \"id_seguridad\": 2, \"id_unidad\": 4, \"id_chofer_ambulancia\": 4, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"MANUAL\", \"estado_despacho\": \"CERRADO\", \"fecha_asignacion\": \"2026-03-05 18:12:00\", \"fecha_cierre\": \"2026-03-05 19:32:00\", \"ubicacion_salida\": \"CDI El Oasis\", \"ubicacion_evento\": \"Avenida principal de La Honda\", \"ubicacion_cierre\": \"Hospital de Tocuyito\", \"observaciones\": \"Atencion primaria en sitio y posterior traslado preventivo.\", \"fecha_registro\": \"2026-03-05 18:12:00\", \"fecha_actualizacion\": \"2026-03-05 19:32:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(194, NULL, 'seguimientos_solicitudes', 'INSERT', '71', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 71, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 2, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-05 18:12:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(195, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '3', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 3, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260305-000002_registro_20260305_181200_0002.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260305-000002_registro_20260305_181200_0002.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"pedro.rivas@situacional.demo\", \"fecha_envio\": \"2026-03-05 18:14:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-05 18:12:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(196, NULL, 'seguimientos_solicitudes', 'INSERT', '72', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 72, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 2, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-05 19:32:00\", \"observacion\": \"Solicitud finalizada con cierre operativo y traslado documentado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(197, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '4', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 4, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"tipo_reporte\": \"CIERRE\", \"nombre_archivo\": \"SEG-20260305-000002_cierre_20260305_193200_0002.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260305-000002_cierre_20260305_193200_0002.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"pedro.rivas@situacional.demo\", \"fecha_envio\": \"2026-03-05 19:36:00\", \"detalle_envio\": \"Reporte de cierre enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-05 19:32:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(198, NULL, 'reportes_traslado', 'INSERT', '2', 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, '{\"id_reporte\": 2, \"id_ayuda\": null, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"id_usuario_operador\": 1, \"id_empleado_chofer\": 8, \"id_unidad\": 4, \"ticket_interno\": \"SEG-20260305-000002\", \"fecha_hora\": \"2026-03-05 19:32:00\", \"diagnostico_paciente\": \"Traumatismo leve en hombro derecho, paciente referido para rayos X.\", \"foto_evidencia\": \"uploads/reportes_traslado/seguridad_20260305_193200_0002.png\", \"km_salida\": 18344, \"km_llegada\": 18360, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(199, NULL, 'seguridad', 'INSERT', '3', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 3, \"ticket_interno\": \"SEG-20260307-000003\", \"id_beneficiario\": 9, \"id_usuario\": 2, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-07 06:45:00\", \"descripcion\": \"Nino con dificultad respiratoria y antecedentes de asma bronquial.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Comunidad Nueva Villa\", \"referencia_evento\": \"Casa azul junto a la bodega\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(200, NULL, 'seguimientos_solicitudes', 'INSERT', '73', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 73, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 3, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-07 06:45:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(201, NULL, 'despachos_unidades', 'INSERT', '3', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 3, \"id_seguridad\": 3, \"id_unidad\": 5, \"id_chofer_ambulancia\": 5, \"id_usuario_asigna\": 2, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"CERRADO\", \"fecha_asignacion\": \"2026-03-07 06:51:00\", \"fecha_cierre\": \"2026-03-07 08:05:00\", \"ubicacion_salida\": \"Parroquia Independencia\", \"ubicacion_evento\": \"Comunidad Nueva Villa\", \"ubicacion_cierre\": \"Hospital de Tocuyito\", \"observaciones\": \"Se administro oxigeno de apoyo durante el recorrido.\", \"fecha_registro\": \"2026-03-07 06:51:00\", \"fecha_actualizacion\": \"2026-03-07 08:05:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(202, NULL, 'seguimientos_solicitudes', 'INSERT', '74', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 74, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 3, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-07 06:51:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(203, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '5', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 5, \"id_seguridad\": 3, \"id_despacho_unidad\": 3, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260307-000003_registro_20260307_065100_0003.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260307-000003_registro_20260307_065100_0003.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"ana.salazar@situacional.demo\", \"fecha_envio\": \"2026-03-07 06:53:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-07 06:51:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(204, NULL, 'seguimientos_solicitudes', 'INSERT', '75', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 75, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 3, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-07 08:05:00\", \"observacion\": \"Solicitud finalizada con cierre operativo y traslado documentado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(205, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '6', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 6, \"id_seguridad\": 3, \"id_despacho_unidad\": 3, \"tipo_reporte\": \"CIERRE\", \"nombre_archivo\": \"SEG-20260307-000003_cierre_20260307_080500_0003.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260307-000003_cierre_20260307_080500_0003.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"ana.salazar@situacional.demo\", \"fecha_envio\": \"2026-03-07 08:09:00\", \"detalle_envio\": \"Reporte de cierre enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-07 08:05:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(206, NULL, 'reportes_traslado', 'INSERT', '3', 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, '{\"id_reporte\": 3, \"id_ayuda\": null, \"id_seguridad\": 3, \"id_despacho_unidad\": 3, \"id_usuario_operador\": 2, \"id_empleado_chofer\": 9, \"id_unidad\": 5, \"ticket_interno\": \"SEG-20260307-000003\", \"fecha_hora\": \"2026-03-07 08:05:00\", \"diagnostico_paciente\": \"Crisis asmatica controlada con respuesta favorable a nebulizacion inicial.\", \"foto_evidencia\": \"uploads/reportes_traslado/seguridad_20260307_080500_0003.jpg\", \"km_salida\": 19872, \"km_llegada\": 19888, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(207, NULL, 'seguridad', 'INSERT', '4', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 4, \"ticket_interno\": \"SEG-20260310-000004\", \"id_beneficiario\": 13, \"id_usuario\": 1, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-10 11:30:00\", \"descripcion\": \"Gestante con contracciones regulares y dolor abdominal en fase activa.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Urbanizacion Villa Jardin\", \"referencia_evento\": \"Edificio 3, planta baja\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(208, NULL, 'seguimientos_solicitudes', 'INSERT', '76', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 76, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 4, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-10 11:30:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(209, NULL, 'despachos_unidades', 'INSERT', '4', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 4, \"id_seguridad\": 4, \"id_unidad\": 1, \"id_chofer_ambulancia\": 1, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"MANUAL\", \"estado_despacho\": \"CERRADO\", \"fecha_asignacion\": \"2026-03-10 11:37:00\", \"fecha_cierre\": \"2026-03-10 12:42:00\", \"ubicacion_salida\": \"Hospital de Tocuyito\", \"ubicacion_evento\": \"Urbanizacion Villa Jardin\", \"ubicacion_cierre\": \"Maternidad municipal\", \"observaciones\": \"Ingreso rapido y sin complicaciones durante el traslado.\", \"fecha_registro\": \"2026-03-10 11:37:00\", \"fecha_actualizacion\": \"2026-03-10 12:42:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(210, NULL, 'seguimientos_solicitudes', 'INSERT', '77', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 77, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 4, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-10 11:37:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(211, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '7', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 7, \"id_seguridad\": 4, \"id_despacho_unidad\": 4, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260310-000004_registro_20260310_113700_0004.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260310-000004_registro_20260310_113700_0004.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"meza.elsy@gmail.com\", \"fecha_envio\": \"2026-03-10 11:39:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-10 11:37:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(212, NULL, 'seguimientos_solicitudes', 'INSERT', '78', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 78, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 4, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-10 12:42:00\", \"observacion\": \"Solicitud finalizada con cierre operativo y traslado documentado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(213, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '8', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 8, \"id_seguridad\": 4, \"id_despacho_unidad\": 4, \"tipo_reporte\": \"CIERRE\", \"nombre_archivo\": \"SEG-20260310-000004_cierre_20260310_124200_0004.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260310-000004_cierre_20260310_124200_0004.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"meza.elsy@gmail.com\", \"fecha_envio\": \"2026-03-10 12:46:00\", \"detalle_envio\": \"Reporte de cierre enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-10 12:42:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(214, NULL, 'reportes_traslado', 'INSERT', '4', 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, '{\"id_reporte\": 4, \"id_ayuda\": null, \"id_seguridad\": 4, \"id_despacho_unidad\": 4, \"id_usuario_operador\": 1, \"id_empleado_chofer\": 1, \"id_unidad\": 1, \"ticket_interno\": \"SEG-20260310-000004\", \"fecha_hora\": \"2026-03-10 12:42:00\", \"diagnostico_paciente\": \"Paciente entregada en sala de parto con signos estables.\", \"foto_evidencia\": \"uploads/reportes_traslado/seguridad_20260310_124200_0004.png\", \"km_salida\": 24138, \"km_llegada\": 24149, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(215, NULL, 'seguridad', 'INSERT', '5', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 5, \"ticket_interno\": \"SEG-20260322-000005\", \"id_beneficiario\": 15, \"id_usuario\": 2, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-22 20:15:00\", \"descripcion\": \"Adulto mayor con dolor toracico y dificultad para caminar.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"Casco Comercial de Tocuyito\", \"referencia_evento\": \"Frente a la farmacia principal\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(216, NULL, 'seguimientos_solicitudes', 'INSERT', '79', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 79, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 5, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-22 20:15:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(217, NULL, 'despachos_unidades', 'INSERT', '5', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 5, \"id_seguridad\": 5, \"id_unidad\": 1, \"id_chofer_ambulancia\": 1, \"id_usuario_asigna\": 2, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"ACTIVO\", \"fecha_asignacion\": \"2026-03-22 20:22:00\", \"fecha_cierre\": null, \"ubicacion_salida\": \"Hospital de Tocuyito\", \"ubicacion_evento\": \"Casco Comercial de Tocuyito\", \"ubicacion_cierre\": null, \"observaciones\": \"Unidad en ruta al sitio con prioridad uno.\", \"fecha_registro\": \"2026-03-22 20:22:00\", \"fecha_actualizacion\": \"2026-03-22 20:22:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(218, NULL, 'seguimientos_solicitudes', 'INSERT', '80', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 80, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 5, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-22 20:22:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(219, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '9', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 9, \"id_seguridad\": 5, \"id_despacho_unidad\": 5, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260322-000005_registro_20260322_202200_0005.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260322-000005_registro_20260322_202200_0005.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"meza.elsy@gmail.com\", \"fecha_envio\": \"2026-03-22 20:24:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-22 20:22:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(220, NULL, 'seguridad', 'INSERT', '6', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 6, \"ticket_interno\": \"SEG-20260323-000006\", \"id_beneficiario\": 18, \"id_usuario\": 1, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-23 14:40:00\", \"descripcion\": \"Paciente con hipoglucemia reportada por familiares y mareo intenso.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"Urbanizacion Jose Rafael Pocaterra\", \"referencia_evento\": \"Casa 14, calle A\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(221, NULL, 'seguimientos_solicitudes', 'INSERT', '81', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 81, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 6, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-23 14:40:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(222, NULL, 'despachos_unidades', 'INSERT', '6', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 6, \"id_seguridad\": 6, \"id_unidad\": 2, \"id_chofer_ambulancia\": 2, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"ACTIVO\", \"fecha_asignacion\": \"2026-03-23 14:50:00\", \"fecha_cierre\": null, \"ubicacion_salida\": \"Urbanizacion Jose Rafael Pocaterra\", \"ubicacion_evento\": \"Urbanizacion Jose Rafael Pocaterra\", \"ubicacion_cierre\": null, \"observaciones\": \"Unidad en atencion activa con reporte telefonico abierto.\", \"fecha_registro\": \"2026-03-23 14:50:00\", \"fecha_actualizacion\": \"2026-03-23 14:50:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(223, NULL, 'seguimientos_solicitudes', 'INSERT', '82', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 82, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 6, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-23 14:50:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(224, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '10', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 10, \"id_seguridad\": 6, \"id_despacho_unidad\": 6, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260323-000006_registro_20260323_145000_0006.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260323-000006_registro_20260323_145000_0006.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"flaura2705@gmail.com\", \"fecha_envio\": \"2026-03-23 14:52:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-23 14:50:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(225, NULL, 'seguridad', 'INSERT', '7', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 7, \"ticket_interno\": \"SEG-20260323-000007\", \"id_beneficiario\": 21, \"id_usuario\": 2, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-23 07:10:00\", \"descripcion\": \"Adulto mayor con sospecha de deshidratacion mientras se libera una unidad.\", \"estado_atencion\": \"PENDIENTE_UNIDAD\", \"ubicacion_evento\": \"Barrio El Oasis\", \"referencia_evento\": \"Cancha techada\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(226, NULL, 'seguimientos_solicitudes', 'INSERT', '83', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 83, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 7, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-23 07:10:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(227, NULL, 'seguimientos_solicitudes', 'INSERT', '84', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 84, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 7, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-23 07:20:00\", \"observacion\": \"Caso en espera de unidad operativa disponible.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(228, NULL, 'seguridad', 'INSERT', '8', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 8, \"ticket_interno\": \"SEG-20260312-000008\", \"id_beneficiario\": 23, \"id_usuario\": 4, \"id_tipo_seguridad\": 6, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Hurto\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-12 09:00:00\", \"descripcion\": \"Denuncia de hurto de cableado residencial con afectacion de servicio domestico.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Santa Eduviges\", \"referencia_evento\": \"Detras de la casa comunal\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(229, NULL, 'seguimientos_solicitudes', 'INSERT', '85', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 85, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 8, \"id_estado_solicitud\": 1, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-12 09:00:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(230, NULL, 'seguimientos_solicitudes', 'INSERT', '86', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 86, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 8, \"id_estado_solicitud\": 3, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-12 11:00:00\", \"observacion\": \"Gestion cerrada por el equipo operativo correspondiente.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(231, NULL, 'seguridad', 'INSERT', '9', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 9, \"ticket_interno\": \"SEG-20260313-000009\", \"id_beneficiario\": 24, \"id_usuario\": 4, \"id_tipo_seguridad\": 5, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Robo de vehiculo\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-13 22:10:00\", \"descripcion\": \"Reporte de robo de motocicleta al salir de jornada laboral nocturna.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Zanjon Dulce\", \"referencia_evento\": \"Cerca de la parada de autobuses\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(232, NULL, 'seguimientos_solicitudes', 'INSERT', '87', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 87, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 9, \"id_estado_solicitud\": 1, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-13 22:10:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(233, NULL, 'seguridad', 'INSERT', '10', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 10, \"ticket_interno\": \"SEG-20260315-000010\", \"id_beneficiario\": 25, \"id_usuario\": 2, \"id_tipo_seguridad\": 8, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Riesgo de vias publicas\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-15 17:35:00\", \"descripcion\": \"Arbol inclinado sobre vialidad con riesgo de caida sobre peatones.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Los Mangos\", \"referencia_evento\": \"Frente a la escuela tecnica\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(234, NULL, 'seguimientos_solicitudes', 'INSERT', '88', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 88, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 10, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-15 17:35:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(235, NULL, 'seguimientos_solicitudes', 'INSERT', '89', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 89, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 10, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-15 19:35:00\", \"observacion\": \"Gestion cerrada por el equipo operativo correspondiente.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(236, NULL, 'seguridad', 'INSERT', '11', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 11, \"ticket_interno\": \"SEG-20260316-000011\", \"id_beneficiario\": 26, \"id_usuario\": 2, \"id_tipo_seguridad\": 11, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Reubicacion de insectos\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-16 13:25:00\", \"descripcion\": \"Avispero activo en techo de vivienda multifamiliar.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Urbanizacion La Esperanza\", \"referencia_evento\": \"Casa esquinera color beige\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(237, NULL, 'seguimientos_solicitudes', 'INSERT', '90', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 90, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 11, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-16 13:25:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(238, NULL, 'seguimientos_solicitudes', 'INSERT', '91', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 91, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 11, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-16 15:25:00\", \"observacion\": \"Gestion cerrada por el equipo operativo correspondiente.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(239, NULL, 'seguridad', 'INSERT', '12', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 12, \"ticket_interno\": \"SEG-20260318-000012\", \"id_beneficiario\": 27, \"id_usuario\": 4, \"id_tipo_seguridad\": 9, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Maltrato domestico\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-18 19:10:00\", \"descripcion\": \"Vecinos reportan presunta situacion de violencia intrafamiliar.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Colinas del Rosario\", \"referencia_evento\": \"Pasillo 4 del conjunto residencial\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(240, NULL, 'seguimientos_solicitudes', 'INSERT', '92', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 92, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 12, \"id_estado_solicitud\": 1, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-18 19:10:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1),
(241, NULL, 'seguridad', 'INSERT', '13', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 13, \"ticket_interno\": \"SEG-20260319-000013\", \"id_beneficiario\": 28, \"id_usuario\": 1, \"id_tipo_seguridad\": 1, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Guardia y seguridad\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-19 06:30:00\", \"descripcion\": \"Solicitud de apoyo preventivo por evento comunitario con alta asistencia.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Comunidad Bicentenario\", \"referencia_evento\": \"Plaza central\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(242, NULL, 'seguimientos_solicitudes', 'INSERT', '93', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 93, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 13, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-19 06:30:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(243, NULL, 'seguimientos_solicitudes', 'INSERT', '94', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 94, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 13, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-19 08:30:00\", \"observacion\": \"Gestion cerrada por el equipo operativo correspondiente.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(244, NULL, 'seguridad', 'INSERT', '14', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 14, \"ticket_interno\": \"SEG-20260320-000014\", \"id_beneficiario\": 29, \"id_usuario\": 4, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Robo de inmueble\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-20 03:50:00\", \"descripcion\": \"Reporte de intrusion nocturna en vivienda desocupada parcialmente.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Banco Obrero Las Palmas\", \"referencia_evento\": \"Casa 8, vereda final\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(245, NULL, 'seguimientos_solicitudes', 'INSERT', '95', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 95, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 14, \"id_estado_solicitud\": 1, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-20 03:50:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(246, 1, 'AUTENTICACION', 'LOGIN_OK', 'admin', 'Evento de autenticacion: LOGIN_OK', 'Inicio de sesion administrativo para revision de tableros.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(247, 2, 'AUTENTICACION', 'LOGIN_OK', 'operador.sala', 'Evento de autenticacion: LOGIN_OK', 'Ingreso del operador de sala para coordinacion operativa.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(248, 3, 'AUTENTICACION', 'LOGIN_OK', 'atencion.ciudadana', 'Evento de autenticacion: LOGIN_OK', 'Ingreso para carga de solicitudes ciudadanas.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(249, 4, 'AUTENTICACION', 'LOGIN_FAIL', 'consulta.tribunal', 'Evento de autenticacion: LOGIN_FAIL', 'Intento previo con clave vencida antes de la autenticacion correcta.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(250, 4, 'AUTENTICACION', 'LOGIN_OK', 'consulta.tribunal', 'Evento de autenticacion: LOGIN_OK', 'Ingreso de consulta para revision de bitacora institucional.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1),
(251, 1, 'AUTENTICACION', 'LOGOUT', 'admin', 'Evento de autenticacion: LOGOUT', 'Cierre de sesion del usuario \'admin\'.', NULL, NULL, 'root@localhost', '::1', '2026-03-24 02:42:24', '2026-03-23 22:42:24', 1),
(252, NULL, 'usuarios_seguridad_acceso', 'UPDATE', '2', 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-20 08:00:00\"}', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-23 22:42:55\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:42:55', '2026-03-23 22:42:55', 1),
(253, 2, 'AUTENTICACION', 'LOGIN_OK', 'operador.sala', 'Evento de autenticacion: LOGIN_OK', 'Inicio de sesion exitoso para el usuario \'operador.sala\'.', NULL, NULL, 'root@localhost', '::1', '2026-03-24 02:42:55', '2026-03-23 22:42:55', 1),
(254, NULL, 'tipos_seguridad_emergencia', 'UPDATE', '3', 'UPDATE en tipos_seguridad_emergencia', 'Se actualizo un registro en tipos_seguridad_emergencia', '{\"id_tipo_seguridad\": 3, \"nombre_tipo\": \"Traslado\", \"requiere_ambulancia\": 0, \"estado\": 1, \"fecha_registro\": \"2026-03-13 14:34:52\"}', '{\"id_tipo_seguridad\": 3, \"nombre_tipo\": \"Traslado\", \"requiere_ambulancia\": 1, \"estado\": 1, \"fecha_registro\": \"2026-03-13 14:34:52\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:45:13', '2026-03-23 22:45:13', 1),
(255, 2, 'SISTEMA', 'OPERACION', NULL, 'Operacion del sistema', 'CONFIGURACION ACTUALIZAR - Catalogo: tipos_seguridad_emergencia - Registro: 3', NULL, NULL, 'root@localhost', '::1', '2026-03-24 02:45:13', '2026-03-23 22:45:13', 1);

INSERT INTO `choferes_ambulancia` (`id_chofer_ambulancia`, `id_empleado`, `numero_licencia`, `categoria_licencia`, `vencimiento_licencia`, `contacto_emergencia`, `telefono_contacto_emergencia`, `observaciones`, `estado`, `fecha_registro`, `fecha_actualizacion`) VALUES
(1, 1, 'LIC-14382513', '5to grado', '2030-08-14', 'Andres Aguilar', '0412-7001122', 'Chofer principal de guardia nocturna.', 1, '2026-02-14 07:10:00', '2026-03-22 20:22:00'),
(2, 2, 'LIC-24329534', '5to grado', '2031-04-09', 'Maria Franco', '0424-7012233', 'Disponible para turnos rotativos y traslados largos.', 1, '2026-02-14 07:20:00', '2026-03-23 14:50:00'),
(3, 7, 'LIC-19654321', '5to grado', '2032-01-18', 'Julio Vargas', '0416-7023344', 'Resguardo de unidad para operativos especiales.', 1, '2026-02-15 08:00:00', '2026-03-21 09:40:00'),
(4, 8, 'LIC-21567890', '4to grado', '2031-11-02', 'Laura Rivas', '0412-7034455', 'Apoyo en guardias diurnas y relevo de ambulancias.', 1, '2026-02-15 08:15:00', '2026-03-20 16:30:00'),
(5, 9, 'LIC-18345678', '4to grado', '2030-09-27', 'Jose Salazar', '0414-7045566', 'Conductora asignada a guardias comunitarias.', 1, '2026-02-16 09:00:00', '2026-03-18 11:20:00'),
(6, 10, 'LIC-25432109', '4to grado', '2031-06-30', 'Nelly Suarez', '0424-7056677', 'Chofer de reserva para unidades en mantenimiento.', 1, '2026-02-16 09:20:00', '2026-03-17 08:10:00');

INSERT INTO `comunidades` (`id_comunidad`, `nombre_comunidad`, `estado`, `fecha_registro`) VALUES
(1, 'Casco Comercial de Tocuyito', 1, '2026-03-13 12:17:31'),
(2, 'Urbanizacion Valles de San Francisco', 1, '2026-03-13 12:17:31'),
(3, 'Conjunto Residencial Los Trescientos', 1, '2026-03-13 12:17:31'),
(4, 'Urbanizacion Jose Rafael Pocaterra', 1, '2026-03-13 12:17:31'),
(5, 'Centro Penitenciario Tocuyito', 1, '2026-03-13 12:17:31'),
(6, 'Santa Eduviges', 1, '2026-03-13 12:17:31'),
(7, 'Bella Vista', 1, '2026-03-13 12:17:31'),
(8, 'Los Mangos', 1, '2026-03-13 12:17:31'),
(9, 'La Herrerena', 1, '2026-03-13 12:17:31'),
(10, 'Urbanizacion La Esperanza', 1, '2026-03-13 12:17:31'),
(11, 'Triangulo El Oasis', 1, '2026-03-13 12:17:31'),
(12, 'Hacienda Juana Paula', 1, '2026-03-13 12:17:31'),
(13, 'Encrucijada de Carabobo', 1, '2026-03-13 12:17:31'),
(14, 'Urbanizacion Santa Paula', 1, '2026-03-13 12:17:31'),
(15, 'Hacienda La Trinidad', 1, '2026-03-13 12:17:31'),
(16, 'Hacienda El Rosario', 1, '2026-03-13 12:17:31'),
(17, 'El Rosario', 1, '2026-03-13 12:17:31'),
(18, 'El Rosal', 1, '2026-03-13 12:17:31'),
(19, 'Los Rosales', 1, '2026-03-13 12:17:31'),
(20, 'Colinas del Rosario', 1, '2026-03-13 12:17:31'),
(21, 'Barrio La Trinidad', 1, '2026-03-13 12:17:31'),
(22, 'Zanjon Dulce', 1, '2026-03-13 12:17:31'),
(23, 'Escuela de Cadafe', 1, '2026-03-13 12:17:31'),
(24, '12 de Octubre', 1, '2026-03-13 12:17:31'),
(25, '9 de Diciembre', 1, '2026-03-13 12:17:31'),
(26, 'La Honda', 1, '2026-03-13 12:17:31'),
(27, 'Altos de La Honda', 1, '2026-03-13 12:17:31'),
(28, 'Banco Obrero Las Palmas', 1, '2026-03-13 12:17:31'),
(29, 'Simon Bolivar', 1, '2026-03-13 12:17:31'),
(30, 'Urbanizacion El Libertador', 1, '2026-03-13 12:17:31'),
(31, 'Jardines del Cementerio El Oasis', 1, '2026-03-13 12:17:31'),
(32, 'Parque Agrinco', 1, '2026-03-13 12:17:31'),
(33, 'San Pablo Valley', 1, '2026-03-13 12:17:31'),
(34, 'El Encanto', 1, '2026-03-13 12:17:31'),
(35, 'Barrio El Oasis', 1, '2026-03-13 12:17:31'),
(36, 'Urbanizacion Villa Jardin', 1, '2026-03-13 12:17:31'),
(37, 'Avicola La Guasima', 1, '2026-03-13 12:17:31'),
(38, 'La Guasima I y II', 1, '2026-03-13 12:17:31'),
(39, 'Comunidad Bicentenario', 1, '2026-03-13 12:17:31'),
(40, 'Comunidad Nueva Villa', 1, '2026-03-13 12:17:31'),
(41, 'Comunidad Alexis Cravo', 1, '2026-03-13 12:17:31'),
(42, 'Barrio Manuelita Saenz', 1, '2026-03-13 12:17:31'),
(43, 'Comunidad Los Chaguaramos', 1, '2026-03-13 12:17:31'),
(44, 'Vertedero La Guasima', 1, '2026-03-13 12:17:31'),
(45, 'Fundacion CAP', 1, '2026-03-13 12:17:31'),
(46, 'Barrio Bueno', 1, '2026-03-13 12:17:31'),
(47, 'Los Chorritos', 1, '2026-03-13 12:17:31'),
(48, 'Urbanizacion El Molino', 1, '2026-03-13 12:17:31'),
(49, 'Comunidad Juncalito', 1, '2026-03-13 12:17:31'),
(50, 'Urbanizacion Altos de Uslar', 1, '2026-03-13 12:17:31'),
(51, 'Urbanizacion Negra Matea', 1, '2026-03-13 12:17:31'),
(52, 'Comunidad Brisas de Guataparo', 1, '2026-03-13 12:17:31'),
(53, 'Comunidad La Vega', 1, '2026-03-13 12:17:31'),
(54, 'Comunidad El Vigia', 1, '2026-03-13 12:17:31'),
(55, 'Comunidad El Charal', 1, '2026-03-13 12:17:31'),
(56, 'Comunidad 23 de Enero', 1, '2026-03-13 12:17:31'),
(57, 'Mayorista', 1, '2026-03-13 12:17:31'),
(58, 'Colina de Carrizales', 1, '2026-03-13 12:17:31'),
(59, 'Barrerita', 1, '2026-03-13 12:17:31'),
(60, 'Safari Country Club', 1, '2026-03-13 12:17:31'),
(61, 'Barrio Nueva Valencia', 1, '2026-03-13 12:17:31'),
(62, 'Barrio Jardines de San Luis', 1, '2026-03-13 12:17:31'),
(63, 'Urbanizacion San Luis', 1, '2026-03-13 12:17:31'),
(64, 'Terrenos Propios del Municipio Libertador', 1, '2026-03-13 12:17:31'),
(65, 'Urbanizacion Los Cardones', 1, '2026-03-13 12:17:31'),
(66, 'Campamento Bautista', 1, '2026-03-13 12:17:31'),
(67, 'Parcelamiento Los Aguacatales', 1, '2026-03-13 12:17:31'),
(68, 'Hato Barrera', 1, '2026-03-13 12:17:31'),
(69, 'Santa Isabel', 1, '2026-03-13 12:17:31'),
(70, 'Hacienda San Rafael', 1, '2026-03-13 12:17:31'),
(71, 'Comunidad La Yaguara', 1, '2026-03-13 12:17:31'),
(72, 'Terrenos Inmediatos al Dique de Guataparo', 1, '2026-03-13 12:17:31'),
(73, 'Hacienda Country Club', 1, '2026-03-13 12:17:31'),
(74, 'Colinas de Carabobo', 1, '2026-03-13 12:17:31'),
(75, 'Hector Pereda', 1, '2026-03-13 12:17:31'),
(76, 'La Alegria', 1, '2026-03-13 12:17:31'),
(77, 'Negro Primero', 1, '2026-03-13 12:17:31'),
(78, 'Las Americas Jose Luis Martinez', 1, '2026-03-13 12:17:31'),
(79, 'Barrera Norte', 1, '2026-03-13 12:17:31'),
(80, 'Barrera Centro', 1, '2026-03-13 12:17:31'),
(81, 'Hato Residencial La Gran Sabana', 1, '2026-03-13 12:17:31'),
(82, 'Parcelamiento Sabana del Medio', 1, '2026-03-13 12:17:31'),
(83, 'Campo de Carabobo', 1, '2026-03-13 12:17:31'),
(84, 'Barrio El Cementerio', 1, '2026-03-13 12:17:31'),
(85, 'Barrio del Rincon', 1, '2026-03-13 12:17:31'),
(86, 'Barrio Sucre', 1, '2026-03-13 12:17:31'),
(87, 'Barrio Union', 1, '2026-03-13 12:17:31'),
(88, 'Brisas del Campo', 1, '2026-03-13 12:17:31'),
(89, 'La Pica', 1, '2026-03-13 12:17:31'),
(90, 'Las Manzanas', 1, '2026-03-13 12:17:31'),
(91, 'Pueblo Nuevo', 1, '2026-03-13 12:17:31'),
(92, 'Nuevo Carabobo', 1, '2026-03-13 12:17:31'),
(93, 'El Rincon', 1, '2026-03-13 12:17:31'),
(94, 'Los Chorros', 1, '2026-03-13 12:17:31'),
(95, 'La Cuesta', 1, '2026-03-13 12:17:31'),
(96, 'Manzana de Oro', 1, '2026-03-13 12:17:31'),
(97, 'Los Cocos', 1, '2026-03-13 12:17:31'),
(98, 'Las Manzanitas', 1, '2026-03-13 12:17:31'),
(99, 'Ruiz Pineda', 1, '2026-03-13 12:17:31'),
(100, 'Barrio Josefina', 1, '2026-03-13 12:17:31'),
(101, '7 de Octubre', 1, '2026-03-13 12:17:31'),
(102, 'San Antonio', 1, '2026-03-13 12:17:31'),
(103, 'El Chaguaramal', 1, '2026-03-13 12:17:31'),
(104, 'Barrio El Carmen', 1, '2026-03-13 12:17:31'),
(105, 'Eulalia Buroz', 1, '2026-03-13 12:17:31'),
(106, 'Barrio La Adobera', 1, '2026-03-13 12:17:31'),
(107, 'La Florida', 1, '2026-03-13 12:17:31'),
(108, 'Barrio Palotal', 1, '2026-03-13 12:17:31'),
(109, 'Urbanizacion Los Jabilos', 1, '2026-03-13 12:17:31'),
(110, 'Urbanizacion Los Chaguaramos', 1, '2026-03-13 12:17:31'),
(111, 'Urbanizacion Tucan', 1, '2026-03-13 12:17:31'),
(112, 'Conjunto Residencial Las Palmas', 1, '2026-03-13 12:17:31'),
(113, 'Conjunto Residencial Cachiri', 1, '2026-03-13 12:17:31'),
(114, 'Urbanizacion La Honda', 1, '2026-03-13 12:17:31'),
(115, 'Urbanizacion El Rosario', 1, '2026-03-13 12:17:31'),
(116, 'Urbanizacion Alto de Jalisco', 1, '2026-03-13 12:17:31'),
(117, 'Urbanizacion Libertador', 1, '2026-03-13 12:17:31'),
(118, 'Urbanizacion Jose Hernandez', 1, '2026-03-13 12:17:31'),
(119, 'Urbanizacion El Rincon', 1, '2026-03-13 12:17:31'),
(120, 'Urbanizacion Cantarrana', 1, '2026-03-13 12:17:31'),
(121, 'Urbanizacion Los Cedros', 1, '2026-03-13 12:17:31'),
(122, 'Urbanizacion Manzana de Oro', 1, '2026-03-13 12:17:31'),
(123, 'Urbanizacion La Adobera', 1, '2026-03-13 12:17:31'),
(124, 'Urbanizacion Palotal', 1, '2026-03-13 12:17:31'),
(125, 'Casco de Tocuyito', 1, '2026-03-13 12:17:31'),
(126, 'Cantarrana Tocuyito', 1, '2026-03-13 12:17:31'),
(127, 'Tocuyito', 1, '2026-03-13 12:17:31'),
(128, 'No Especificada', 1, '2026-03-13 12:17:31'),
(129, 'valencia', 0, '2026-03-13 12:17:31');

INSERT INTO `configuracion_smtp` (`id_configuracion_smtp`, `host`, `puerto`, `usuario`, `clave`, `correo_remitente`, `nombre_remitente`, `usar_tls`, `estado`, `id_usuario_actualiza`, `fecha_registro`, `fecha_actualizacion`) VALUES
(1, 'smtp.gmail.com', 587, 'meza.elsy@gmail.com', 'mqmrsujmyabwpgbv', 'meza.elsy@gmail.com', 'Sala Situacional 1', 1, 1, 1, '0000-00-00 00:00:00', '2026-03-18 22:07:07');

INSERT INTO `dependencias` (`id_dependencia`, `nombre_dependencia`, `estado`) VALUES
(2, 'Atención al Ciudadano', 1),
(5, 'Auditoría Interna', 1),
(3, 'Catastro', 1),
(6, 'Dirección General', 1),
(1, 'Informática', 1),
(7, 'Registro Civil', 1),
(4, 'Sala Situacional', 1);

INSERT INTO `despachos_unidades` (`id_despacho_unidad`, `id_seguridad`, `id_unidad`, `id_chofer_ambulancia`, `id_usuario_asigna`, `modo_asignacion`, `estado_despacho`, `fecha_asignacion`, `fecha_cierre`, `ubicacion_salida`, `ubicacion_evento`, `ubicacion_cierre`, `observaciones`, `fecha_registro`, `fecha_actualizacion`) VALUES
(1, 1, 3, 3, 2, 'AUTO', 'CERRADO', '2026-03-03 08:28:00', '2026-03-03 10:10:00', 'Base central', 'Sector 12 de Octubre, calle principal', 'Hospital de Tocuyito', 'Traslado estabilizado sin novedades durante el recorrido.', '2026-03-03 08:28:00', '2026-03-03 10:10:00'),
(2, 2, 4, 4, 1, 'MANUAL', 'CERRADO', '2026-03-05 18:12:00', '2026-03-05 19:32:00', 'CDI El Oasis', 'Avenida principal de La Honda', 'Hospital de Tocuyito', 'Atencion primaria en sitio y posterior traslado preventivo.', '2026-03-05 18:12:00', '2026-03-05 19:32:00'),
(3, 3, 5, 5, 2, 'AUTO', 'CERRADO', '2026-03-07 06:51:00', '2026-03-07 08:05:00', 'Parroquia Independencia', 'Comunidad Nueva Villa', 'Hospital de Tocuyito', 'Se administro oxigeno de apoyo durante el recorrido.', '2026-03-07 06:51:00', '2026-03-07 08:05:00'),
(4, 4, 1, 1, 1, 'MANUAL', 'CERRADO', '2026-03-10 11:37:00', '2026-03-10 12:42:00', 'Hospital de Tocuyito', 'Urbanizacion Villa Jardin', 'Maternidad municipal', 'Ingreso rapido y sin complicaciones durante el traslado.', '2026-03-10 11:37:00', '2026-03-10 12:42:00'),
(5, 5, 1, 1, 2, 'AUTO', 'ACTIVO', '2026-03-22 20:22:00', NULL, 'Hospital de Tocuyito', 'Casco Comercial de Tocuyito', NULL, 'Unidad en ruta al sitio con prioridad uno.', '2026-03-22 20:22:00', '2026-03-22 20:22:00'),
(6, 6, 2, 2, 1, 'AUTO', 'ACTIVO', '2026-03-23 14:50:00', NULL, 'Urbanizacion Jose Rafael Pocaterra', 'Urbanizacion Jose Rafael Pocaterra', NULL, 'Unidad en atencion activa con reporte telefonico abierto.', '2026-03-23 14:50:00', '2026-03-23 14:50:00');

INSERT INTO `empleados` (`id_empleado`, `cedula`, `nombre`, `apellido`, `id_dependencia`, `telefono`, `correo`, `direccion`, `estado`) VALUES
(1, 14382513, 'Elsy', 'Meza', 6, '04269390643', 'meza.elsy@gmail.com', 'San Diego', 1),
(2, 24329534, 'Laura', 'Franco', 3, '04244668450', 'flaura2705@gmail.com', 'Libetrador - tocuyito', 1),
(3, 22206460, 'elsy', 'meza', 6, NULL, 'aliguerrero102@gmail.com', NULL, 1),
(4, 30124567, 'Jose Gregorio', 'Carrasco', 4, '0412-5503412', 'jose.carrasco@situacional.demo', 'Tocuyito, sector centro', 1),
(5, 28455102, 'Maria Alejandra', 'Perez', 2, '0414-5503413', 'maria.perez@situacional.demo', 'Tocuyito, casco central', 1),
(6, 26789012, 'Luis Alberto', 'Romero', 7, '0424-5503414', 'luis.romero@situacional.demo', 'Parroquia Independencia', 1),
(7, 19654321, 'Carmen Elena', 'Vargas', 4, '0416-5503415', 'carmen.vargas@situacional.demo', 'Barrio El Oasis', 1),
(8, 21567890, 'Pedro Antonio', 'Rivas', 2, '0412-5503416', 'pedro.rivas@situacional.demo', 'Urbanizacion La Esperanza', 1),
(9, 18345678, 'Ana Beatriz', 'Salazar', 4, '0414-5503417', 'ana.salazar@situacional.demo', 'Santa Eduviges', 1),
(10, 25432109, 'Ramon Eduardo', 'Suarez', 3, '0424-5503418', 'ramon.suarez@situacional.demo', 'Comunidad Bicentenario', 1);

INSERT INTO `estados_solicitudes` (`id_estado_solicitud`, `codigo_estado`, `nombre_estado`, `descripcion`, `clase_badge`, `es_atendida`, `orden_visual`, `estado`) VALUES
(1, 'REGISTRADA', 'Registrada', 'Solicitud creada y pendiente por gestion.', 'draft', 0, 1, 1),
(2, 'EN_GESTION', 'En gestion', 'Solicitud en proceso de atencion o seguimiento.', 'info', 0, 2, 1),
(3, 'ATENDIDA', 'Atendida', 'Solicitud atendida y cerrada satisfactoriamente.', 'active', 1, 3, 1),
(4, 'NO_ATENDIDA', 'No atendida', 'Solicitud cerrada sin atencion satisfactoria.', 'warning', 0, 4, 1);

INSERT INTO `permisos` (`id_permiso`, `nombre_permiso`, `descripcion`, `estado`) VALUES
(1, 'Escritorio', 'Permite acceder y gestionar el modulo de Beneficiarios.', 1),
(2, 'Concepto', 'Permite acceder al Panel General y administrar catalogos base en Configuracion.', 1),
(3, 'Ayuda', 'Permite registrar y gestionar solicitudes del modulo de Ayuda Social.', 1),
(4, 'Emergencia', 'Permite gestionar Seguridad y Emergencia, incluyendo despacho y operativa de ambulancias.', 1),
(5, 'Publicos', 'Permite gestionar solicitudes del modulo de Servicios Publicos.', 1),
(6, 'Usuarios', 'Permite administrar usuarios del sistema y su matriz de permisos.', 1),
(7, 'Tribunal', 'Permite consultar el modulo de Bitacora y su historial de eventos.', 1),
(8, 'Chofer', 'Permite gestionar funciones operativas relacionadas con choferes y traslados.', 1),
(99, 'Acceso total del sistema', 'Permiso exclusivo para acceso completo a todos los modulos; solo puede transferirse a otro usuario administrador.', 1);

INSERT INTO `reportes_solicitudes_ambulancia` (`id_reporte_solicitud`, `id_seguridad`, `id_despacho_unidad`, `tipo_reporte`, `nombre_archivo`, `ruta_archivo`, `estado_envio`, `correo_destino`, `fecha_envio`, `detalle_envio`, `id_usuario_genera`, `fecha_generacion`, `estado`) VALUES
(1, 1, 1, 'REGISTRO', 'SEG-20260303-000001_registro_20260303_082800_0001.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260303-000001_registro_20260303_082800_0001.pdf', 'ENVIADO', 'carmen.vargas@situacional.demo', '2026-03-03 08:30:00', 'Reporte de salida enviado correctamente al correo del chofer.', 2, '2026-03-03 08:28:00', 1),
(2, 1, 1, 'CIERRE', 'SEG-20260303-000001_cierre_20260303_101000_0001.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260303-000001_cierre_20260303_101000_0001.pdf', 'ENVIADO', 'carmen.vargas@situacional.demo', '2026-03-03 10:14:00', 'Reporte de cierre enviado correctamente al correo del chofer.', 2, '2026-03-03 10:10:00', 1),
(3, 2, 2, 'REGISTRO', 'SEG-20260305-000002_registro_20260305_181200_0002.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260305-000002_registro_20260305_181200_0002.pdf', 'ENVIADO', 'pedro.rivas@situacional.demo', '2026-03-05 18:14:00', 'Reporte de salida enviado correctamente al correo del chofer.', 1, '2026-03-05 18:12:00', 1),
(4, 2, 2, 'CIERRE', 'SEG-20260305-000002_cierre_20260305_193200_0002.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260305-000002_cierre_20260305_193200_0002.pdf', 'ENVIADO', 'pedro.rivas@situacional.demo', '2026-03-05 19:36:00', 'Reporte de cierre enviado correctamente al correo del chofer.', 1, '2026-03-05 19:32:00', 1),
(5, 3, 3, 'REGISTRO', 'SEG-20260307-000003_registro_20260307_065100_0003.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260307-000003_registro_20260307_065100_0003.pdf', 'ENVIADO', 'ana.salazar@situacional.demo', '2026-03-07 06:53:00', 'Reporte de salida enviado correctamente al correo del chofer.', 2, '2026-03-07 06:51:00', 1),
(6, 3, 3, 'CIERRE', 'SEG-20260307-000003_cierre_20260307_080500_0003.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260307-000003_cierre_20260307_080500_0003.pdf', 'ENVIADO', 'ana.salazar@situacional.demo', '2026-03-07 08:09:00', 'Reporte de cierre enviado correctamente al correo del chofer.', 2, '2026-03-07 08:05:00', 1),
(7, 4, 4, 'REGISTRO', 'SEG-20260310-000004_registro_20260310_113700_0004.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260310-000004_registro_20260310_113700_0004.pdf', 'ENVIADO', 'meza.elsy@gmail.com', '2026-03-10 11:39:00', 'Reporte de salida enviado correctamente al correo del chofer.', 1, '2026-03-10 11:37:00', 1),
(8, 4, 4, 'CIERRE', 'SEG-20260310-000004_cierre_20260310_124200_0004.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260310-000004_cierre_20260310_124200_0004.pdf', 'ENVIADO', 'meza.elsy@gmail.com', '2026-03-10 12:46:00', 'Reporte de cierre enviado correctamente al correo del chofer.', 1, '2026-03-10 12:42:00', 1),
(9, 5, 5, 'REGISTRO', 'SEG-20260322-000005_registro_20260322_202200_0005.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260322-000005_registro_20260322_202200_0005.pdf', 'ENVIADO', 'meza.elsy@gmail.com', '2026-03-22 20:24:00', 'Reporte de salida enviado correctamente al correo del chofer.', 2, '2026-03-22 20:22:00', 1),
(10, 6, 6, 'REGISTRO', 'SEG-20260323-000006_registro_20260323_145000_0006.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260323-000006_registro_20260323_145000_0006.pdf', 'ENVIADO', 'flaura2705@gmail.com', '2026-03-23 14:52:00', 'Reporte de salida enviado correctamente al correo del chofer.', 1, '2026-03-23 14:50:00', 1);

INSERT INTO `reportes_traslado` (`id_reporte`, `id_ayuda`, `id_seguridad`, `id_despacho_unidad`, `id_usuario_operador`, `id_empleado_chofer`, `id_unidad`, `ticket_interno`, `fecha_hora`, `diagnostico_paciente`, `foto_evidencia`, `km_salida`, `km_llegada`, `estado`) VALUES
(1, NULL, 1, 1, 2, 7, 3, 'SEG-20260303-000001', '2026-03-03 10:10:00', 'Paciente estabilizada y entregada en urgencias con signos vitales compensados.', 'uploads/reportes_traslado/seguridad_20260303_101000_0001.jpg', 24120, 24138, 1),
(2, NULL, 2, 2, 1, 8, 4, 'SEG-20260305-000002', '2026-03-05 19:32:00', 'Traumatismo leve en hombro derecho, paciente referido para rayos X.', 'uploads/reportes_traslado/seguridad_20260305_193200_0002.png', 18344, 18360, 1),
(3, NULL, 3, 3, 2, 9, 5, 'SEG-20260307-000003', '2026-03-07 08:05:00', 'Crisis asmatica controlada con respuesta favorable a nebulizacion inicial.', 'uploads/reportes_traslado/seguridad_20260307_080500_0003.jpg', 19872, 19888, 1),
(4, NULL, 4, 4, 1, 1, 1, 'SEG-20260310-000004', '2026-03-10 12:42:00', 'Paciente entregada en sala de parto con signos estables.', 'uploads/reportes_traslado/seguridad_20260310_124200_0004.png', 24138, 24149, 1);

INSERT INTO `seguimientos_solicitudes` (`id_seguimiento_solicitud`, `modulo`, `id_referencia`, `id_estado_solicitud`, `id_usuario`, `fecha_gestion`, `observacion`, `estado`) VALUES
(1, 'AYUDA_SOCIAL', 1, 1, 1, '2026-02-18 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(2, 'AYUDA_SOCIAL', 1, 3, 1, '2026-02-20 14:00:00', 'Solicitud resuelta y apoyo entregado al beneficiario.', 1),
(3, 'AYUDA_SOCIAL', 2, 1, 2, '2026-02-20 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(4, 'AYUDA_SOCIAL', 2, 2, 2, '2026-02-20 11:30:00', 'Caso canalizado a la dependencia social para seguimiento.', 1),
(5, 'AYUDA_SOCIAL', 3, 1, 3, '2026-02-22 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(6, 'AYUDA_SOCIAL', 4, 1, 1, '2026-02-24 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(7, 'AYUDA_SOCIAL', 4, 3, 1, '2026-02-26 14:00:00', 'Solicitud resuelta y apoyo entregado al beneficiario.', 1),
(8, 'AYUDA_SOCIAL', 5, 1, 2, '2026-02-26 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(9, 'AYUDA_SOCIAL', 5, 2, 2, '2026-02-26 11:30:00', 'Caso canalizado a la dependencia social para seguimiento.', 1),
(10, 'AYUDA_SOCIAL', 6, 1, 3, '2026-02-28 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(11, 'AYUDA_SOCIAL', 6, 3, 3, '2026-03-02 14:00:00', 'Solicitud resuelta y apoyo entregado al beneficiario.', 1),
(12, 'AYUDA_SOCIAL', 7, 1, 1, '2026-03-02 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(13, 'AYUDA_SOCIAL', 7, 4, 1, '2026-03-05 16:00:00', 'Solicitud cerrada sin disponibilidad operativa inmediata.', 1),
(14, 'AYUDA_SOCIAL', 8, 1, 2, '2026-03-04 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(15, 'AYUDA_SOCIAL', 8, 3, 2, '2026-03-06 14:00:00', 'Solicitud resuelta y apoyo entregado al beneficiario.', 1),
(16, 'AYUDA_SOCIAL', 9, 1, 3, '2026-03-06 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(17, 'AYUDA_SOCIAL', 9, 2, 3, '2026-03-06 11:30:00', 'Caso canalizado a la dependencia social para seguimiento.', 1),
(18, 'AYUDA_SOCIAL', 10, 1, 1, '2026-03-08 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(19, 'AYUDA_SOCIAL', 10, 3, 1, '2026-03-10 14:00:00', 'Solicitud resuelta y apoyo entregado al beneficiario.', 1),
(20, 'AYUDA_SOCIAL', 11, 1, 2, '2026-03-10 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(21, 'AYUDA_SOCIAL', 12, 1, 3, '2026-03-12 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(22, 'AYUDA_SOCIAL', 12, 3, 3, '2026-03-14 14:00:00', 'Solicitud resuelta y apoyo entregado al beneficiario.', 1),
(23, 'AYUDA_SOCIAL', 13, 1, 1, '2026-03-14 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(24, 'AYUDA_SOCIAL', 13, 3, 1, '2026-03-16 14:00:00', 'Solicitud resuelta y apoyo entregado al beneficiario.', 1),
(25, 'AYUDA_SOCIAL', 14, 1, 2, '2026-03-16 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(26, 'AYUDA_SOCIAL', 14, 4, 2, '2026-03-19 16:00:00', 'Solicitud cerrada sin disponibilidad operativa inmediata.', 1),
(27, 'AYUDA_SOCIAL', 15, 1, 3, '2026-03-18 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(28, 'AYUDA_SOCIAL', 15, 2, 3, '2026-03-18 11:30:00', 'Caso canalizado a la dependencia social para seguimiento.', 1),
(29, 'AYUDA_SOCIAL', 16, 1, 1, '2026-03-20 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(30, 'AYUDA_SOCIAL', 16, 3, 1, '2026-03-22 14:00:00', 'Solicitud resuelta y apoyo entregado al beneficiario.', 1),
(31, 'AYUDA_SOCIAL', 17, 1, 2, '2026-03-22 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(32, 'AYUDA_SOCIAL', 18, 1, 3, '2026-03-24 08:00:00', 'Solicitud registrada en ayuda social.', 1),
(33, 'AYUDA_SOCIAL', 18, 3, 3, '2026-03-26 14:00:00', 'Solicitud resuelta y apoyo entregado al beneficiario.', 1),
(34, 'SERVICIOS_PUBLICOS', 1, 1, 2, '2026-02-19 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(35, 'SERVICIOS_PUBLICOS', 1, 3, 2, '2026-02-20 15:15:00', 'Solicitud atendida y gestion cerrada en sitio.', 1),
(36, 'SERVICIOS_PUBLICOS', 2, 1, 3, '2026-02-21 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(37, 'SERVICIOS_PUBLICOS', 2, 2, 3, '2026-02-21 10:45:00', 'Solicitud remitida a cuadrilla operativa para programacion.', 1),
(38, 'SERVICIOS_PUBLICOS', 3, 1, 1, '2026-02-23 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(39, 'SERVICIOS_PUBLICOS', 3, 3, 1, '2026-02-24 15:15:00', 'Solicitud atendida y gestion cerrada en sitio.', 1),
(40, 'SERVICIOS_PUBLICOS', 4, 1, 2, '2026-02-25 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(41, 'SERVICIOS_PUBLICOS', 5, 1, 3, '2026-02-27 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(42, 'SERVICIOS_PUBLICOS', 5, 2, 3, '2026-02-27 10:45:00', 'Solicitud remitida a cuadrilla operativa para programacion.', 1),
(43, 'SERVICIOS_PUBLICOS', 6, 1, 1, '2026-03-01 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(44, 'SERVICIOS_PUBLICOS', 6, 3, 1, '2026-03-02 15:15:00', 'Solicitud atendida y gestion cerrada en sitio.', 1),
(45, 'SERVICIOS_PUBLICOS', 7, 1, 2, '2026-03-03 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(46, 'SERVICIOS_PUBLICOS', 7, 4, 2, '2026-03-06 17:00:00', 'Solicitud cerrada por falta de disponibilidad presupuestaria.', 1),
(47, 'SERVICIOS_PUBLICOS', 8, 1, 3, '2026-03-05 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(48, 'SERVICIOS_PUBLICOS', 8, 3, 3, '2026-03-06 15:15:00', 'Solicitud atendida y gestion cerrada en sitio.', 1),
(49, 'SERVICIOS_PUBLICOS', 9, 1, 1, '2026-03-07 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(50, 'SERVICIOS_PUBLICOS', 9, 2, 1, '2026-03-07 10:45:00', 'Solicitud remitida a cuadrilla operativa para programacion.', 1),
(51, 'SERVICIOS_PUBLICOS', 10, 1, 2, '2026-03-09 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(52, 'SERVICIOS_PUBLICOS', 10, 3, 2, '2026-03-10 15:15:00', 'Solicitud atendida y gestion cerrada en sitio.', 1),
(53, 'SERVICIOS_PUBLICOS', 11, 1, 3, '2026-03-11 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(54, 'SERVICIOS_PUBLICOS', 12, 1, 1, '2026-03-13 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(55, 'SERVICIOS_PUBLICOS', 12, 3, 1, '2026-03-14 15:15:00', 'Solicitud atendida y gestion cerrada en sitio.', 1),
(56, 'SERVICIOS_PUBLICOS', 13, 1, 2, '2026-03-15 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(57, 'SERVICIOS_PUBLICOS', 13, 3, 2, '2026-03-16 15:15:00', 'Solicitud atendida y gestion cerrada en sitio.', 1),
(58, 'SERVICIOS_PUBLICOS', 14, 1, 3, '2026-03-17 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(59, 'SERVICIOS_PUBLICOS', 14, 4, 3, '2026-03-20 17:00:00', 'Solicitud cerrada por falta de disponibilidad presupuestaria.', 1),
(60, 'SERVICIOS_PUBLICOS', 15, 1, 1, '2026-03-19 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(61, 'SERVICIOS_PUBLICOS', 15, 3, 1, '2026-03-20 15:15:00', 'Solicitud atendida y gestion cerrada en sitio.', 1),
(62, 'SERVICIOS_PUBLICOS', 16, 1, 2, '2026-03-21 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(63, 'SERVICIOS_PUBLICOS', 16, 2, 2, '2026-03-21 10:45:00', 'Solicitud remitida a cuadrilla operativa para programacion.', 1),
(64, 'SERVICIOS_PUBLICOS', 17, 1, 3, '2026-03-23 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(65, 'SERVICIOS_PUBLICOS', 17, 3, 3, '2026-03-24 15:15:00', 'Solicitud atendida y gestion cerrada en sitio.', 1),
(66, 'SERVICIOS_PUBLICOS', 18, 1, 1, '2026-03-25 08:30:00', 'Solicitud registrada en servicios publicos.', 1),
(67, 'SEGURIDAD', 1, 1, 2, '2026-03-03 08:20:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(68, 'SEGURIDAD', 1, 2, 2, '2026-03-03 08:28:00', 'Solicitud en gestion operativa con unidad y chofer asignados.', 1),
(69, 'SEGURIDAD', 1, 3, 2, '2026-03-03 10:10:00', 'Solicitud finalizada con cierre operativo y traslado documentado.', 1),
(70, 'SEGURIDAD', 2, 1, 1, '2026-03-05 18:05:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(71, 'SEGURIDAD', 2, 2, 1, '2026-03-05 18:12:00', 'Solicitud en gestion operativa con unidad y chofer asignados.', 1),
(72, 'SEGURIDAD', 2, 3, 1, '2026-03-05 19:32:00', 'Solicitud finalizada con cierre operativo y traslado documentado.', 1),
(73, 'SEGURIDAD', 3, 1, 2, '2026-03-07 06:45:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(74, 'SEGURIDAD', 3, 2, 2, '2026-03-07 06:51:00', 'Solicitud en gestion operativa con unidad y chofer asignados.', 1),
(75, 'SEGURIDAD', 3, 3, 2, '2026-03-07 08:05:00', 'Solicitud finalizada con cierre operativo y traslado documentado.', 1),
(76, 'SEGURIDAD', 4, 1, 1, '2026-03-10 11:30:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(77, 'SEGURIDAD', 4, 2, 1, '2026-03-10 11:37:00', 'Solicitud en gestion operativa con unidad y chofer asignados.', 1),
(78, 'SEGURIDAD', 4, 3, 1, '2026-03-10 12:42:00', 'Solicitud finalizada con cierre operativo y traslado documentado.', 1),
(79, 'SEGURIDAD', 5, 1, 2, '2026-03-22 20:15:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(80, 'SEGURIDAD', 5, 2, 2, '2026-03-22 20:22:00', 'Solicitud en gestion operativa con unidad y chofer asignados.', 1),
(81, 'SEGURIDAD', 6, 1, 1, '2026-03-23 14:40:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(82, 'SEGURIDAD', 6, 2, 1, '2026-03-23 14:50:00', 'Solicitud en gestion operativa con unidad y chofer asignados.', 1),
(83, 'SEGURIDAD', 7, 1, 2, '2026-03-23 07:10:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(84, 'SEGURIDAD', 7, 2, 2, '2026-03-23 07:20:00', 'Caso en espera de unidad operativa disponible.', 1),
(85, 'SEGURIDAD', 8, 1, 4, '2026-03-12 09:00:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(86, 'SEGURIDAD', 8, 3, 4, '2026-03-12 11:00:00', 'Gestion cerrada por el equipo operativo correspondiente.', 1),
(87, 'SEGURIDAD', 9, 1, 4, '2026-03-13 22:10:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(88, 'SEGURIDAD', 10, 1, 2, '2026-03-15 17:35:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(89, 'SEGURIDAD', 10, 3, 2, '2026-03-15 19:35:00', 'Gestion cerrada por el equipo operativo correspondiente.', 1),
(90, 'SEGURIDAD', 11, 1, 2, '2026-03-16 13:25:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(91, 'SEGURIDAD', 11, 3, 2, '2026-03-16 15:25:00', 'Gestion cerrada por el equipo operativo correspondiente.', 1),
(92, 'SEGURIDAD', 12, 1, 4, '2026-03-18 19:10:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(93, 'SEGURIDAD', 13, 1, 1, '2026-03-19 06:30:00', 'Solicitud registrada en seguridad y emergencia.', 1),
(94, 'SEGURIDAD', 13, 3, 1, '2026-03-19 08:30:00', 'Gestion cerrada por el equipo operativo correspondiente.', 1),
(95, 'SEGURIDAD', 14, 1, 4, '2026-03-20 03:50:00', 'Solicitud registrada en seguridad y emergencia.', 1);

INSERT INTO `seguridad` (`id_seguridad`, `ticket_interno`, `id_beneficiario`, `id_usuario`, `id_tipo_seguridad`, `id_solicitud_seguridad`, `id_estado_solicitud`, `tipo_seguridad`, `tipo_solicitud`, `fecha_seguridad`, `descripcion`, `estado_atencion`, `ubicacion_evento`, `referencia_evento`, `estado`) VALUES
(1, 'SEG-20260303-000001', 1, 2, 4, 2, 3, 'Atencion prehospitalaria', 'Atencion al ciudadano', '2026-03-03 08:20:00', 'Paciente femenina de 67 anos con crisis hipertensiva y mareos persistentes.', 'FINALIZADO', 'Sector 12 de Octubre, calle principal', 'Frente al ambulatorio popular', 1),
(2, 'SEG-20260305-000002', 6, 1, 4, 1, 3, 'Atencion prehospitalaria', '1X10', '2026-03-05 18:05:00', 'Adulto masculino lesionado por caida de moto con dolor en hombro y escoriaciones.', 'FINALIZADO', 'Avenida principal de La Honda', 'Cerca del puente peatonal', 1),
(3, 'SEG-20260307-000003', 9, 2, 4, 3, 3, 'Atencion prehospitalaria', 'Redes sociales', '2026-03-07 06:45:00', 'Nino con dificultad respiratoria y antecedentes de asma bronquial.', 'FINALIZADO', 'Comunidad Nueva Villa', 'Casa azul junto a la bodega', 1),
(4, 'SEG-20260310-000004', 13, 1, 4, 2, 3, 'Atencion prehospitalaria', 'Atencion al ciudadano', '2026-03-10 11:30:00', 'Gestante con contracciones regulares y dolor abdominal en fase activa.', 'FINALIZADO', 'Urbanizacion Villa Jardin', 'Edificio 3, planta baja', 1),
(5, 'SEG-20260322-000005', 15, 2, 4, 1, 2, 'Atencion prehospitalaria', '1X10', '2026-03-22 20:15:00', 'Adulto mayor con dolor toracico y dificultad para caminar.', 'DESPACHADO', 'Casco Comercial de Tocuyito', 'Frente a la farmacia principal', 1),
(6, 'SEG-20260323-000006', 18, 1, 4, 3, 2, 'Atencion prehospitalaria', 'Redes sociales', '2026-03-23 14:40:00', 'Paciente con hipoglucemia reportada por familiares y mareo intenso.', 'DESPACHADO', 'Urbanizacion Jose Rafael Pocaterra', 'Casa 14, calle A', 1),
(7, 'SEG-20260323-000007', 21, 2, 4, 2, 2, 'Atencion prehospitalaria', 'Atencion al ciudadano', '2026-03-23 07:10:00', 'Adulto mayor con sospecha de deshidratacion mientras se libera una unidad.', 'PENDIENTE_UNIDAD', 'Barrio El Oasis', 'Cancha techada', 1),
(8, 'SEG-20260312-000008', 23, 4, 6, 2, 3, 'Hurto', 'Atencion al ciudadano', '2026-03-12 09:00:00', 'Denuncia de hurto de cableado residencial con afectacion de servicio domestico.', 'FINALIZADO', 'Santa Eduviges', 'Detras de la casa comunal', 1),
(9, 'SEG-20260313-000009', 24, 4, 5, 1, 1, 'Robo de vehiculo', '1X10', '2026-03-13 22:10:00', 'Reporte de robo de motocicleta al salir de jornada laboral nocturna.', 'REGISTRADO', 'Zanjon Dulce', 'Cerca de la parada de autobuses', 1),
(10, 'SEG-20260315-000010', 25, 2, 8, 3, 3, 'Riesgo de vias publicas', 'Redes sociales', '2026-03-15 17:35:00', 'Arbol inclinado sobre vialidad con riesgo de caida sobre peatones.', 'FINALIZADO', 'Los Mangos', 'Frente a la escuela tecnica', 1),
(11, 'SEG-20260316-000011', 26, 2, 11, 2, 3, 'Reubicacion de insectos', 'Atencion al ciudadano', '2026-03-16 13:25:00', 'Avispero activo en techo de vivienda multifamiliar.', 'FINALIZADO', 'Urbanizacion La Esperanza', 'Casa esquinera color beige', 1),
(12, 'SEG-20260318-000012', 27, 4, 9, 3, 1, 'Maltrato domestico', 'Redes sociales', '2026-03-18 19:10:00', 'Vecinos reportan presunta situacion de violencia intrafamiliar.', 'REGISTRADO', 'Colinas del Rosario', 'Pasillo 4 del conjunto residencial', 1),
(13, 'SEG-20260319-000013', 28, 1, 1, 1, 3, 'Guardia y seguridad', '1X10', '2026-03-19 06:30:00', 'Solicitud de apoyo preventivo por evento comunitario con alta asistencia.', 'FINALIZADO', 'Comunidad Bicentenario', 'Plaza central', 1),
(14, 'SEG-20260320-000014', 29, 4, 7, 2, 1, 'Robo de inmueble', 'Atencion al ciudadano', '2026-03-20 03:50:00', 'Reporte de intrusion nocturna en vivienda desocupada parcialmente.', 'REGISTRADO', 'Banco Obrero Las Palmas', 'Casa 8, vereda final', 1);

INSERT INTO `servicios_publicos` (`id_servicio`, `ticket_interno`, `id_beneficiario`, `id_usuario`, `id_tipo_servicio_publico`, `id_solicitud_servicio_publico`, `id_estado_solicitud`, `tipo_servicio`, `solicitud_servicio`, `fecha_servicio`, `descripcion`, `estado`) VALUES
(1, 'SPU-20260219-000001', 6, 2, 1, 2, 3, 'Agua', 'Atencion al ciudadano', '2026-02-19', 'Fuga de agua blanca en tuberia principal cercana a la escuela del sector.', 1),
(2, 'SPU-20260221-000002', 7, 3, 2, 3, 2, 'Aguas Negras', 'Redes sociales', '2026-02-21', 'Desborde de aguas negras en calle ciega con afectacion de varias viviendas.', 1),
(3, 'SPU-20260223-000003', 8, 1, 3, 1, 3, 'Alumbrado Publico', '1X10', '2026-02-23', 'Luminarias apagadas en corredor peatonal de alta circulacion nocturna.', 1),
(4, 'SPU-20260225-000004', 9, 2, 4, 2, 1, 'Ambiente', 'Atencion al ciudadano', '2026-02-25', 'Acumulacion de desechos vegetales en espacio comunal.', 1),
(5, 'SPU-20260227-000005', 10, 3, 5, 3, 2, 'Asfaltado', 'Redes sociales', '2026-02-27', 'Bache de gran tamano en vialidad principal con riesgo para motorizados.', 1),
(6, 'SPU-20260301-000006', 11, 1, 6, 1, 3, 'Canos y Embaulamiento', '1X10', '2026-03-01', 'Limpieza y desobstruccion de cano lateral antes del periodo de lluvias.', 1),
(7, 'SPU-20260303-000007', 12, 2, 7, 2, 4, 'Energia', 'Atencion al ciudadano', '2026-03-03', 'Variacion de voltaje reportada en manzana con transformador sobrecargado.', 1),
(8, 'SPU-20260305-000008', 13, 3, 8, 3, 3, 'Infraestructura', 'Redes sociales', '2026-03-05', 'Reparacion de filtracion en techo de modulo comunal.', 1),
(9, 'SPU-20260307-000009', 14, 1, 9, 1, 2, 'Pica y Poda', '1X10', '2026-03-07', 'Ramas sobre tendido electrico con riesgo de caida por vientos.', 1),
(10, 'SPU-20260309-000010', 15, 2, 10, 2, 3, 'Vial', 'Atencion al ciudadano', '2026-03-09', 'Se requiere demarcacion y reparacion parcial de paso peatonal.', 1),
(11, 'SPU-20260311-000011', 16, 3, 1, 3, 1, 'Agua', 'Redes sociales', '2026-03-11', 'Baja presion de agua en zona alta de la comunidad durante la tarde.', 1),
(12, 'SPU-20260313-000012', 17, 1, 3, 1, 3, 'Alumbrado Publico', '1X10', '2026-03-13', 'Reposicion de reflector en cancha multiple para jornada nocturna.', 1),
(13, 'SPU-20260315-000013', 18, 2, 5, 2, 3, 'Asfaltado', 'Atencion al ciudadano', '2026-03-15', 'Hundimiento de calzada cerca de parada de transporte publico.', 1),
(14, 'SPU-20260317-000014', 19, 3, 8, 3, 4, 'Infraestructura', 'Redes sociales', '2026-03-17', 'Solicitud de rehabilitacion integral de plaza sin presupuesto asignado.', 1),
(15, 'SPU-20260319-000015', 20, 1, 9, 1, 3, 'Pica y Poda', '1X10', '2026-03-19', 'Poda preventiva de arboles frente a preescolar municipal.', 1),
(16, 'SPU-20260321-000016', 21, 2, 6, 2, 2, 'Canos y Embaulamiento', 'Atencion al ciudadano', '2026-03-21', 'Sedimentacion en embaulamiento con necesidad de maquinaria liviana.', 1),
(17, 'SPU-20260323-000017', 22, 3, 7, 3, 3, 'Energia', 'Redes sociales', '2026-03-23', 'Reposicion de fusible y chequeo de acometida en sector residencial.', 1),
(18, 'SPU-20260325-000018', 23, 1, 10, 1, 1, 'Vial', '1X10', '2026-03-25', 'Solicitud de reductores de velocidad frente a centro educativo.', 1);

INSERT INTO `solicitudes_generales` (`id_solicitud_general`, `codigo_solicitud`, `nombre_solicitud`, `estado`, `fecha_registro`) VALUES
(1, 'SOL-1X10', '1X10', 1, '2026-03-13 23:43:24'),
(2, 'SOL-ATC', 'Atencion al ciudadano', 1, '2026-03-13 23:43:24'),
(3, 'SOL-RDS', 'Redes sociales', 1, '2026-03-13 23:43:24');

INSERT INTO `tipos_ayuda_social` (`id_tipo_ayuda_social`, `nombre_tipo_ayuda`, `requiere_ambulancia`, `estado`, `fecha_registro`) VALUES
(1, 'Medicas', 0, 1, '2026-03-13 13:11:42'),
(2, 'Tecnicas', 0, 1, '2026-03-13 13:11:42'),
(3, 'Sociales', 0, 1, '2026-03-13 13:11:42'),
(4, 'Guardia y seguridad', 0, 1, '2026-03-17 13:02:26'),
(5, 'Supresion de incendio', 0, 1, '2026-03-17 13:02:26'),
(6, 'Traslado', 1, 1, '2026-03-17 13:02:26'),
(7, 'Atencion prehospitalaria', 1, 1, '2026-03-17 13:02:26'),
(8, 'Robo de vehiculo', 0, 1, '2026-03-17 13:02:26'),
(9, 'Hurto', 0, 1, '2026-03-17 13:02:26'),
(10, 'Robo de inmueble', 0, 1, '2026-03-17 13:02:26'),
(11, 'Riesgo de vias publicas', 0, 1, '2026-03-17 13:02:26'),
(12, 'Maltrato domestico', 0, 1, '2026-03-17 13:02:26'),
(13, 'Atraco a mano armada', 0, 1, '2026-03-17 13:02:26'),
(14, 'Reubicacion de insectos', 0, 1, '2026-03-17 13:02:26');

INSERT INTO `tipos_seguridad_emergencia` (`id_tipo_seguridad`, `nombre_tipo`, `requiere_ambulancia`, `estado`, `fecha_registro`) VALUES
(1, 'Guardia y seguridad', 0, 1, '2026-03-13 14:34:52'),
(2, 'Supresion de incendio', 0, 1, '2026-03-13 14:34:52'),
(3, 'Traslado', 1, 1, '2026-03-13 14:34:52'),
(4, 'Atencion prehospitalaria', 1, 1, '2026-03-13 14:34:52'),
(5, 'Robo de vehiculo', 0, 1, '2026-03-13 14:34:52'),
(6, 'Hurto', 0, 1, '2026-03-13 14:34:52'),
(7, 'Robo de inmueble', 0, 1, '2026-03-13 14:34:52'),
(8, 'Riesgo de vias publicas', 0, 1, '2026-03-13 14:34:52'),
(9, 'Maltrato domestico', 0, 1, '2026-03-13 14:34:52'),
(10, 'Atraco a mano armada', 0, 1, '2026-03-13 14:34:52'),
(11, 'Reubicacion de insectos', 0, 1, '2026-03-13 14:34:52');

INSERT INTO `tipos_servicios_publicos` (`id_tipo_servicio_publico`, `codigo_tipo_servicio_publico`, `nombre_tipo_servicio`, `estado`, `fecha_registro`) VALUES
(1, 'SP-AGU', 'Agua', 1, '2026-03-13 16:15:26'),
(2, 'SP-AGN', 'Aguas Negras', 1, '2026-03-13 16:15:26'),
(3, 'SP-ALU', 'Alumbrado Publico', 1, '2026-03-13 16:15:26'),
(4, 'SP-AMB', 'Ambiente', 1, '2026-03-13 16:15:26'),
(5, 'SP-ASF', 'Asfaltado', 1, '2026-03-13 16:15:26'),
(6, 'SP-CAN', 'Canos y Embaulamiento', 1, '2026-03-13 16:15:26'),
(7, 'SP-ENE', 'Energia', 1, '2026-03-13 16:15:26'),
(8, 'SP-INF', 'Infraestructura', 1, '2026-03-13 16:15:26'),
(9, 'SP-PYP', 'Pica y Poda', 1, '2026-03-13 16:15:26'),
(10, 'SP-VIA', 'Vial', 1, '2026-03-13 16:15:26');

INSERT INTO `unidades` (`id_unidad`, `codigo_unidad`, `descripcion`, `placa`, `estado`, `estado_operativo`, `ubicacion_actual`, `referencia_actual`, `prioridad_despacho`, `fecha_actualizacion_operativa`) VALUES
(1, 'AMB-001', 'Ambulancia Ford Transit', 'AB7C21D', 1, 'EN_SERVICIO', 'Hospital de Tocuyito', 'Area de urgencias', 1, '2026-03-22 20:22:00'),
(2, 'AMB-002', 'Ambulancia Toyota Hiace', 'AC4G91M', 1, 'EN_SERVICIO', 'Urbanizacion Jose Rafael Pocaterra', 'Frente al modulo policial', 2, '2026-03-23 14:50:00'),
(3, 'AMB-003', 'Ambulancia Iveco Daily', 'AD2L44R', 1, 'DISPONIBLE', 'Base central', 'Patio operacional', 3, '2026-03-21 09:40:00'),
(4, 'AMB-004', 'Ambulancia Mercedes Sprinter', 'AE6J12K', 1, 'DISPONIBLE', 'CDI El Oasis', 'Area de espera', 4, '2026-03-20 16:30:00'),
(5, 'AMB-005', 'Ambulancia Chevrolet Express', 'AF8P33T', 1, 'DISPONIBLE', 'Parroquia Independencia', 'Puesto sanitario movil', 5, '2026-03-18 11:20:00'),
(6, 'AMB-006', 'Unidad de respuesta rapida', 'AG1N58Q', 1, 'FUERA_SERVICIO', 'Taller municipal', 'Revision de frenos', 6, '2026-03-17 08:10:00');

INSERT INTO `usuarios` (`id_usuario`, `id_empleado`, `usuario`, `password`, `rol`, `estado`) VALUES
(1, 3, 'admin', '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225', 'ADMIN', 1),
(2, 4, 'operador.sala', '163c228e938c409a30b29992fe3cf9856c4b8480af5b0900c9d384d541566888', 'OPERADOR', 1),
(3, 5, 'atencion.ciudadana', '163c228e938c409a30b29992fe3cf9856c4b8480af5b0900c9d384d541566888', 'OPERADOR', 1),
(4, 6, 'consulta.tribunal', '163c228e938c409a30b29992fe3cf9856c4b8480af5b0900c9d384d541566888', 'CONSULTOR', 1);

INSERT INTO `usuarios_seguridad_acceso` (`id_usuario`, `intentos_fallidos`, `bloqueado`, `fecha_bloqueo`, `password_temporal`, `fecha_password_temporal`, `fecha_actualizacion`) VALUES
(1, 0, 0, NULL, 1, '2026-03-18 21:55:11', '2026-03-18 21:55:11'),
(2, 0, 0, NULL, 0, NULL, '2026-03-20 08:00:00'),
(3, 0, 0, NULL, 0, NULL, '2026-03-20 08:05:00'),
(4, 1, 0, NULL, 0, NULL, '2026-03-21 10:00:00');

INSERT INTO `usuario_permisos` (`id_usuario_permiso`, `id_usuario`, `id_permiso`, `estado`) VALUES
(1, 1, 1, 1),
(2, 1, 2, 1),
(3, 1, 3, 1),
(4, 1, 4, 1),
(5, 1, 5, 1),
(6, 1, 6, 1),
(7, 1, 7, 1),
(8, 1, 8, 1),
(9, 1, 99, 1),
(10, 2, 1, 1),
(11, 2, 2, 1),
(12, 2, 3, 1),
(13, 2, 4, 1),
(14, 2, 5, 1),
(15, 2, 7, 1),
(16, 2, 8, 1),
(17, 3, 1, 1),
(18, 3, 3, 1),
(19, 3, 5, 1),
(20, 4, 2, 1),
(21, 4, 7, 1);

ALTER TABLE `asignaciones_unidades_choferes`
  ADD PRIMARY KEY (`id_asignacion_unidad_chofer`),
  ADD KEY `idx_asignaciones_unidades_choferes_unidad` (`id_unidad`,`estado`),
  ADD KEY `idx_asignaciones_unidades_choferes_chofer` (`id_chofer_ambulancia`,`estado`);

ALTER TABLE `ayuda_social`
  ADD PRIMARY KEY (`id_ayuda`),
  ADD KEY `fk_as_benef` (`id_beneficiario`),
  ADD KEY `fk_as_user` (`id_usuario`),
  ADD KEY `idx_ayuda_social_id_tipo_ayuda_social` (`id_tipo_ayuda_social`),
  ADD KEY `idx_ayuda_social_id_solicitud_ayuda_social` (`id_solicitud_ayuda_social`),
  ADD KEY `idx_ayuda_social_estado_solicitud` (`id_estado_solicitud`);

ALTER TABLE `beneficiarios`
  ADD PRIMARY KEY (`id_beneficiario`),
  ADD UNIQUE KEY `cedula` (`cedula`),
  ADD KEY `idx_beneficiarios_id_comunidad` (`id_comunidad`);

ALTER TABLE `bitacora`
  ADD PRIMARY KEY (`id_bitacora`),
  ADD KEY `fk_bit_user` (`id_usuario`),
  ADD KEY `idx_bitacora_tabla_accion_fecha` (`tabla_afectada`,`accion`,`fecha_evento`),
  ADD KEY `idx_bitacora_tabla_registro` (`tabla_afectada`,`id_registro`);

ALTER TABLE `choferes_ambulancia`
  ADD PRIMARY KEY (`id_chofer_ambulancia`),
  ADD UNIQUE KEY `uk_choferes_ambulancia_empleado` (`id_empleado`),
  ADD KEY `idx_choferes_ambulancia_estado` (`estado`,`id_empleado`);

ALTER TABLE `comunidades`
  ADD PRIMARY KEY (`id_comunidad`),
  ADD UNIQUE KEY `uk_comunidad_nombre` (`nombre_comunidad`),
  ADD KEY `idx_comunidades_estado_nombre` (`estado`,`nombre_comunidad`);

ALTER TABLE `configuracion_smtp`
  ADD PRIMARY KEY (`id_configuracion_smtp`),
  ADD KEY `idx_configuracion_smtp_estado` (`estado`,`id_configuracion_smtp`),
  ADD KEY `idx_configuracion_smtp_usuario` (`id_usuario_actualiza`);

ALTER TABLE `dependencias`
  ADD PRIMARY KEY (`id_dependencia`),
  ADD UNIQUE KEY `uk_dependencias_nombre` (`nombre_dependencia`),
  ADD KEY `idx_dependencias_estado_nombre` (`estado`,`nombre_dependencia`);

ALTER TABLE `despachos_unidades`
  ADD PRIMARY KEY (`id_despacho_unidad`),
  ADD KEY `idx_despachos_unidades_seguridad` (`id_seguridad`,`estado_despacho`),
  ADD KEY `idx_despachos_unidades_unidad` (`id_unidad`,`estado_despacho`),
  ADD KEY `idx_despachos_unidades_chofer` (`id_chofer_ambulancia`,`estado_despacho`),
  ADD KEY `fk_despachos_usuarios` (`id_usuario_asigna`);

ALTER TABLE `empleados`
  ADD PRIMARY KEY (`id_empleado`),
  ADD UNIQUE KEY `cedula` (`cedula`),
  ADD KEY `fk_emp_dependencia` (`id_dependencia`),
  ADD KEY `idx_empleados_estado_nombre` (`estado`,`apellido`,`nombre`),
  ADD KEY `idx_empleados_dependencia` (`id_dependencia`);

ALTER TABLE `estados_solicitudes`
  ADD PRIMARY KEY (`id_estado_solicitud`),
  ADD UNIQUE KEY `uk_estados_solicitudes_codigo` (`codigo_estado`),
  ADD UNIQUE KEY `uk_estados_solicitudes_nombre` (`nombre_estado`);

ALTER TABLE `permisos`
  ADD PRIMARY KEY (`id_permiso`),
  ADD UNIQUE KEY `nombre_permiso` (`nombre_permiso`),
  ADD KEY `idx_permisos_estado_nombre` (`estado`,`nombre_permiso`);

ALTER TABLE `reportes_solicitudes_ambulancia`
  ADD PRIMARY KEY (`id_reporte_solicitud`),
  ADD KEY `idx_rsa_seguridad` (`id_seguridad`,`estado`,`tipo_reporte`),
  ADD KEY `idx_rsa_despacho` (`id_despacho_unidad`),
  ADD KEY `idx_rsa_usuario` (`id_usuario_genera`),
  ADD KEY `idx_rsa_envio` (`estado_envio`,`fecha_envio`);

ALTER TABLE `reportes_traslado`
  ADD PRIMARY KEY (`id_reporte`),
  ADD KEY `fk_rep_ayuda_final` (`id_ayuda`),
  ADD KEY `fk_rep_user_final` (`id_usuario_operador`),
  ADD KEY `fk_rep_unit_final` (`id_unidad`),
  ADD KEY `fk_rep_seguridad` (`id_seguridad`),
  ADD KEY `fk_rep_chofer_emp` (`id_empleado_chofer`),
  ADD KEY `idx_reportes_traslado_id_despacho_unidad` (`id_despacho_unidad`);

ALTER TABLE `seguimientos_solicitudes`
  ADD PRIMARY KEY (`id_seguimiento_solicitud`),
  ADD KEY `idx_seguimientos_modulo_referencia` (`modulo`,`id_referencia`),
  ADD KEY `idx_seguimientos_estado` (`id_estado_solicitud`),
  ADD KEY `idx_seguimientos_usuario` (`id_usuario`);

ALTER TABLE `seguridad`
  ADD PRIMARY KEY (`id_seguridad`),
  ADD KEY `fk_seg_benef` (`id_beneficiario`),
  ADD KEY `idx_seg_id_usuario` (`id_usuario`),
  ADD KEY `idx_seguridad_id_tipo_seguridad` (`id_tipo_seguridad`),
  ADD KEY `idx_seguridad_id_solicitud_seguridad` (`id_solicitud_seguridad`),
  ADD KEY `idx_seguridad_estado_solicitud` (`id_estado_solicitud`);

ALTER TABLE `servicios_publicos`
  ADD PRIMARY KEY (`id_servicio`),
  ADD KEY `fk_ser_benef` (`id_beneficiario`),
  ADD KEY `idx_ser_id_usuario` (`id_usuario`),
  ADD KEY `idx_servicios_publicos_id_tipo_servicio_publico` (`id_tipo_servicio_publico`),
  ADD KEY `idx_servicios_publicos_id_solicitud_servicio_publico` (`id_solicitud_servicio_publico`),
  ADD KEY `idx_servicios_publicos_estado_solicitud` (`id_estado_solicitud`);

ALTER TABLE `solicitudes_generales`
  ADD PRIMARY KEY (`id_solicitud_general`),
  ADD UNIQUE KEY `uk_solicitudes_generales_codigo` (`codigo_solicitud`),
  ADD UNIQUE KEY `uk_solicitudes_generales_nombre` (`nombre_solicitud`),
  ADD KEY `idx_solicitudes_generales_estado_codigo_nombre` (`estado`,`codigo_solicitud`,`nombre_solicitud`);

ALTER TABLE `tipos_ayuda_social`
  ADD PRIMARY KEY (`id_tipo_ayuda_social`),
  ADD UNIQUE KEY `uk_tipos_ayuda_social_nombre` (`nombre_tipo_ayuda`),
  ADD KEY `idx_tipos_ayuda_social_estado_nombre` (`estado`,`nombre_tipo_ayuda`);

ALTER TABLE `tipos_seguridad_emergencia`
  ADD PRIMARY KEY (`id_tipo_seguridad`),
  ADD UNIQUE KEY `uk_tipos_seguridad_emergencia_nombre` (`nombre_tipo`),
  ADD KEY `idx_tipos_seguridad_emergencia_estado` (`estado`,`nombre_tipo`);

ALTER TABLE `tipos_servicios_publicos`
  ADD PRIMARY KEY (`id_tipo_servicio_publico`),
  ADD UNIQUE KEY `uk_tipos_servicios_publicos_codigo` (`codigo_tipo_servicio_publico`),
  ADD UNIQUE KEY `uk_tipos_servicios_publicos_nombre` (`nombre_tipo_servicio`),
  ADD KEY `idx_tipos_servicios_publicos_estado_codigo_nombre` (`estado`,`codigo_tipo_servicio_publico`,`nombre_tipo_servicio`);

ALTER TABLE `unidades`
  ADD PRIMARY KEY (`id_unidad`),
  ADD UNIQUE KEY `codigo_unidad` (`codigo_unidad`),
  ADD UNIQUE KEY `placa` (`placa`);

ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `usuario` (`usuario`),
  ADD KEY `fk_user_emp` (`id_empleado`);

ALTER TABLE `usuarios_seguridad_acceso`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `idx_usuarios_seguridad_bloqueo` (`bloqueado`,`intentos_fallidos`);

ALTER TABLE `usuario_permisos`
  ADD PRIMARY KEY (`id_usuario_permiso`),
  ADD UNIQUE KEY `uk_usuario_permiso` (`id_usuario`,`id_permiso`),
  ADD KEY `fk_p_permisos` (`id_permiso`),
  ADD KEY `fk_u_permisos` (`id_usuario`);

ALTER TABLE `asignaciones_unidades_choferes`
  MODIFY `id_asignacion_unidad_chofer` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_asignacion_unidad_chofer de la tabla asignaciones_unidades_choferes.', AUTO_INCREMENT=8;

ALTER TABLE `ayuda_social`
  MODIFY `id_ayuda` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Número correlativo de la solicitud', AUTO_INCREMENT=19;

ALTER TABLE `beneficiarios`
  MODIFY `id_beneficiario` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_beneficiario de la tabla beneficiarios.', AUTO_INCREMENT=37;

ALTER TABLE `bitacora`
  MODIFY `id_bitacora` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_bitacora de la tabla bitacora.', AUTO_INCREMENT=256;

ALTER TABLE `choferes_ambulancia`
  MODIFY `id_chofer_ambulancia` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_chofer_ambulancia de la tabla choferes_ambulancia.', AUTO_INCREMENT=7;

ALTER TABLE `comunidades`
  MODIFY `id_comunidad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_comunidad de la tabla comunidades.', AUTO_INCREMENT=131;

ALTER TABLE `configuracion_smtp`
  MODIFY `id_configuracion_smtp` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_configuracion_smtp de la tabla configuracion_smtp.', AUTO_INCREMENT=2;

ALTER TABLE `dependencias`
  MODIFY `id_dependencia` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_dependencia de la tabla dependencias.', AUTO_INCREMENT=8;

ALTER TABLE `despachos_unidades`
  MODIFY `id_despacho_unidad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_despacho_unidad de la tabla despachos_unidades.', AUTO_INCREMENT=7;

ALTER TABLE `empleados`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_empleado de la tabla empleados.', AUTO_INCREMENT=11;

ALTER TABLE `estados_solicitudes`
  MODIFY `id_estado_solicitud` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_estado_solicitud de la tabla estados_solicitudes.', AUTO_INCREMENT=5;

ALTER TABLE `permisos`
  MODIFY `id_permiso` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_permiso de la tabla permisos.', AUTO_INCREMENT=100;

ALTER TABLE `reportes_solicitudes_ambulancia`
  MODIFY `id_reporte_solicitud` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_reporte_solicitud de la tabla reportes_solicitudes_ambulancia.', AUTO_INCREMENT=11;

ALTER TABLE `reportes_traslado`
  MODIFY `id_reporte` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_reporte de la tabla reportes_traslado.', AUTO_INCREMENT=5;

ALTER TABLE `seguimientos_solicitudes`
  MODIFY `id_seguimiento_solicitud` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_seguimiento_solicitud de la tabla seguimientos_solicitudes.', AUTO_INCREMENT=96;

ALTER TABLE `seguridad`
  MODIFY `id_seguridad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_seguridad de la tabla seguridad.', AUTO_INCREMENT=15;

ALTER TABLE `servicios_publicos`
  MODIFY `id_servicio` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_servicio de la tabla servicios_publicos.', AUTO_INCREMENT=19;

ALTER TABLE `solicitudes_generales`
  MODIFY `id_solicitud_general` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_solicitud_general de la tabla solicitudes_generales.', AUTO_INCREMENT=6;

ALTER TABLE `tipos_ayuda_social`
  MODIFY `id_tipo_ayuda_social` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_tipo_ayuda_social de la tabla tipos_ayuda_social.', AUTO_INCREMENT=15;

ALTER TABLE `tipos_seguridad_emergencia`
  MODIFY `id_tipo_seguridad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_tipo_seguridad de la tabla tipos_seguridad_emergencia.', AUTO_INCREMENT=12;

ALTER TABLE `tipos_servicios_publicos`
  MODIFY `id_tipo_servicio_publico` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_tipo_servicio_publico de la tabla tipos_servicios_publicos.', AUTO_INCREMENT=11;

ALTER TABLE `unidades`
  MODIFY `id_unidad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_unidad de la tabla unidades.', AUTO_INCREMENT=7;

ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria: Identificador único del sistema', AUTO_INCREMENT=5;

ALTER TABLE `usuario_permisos`
  MODIFY `id_usuario_permiso` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_usuario_permiso de la tabla usuario_permisos.', AUTO_INCREMENT=22;

ALTER TABLE `asignaciones_unidades_choferes`
  ADD CONSTRAINT `fk_asignaciones_choferes` FOREIGN KEY (`id_chofer_ambulancia`) REFERENCES `choferes_ambulancia` (`id_chofer_ambulancia`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_asignaciones_unidades` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON UPDATE CASCADE;

ALTER TABLE `ayuda_social`
  ADD CONSTRAINT `fk_as_benef` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiarios` (`id_beneficiario`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_as_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `fk_ayuda_social_estado_solicitud` FOREIGN KEY (`id_estado_solicitud`) REFERENCES `estados_solicitudes` (`id_estado_solicitud`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ayuda_social_solicitudes_generales` FOREIGN KEY (`id_solicitud_ayuda_social`) REFERENCES `solicitudes_generales` (`id_solicitud_general`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ayuda_social_tipos` FOREIGN KEY (`id_tipo_ayuda_social`) REFERENCES `tipos_ayuda_social` (`id_tipo_ayuda_social`) ON UPDATE CASCADE;

ALTER TABLE `beneficiarios`
  ADD CONSTRAINT `fk_beneficiarios_comunidades` FOREIGN KEY (`id_comunidad`) REFERENCES `comunidades` (`id_comunidad`) ON UPDATE CASCADE;

ALTER TABLE `bitacora`
  ADD CONSTRAINT `fk_bit_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL;

ALTER TABLE `choferes_ambulancia`
  ADD CONSTRAINT `fk_choferes_ambulancia_empleados` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`) ON UPDATE CASCADE;

ALTER TABLE `configuracion_smtp`
  ADD CONSTRAINT `fk_config_smtp_usuario` FOREIGN KEY (`id_usuario_actualiza`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `despachos_unidades`
  ADD CONSTRAINT `fk_despachos_choferes` FOREIGN KEY (`id_chofer_ambulancia`) REFERENCES `choferes_ambulancia` (`id_chofer_ambulancia`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_despachos_seguridad` FOREIGN KEY (`id_seguridad`) REFERENCES `seguridad` (`id_seguridad`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_despachos_unidades` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_despachos_usuarios` FOREIGN KEY (`id_usuario_asigna`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `empleados`
  ADD CONSTRAINT `fk_emp_dependencia` FOREIGN KEY (`id_dependencia`) REFERENCES `dependencias` (`id_dependencia`);

ALTER TABLE `reportes_solicitudes_ambulancia`
  ADD CONSTRAINT `fk_rsa_despacho` FOREIGN KEY (`id_despacho_unidad`) REFERENCES `despachos_unidades` (`id_despacho_unidad`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rsa_seguridad` FOREIGN KEY (`id_seguridad`) REFERENCES `seguridad` (`id_seguridad`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rsa_usuario` FOREIGN KEY (`id_usuario_genera`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `reportes_traslado`
  ADD CONSTRAINT `fk_rep_ayuda_final` FOREIGN KEY (`id_ayuda`) REFERENCES `ayuda_social` (`id_ayuda`),
  ADD CONSTRAINT `fk_rep_chofer_emp` FOREIGN KEY (`id_empleado_chofer`) REFERENCES `empleados` (`id_empleado`),
  ADD CONSTRAINT `fk_rep_seguridad` FOREIGN KEY (`id_seguridad`) REFERENCES `seguridad` (`id_seguridad`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_rep_unit_final` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`),
  ADD CONSTRAINT `fk_rep_user_final` FOREIGN KEY (`id_usuario_operador`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `fk_reportes_traslado_despacho` FOREIGN KEY (`id_despacho_unidad`) REFERENCES `despachos_unidades` (`id_despacho_unidad`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `seguimientos_solicitudes`
  ADD CONSTRAINT `fk_seguimientos_estados_solicitudes` FOREIGN KEY (`id_estado_solicitud`) REFERENCES `estados_solicitudes` (`id_estado_solicitud`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seguimientos_usuarios` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `seguridad`
  ADD CONSTRAINT `fk_seg_benef` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiarios` (`id_beneficiario`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_seg_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seguridad_estado_solicitud` FOREIGN KEY (`id_estado_solicitud`) REFERENCES `estados_solicitudes` (`id_estado_solicitud`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seguridad_solicitudes_generales` FOREIGN KEY (`id_solicitud_seguridad`) REFERENCES `solicitudes_generales` (`id_solicitud_general`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seguridad_tipos_ayuda_social` FOREIGN KEY (`id_tipo_seguridad`) REFERENCES `tipos_seguridad_emergencia` (`id_tipo_seguridad`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `servicios_publicos`
  ADD CONSTRAINT `fk_ser_benef` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiarios` (`id_beneficiario`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ser_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_servicios_publicos_estado_solicitud` FOREIGN KEY (`id_estado_solicitud`) REFERENCES `estados_solicitudes` (`id_estado_solicitud`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_servicios_publicos_solicitudes_generales` FOREIGN KEY (`id_solicitud_servicio_publico`) REFERENCES `solicitudes_generales` (`id_solicitud_general`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_servicios_publicos_tipos` FOREIGN KEY (`id_tipo_servicio_publico`) REFERENCES `tipos_servicios_publicos` (`id_tipo_servicio_publico`) ON UPDATE CASCADE;

ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_user_emp` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`);

ALTER TABLE `usuarios_seguridad_acceso`
  ADD CONSTRAINT `fk_usuarios_seguridad_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `usuario_permisos`
  ADD CONSTRAINT `fk_p_permisos` FOREIGN KEY (`id_permiso`) REFERENCES `permisos` (`id_permiso`),
  ADD CONSTRAINT `fk_u_permisos` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_bitacora_sistema`  AS SELECT `b`.`id_bitacora` AS `id_bitacora`, `b`.`id_usuario` AS `id_usuario`, `u`.`usuario` AS `usuario_login`, trim(concat(ifnull(`e`.`nombre`,''),' ',ifnull(`e`.`apellido`,''))) AS `usuario_nombre`, CASE WHEN `u`.`id_usuario` is not null AND trim(concat(ifnull(`e`.`nombre`,''),' ',ifnull(`e`.`apellido`,''))) <> '' THEN concat(`u`.`usuario`,' - ',trim(concat(ifnull(`e`.`nombre`,''),' ',ifnull(`e`.`apellido`,'')))) WHEN `u`.`id_usuario` is not null THEN `u`.`usuario` WHEN coalesce(`b`.`usuario_bd`,'') <> '' THEN concat('Sistema - ',`b`.`usuario_bd`) ELSE 'Sistema' END AS `usuario_mostrar`, `b`.`tabla_afectada` AS `tabla_afectada`, `b`.`accion` AS `accion`, concat(coalesce(`b`.`tabla_afectada`,'SISTEMA'),' / ',coalesce(`b`.`accion`,'LEGACY')) AS `origen_evento`, `b`.`id_registro` AS `id_registro`, `b`.`resumen` AS `resumen`, `b`.`detalle` AS `detalle`, `b`.`datos_antes` AS `datos_antes`, `b`.`datos_despues` AS `datos_despues`, `b`.`usuario_bd` AS `usuario_bd`, `b`.`ipaddr` AS `ipaddr`, `b`.`moment` AS `moment`, `b`.`fecha_evento` AS `fecha_evento`, date_format(`b`.`fecha_evento`,'%d/%m/%Y %h:%i %p') AS `fecha_evento_formateada`, `b`.`estado` AS `estado` FROM ((`bitacora` `b` left join `usuarios` `u` on(`u`.`id_usuario` = `b`.`id_usuario`)) left join `empleados` `e` on(`e`.`id_empleado` = `u`.`id_empleado`)) ;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_bitacora_autenticacion`  AS SELECT `b`.`id_bitacora` AS `id_bitacora`, `b`.`id_usuario` AS `id_usuario`, `b`.`usuario_login` AS `usuario_login`, `b`.`usuario_nombre` AS `usuario_nombre`, `b`.`usuario_mostrar` AS `usuario_mostrar`, `b`.`tabla_afectada` AS `tabla_afectada`, `b`.`accion` AS `accion`, `b`.`origen_evento` AS `origen_evento`, `b`.`id_registro` AS `id_registro`, `b`.`resumen` AS `resumen`, `b`.`detalle` AS `detalle`, `b`.`ipaddr` AS `ipaddr`, `b`.`fecha_evento` AS `fecha_evento`, `b`.`fecha_evento_formateada` AS `fecha_evento_formateada`, `b`.`estado` AS `estado` FROM `vw_bitacora_sistema` AS `b` WHERE `b`.`tabla_afectada` = 'AUTENTICACION' OR `b`.`accion` in ('LOGIN_OK','LOGIN_FAIL','LOGOUT','BLOQUEO_USUARIO','DESBLOQUEO_USUARIO') ;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_seguridad_operativa`  AS SELECT `s`.`id_seguridad` AS `id_seguridad`, `s`.`ticket_interno` AS `ticket_interno`, `s`.`id_beneficiario` AS `id_beneficiario`, `s`.`id_usuario` AS `id_usuario`, `s`.`id_tipo_seguridad` AS `id_tipo_seguridad`, `s`.`id_solicitud_seguridad` AS `id_solicitud_seguridad`, `s`.`id_estado_solicitud` AS `id_estado_solicitud`, coalesce(`tse`.`nombre_tipo`,`s`.`tipo_seguridad`) AS `tipo_seguridad`, coalesce(`tse`.`requiere_ambulancia`,0) AS `requiere_ambulancia`, coalesce(`sg`.`nombre_solicitud`,`s`.`tipo_solicitud`) AS `tipo_solicitud`, coalesce(`es`.`nombre_estado`,'Registrada') AS `estado_solicitud`, coalesce(`es`.`codigo_estado`,'REGISTRADA') AS `codigo_estado_solicitud`, coalesce(`es`.`clase_badge`,'draft') AS `clase_badge_estado_solicitud`, coalesce(`es`.`es_atendida`,0) AS `es_atendida`, `s`.`fecha_seguridad` AS `fecha_seguridad`, date_format(`s`.`fecha_seguridad`,'%Y-%m-%dT%H:%i') AS `fecha_seguridad_input`, date_format(`s`.`fecha_seguridad`,'%d/%m/%Y %h:%i %p') AS `fecha_seguridad_formateada`, `s`.`descripcion` AS `descripcion`, `s`.`estado` AS `estado`, `s`.`estado_atencion` AS `estado_atencion`, `s`.`ubicacion_evento` AS `ubicacion_evento`, `s`.`referencia_evento` AS `referencia_evento`, `b`.`nacionalidad` AS `nacionalidad`, `b`.`cedula` AS `cedula`, `b`.`nombre_beneficiario` AS `nombre_beneficiario`, `b`.`telefono` AS `telefono`, concat(`b`.`nacionalidad`,'-',`b`.`cedula`,' ',`b`.`nombre_beneficiario`) AS `beneficiario`, `du`.`id_despacho_unidad` AS `id_despacho_unidad`, `du`.`estado_despacho` AS `estado_despacho`, `du`.`modo_asignacion` AS `modo_asignacion`, `du`.`fecha_asignacion` AS `fecha_asignacion`, `u`.`id_unidad` AS `id_unidad`, `u`.`codigo_unidad` AS `codigo_unidad`, `u`.`descripcion` AS `descripcion_unidad`, `u`.`placa` AS `placa`, `u`.`ubicacion_actual` AS `ubicacion_actual`, `u`.`referencia_actual` AS `referencia_actual`, `ca`.`id_chofer_ambulancia` AS `id_chofer_ambulancia`, `ca`.`numero_licencia` AS `numero_licencia`, `ca`.`categoria_licencia` AS `categoria_licencia`, `ca`.`vencimiento_licencia` AS `vencimiento_licencia`, `e`.`id_empleado` AS `id_empleado`, `e`.`cedula` AS `cedula_chofer`, concat(`e`.`nombre`,' ',`e`.`apellido`) AS `nombre_chofer`, `e`.`telefono` AS `telefono_chofer`, `e`.`correo` AS `correo_chofer` FROM ((((((((`seguridad` `s` left join `tipos_seguridad_emergencia` `tse` on(`tse`.`id_tipo_seguridad` = `s`.`id_tipo_seguridad`)) left join `solicitudes_generales` `sg` on(`sg`.`id_solicitud_general` = `s`.`id_solicitud_seguridad`)) left join `estados_solicitudes` `es` on(`es`.`id_estado_solicitud` = `s`.`id_estado_solicitud`)) left join `beneficiarios` `b` on(`b`.`id_beneficiario` = `s`.`id_beneficiario`)) left join (select `d1`.`id_despacho_unidad` AS `id_despacho_unidad`,`d1`.`id_seguridad` AS `id_seguridad`,`d1`.`id_unidad` AS `id_unidad`,`d1`.`id_chofer_ambulancia` AS `id_chofer_ambulancia`,`d1`.`id_usuario_asigna` AS `id_usuario_asigna`,`d1`.`modo_asignacion` AS `modo_asignacion`,`d1`.`estado_despacho` AS `estado_despacho`,`d1`.`fecha_asignacion` AS `fecha_asignacion`,`d1`.`fecha_cierre` AS `fecha_cierre`,`d1`.`ubicacion_salida` AS `ubicacion_salida`,`d1`.`ubicacion_evento` AS `ubicacion_evento`,`d1`.`ubicacion_cierre` AS `ubicacion_cierre`,`d1`.`observaciones` AS `observaciones`,`d1`.`fecha_registro` AS `fecha_registro`,`d1`.`fecha_actualizacion` AS `fecha_actualizacion` from (`despachos_unidades` `d1` join (select `despachos_unidades`.`id_seguridad` AS `id_seguridad`,max(`despachos_unidades`.`id_despacho_unidad`) AS `max_id` from `despachos_unidades` group by `despachos_unidades`.`id_seguridad`) `dm` on(`dm`.`max_id` = `d1`.`id_despacho_unidad`))) `du` on(`du`.`id_seguridad` = `s`.`id_seguridad`)) left join `unidades` `u` on(`u`.`id_unidad` = `du`.`id_unidad`)) left join `choferes_ambulancia` `ca` on(`ca`.`id_chofer_ambulancia` = `du`.`id_chofer_ambulancia`)) left join `empleados` `e` on(`e`.`id_empleado` = `ca`.`id_empleado`)) ;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_solicitudes_ciudadanas`  AS SELECT 'AYUDA_SOCIAL' AS `modulo`, `a`.`id_ayuda` AS `id_registro`, `a`.`ticket_interno` AS `ticket_interno`, `a`.`id_beneficiario` AS `id_beneficiario`, concat(`b`.`nacionalidad`,'-',`b`.`cedula`,' ',`b`.`nombre_beneficiario`) AS `beneficiario`, coalesce(`ta`.`nombre_tipo_ayuda`,`a`.`tipo_ayuda`) AS `tipo_registro`, coalesce(`sg`.`nombre_solicitud`,`a`.`solicitud_ayuda`) AS `solicitud`, coalesce(`es`.`nombre_estado`,'Registrada') AS `estado_solicitud`, coalesce(`es`.`codigo_estado`,'REGISTRADA') AS `codigo_estado_solicitud`, cast(`a`.`fecha_ayuda` as datetime) AS `fecha_evento`, date_format(cast(`a`.`fecha_ayuda` as datetime),'%d/%m/%Y %h:%i %p') AS `fecha_evento_formateada`, `u`.`usuario` AS `usuario_registra`, `a`.`estado` AS `estado` FROM (((((`ayuda_social` `a` left join `beneficiarios` `b` on(`b`.`id_beneficiario` = `a`.`id_beneficiario`)) left join `tipos_ayuda_social` `ta` on(`ta`.`id_tipo_ayuda_social` = `a`.`id_tipo_ayuda_social`)) left join `solicitudes_generales` `sg` on(`sg`.`id_solicitud_general` = `a`.`id_solicitud_ayuda_social`)) left join `estados_solicitudes` `es` on(`es`.`id_estado_solicitud` = `a`.`id_estado_solicitud`)) left join `usuarios` `u` on(`u`.`id_usuario` = `a`.`id_usuario`))union all select 'SERVICIOS_PUBLICOS' AS `modulo`,`sp`.`id_servicio` AS `id_registro`,`sp`.`ticket_interno` AS `ticket_interno`,`sp`.`id_beneficiario` AS `id_beneficiario`,concat(`b`.`nacionalidad`,'-',`b`.`cedula`,' ',`b`.`nombre_beneficiario`) AS `beneficiario`,coalesce(`tsp`.`nombre_tipo_servicio`,`sp`.`tipo_servicio`) AS `tipo_registro`,coalesce(`sg`.`nombre_solicitud`,`sp`.`solicitud_servicio`) AS `solicitud`,coalesce(`es`.`nombre_estado`,'Registrada') AS `estado_solicitud`,coalesce(`es`.`codigo_estado`,'REGISTRADA') AS `codigo_estado_solicitud`,cast(`sp`.`fecha_servicio` as datetime) AS `fecha_evento`,date_format(cast(`sp`.`fecha_servicio` as datetime),'%d/%m/%Y %h:%i %p') AS `fecha_evento_formateada`,`u`.`usuario` AS `usuario_registra`,`sp`.`estado` AS `estado` from (((((`servicios_publicos` `sp` left join `beneficiarios` `b` on(`b`.`id_beneficiario` = `sp`.`id_beneficiario`)) left join `tipos_servicios_publicos` `tsp` on(`tsp`.`id_tipo_servicio_publico` = `sp`.`id_tipo_servicio_publico`)) left join `solicitudes_generales` `sg` on(`sg`.`id_solicitud_general` = `sp`.`id_solicitud_servicio_publico`)) left join `estados_solicitudes` `es` on(`es`.`id_estado_solicitud` = `sp`.`id_estado_solicitud`)) left join `usuarios` `u` on(`u`.`id_usuario` = `sp`.`id_usuario`)) union all select 'SEGURIDAD_EMERGENCIA' AS `modulo`,`s`.`id_seguridad` AS `id_registro`,`s`.`ticket_interno` AS `ticket_interno`,`s`.`id_beneficiario` AS `id_beneficiario`,concat(`b`.`nacionalidad`,'-',`b`.`cedula`,' ',`b`.`nombre_beneficiario`) AS `beneficiario`,coalesce(`tse`.`nombre_tipo`,`s`.`tipo_seguridad`) AS `tipo_registro`,coalesce(`sg`.`nombre_solicitud`,`s`.`tipo_solicitud`) AS `solicitud`,coalesce(`es`.`nombre_estado`,'Registrada') AS `estado_solicitud`,coalesce(`es`.`codigo_estado`,'REGISTRADA') AS `codigo_estado_solicitud`,`s`.`fecha_seguridad` AS `fecha_evento`,date_format(`s`.`fecha_seguridad`,'%d/%m/%Y %h:%i %p') AS `fecha_evento_formateada`,`u`.`usuario` AS `usuario_registra`,`s`.`estado` AS `estado` from (((((`seguridad` `s` left join `beneficiarios` `b` on(`b`.`id_beneficiario` = `s`.`id_beneficiario`)) left join `tipos_seguridad_emergencia` `tse` on(`tse`.`id_tipo_seguridad` = `s`.`id_tipo_seguridad`)) left join `solicitudes_generales` `sg` on(`sg`.`id_solicitud_general` = `s`.`id_solicitud_seguridad`)) left join `estados_solicitudes` `es` on(`es`.`id_estado_solicitud` = `s`.`id_estado_solicitud`)) left join `usuarios` `u` on(`u`.`id_usuario` = `s`.`id_usuario`))  ;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_unidades_operativas_actuales`  AS SELECT `u`.`id_unidad` AS `id_unidad`, `u`.`codigo_unidad` AS `codigo_unidad`, `u`.`descripcion` AS `descripcion`, `u`.`placa` AS `placa`, `u`.`estado` AS `estado`, `u`.`estado_operativo` AS `estado_operativo`, `u`.`ubicacion_actual` AS `ubicacion_actual`, `u`.`referencia_actual` AS `referencia_actual`, `u`.`prioridad_despacho` AS `prioridad_despacho`, `au`.`id_asignacion_unidad_chofer` AS `id_asignacion_unidad_chofer`, `ca`.`id_chofer_ambulancia` AS `id_chofer_ambulancia`, `ca`.`numero_licencia` AS `numero_licencia`, `ca`.`categoria_licencia` AS `categoria_licencia`, `ca`.`vencimiento_licencia` AS `vencimiento_licencia`, `e`.`id_empleado` AS `id_empleado`, `e`.`cedula` AS `cedula_chofer`, concat(coalesce(`e`.`nombre`,''),' ',coalesce(`e`.`apellido`,'')) AS `nombre_chofer`, `e`.`telefono` AS `telefono_chofer`, `du`.`id_despacho_unidad` AS `id_despacho_unidad`, `du`.`estado_despacho` AS `estado_despacho`, `du`.`fecha_asignacion` AS `fecha_asignacion`, `du`.`id_seguridad` AS `id_seguridad`, `s`.`ticket_interno` AS `ticket_interno` FROM (((((`unidades` `u` left join (select `a1`.`id_asignacion_unidad_chofer` AS `id_asignacion_unidad_chofer`,`a1`.`id_unidad` AS `id_unidad`,`a1`.`id_chofer_ambulancia` AS `id_chofer_ambulancia`,`a1`.`fecha_inicio` AS `fecha_inicio`,`a1`.`fecha_fin` AS `fecha_fin`,`a1`.`observaciones` AS `observaciones`,`a1`.`estado` AS `estado`,`a1`.`fecha_registro` AS `fecha_registro`,`a1`.`fecha_actualizacion` AS `fecha_actualizacion` from (`asignaciones_unidades_choferes` `a1` join (select `asignaciones_unidades_choferes`.`id_unidad` AS `id_unidad`,max(`asignaciones_unidades_choferes`.`id_asignacion_unidad_chofer`) AS `max_id` from `asignaciones_unidades_choferes` where `asignaciones_unidades_choferes`.`estado` = 1 and `asignaciones_unidades_choferes`.`fecha_fin` is null group by `asignaciones_unidades_choferes`.`id_unidad`) `am` on(`am`.`max_id` = `a1`.`id_asignacion_unidad_chofer`))) `au` on(`au`.`id_unidad` = `u`.`id_unidad`)) left join `choferes_ambulancia` `ca` on(`ca`.`id_chofer_ambulancia` = `au`.`id_chofer_ambulancia`)) left join `empleados` `e` on(`e`.`id_empleado` = `ca`.`id_empleado`)) left join (select `d1`.`id_despacho_unidad` AS `id_despacho_unidad`,`d1`.`id_seguridad` AS `id_seguridad`,`d1`.`id_unidad` AS `id_unidad`,`d1`.`id_chofer_ambulancia` AS `id_chofer_ambulancia`,`d1`.`id_usuario_asigna` AS `id_usuario_asigna`,`d1`.`modo_asignacion` AS `modo_asignacion`,`d1`.`estado_despacho` AS `estado_despacho`,`d1`.`fecha_asignacion` AS `fecha_asignacion`,`d1`.`fecha_cierre` AS `fecha_cierre`,`d1`.`ubicacion_salida` AS `ubicacion_salida`,`d1`.`ubicacion_evento` AS `ubicacion_evento`,`d1`.`ubicacion_cierre` AS `ubicacion_cierre`,`d1`.`observaciones` AS `observaciones`,`d1`.`fecha_registro` AS `fecha_registro`,`d1`.`fecha_actualizacion` AS `fecha_actualizacion` from (`despachos_unidades` `d1` join (select `despachos_unidades`.`id_unidad` AS `id_unidad`,max(`despachos_unidades`.`id_despacho_unidad`) AS `max_id` from `despachos_unidades` where `despachos_unidades`.`estado_despacho` = 'ACTIVO' group by `despachos_unidades`.`id_unidad`) `dm` on(`dm`.`max_id` = `d1`.`id_despacho_unidad`))) `du` on(`du`.`id_unidad` = `u`.`id_unidad`)) left join `seguridad` `s` on(`s`.`id_seguridad` = `du`.`id_seguridad`)) WHERE `u`.`estado` = 1 ;

CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_usuarios_estado_acceso`  AS SELECT `u`.`id_usuario` AS `id_usuario`, `u`.`id_empleado` AS `id_empleado`, `e`.`id_dependencia` AS `id_dependencia`, `u`.`usuario` AS `usuario`, `u`.`rol` AS `rol`, ifnull(`u`.`estado`,1) AS `estado`, `e`.`cedula` AS `cedula`, trim(concat(coalesce(`e`.`nombre`,''),' ',coalesce(`e`.`apellido`,''))) AS `empleado`, `d`.`nombre_dependencia` AS `nombre_dependencia`, ifnull(`usa`.`intentos_fallidos`,0) AS `intentos_fallidos`, ifnull(`usa`.`bloqueado`,0) AS `bloqueado`, ifnull(`usa`.`password_temporal`,0) AS `password_temporal`, `usa`.`fecha_bloqueo` AS `fecha_bloqueo`, `usa`.`fecha_password_temporal` AS `fecha_password_temporal`, `usa`.`fecha_actualizacion` AS `fecha_actualizacion` FROM (((`usuarios` `u` join `empleados` `e` on(`e`.`id_empleado` = `u`.`id_empleado`)) left join `dependencias` `d` on(`d`.`id_dependencia` = `e`.`id_dependencia`)) left join `usuarios_seguridad_acceso` `usa` on(`usa`.`id_usuario` = `u`.`id_usuario`)) ;

DELIMITER $$
CREATE PROCEDURE `sp_bitacora_registrar_evento` (IN `p_id_usuario` INT, IN `p_tabla_afectada` VARCHAR(64), IN `p_accion` VARCHAR(20), IN `p_id_registro` VARCHAR(64), IN `p_resumen` VARCHAR(100), IN `p_detalle` TEXT, IN `p_datos_antes` LONGTEXT, IN `p_datos_despues` LONGTEXT, IN `p_ipaddr` VARCHAR(45), IN `p_estado` TINYINT)   BEGIN
    INSERT INTO `bitacora` (
        `id_usuario`,
        `tabla_afectada`,
        `accion`,
        `id_registro`,
        `resumen`,
        `detalle`,
        `datos_antes`,
        `datos_despues`,
        `usuario_bd`,
        `ipaddr`,
        `fecha_evento`,
        `estado`
    )
    VALUES (
        NULLIF(p_id_usuario, 0),
        COALESCE(NULLIF(TRIM(p_tabla_afectada), ''), 'SISTEMA'),
        COALESCE(NULLIF(TRIM(p_accion), ''), 'LEGACY'),
        NULLIF(TRIM(p_id_registro), ''),
        COALESCE(NULLIF(TRIM(p_resumen), ''), 'Operacion del sistema'),
        NULLIF(p_detalle, ''),
        NULLIF(p_datos_antes, ''),
        NULLIF(p_datos_despues, ''),
        CURRENT_USER(),
        COALESCE(NULLIF(TRIM(p_ipaddr), ''), '127.0.0.1'),
        NOW(),
        IFNULL(p_estado, 1)
    );
END$$

CREATE PROCEDURE `sp_bitacora_registrar_autenticacion` (IN `p_id_usuario` INT, IN `p_usuario` VARCHAR(50), IN `p_accion` VARCHAR(20), IN `p_detalle` TEXT, IN `p_ipaddr` VARCHAR(45))   BEGIN
    CALL `sp_bitacora_registrar_evento`(
        NULLIF(p_id_usuario, 0),
        'AUTENTICACION',
        UPPER(COALESCE(NULLIF(TRIM(p_accion), ''), 'LOGIN_FAIL')),
        NULLIF(TRIM(p_usuario), ''),
        CONCAT('Evento de autenticacion: ', UPPER(COALESCE(NULLIF(TRIM(p_accion), ''), 'LOGIN_FAIL'))),
        NULLIF(p_detalle, ''),
        NULL,
        NULL,
        COALESCE(NULLIF(TRIM(p_ipaddr), ''), '127.0.0.1'),
        1
    );
END$$

CREATE PROCEDURE `sp_bitacora_consultar_autenticacion` (IN `p_fecha_desde` DATETIME, IN `p_fecha_hasta` DATETIME, IN `p_usuario` VARCHAR(50), IN `p_accion` VARCHAR(20))   BEGIN
    SELECT
        `id_bitacora`,
        `id_usuario`,
        `usuario_login`,
        `usuario_nombre`,
        `usuario_mostrar`,
        `tabla_afectada`,
        `accion`,
        `origen_evento`,
        `id_registro`,
        `resumen`,
        `detalle`,
        `ipaddr`,
        `fecha_evento`,
        `fecha_evento_formateada`,
        `estado`
    FROM `vw_bitacora_autenticacion`
    WHERE (p_fecha_desde IS NULL OR `fecha_evento` >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR `fecha_evento` <= p_fecha_hasta)
      AND (p_usuario IS NULL OR p_usuario = '' OR `usuario_mostrar` LIKE CONCAT('%', p_usuario, '%'))
      AND (p_accion IS NULL OR p_accion = '' OR `accion` = UPPER(TRIM(p_accion)))
    ORDER BY `id_bitacora` DESC;
END$$

CREATE PROCEDURE `sp_dashboard_resumen_general` ()   BEGIN
    SELECT
        (SELECT COUNT(*) FROM `beneficiarios` WHERE IFNULL(`estado`, 1) = 1) AS `total_beneficiarios`,
        (SELECT COUNT(*) FROM `ayuda_social` WHERE IFNULL(`estado`, 1) = 1) AS `total_ayudas`,
        (SELECT COUNT(*) FROM `servicios_publicos` WHERE IFNULL(`estado`, 1) = 1) AS `total_servicios`,
        (SELECT COUNT(*) FROM `seguridad` WHERE IFNULL(`estado`, 1) = 1) AS `total_seguridad`,
        (SELECT COUNT(*) FROM `usuarios` WHERE IFNULL(`estado`, 1) = 1) AS `total_usuarios_activos`,
        (SELECT COUNT(*) FROM `usuarios_seguridad_acceso` WHERE IFNULL(`bloqueado`, 0) = 1) AS `total_usuarios_bloqueados`,
        (SELECT COUNT(*) FROM `unidades` WHERE IFNULL(`estado`, 1) = 1 AND `estado_operativo` = 'DISPONIBLE') AS `total_unidades_disponibles`;
END$$

CREATE PROCEDURE `sp_usuarios_incrementar_intento_fallido` (IN `p_id_usuario` INT)   BEGIN
    INSERT INTO `usuarios_seguridad_acceso` (
        `id_usuario`,
        `intentos_fallidos`,
        `bloqueado`,
        `password_temporal`
    )
    VALUES (
        p_id_usuario,
        1,
        0,
        0
    )
    ON DUPLICATE KEY UPDATE
        `intentos_fallidos` = IFNULL(`intentos_fallidos`, 0) + 1;
END$$

CREATE PROCEDURE `sp_usuarios_marcar_bloqueado` (IN `p_id_usuario` INT)   BEGIN
    UPDATE `usuarios_seguridad_acceso`
       SET `bloqueado` = 1,
           `fecha_bloqueo` = NOW()
     WHERE `id_usuario` = p_id_usuario;
END$$

CREATE PROCEDURE `sp_usuarios_reiniciar_seguridad_acceso` (IN `p_id_usuario` INT)   BEGIN
    UPDATE `usuarios_seguridad_acceso`
       SET `intentos_fallidos` = 0,
           `bloqueado` = 0,
           `fecha_bloqueo` = NULL
     WHERE `id_usuario` = p_id_usuario;
END$$

CREATE PROCEDURE `sp_usuarios_desbloquear_manual` (IN `p_id_usuario` INT, IN `p_id_usuario_admin` INT, IN `p_motivo` VARCHAR(255))   BEGIN
    INSERT INTO `usuarios_seguridad_acceso` (
        `id_usuario`,
        `intentos_fallidos`,
        `bloqueado`,
        `fecha_bloqueo`,
        `password_temporal`,
        `fecha_password_temporal`
    )
    VALUES (
        p_id_usuario,
        0,
        0,
        NULL,
        0,
        NULL
    )
    ON DUPLICATE KEY UPDATE
        `intentos_fallidos` = 0,
        `bloqueado` = 0,
        `fecha_bloqueo` = NULL,
        `password_temporal` = 0,
        `fecha_password_temporal` = NULL;

    CALL `sp_bitacora_registrar_evento`(
        NULLIF(p_id_usuario_admin, 0),
        'AUTENTICACION',
        'DESBLOQUEO_USUARIO',
        CAST(p_id_usuario AS CHAR),
        'Desbloqueo de usuario',
        CONCAT(
            'Se restablecio el acceso del usuario ID ',
            p_id_usuario,
            '. Motivo: ',
            COALESCE(NULLIF(TRIM(p_motivo), ''), 'Sin motivo')
        ),
        NULL,
        NULL,
        '127.0.0.1',
        1
    );
END$$

CREATE TRIGGER `tr_asignaciones_unidades_choferes_ai_audit` AFTER INSERT ON `asignaciones_unidades_choferes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'asignaciones_unidades_choferes', 'INSERT', CAST(NEW.id_asignacion_unidad_chofer AS CHAR), 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, JSON_OBJECT('id_asignacion_unidad_chofer', NEW.id_asignacion_unidad_chofer, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'fecha_inicio', NEW.fecha_inicio, 'fecha_fin', NEW.fecha_fin, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_asignaciones_unidades_choferes_au_audit` AFTER UPDATE ON `asignaciones_unidades_choferes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'asignaciones_unidades_choferes', 'UPDATE', CAST(NEW.id_asignacion_unidad_chofer AS CHAR), 'UPDATE en asignaciones_unidades_choferes', 'Se actualizo un registro en asignaciones_unidades_choferes', JSON_OBJECT('id_asignacion_unidad_chofer', OLD.id_asignacion_unidad_chofer, 'id_unidad', OLD.id_unidad, 'id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'fecha_inicio', OLD.fecha_inicio, 'fecha_fin', OLD.fecha_fin, 'observaciones', OLD.observaciones, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_asignacion_unidad_chofer', NEW.id_asignacion_unidad_chofer, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'fecha_inicio', NEW.fecha_inicio, 'fecha_fin', NEW.fecha_fin, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_asignaciones_unidades_choferes_bd_block_delete` BEFORE DELETE ON `asignaciones_unidades_choferes` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla asignaciones_unidades_choferes. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_ayuda_social_ai_audit` AFTER INSERT ON `ayuda_social` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'ayuda_social', 'INSERT', CAST(NEW.id_ayuda AS CHAR), 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, JSON_OBJECT('id_ayuda', NEW.id_ayuda, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'id_solicitud_ayuda_social', NEW.id_solicitud_ayuda_social, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_ayuda', NEW.tipo_ayuda, 'solicitud_ayuda', NEW.solicitud_ayuda, 'fecha_ayuda', NEW.fecha_ayuda, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_ayuda_social_au_audit` AFTER UPDATE ON `ayuda_social` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'ayuda_social', 'UPDATE', CAST(NEW.id_ayuda AS CHAR), 'UPDATE en ayuda_social', 'Se actualizo un registro en ayuda_social', JSON_OBJECT('id_ayuda', OLD.id_ayuda, 'ticket_interno', OLD.ticket_interno, 'id_beneficiario', OLD.id_beneficiario, 'id_usuario', OLD.id_usuario, 'id_tipo_ayuda_social', OLD.id_tipo_ayuda_social, 'id_solicitud_ayuda_social', OLD.id_solicitud_ayuda_social, 'id_estado_solicitud', OLD.id_estado_solicitud, 'tipo_ayuda', OLD.tipo_ayuda, 'solicitud_ayuda', OLD.solicitud_ayuda, 'fecha_ayuda', OLD.fecha_ayuda, 'descripcion', OLD.descripcion, 'estado', OLD.estado), JSON_OBJECT('id_ayuda', NEW.id_ayuda, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'id_solicitud_ayuda_social', NEW.id_solicitud_ayuda_social, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_ayuda', NEW.tipo_ayuda, 'solicitud_ayuda', NEW.solicitud_ayuda, 'fecha_ayuda', NEW.fecha_ayuda, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_ayuda_social_bd_block_delete` BEFORE DELETE ON `ayuda_social` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla ayuda_social. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_beneficiarios_ai_audit` AFTER INSERT ON `beneficiarios` FOR EACH ROW BEGIN
  INSERT INTO `bitacora` (
      `id_usuario`,
      `tabla_afectada`,
      `accion`,
      `id_registro`,
      `resumen`,
      `detalle`,
      `datos_antes`,
      `datos_despues`,
      `usuario_bd`,
      `fecha_evento`,
      `estado`
  )
  VALUES (
      NULL,
      'beneficiarios',
      'INSERT',
      CAST(NEW.`id_beneficiario` AS CHAR),
      'INSERT en beneficiarios',
      'Se inserto un registro en beneficiarios',
      NULL,
      JSON_OBJECT(
          'id_beneficiario', NEW.`id_beneficiario`,
          'nacionalidad', NEW.`nacionalidad`,
          'cedula', NEW.`cedula`,
          'nombre_beneficiario', NEW.`nombre_beneficiario`,
          'telefono', NEW.`telefono`,
          'id_comunidad', NEW.`id_comunidad`,
          'comunidad', NEW.`comunidad`,
          'fecha_registro', NEW.`fecha_registro`,
          'estado', NEW.`estado`
      ),
      CURRENT_USER(),
      NOW(),
      1
  );
END
$$

CREATE TRIGGER `tr_beneficiarios_au_audit` AFTER UPDATE ON `beneficiarios` FOR EACH ROW BEGIN
  INSERT INTO `bitacora` (
      `id_usuario`,
      `tabla_afectada`,
      `accion`,
      `id_registro`,
      `resumen`,
      `detalle`,
      `datos_antes`,
      `datos_despues`,
      `usuario_bd`,
      `fecha_evento`,
      `estado`
  )
  VALUES (
      NULL,
      'beneficiarios',
      'UPDATE',
      CAST(NEW.`id_beneficiario` AS CHAR),
      'UPDATE en beneficiarios',
      'Se actualizo un registro en beneficiarios',
      JSON_OBJECT(
          'id_beneficiario', OLD.`id_beneficiario`,
          'nacionalidad', OLD.`nacionalidad`,
          'cedula', OLD.`cedula`,
          'nombre_beneficiario', OLD.`nombre_beneficiario`,
          'telefono', OLD.`telefono`,
          'id_comunidad', OLD.`id_comunidad`,
          'comunidad', OLD.`comunidad`,
          'fecha_registro', OLD.`fecha_registro`,
          'estado', OLD.`estado`
      ),
      JSON_OBJECT(
          'id_beneficiario', NEW.`id_beneficiario`,
          'nacionalidad', NEW.`nacionalidad`,
          'cedula', NEW.`cedula`,
          'nombre_beneficiario', NEW.`nombre_beneficiario`,
          'telefono', NEW.`telefono`,
          'id_comunidad', NEW.`id_comunidad`,
          'comunidad', NEW.`comunidad`,
          'fecha_registro', NEW.`fecha_registro`,
          'estado', NEW.`estado`
      ),
      CURRENT_USER(),
      NOW(),
      1
  );
END
$$

CREATE TRIGGER `tr_beneficiarios_bd_block_delete` BEFORE DELETE ON `beneficiarios` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla beneficiarios. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_bitacora_bd_lock` BEFORE DELETE ON `bitacora` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bitacora inmutable: no se permite DELETE.';
END
$$

CREATE TRIGGER `tr_bitacora_bi_defaults` BEFORE INSERT ON `bitacora` FOR EACH ROW BEGIN
  SET NEW.accion = COALESCE(NULLIF(NEW.accion, ''), 'LEGACY');
  SET NEW.tabla_afectada = COALESCE(NULLIF(NEW.tabla_afectada, ''), 'SISTEMA');
  SET NEW.usuario_bd = COALESCE(NULLIF(NEW.usuario_bd, ''), CURRENT_USER());
  SET NEW.fecha_evento = COALESCE(NEW.fecha_evento, NOW());
END
$$

CREATE TRIGGER `tr_bitacora_bu_lock` BEFORE UPDATE ON `bitacora` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bitacora inmutable: no se permite UPDATE.';
END
$$

CREATE TRIGGER `tr_choferes_ambulancia_ai_audit` AFTER INSERT ON `choferes_ambulancia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'choferes_ambulancia', 'INSERT', CAST(NEW.id_chofer_ambulancia AS CHAR), 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, JSON_OBJECT('id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_empleado', NEW.id_empleado, 'numero_licencia', NEW.numero_licencia, 'categoria_licencia', NEW.categoria_licencia, 'vencimiento_licencia', NEW.vencimiento_licencia, 'contacto_emergencia', NEW.contacto_emergencia, 'telefono_contacto_emergencia', NEW.telefono_contacto_emergencia, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_choferes_ambulancia_au_audit` AFTER UPDATE ON `choferes_ambulancia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'choferes_ambulancia', 'UPDATE', CAST(NEW.id_chofer_ambulancia AS CHAR), 'UPDATE en choferes_ambulancia', 'Se actualizo un registro en choferes_ambulancia', JSON_OBJECT('id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'id_empleado', OLD.id_empleado, 'numero_licencia', OLD.numero_licencia, 'categoria_licencia', OLD.categoria_licencia, 'vencimiento_licencia', OLD.vencimiento_licencia, 'contacto_emergencia', OLD.contacto_emergencia, 'telefono_contacto_emergencia', OLD.telefono_contacto_emergencia, 'observaciones', OLD.observaciones, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_empleado', NEW.id_empleado, 'numero_licencia', NEW.numero_licencia, 'categoria_licencia', NEW.categoria_licencia, 'vencimiento_licencia', NEW.vencimiento_licencia, 'contacto_emergencia', NEW.contacto_emergencia, 'telefono_contacto_emergencia', NEW.telefono_contacto_emergencia, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_choferes_ambulancia_bd_block_delete` BEFORE DELETE ON `choferes_ambulancia` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla choferes_ambulancia. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_comunidades_ai_audit` AFTER INSERT ON `comunidades` FOR EACH ROW BEGIN
  INSERT INTO `bitacora` (
      `id_usuario`,
      `tabla_afectada`,
      `accion`,
      `id_registro`,
      `resumen`,
      `detalle`,
      `datos_antes`,
      `datos_despues`,
      `usuario_bd`,
      `fecha_evento`,
      `estado`
  )
  VALUES (
      NULL,
      'comunidades',
      'INSERT',
      CAST(NEW.`id_comunidad` AS CHAR),
      'INSERT en comunidades',
      'Se inserto un registro en comunidades',
      NULL,
      JSON_OBJECT(
          'id_comunidad', NEW.`id_comunidad`,
          'nombre_comunidad', NEW.`nombre_comunidad`,
          'estado', NEW.`estado`,
          'fecha_registro', NEW.`fecha_registro`
      ),
      CURRENT_USER(),
      NOW(),
      1
  );
END
$$

CREATE TRIGGER `tr_comunidades_au_audit` AFTER UPDATE ON `comunidades` FOR EACH ROW BEGIN
  INSERT INTO `bitacora` (
      `id_usuario`,
      `tabla_afectada`,
      `accion`,
      `id_registro`,
      `resumen`,
      `detalle`,
      `datos_antes`,
      `datos_despues`,
      `usuario_bd`,
      `fecha_evento`,
      `estado`
  )
  VALUES (
      NULL,
      'comunidades',
      'UPDATE',
      CAST(NEW.`id_comunidad` AS CHAR),
      'UPDATE en comunidades',
      'Se actualizo un registro en comunidades',
      JSON_OBJECT(
          'id_comunidad', OLD.`id_comunidad`,
          'nombre_comunidad', OLD.`nombre_comunidad`,
          'estado', OLD.`estado`,
          'fecha_registro', OLD.`fecha_registro`
      ),
      JSON_OBJECT(
          'id_comunidad', NEW.`id_comunidad`,
          'nombre_comunidad', NEW.`nombre_comunidad`,
          'estado', NEW.`estado`,
          'fecha_registro', NEW.`fecha_registro`
      ),
      CURRENT_USER(),
      NOW(),
      1
  );
END
$$

CREATE TRIGGER `tr_comunidades_bd_block_delete` BEFORE DELETE ON `comunidades` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla comunidades. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_configuracion_smtp_ai_audit` AFTER INSERT ON `configuracion_smtp` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'configuracion_smtp', 'INSERT', CAST(NEW.id_configuracion_smtp AS CHAR), 'INSERT en configuracion_smtp', 'Se inserto un registro en configuracion_smtp', NULL, JSON_OBJECT('id_configuracion_smtp', NEW.id_configuracion_smtp, 'host', NEW.host, 'puerto', NEW.puerto, 'usuario', NEW.usuario, 'clave', NEW.clave, 'correo_remitente', NEW.correo_remitente, 'nombre_remitente', NEW.nombre_remitente, 'usar_tls', NEW.usar_tls, 'estado', NEW.estado, 'id_usuario_actualiza', NEW.id_usuario_actualiza, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_configuracion_smtp_au_audit` AFTER UPDATE ON `configuracion_smtp` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'configuracion_smtp', 'UPDATE', CAST(NEW.id_configuracion_smtp AS CHAR), 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', JSON_OBJECT('id_configuracion_smtp', OLD.id_configuracion_smtp, 'host', OLD.host, 'puerto', OLD.puerto, 'usuario', OLD.usuario, 'clave', OLD.clave, 'correo_remitente', OLD.correo_remitente, 'nombre_remitente', OLD.nombre_remitente, 'usar_tls', OLD.usar_tls, 'estado', OLD.estado, 'id_usuario_actualiza', OLD.id_usuario_actualiza, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_configuracion_smtp', NEW.id_configuracion_smtp, 'host', NEW.host, 'puerto', NEW.puerto, 'usuario', NEW.usuario, 'clave', NEW.clave, 'correo_remitente', NEW.correo_remitente, 'nombre_remitente', NEW.nombre_remitente, 'usar_tls', NEW.usar_tls, 'estado', NEW.estado, 'id_usuario_actualiza', NEW.id_usuario_actualiza, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_configuracion_smtp_bd_block_delete` BEFORE DELETE ON `configuracion_smtp` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla configuracion_smtp. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_dependencias_ai_audit` AFTER INSERT ON `dependencias` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'dependencias', 'INSERT', CAST(NEW.id_dependencia AS CHAR), 'INSERT en dependencias', 'Se inserto un registro en dependencias', NULL, JSON_OBJECT('id_dependencia', NEW.id_dependencia, 'nombre_dependencia', NEW.nombre_dependencia, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_dependencias_au_audit` AFTER UPDATE ON `dependencias` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'dependencias', 'UPDATE', CAST(NEW.id_dependencia AS CHAR), 'UPDATE en dependencias', 'Se actualizo un registro en dependencias', JSON_OBJECT('id_dependencia', OLD.id_dependencia, 'nombre_dependencia', OLD.nombre_dependencia, 'estado', OLD.estado), JSON_OBJECT('id_dependencia', NEW.id_dependencia, 'nombre_dependencia', NEW.nombre_dependencia, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_dependencias_bd_block_delete` BEFORE DELETE ON `dependencias` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla dependencias. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_despachos_unidades_ai_audit` AFTER INSERT ON `despachos_unidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'despachos_unidades', 'INSERT', CAST(NEW.id_despacho_unidad AS CHAR), 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, JSON_OBJECT('id_despacho_unidad', NEW.id_despacho_unidad, 'id_seguridad', NEW.id_seguridad, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_usuario_asigna', NEW.id_usuario_asigna, 'modo_asignacion', NEW.modo_asignacion, 'estado_despacho', NEW.estado_despacho, 'fecha_asignacion', NEW.fecha_asignacion, 'fecha_cierre', NEW.fecha_cierre, 'ubicacion_salida', NEW.ubicacion_salida, 'ubicacion_evento', NEW.ubicacion_evento, 'ubicacion_cierre', NEW.ubicacion_cierre, 'observaciones', NEW.observaciones, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_despachos_unidades_au_audit` AFTER UPDATE ON `despachos_unidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'despachos_unidades', 'UPDATE', CAST(NEW.id_despacho_unidad AS CHAR), 'UPDATE en despachos_unidades', 'Se actualizo un registro en despachos_unidades', JSON_OBJECT('id_despacho_unidad', OLD.id_despacho_unidad, 'id_seguridad', OLD.id_seguridad, 'id_unidad', OLD.id_unidad, 'id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'id_usuario_asigna', OLD.id_usuario_asigna, 'modo_asignacion', OLD.modo_asignacion, 'estado_despacho', OLD.estado_despacho, 'fecha_asignacion', OLD.fecha_asignacion, 'fecha_cierre', OLD.fecha_cierre, 'ubicacion_salida', OLD.ubicacion_salida, 'ubicacion_evento', OLD.ubicacion_evento, 'ubicacion_cierre', OLD.ubicacion_cierre, 'observaciones', OLD.observaciones, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_despacho_unidad', NEW.id_despacho_unidad, 'id_seguridad', NEW.id_seguridad, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_usuario_asigna', NEW.id_usuario_asigna, 'modo_asignacion', NEW.modo_asignacion, 'estado_despacho', NEW.estado_despacho, 'fecha_asignacion', NEW.fecha_asignacion, 'fecha_cierre', NEW.fecha_cierre, 'ubicacion_salida', NEW.ubicacion_salida, 'ubicacion_evento', NEW.ubicacion_evento, 'ubicacion_cierre', NEW.ubicacion_cierre, 'observaciones', NEW.observaciones, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_despachos_unidades_bd_block_delete` BEFORE DELETE ON `despachos_unidades` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla despachos_unidades. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_empleados_ai_audit` AFTER INSERT ON `empleados` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'empleados', 'INSERT', CAST(NEW.id_empleado AS CHAR), 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, JSON_OBJECT('id_empleado', NEW.id_empleado, 'cedula', NEW.cedula, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'id_dependencia', NEW.id_dependencia, 'telefono', NEW.telefono, 'correo', NEW.correo, 'direccion', NEW.direccion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_empleados_au_audit` AFTER UPDATE ON `empleados` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'empleados', 'UPDATE', CAST(NEW.id_empleado AS CHAR), 'UPDATE en empleados', 'Se actualizo un registro en empleados', JSON_OBJECT('id_empleado', OLD.id_empleado, 'cedula', OLD.cedula, 'nombre', OLD.nombre, 'apellido', OLD.apellido, 'id_dependencia', OLD.id_dependencia, 'telefono', OLD.telefono, 'correo', OLD.correo, 'direccion', OLD.direccion, 'estado', OLD.estado), JSON_OBJECT('id_empleado', NEW.id_empleado, 'cedula', NEW.cedula, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'id_dependencia', NEW.id_dependencia, 'telefono', NEW.telefono, 'correo', NEW.correo, 'direccion', NEW.direccion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_empleados_bd_block_delete` BEFORE DELETE ON `empleados` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla empleados. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_estados_solicitudes_ai_audit` AFTER INSERT ON `estados_solicitudes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'estados_solicitudes', 'INSERT', CAST(NEW.id_estado_solicitud AS CHAR), 'INSERT en estados_solicitudes', 'Se inserto un registro en estados_solicitudes', NULL, JSON_OBJECT('id_estado_solicitud', NEW.id_estado_solicitud, 'codigo_estado', NEW.codigo_estado, 'nombre_estado', NEW.nombre_estado, 'descripcion', NEW.descripcion, 'clase_badge', NEW.clase_badge, 'es_atendida', NEW.es_atendida, 'orden_visual', NEW.orden_visual, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_estados_solicitudes_au_audit` AFTER UPDATE ON `estados_solicitudes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'estados_solicitudes', 'UPDATE', CAST(NEW.id_estado_solicitud AS CHAR), 'UPDATE en estados_solicitudes', 'Se actualizo un registro en estados_solicitudes', JSON_OBJECT('id_estado_solicitud', OLD.id_estado_solicitud, 'codigo_estado', OLD.codigo_estado, 'nombre_estado', OLD.nombre_estado, 'descripcion', OLD.descripcion, 'clase_badge', OLD.clase_badge, 'es_atendida', OLD.es_atendida, 'orden_visual', OLD.orden_visual, 'estado', OLD.estado), JSON_OBJECT('id_estado_solicitud', NEW.id_estado_solicitud, 'codigo_estado', NEW.codigo_estado, 'nombre_estado', NEW.nombre_estado, 'descripcion', NEW.descripcion, 'clase_badge', NEW.clase_badge, 'es_atendida', NEW.es_atendida, 'orden_visual', NEW.orden_visual, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_estados_solicitudes_bd_block_delete` BEFORE DELETE ON `estados_solicitudes` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla estados_solicitudes. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_permisos_ai_audit` AFTER INSERT ON `permisos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'permisos', 'INSERT', CAST(NEW.id_permiso AS CHAR), 'INSERT en permisos', 'Se inserto un registro en permisos', NULL, JSON_OBJECT('id_permiso', NEW.id_permiso, 'nombre_permiso', NEW.nombre_permiso, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_permisos_au_audit` AFTER UPDATE ON `permisos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'permisos', 'UPDATE', CAST(NEW.id_permiso AS CHAR), 'UPDATE en permisos', 'Se actualizo un registro en permisos', JSON_OBJECT('id_permiso', OLD.id_permiso, 'nombre_permiso', OLD.nombre_permiso, 'descripcion', OLD.descripcion, 'estado', OLD.estado), JSON_OBJECT('id_permiso', NEW.id_permiso, 'nombre_permiso', NEW.nombre_permiso, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_permisos_bd_block_delete` BEFORE DELETE ON `permisos` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla permisos. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_reportes_solicitudes_ambulancia_ai_audit` AFTER INSERT ON `reportes_solicitudes_ambulancia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_solicitudes_ambulancia', 'INSERT', CAST(NEW.id_reporte_solicitud AS CHAR), 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, JSON_OBJECT('id_reporte_solicitud', NEW.id_reporte_solicitud, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'tipo_reporte', NEW.tipo_reporte, 'nombre_archivo', NEW.nombre_archivo, 'ruta_archivo', NEW.ruta_archivo, 'estado_envio', NEW.estado_envio, 'correo_destino', NEW.correo_destino, 'fecha_envio', NEW.fecha_envio, 'detalle_envio', NEW.detalle_envio, 'id_usuario_genera', NEW.id_usuario_genera, 'fecha_generacion', NEW.fecha_generacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_reportes_solicitudes_ambulancia_au_audit` AFTER UPDATE ON `reportes_solicitudes_ambulancia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_solicitudes_ambulancia', 'UPDATE', CAST(NEW.id_reporte_solicitud AS CHAR), 'UPDATE en reportes_solicitudes_ambulancia', 'Se actualizo un registro en reportes_solicitudes_ambulancia', JSON_OBJECT('id_reporte_solicitud', OLD.id_reporte_solicitud, 'id_seguridad', OLD.id_seguridad, 'id_despacho_unidad', OLD.id_despacho_unidad, 'tipo_reporte', OLD.tipo_reporte, 'nombre_archivo', OLD.nombre_archivo, 'ruta_archivo', OLD.ruta_archivo, 'estado_envio', OLD.estado_envio, 'correo_destino', OLD.correo_destino, 'fecha_envio', OLD.fecha_envio, 'detalle_envio', OLD.detalle_envio, 'id_usuario_genera', OLD.id_usuario_genera, 'fecha_generacion', OLD.fecha_generacion, 'estado', OLD.estado), JSON_OBJECT('id_reporte_solicitud', NEW.id_reporte_solicitud, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'tipo_reporte', NEW.tipo_reporte, 'nombre_archivo', NEW.nombre_archivo, 'ruta_archivo', NEW.ruta_archivo, 'estado_envio', NEW.estado_envio, 'correo_destino', NEW.correo_destino, 'fecha_envio', NEW.fecha_envio, 'detalle_envio', NEW.detalle_envio, 'id_usuario_genera', NEW.id_usuario_genera, 'fecha_generacion', NEW.fecha_generacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_reportes_solicitudes_ambulancia_bd_block_delete` BEFORE DELETE ON `reportes_solicitudes_ambulancia` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla reportes_solicitudes_ambulancia. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_reportes_traslado_ai_audit` AFTER INSERT ON `reportes_traslado` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_traslado', 'INSERT', CAST(NEW.id_reporte AS CHAR), 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, JSON_OBJECT('id_reporte', NEW.id_reporte, 'id_ayuda', NEW.id_ayuda, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'id_usuario_operador', NEW.id_usuario_operador, 'id_empleado_chofer', NEW.id_empleado_chofer, 'id_unidad', NEW.id_unidad, 'ticket_interno', NEW.ticket_interno, 'fecha_hora', NEW.fecha_hora, 'diagnostico_paciente', NEW.diagnostico_paciente, 'foto_evidencia', NEW.foto_evidencia, 'km_salida', NEW.km_salida, 'km_llegada', NEW.km_llegada, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_reportes_traslado_au_audit` AFTER UPDATE ON `reportes_traslado` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_traslado', 'UPDATE', CAST(NEW.id_reporte AS CHAR), 'UPDATE en reportes_traslado', 'Se actualizo un registro en reportes_traslado', JSON_OBJECT('id_reporte', OLD.id_reporte, 'id_ayuda', OLD.id_ayuda, 'id_seguridad', OLD.id_seguridad, 'id_despacho_unidad', OLD.id_despacho_unidad, 'id_usuario_operador', OLD.id_usuario_operador, 'id_empleado_chofer', OLD.id_empleado_chofer, 'id_unidad', OLD.id_unidad, 'ticket_interno', OLD.ticket_interno, 'fecha_hora', OLD.fecha_hora, 'diagnostico_paciente', OLD.diagnostico_paciente, 'foto_evidencia', OLD.foto_evidencia, 'km_salida', OLD.km_salida, 'km_llegada', OLD.km_llegada, 'estado', OLD.estado), JSON_OBJECT('id_reporte', NEW.id_reporte, 'id_ayuda', NEW.id_ayuda, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'id_usuario_operador', NEW.id_usuario_operador, 'id_empleado_chofer', NEW.id_empleado_chofer, 'id_unidad', NEW.id_unidad, 'ticket_interno', NEW.ticket_interno, 'fecha_hora', NEW.fecha_hora, 'diagnostico_paciente', NEW.diagnostico_paciente, 'foto_evidencia', NEW.foto_evidencia, 'km_salida', NEW.km_salida, 'km_llegada', NEW.km_llegada, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_reportes_traslado_bd_block_delete` BEFORE DELETE ON `reportes_traslado` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla reportes_traslado. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_seguimientos_solicitudes_ai_audit` AFTER INSERT ON `seguimientos_solicitudes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguimientos_solicitudes', 'INSERT', CAST(NEW.id_seguimiento_solicitud AS CHAR), 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, JSON_OBJECT('id_seguimiento_solicitud', NEW.id_seguimiento_solicitud, 'modulo', NEW.modulo, 'id_referencia', NEW.id_referencia, 'id_estado_solicitud', NEW.id_estado_solicitud, 'id_usuario', NEW.id_usuario, 'fecha_gestion', NEW.fecha_gestion, 'observacion', NEW.observacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_seguimientos_solicitudes_au_audit` AFTER UPDATE ON `seguimientos_solicitudes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguimientos_solicitudes', 'UPDATE', CAST(NEW.id_seguimiento_solicitud AS CHAR), 'UPDATE en seguimientos_solicitudes', 'Se actualizo un registro en seguimientos_solicitudes', JSON_OBJECT('id_seguimiento_solicitud', OLD.id_seguimiento_solicitud, 'modulo', OLD.modulo, 'id_referencia', OLD.id_referencia, 'id_estado_solicitud', OLD.id_estado_solicitud, 'id_usuario', OLD.id_usuario, 'fecha_gestion', OLD.fecha_gestion, 'observacion', OLD.observacion, 'estado', OLD.estado), JSON_OBJECT('id_seguimiento_solicitud', NEW.id_seguimiento_solicitud, 'modulo', NEW.modulo, 'id_referencia', NEW.id_referencia, 'id_estado_solicitud', NEW.id_estado_solicitud, 'id_usuario', NEW.id_usuario, 'fecha_gestion', NEW.fecha_gestion, 'observacion', NEW.observacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_seguimientos_solicitudes_bd_block_delete` BEFORE DELETE ON `seguimientos_solicitudes` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla seguimientos_solicitudes. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_seguridad_ai_audit` AFTER INSERT ON `seguridad` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguridad', 'INSERT', CAST(NEW.id_seguridad AS CHAR), 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, JSON_OBJECT('id_seguridad', NEW.id_seguridad, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_seguridad', NEW.id_tipo_seguridad, 'id_solicitud_seguridad', NEW.id_solicitud_seguridad, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_seguridad', NEW.tipo_seguridad, 'tipo_solicitud', NEW.tipo_solicitud, 'fecha_seguridad', NEW.fecha_seguridad, 'descripcion', NEW.descripcion, 'estado_atencion', NEW.estado_atencion, 'ubicacion_evento', NEW.ubicacion_evento, 'referencia_evento', NEW.referencia_evento, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_seguridad_au_audit` AFTER UPDATE ON `seguridad` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguridad', 'UPDATE', CAST(NEW.id_seguridad AS CHAR), 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', JSON_OBJECT('id_seguridad', OLD.id_seguridad, 'ticket_interno', OLD.ticket_interno, 'id_beneficiario', OLD.id_beneficiario, 'id_usuario', OLD.id_usuario, 'id_tipo_seguridad', OLD.id_tipo_seguridad, 'id_solicitud_seguridad', OLD.id_solicitud_seguridad, 'id_estado_solicitud', OLD.id_estado_solicitud, 'tipo_seguridad', OLD.tipo_seguridad, 'tipo_solicitud', OLD.tipo_solicitud, 'fecha_seguridad', OLD.fecha_seguridad, 'descripcion', OLD.descripcion, 'estado_atencion', OLD.estado_atencion, 'ubicacion_evento', OLD.ubicacion_evento, 'referencia_evento', OLD.referencia_evento, 'estado', OLD.estado), JSON_OBJECT('id_seguridad', NEW.id_seguridad, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_seguridad', NEW.id_tipo_seguridad, 'id_solicitud_seguridad', NEW.id_solicitud_seguridad, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_seguridad', NEW.tipo_seguridad, 'tipo_solicitud', NEW.tipo_solicitud, 'fecha_seguridad', NEW.fecha_seguridad, 'descripcion', NEW.descripcion, 'estado_atencion', NEW.estado_atencion, 'ubicacion_evento', NEW.ubicacion_evento, 'referencia_evento', NEW.referencia_evento, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_seguridad_bd_block_delete` BEFORE DELETE ON `seguridad` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla seguridad. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_servicios_publicos_ai_audit` AFTER INSERT ON `servicios_publicos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'servicios_publicos', 'INSERT', CAST(NEW.id_servicio AS CHAR), 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, JSON_OBJECT('id_servicio', NEW.id_servicio, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'id_solicitud_servicio_publico', NEW.id_solicitud_servicio_publico, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_servicio', NEW.tipo_servicio, 'solicitud_servicio', NEW.solicitud_servicio, 'fecha_servicio', NEW.fecha_servicio, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_servicios_publicos_au_audit` AFTER UPDATE ON `servicios_publicos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'servicios_publicos', 'UPDATE', CAST(NEW.id_servicio AS CHAR), 'UPDATE en servicios_publicos', 'Se actualizo un registro en servicios_publicos', JSON_OBJECT('id_servicio', OLD.id_servicio, 'ticket_interno', OLD.ticket_interno, 'id_beneficiario', OLD.id_beneficiario, 'id_usuario', OLD.id_usuario, 'id_tipo_servicio_publico', OLD.id_tipo_servicio_publico, 'id_solicitud_servicio_publico', OLD.id_solicitud_servicio_publico, 'id_estado_solicitud', OLD.id_estado_solicitud, 'tipo_servicio', OLD.tipo_servicio, 'solicitud_servicio', OLD.solicitud_servicio, 'fecha_servicio', OLD.fecha_servicio, 'descripcion', OLD.descripcion, 'estado', OLD.estado), JSON_OBJECT('id_servicio', NEW.id_servicio, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'id_solicitud_servicio_publico', NEW.id_solicitud_servicio_publico, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_servicio', NEW.tipo_servicio, 'solicitud_servicio', NEW.solicitud_servicio, 'fecha_servicio', NEW.fecha_servicio, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_servicios_publicos_bd_block_delete` BEFORE DELETE ON `servicios_publicos` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla servicios_publicos. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_solicitudes_generales_ai_audit` AFTER INSERT ON `solicitudes_generales` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'solicitudes_generales', 'INSERT', CAST(NEW.id_solicitud_general AS CHAR), 'INSERT en solicitudes_generales', 'Se inserto un registro en solicitudes_generales', NULL, JSON_OBJECT('id_solicitud_general', NEW.id_solicitud_general, 'codigo_solicitud', NEW.codigo_solicitud, 'nombre_solicitud', NEW.nombre_solicitud, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_solicitudes_generales_au_audit` AFTER UPDATE ON `solicitudes_generales` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'solicitudes_generales', 'UPDATE', CAST(NEW.id_solicitud_general AS CHAR), 'UPDATE en solicitudes_generales', 'Se actualizo un registro en solicitudes_generales', JSON_OBJECT('id_solicitud_general', OLD.id_solicitud_general, 'codigo_solicitud', OLD.codigo_solicitud, 'nombre_solicitud', OLD.nombre_solicitud, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_solicitud_general', NEW.id_solicitud_general, 'codigo_solicitud', NEW.codigo_solicitud, 'nombre_solicitud', NEW.nombre_solicitud, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_solicitudes_generales_bd_block_delete` BEFORE DELETE ON `solicitudes_generales` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla solicitudes_generales. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_tipos_ayuda_social_ai_audit` AFTER INSERT ON `tipos_ayuda_social` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_ayuda_social', 'INSERT', CAST(NEW.id_tipo_ayuda_social AS CHAR), 'INSERT en tipos_ayuda_social', 'Se inserto un registro en tipos_ayuda_social', NULL, JSON_OBJECT('id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'nombre_tipo_ayuda', NEW.nombre_tipo_ayuda, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_tipos_ayuda_social_au_audit` AFTER UPDATE ON `tipos_ayuda_social` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_ayuda_social', 'UPDATE', CAST(NEW.id_tipo_ayuda_social AS CHAR), 'UPDATE en tipos_ayuda_social', 'Se actualizo un registro en tipos_ayuda_social', JSON_OBJECT('id_tipo_ayuda_social', OLD.id_tipo_ayuda_social, 'nombre_tipo_ayuda', OLD.nombre_tipo_ayuda, 'requiere_ambulancia', OLD.requiere_ambulancia, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'nombre_tipo_ayuda', NEW.nombre_tipo_ayuda, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_tipos_ayuda_social_bd_block_delete` BEFORE DELETE ON `tipos_ayuda_social` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_ayuda_social. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_tipos_seguridad_emergencia_ai_audit` AFTER INSERT ON `tipos_seguridad_emergencia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_seguridad_emergencia', 'INSERT', CAST(NEW.id_tipo_seguridad AS CHAR), 'INSERT en tipos_seguridad_emergencia', 'Se inserto un registro en tipos_seguridad_emergencia', NULL, JSON_OBJECT('id_tipo_seguridad', NEW.id_tipo_seguridad, 'nombre_tipo', NEW.nombre_tipo, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_tipos_seguridad_emergencia_au_audit` AFTER UPDATE ON `tipos_seguridad_emergencia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_seguridad_emergencia', 'UPDATE', CAST(NEW.id_tipo_seguridad AS CHAR), 'UPDATE en tipos_seguridad_emergencia', 'Se actualizo un registro en tipos_seguridad_emergencia', JSON_OBJECT('id_tipo_seguridad', OLD.id_tipo_seguridad, 'nombre_tipo', OLD.nombre_tipo, 'requiere_ambulancia', OLD.requiere_ambulancia, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_tipo_seguridad', NEW.id_tipo_seguridad, 'nombre_tipo', NEW.nombre_tipo, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_tipos_seguridad_emergencia_bd_block_delete` BEFORE DELETE ON `tipos_seguridad_emergencia` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_seguridad_emergencia. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_tipos_servicios_publicos_ai_audit` AFTER INSERT ON `tipos_servicios_publicos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_servicios_publicos', 'INSERT', CAST(NEW.id_tipo_servicio_publico AS CHAR), 'INSERT en tipos_servicios_publicos', 'Se inserto un registro en tipos_servicios_publicos', NULL, JSON_OBJECT('id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'codigo_tipo_servicio_publico', NEW.codigo_tipo_servicio_publico, 'nombre_tipo_servicio', NEW.nombre_tipo_servicio, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_tipos_servicios_publicos_au_audit` AFTER UPDATE ON `tipos_servicios_publicos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_servicios_publicos', 'UPDATE', CAST(NEW.id_tipo_servicio_publico AS CHAR), 'UPDATE en tipos_servicios_publicos', 'Se actualizo un registro en tipos_servicios_publicos', JSON_OBJECT('id_tipo_servicio_publico', OLD.id_tipo_servicio_publico, 'codigo_tipo_servicio_publico', OLD.codigo_tipo_servicio_publico, 'nombre_tipo_servicio', OLD.nombre_tipo_servicio, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'codigo_tipo_servicio_publico', NEW.codigo_tipo_servicio_publico, 'nombre_tipo_servicio', NEW.nombre_tipo_servicio, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_tipos_servicios_publicos_bd_block_delete` BEFORE DELETE ON `tipos_servicios_publicos` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_servicios_publicos. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_unidades_ai_audit` AFTER INSERT ON `unidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'unidades', 'INSERT', CAST(NEW.id_unidad AS CHAR), 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, JSON_OBJECT('id_unidad', NEW.id_unidad, 'codigo_unidad', NEW.codigo_unidad, 'descripcion', NEW.descripcion, 'placa', NEW.placa, 'estado', NEW.estado, 'estado_operativo', NEW.estado_operativo, 'ubicacion_actual', NEW.ubicacion_actual, 'referencia_actual', NEW.referencia_actual, 'prioridad_despacho', NEW.prioridad_despacho, 'fecha_actualizacion_operativa', NEW.fecha_actualizacion_operativa), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_unidades_au_audit` AFTER UPDATE ON `unidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'unidades', 'UPDATE', CAST(NEW.id_unidad AS CHAR), 'UPDATE en unidades', 'Se actualizo un registro en unidades', JSON_OBJECT('id_unidad', OLD.id_unidad, 'codigo_unidad', OLD.codigo_unidad, 'descripcion', OLD.descripcion, 'placa', OLD.placa, 'estado', OLD.estado, 'estado_operativo', OLD.estado_operativo, 'ubicacion_actual', OLD.ubicacion_actual, 'referencia_actual', OLD.referencia_actual, 'prioridad_despacho', OLD.prioridad_despacho, 'fecha_actualizacion_operativa', OLD.fecha_actualizacion_operativa), JSON_OBJECT('id_unidad', NEW.id_unidad, 'codigo_unidad', NEW.codigo_unidad, 'descripcion', NEW.descripcion, 'placa', NEW.placa, 'estado', NEW.estado, 'estado_operativo', NEW.estado_operativo, 'ubicacion_actual', NEW.ubicacion_actual, 'referencia_actual', NEW.referencia_actual, 'prioridad_despacho', NEW.prioridad_despacho, 'fecha_actualizacion_operativa', NEW.fecha_actualizacion_operativa), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_unidades_bd_block_delete` BEFORE DELETE ON `unidades` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla unidades. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_usuarios_ai_audit` AFTER INSERT ON `usuarios` FOR EACH ROW BEGIN
  INSERT INTO bitacora (
      id_usuario,
      tabla_afectada,
      accion,
      id_registro,
      resumen,
      detalle,
      datos_antes,
      datos_despues,
      usuario_bd,
      fecha_evento,
      estado
  )
  VALUES (
      NULL,
      'usuarios',
      'INSERT',
      CAST(NEW.id_usuario AS CHAR),
      'INSERT en usuarios',
      'Se inserto un registro en usuarios',
      NULL,
      JSON_OBJECT(
          'id_usuario', NEW.id_usuario,
          'id_empleado', NEW.id_empleado,
          'usuario', NEW.usuario,
          'password', NEW.password,
          'rol', NEW.rol,
          'estado', NEW.estado
      ),
      CURRENT_USER(),
      NOW(),
      1
  );
END
$$

CREATE TRIGGER `tr_usuarios_au_audit` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
  INSERT INTO bitacora (
      id_usuario,
      tabla_afectada,
      accion,
      id_registro,
      resumen,
      detalle,
      datos_antes,
      datos_despues,
      usuario_bd,
      fecha_evento,
      estado
  )
  VALUES (
      NULL,
      'usuarios',
      'UPDATE',
      CAST(NEW.id_usuario AS CHAR),
      'UPDATE en usuarios',
      'Se actualizo un registro en usuarios',
      JSON_OBJECT(
          'id_usuario', OLD.id_usuario,
          'id_empleado', OLD.id_empleado,
          'usuario', OLD.usuario,
          'password', OLD.password,
          'rol', OLD.rol,
          'estado', OLD.estado
      ),
      JSON_OBJECT(
          'id_usuario', NEW.id_usuario,
          'id_empleado', NEW.id_empleado,
          'usuario', NEW.usuario,
          'password', NEW.password,
          'rol', NEW.rol,
          'estado', NEW.estado
      ),
      CURRENT_USER(),
      NOW(),
      1
  );
END
$$

CREATE TRIGGER `tr_usuarios_bd_block_delete` BEFORE DELETE ON `usuarios` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuarios. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_usuarios_seguridad_acceso_ai_audit` AFTER INSERT ON `usuarios_seguridad_acceso` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuarios_seguridad_acceso', 'INSERT', CAST(NEW.id_usuario AS CHAR), 'INSERT en usuarios_seguridad_acceso', 'Se inserto un registro en usuarios_seguridad_acceso', NULL, JSON_OBJECT('id_usuario', NEW.id_usuario, 'intentos_fallidos', NEW.intentos_fallidos, 'bloqueado', NEW.bloqueado, 'fecha_bloqueo', NEW.fecha_bloqueo, 'password_temporal', NEW.password_temporal, 'fecha_password_temporal', NEW.fecha_password_temporal, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_usuarios_seguridad_acceso_au_audit` AFTER UPDATE ON `usuarios_seguridad_acceso` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuarios_seguridad_acceso', 'UPDATE', CAST(NEW.id_usuario AS CHAR), 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', JSON_OBJECT('id_usuario', OLD.id_usuario, 'intentos_fallidos', OLD.intentos_fallidos, 'bloqueado', OLD.bloqueado, 'fecha_bloqueo', OLD.fecha_bloqueo, 'password_temporal', OLD.password_temporal, 'fecha_password_temporal', OLD.fecha_password_temporal, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_usuario', NEW.id_usuario, 'intentos_fallidos', NEW.intentos_fallidos, 'bloqueado', NEW.bloqueado, 'fecha_bloqueo', NEW.fecha_bloqueo, 'password_temporal', NEW.password_temporal, 'fecha_password_temporal', NEW.fecha_password_temporal, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_usuarios_seguridad_acceso_bd_block_delete` BEFORE DELETE ON `usuarios_seguridad_acceso` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuarios_seguridad_acceso. Use eliminacion logica.';
END
$$

CREATE TRIGGER `tr_usuario_permisos_ai_audit` AFTER INSERT ON `usuario_permisos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuario_permisos', 'INSERT', CAST(NEW.id_usuario_permiso AS CHAR), 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, JSON_OBJECT('id_usuario_permiso', NEW.id_usuario_permiso, 'id_usuario', NEW.id_usuario, 'id_permiso', NEW.id_permiso, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_usuario_permisos_au_audit` AFTER UPDATE ON `usuario_permisos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuario_permisos', 'UPDATE', CAST(NEW.id_usuario_permiso AS CHAR), 'UPDATE en usuario_permisos', 'Se actualizo un registro en usuario_permisos', JSON_OBJECT('id_usuario_permiso', OLD.id_usuario_permiso, 'id_usuario', OLD.id_usuario, 'id_permiso', OLD.id_permiso, 'estado', OLD.estado), JSON_OBJECT('id_usuario_permiso', NEW.id_usuario_permiso, 'id_usuario', NEW.id_usuario, 'id_permiso', NEW.id_permiso, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$

CREATE TRIGGER `tr_usuario_permisos_bd_block_delete` BEFORE DELETE ON `usuario_permisos` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuario_permisos. Use eliminacion logica.';
END
$$

DELIMITER ;

-- ============================================================
-- ESQUEMA DE RESPALDO: sala_situacional_respaldo_bitacora
-- ============================================================
USE `sala_situacional_respaldo_bitacora`;

DROP EVENT IF EXISTS `ev_backup_bitacora_cada_minuto`;
DROP PROCEDURE IF EXISTS `sp_sync_bitacora_desde_operativa`;
DROP PROCEDURE IF EXISTS `sp_respaldo_bitacora_resumen`;
DROP TABLE IF EXISTS `control_respaldo_bitacora`;
DROP TABLE IF EXISTS `bitacora_respaldo`;

CREATE TABLE `bitacora_respaldo` (
  `id_bitacora` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `tabla_afectada` varchar(64) DEFAULT NULL,
  `accion` varchar(20) NOT NULL DEFAULT 'LEGACY',
  `id_registro` varchar(64) DEFAULT NULL,
  `resumen` varchar(100) NOT NULL,
  `detalle` text DEFAULT NULL,
  `datos_antes` longtext DEFAULT NULL,
  `datos_despues` longtext DEFAULT NULL,
  `usuario_bd` varchar(100) DEFAULT NULL,
  `ipaddr` varchar(45) DEFAULT '127.0.0.1',
  `moment` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_evento` datetime NOT NULL DEFAULT current_timestamp(),
  `estado` tinyint(1) NOT NULL DEFAULT 1,
  `origen_bd` varchar(64) NOT NULL DEFAULT 'sala_situacional',
  `fecha_respaldo` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `control_respaldo_bitacora` (
  `id_control` tinyint(1) NOT NULL,
  `ultimo_id_bitacora` int(11) NOT NULL DEFAULT 0,
  `registros_insertados` int(11) NOT NULL DEFAULT 0,
  `fecha_ultimo_respaldo` datetime DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'PENDIENTE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `bitacora_respaldo` (`id_bitacora`, `id_usuario`, `tabla_afectada`, `accion`, `id_registro`, `resumen`, `detalle`, `datos_antes`, `datos_despues`, `usuario_bd`, `ipaddr`, `moment`, `fecha_evento`, `estado`, `origen_bd`, `fecha_respaldo`) VALUES
(1, NULL, 'empleados', 'UPDATE', '2', 'UPDATE en empleados', 'Se actualizo un registro en empleados', '{\"id_empleado\": 2, \"cedula\": 22222222, \"nombre\": \"Laura\", \"apellido\": \"Franco\", \"id_dependencia\": 3, \"telefono\": \"04244668450\", \"correo\": \"flaura2705@gmail.com\", \"direccion\": \"Libetrador - tocuyito\", \"estado\": 1}', '{\"id_empleado\": 2, \"cedula\": 24329534, \"nombre\": \"Laura\", \"apellido\": \"Franco\", \"id_dependencia\": 3, \"telefono\": \"04244668450\", \"correo\": \"flaura2705@gmail.com\", \"direccion\": \"Libetrador - tocuyito\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:02:31', '2026-03-23 22:02:31', 1, 'sala_situacional', '2026-03-23 22:02:36'),
(2, NULL, 'empleados', 'UPDATE', '1', 'UPDATE en empleados', 'Se actualizo un registro en empleados', '{\"id_empleado\": 1, \"cedula\": 123456789, \"nombre\": \"Elsy\", \"apellido\": \"Meza\", \"id_dependencia\": 6, \"telefono\": \"04269390643\", \"correo\": \"meza.elsy@gmail.com\", \"direccion\": \"San Diego\", \"estado\": 1}', '{\"id_empleado\": 1, \"cedula\": 14382513, \"nombre\": \"Elsy\", \"apellido\": \"Meza\", \"id_dependencia\": 6, \"telefono\": \"04269390643\", \"correo\": \"meza.elsy@gmail.com\", \"direccion\": \"San Diego\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:03:04', '2026-03-23 22:03:04', 1, 'sala_situacional', '2026-03-23 22:03:36'),
(3, NULL, 'empleados', 'INSERT', '6', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 6, \"cedula\": 26789012, \"nombre\": \"Luis Alberto\", \"apellido\": \"Romero\", \"id_dependencia\": 7, \"telefono\": \"0424-5503414\", \"correo\": \"luis.romero@situacional.demo\", \"direccion\": \"Parroquia Independencia\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(4, NULL, 'empleados', 'INSERT', '7', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 7, \"cedula\": 19654321, \"nombre\": \"Carmen Elena\", \"apellido\": \"Vargas\", \"id_dependencia\": 4, \"telefono\": \"0416-5503415\", \"correo\": \"carmen.vargas@situacional.demo\", \"direccion\": \"Barrio El Oasis\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(5, NULL, 'empleados', 'INSERT', '8', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 8, \"cedula\": 21567890, \"nombre\": \"Pedro Antonio\", \"apellido\": \"Rivas\", \"id_dependencia\": 2, \"telefono\": \"0412-5503416\", \"correo\": \"pedro.rivas@situacional.demo\", \"direccion\": \"Urbanizacion La Esperanza\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(6, NULL, 'empleados', 'INSERT', '9', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 9, \"cedula\": 18345678, \"nombre\": \"Ana Beatriz\", \"apellido\": \"Salazar\", \"id_dependencia\": 4, \"telefono\": \"0414-5503417\", \"correo\": \"ana.salazar@situacional.demo\", \"direccion\": \"Santa Eduviges\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(7, NULL, 'empleados', 'INSERT', '10', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 10, \"cedula\": 25432109, \"nombre\": \"Ramon Eduardo\", \"apellido\": \"Suarez\", \"id_dependencia\": 3, \"telefono\": \"0424-5503418\", \"correo\": \"ramon.suarez@situacional.demo\", \"direccion\": \"Comunidad Bicentenario\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(8, NULL, 'usuarios', 'INSERT', '2', 'INSERT en usuarios', 'Se inserto un registro en usuarios', NULL, '{\"id_usuario\": 2, \"id_empleado\": 4, \"usuario\": \"operador.sala\", \"password\": \"163c228e938c409a30b29992fe3cf9856c4b8480af5b0900c9d384d541566888\", \"rol\": \"OPERADOR\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(9, NULL, 'usuarios_seguridad_acceso', 'UPDATE', '2', 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 21:22:18\"}', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-20 08:00:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(10, NULL, 'usuario_permisos', 'INSERT', '10', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 10, \"id_usuario\": 2, \"id_permiso\": 1, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(11, NULL, 'usuario_permisos', 'INSERT', '11', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 11, \"id_usuario\": 2, \"id_permiso\": 2, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(12, NULL, 'usuario_permisos', 'INSERT', '12', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 12, \"id_usuario\": 2, \"id_permiso\": 3, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(13, NULL, 'usuario_permisos', 'INSERT', '13', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 13, \"id_usuario\": 2, \"id_permiso\": 4, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(14, NULL, 'usuario_permisos', 'INSERT', '14', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 14, \"id_usuario\": 2, \"id_permiso\": 5, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(15, NULL, 'usuario_permisos', 'INSERT', '15', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 15, \"id_usuario\": 2, \"id_permiso\": 7, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(16, NULL, 'usuario_permisos', 'INSERT', '16', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 16, \"id_usuario\": 2, \"id_permiso\": 8, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(17, NULL, 'usuarios', 'INSERT', '3', 'INSERT en usuarios', 'Se inserto un registro en usuarios', NULL, '{\"id_usuario\": 3, \"id_empleado\": 5, \"usuario\": \"atencion.ciudadana\", \"password\": \"163c228e938c409a30b29992fe3cf9856c4b8480af5b0900c9d384d541566888\", \"rol\": \"OPERADOR\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(18, NULL, 'usuarios_seguridad_acceso', 'INSERT', '3', 'INSERT en usuarios_seguridad_acceso', 'Se inserto un registro en usuarios_seguridad_acceso', NULL, '{\"id_usuario\": 3, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-20 08:05:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(19, NULL, 'usuario_permisos', 'INSERT', '17', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 17, \"id_usuario\": 3, \"id_permiso\": 1, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(20, NULL, 'usuario_permisos', 'INSERT', '18', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 18, \"id_usuario\": 3, \"id_permiso\": 3, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(21, NULL, 'usuario_permisos', 'INSERT', '19', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 19, \"id_usuario\": 3, \"id_permiso\": 5, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(22, NULL, 'usuarios', 'INSERT', '4', 'INSERT en usuarios', 'Se inserto un registro en usuarios', NULL, '{\"id_usuario\": 4, \"id_empleado\": 6, \"usuario\": \"consulta.tribunal\", \"password\": \"163c228e938c409a30b29992fe3cf9856c4b8480af5b0900c9d384d541566888\", \"rol\": \"CONSULTOR\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(23, NULL, 'usuarios_seguridad_acceso', 'INSERT', '4', 'INSERT en usuarios_seguridad_acceso', 'Se inserto un registro en usuarios_seguridad_acceso', NULL, '{\"id_usuario\": 4, \"intentos_fallidos\": 1, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-21 10:00:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(24, NULL, 'usuario_permisos', 'INSERT', '20', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 20, \"id_usuario\": 4, \"id_permiso\": 2, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(25, NULL, 'usuario_permisos', 'INSERT', '21', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 21, \"id_usuario\": 4, \"id_permiso\": 7, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(26, NULL, 'beneficiarios', 'INSERT', '1', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 1, \"nacionalidad\": \"E\", \"cedula\": 15234000, \"nombre_beneficiario\": \"Maria Fernanda Rojas\", \"telefono\": \"0412-5100000\", \"id_comunidad\": 1, \"comunidad\": \"Casco Comercial de Tocuyito\", \"fecha_registro\": \"2026-02-15 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(27, NULL, 'beneficiarios', 'INSERT', '2', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 2, \"nacionalidad\": \"V\", \"cedula\": 15234431, \"nombre_beneficiario\": \"Jose Gregorio Navas\", \"telefono\": \"0414-5100137\", \"id_comunidad\": 2, \"comunidad\": \"Urbanizacion Valles de San Francisco\", \"fecha_registro\": \"2026-02-16 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(28, NULL, 'beneficiarios', 'INSERT', '3', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 3, \"nacionalidad\": \"V\", \"cedula\": 15234862, \"nombre_beneficiario\": \"Carmen Elena Perez\", \"telefono\": \"0424-5100274\", \"id_comunidad\": 3, \"comunidad\": \"Conjunto Residencial Los Trescientos\", \"fecha_registro\": \"2026-02-17 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(29, NULL, 'beneficiarios', 'INSERT', '4', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 4, \"nacionalidad\": \"V\", \"cedula\": 15235293, \"nombre_beneficiario\": \"Luis Alberto Romero\", \"telefono\": \"0426-5100411\", \"id_comunidad\": 4, \"comunidad\": \"Urbanizacion Jose Rafael Pocaterra\", \"fecha_registro\": \"2026-02-18 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(30, NULL, 'beneficiarios', 'INSERT', '5', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 5, \"nacionalidad\": \"V\", \"cedula\": 15235724, \"nombre_beneficiario\": \"Ana Karina Salcedo\", \"telefono\": \"0412-5100548\", \"id_comunidad\": 5, \"comunidad\": \"Centro Penitenciario Tocuyito\", \"fecha_registro\": \"2026-02-19 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(31, NULL, 'beneficiarios', 'INSERT', '6', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 6, \"nacionalidad\": \"V\", \"cedula\": 15236155, \"nombre_beneficiario\": \"Pedro Antonio Marquez\", \"telefono\": \"0414-5100685\", \"id_comunidad\": 6, \"comunidad\": \"Santa Eduviges\", \"fecha_registro\": \"2026-02-20 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(32, NULL, 'beneficiarios', 'INSERT', '7', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 7, \"nacionalidad\": \"V\", \"cedula\": 15236586, \"nombre_beneficiario\": \"Yelitza Carolina Gil\", \"telefono\": \"0424-5100822\", \"id_comunidad\": 7, \"comunidad\": \"Bella Vista\", \"fecha_registro\": \"2026-02-21 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(33, NULL, 'beneficiarios', 'INSERT', '8', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 8, \"nacionalidad\": \"V\", \"cedula\": 15237017, \"nombre_beneficiario\": \"Ramon Eduardo Suarez\", \"telefono\": \"0426-5100959\", \"id_comunidad\": 8, \"comunidad\": \"Los Mangos\", \"fecha_registro\": \"2026-02-22 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(34, NULL, 'beneficiarios', 'INSERT', '9', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 9, \"nacionalidad\": \"V\", \"cedula\": 15237448, \"nombre_beneficiario\": \"Andreina del Valle Medina\", \"telefono\": \"0412-5101096\", \"id_comunidad\": 9, \"comunidad\": \"La Herrerena\", \"fecha_registro\": \"2026-02-23 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(35, NULL, 'beneficiarios', 'INSERT', '10', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 10, \"nacionalidad\": \"E\", \"cedula\": 15237879, \"nombre_beneficiario\": \"Carlos Andres Sequera\", \"telefono\": \"0414-5101233\", \"id_comunidad\": 10, \"comunidad\": \"Urbanizacion La Esperanza\", \"fecha_registro\": \"2026-02-24 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(36, NULL, 'beneficiarios', 'INSERT', '11', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 11, \"nacionalidad\": \"V\", \"cedula\": 15238310, \"nombre_beneficiario\": \"Beatriz Elena Farias\", \"telefono\": \"0424-5101370\", \"id_comunidad\": 11, \"comunidad\": \"Triangulo El Oasis\", \"fecha_registro\": \"2026-02-25 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(37, NULL, 'beneficiarios', 'INSERT', '12', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 12, \"nacionalidad\": \"V\", \"cedula\": 15238741, \"nombre_beneficiario\": \"Juan Pablo Ortega\", \"telefono\": \"0426-5101507\", \"id_comunidad\": 12, \"comunidad\": \"Hacienda Juana Paula\", \"fecha_registro\": \"2026-02-26 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(38, NULL, 'beneficiarios', 'INSERT', '13', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 13, \"nacionalidad\": \"V\", \"cedula\": 15239172, \"nombre_beneficiario\": \"Norelys Alexandra Pino\", \"telefono\": \"0412-5101644\", \"id_comunidad\": 13, \"comunidad\": \"Encrucijada de Carabobo\", \"fecha_registro\": \"2026-02-27 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(39, NULL, 'beneficiarios', 'INSERT', '14', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 14, \"nacionalidad\": \"V\", \"cedula\": 15239603, \"nombre_beneficiario\": \"Daniel Enrique Salazar\", \"telefono\": \"0414-5101781\", \"id_comunidad\": 14, \"comunidad\": \"Urbanizacion Santa Paula\", \"fecha_registro\": \"2026-02-28 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(40, NULL, 'beneficiarios', 'INSERT', '15', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 15, \"nacionalidad\": \"V\", \"cedula\": 15240034, \"nombre_beneficiario\": \"Gledys Carolina Rivas\", \"telefono\": \"0424-5101918\", \"id_comunidad\": 15, \"comunidad\": \"Hacienda La Trinidad\", \"fecha_registro\": \"2026-03-01 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(41, NULL, 'beneficiarios', 'INSERT', '16', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 16, \"nacionalidad\": \"V\", \"cedula\": 15240465, \"nombre_beneficiario\": \"Victor Manuel Carvajal\", \"telefono\": \"0426-5102055\", \"id_comunidad\": 16, \"comunidad\": \"Hacienda El Rosario\", \"fecha_registro\": \"2026-03-02 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(42, NULL, 'beneficiarios', 'INSERT', '17', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 17, \"nacionalidad\": \"V\", \"cedula\": 15240896, \"nombre_beneficiario\": \"Yusmary del Carmen Flores\", \"telefono\": \"0412-5102192\", \"id_comunidad\": 17, \"comunidad\": \"El Rosario\", \"fecha_registro\": \"2026-03-03 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(43, NULL, 'beneficiarios', 'INSERT', '18', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 18, \"nacionalidad\": \"V\", \"cedula\": 15241327, \"nombre_beneficiario\": \"Julio Cesar Mendez\", \"telefono\": \"0414-5102329\", \"id_comunidad\": 18, \"comunidad\": \"El Rosal\", \"fecha_registro\": \"2026-03-04 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(44, NULL, 'beneficiarios', 'INSERT', '19', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 19, \"nacionalidad\": \"E\", \"cedula\": 15241758, \"nombre_beneficiario\": \"Adriana Paola Infante\", \"telefono\": \"0424-5102466\", \"id_comunidad\": 19, \"comunidad\": \"Los Rosales\", \"fecha_registro\": \"2026-03-05 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(45, NULL, 'beneficiarios', 'INSERT', '20', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 20, \"nacionalidad\": \"V\", \"cedula\": 15242189, \"nombre_beneficiario\": \"Wilmer Antonio Silva\", \"telefono\": \"0426-5102603\", \"id_comunidad\": 20, \"comunidad\": \"Colinas del Rosario\", \"fecha_registro\": \"2026-03-06 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(46, NULL, 'beneficiarios', 'INSERT', '21', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 21, \"nacionalidad\": \"V\", \"cedula\": 15242620, \"nombre_beneficiario\": \"Lisbeth Coromoto Barrios\", \"telefono\": \"0412-5102740\", \"id_comunidad\": 21, \"comunidad\": \"Barrio La Trinidad\", \"fecha_registro\": \"2026-03-07 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(47, NULL, 'beneficiarios', 'INSERT', '22', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 22, \"nacionalidad\": \"V\", \"cedula\": 15243051, \"nombre_beneficiario\": \"Hector Jose Villarroel\", \"telefono\": \"0414-5102877\", \"id_comunidad\": 22, \"comunidad\": \"Zanjon Dulce\", \"fecha_registro\": \"2026-03-08 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(48, NULL, 'beneficiarios', 'INSERT', '23', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 23, \"nacionalidad\": \"V\", \"cedula\": 15243482, \"nombre_beneficiario\": \"Damaris Elena Cabrera\", \"telefono\": \"0424-5103014\", \"id_comunidad\": 23, \"comunidad\": \"Escuela de Cadafe\", \"fecha_registro\": \"2026-03-09 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(49, NULL, 'beneficiarios', 'INSERT', '24', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 24, \"nacionalidad\": \"V\", \"cedula\": 15243913, \"nombre_beneficiario\": \"Franklin Javier Lozada\", \"telefono\": \"0426-5103151\", \"id_comunidad\": 24, \"comunidad\": \"12 de Octubre\", \"fecha_registro\": \"2026-03-10 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(50, NULL, 'beneficiarios', 'INSERT', '25', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 25, \"nacionalidad\": \"V\", \"cedula\": 15244344, \"nombre_beneficiario\": \"Marisela Josefina Quero\", \"telefono\": \"0412-5103288\", \"id_comunidad\": 1, \"comunidad\": \"Casco Comercial de Tocuyito\", \"fecha_registro\": \"2026-03-11 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(51, NULL, 'beneficiarios', 'INSERT', '26', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 26, \"nacionalidad\": \"V\", \"cedula\": 15244775, \"nombre_beneficiario\": \"Nelson David Zambrano\", \"telefono\": \"0414-5103425\", \"id_comunidad\": 2, \"comunidad\": \"Urbanizacion Valles de San Francisco\", \"fecha_registro\": \"2026-03-12 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(52, NULL, 'beneficiarios', 'INSERT', '27', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 27, \"nacionalidad\": \"V\", \"cedula\": 15245206, \"nombre_beneficiario\": \"Rosangelica Soto\", \"telefono\": \"0424-5103562\", \"id_comunidad\": 3, \"comunidad\": \"Conjunto Residencial Los Trescientos\", \"fecha_registro\": \"2026-03-13 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(53, NULL, 'beneficiarios', 'INSERT', '28', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 28, \"nacionalidad\": \"E\", \"cedula\": 15245637, \"nombre_beneficiario\": \"Reinaldo Antonio Acosta\", \"telefono\": \"0426-5103699\", \"id_comunidad\": 4, \"comunidad\": \"Urbanizacion Jose Rafael Pocaterra\", \"fecha_registro\": \"2026-03-14 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(54, NULL, 'beneficiarios', 'INSERT', '29', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 29, \"nacionalidad\": \"V\", \"cedula\": 15246068, \"nombre_beneficiario\": \"Marianela Torres\", \"telefono\": \"0412-5103836\", \"id_comunidad\": 5, \"comunidad\": \"Centro Penitenciario Tocuyito\", \"fecha_registro\": \"2026-03-15 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(55, NULL, 'beneficiarios', 'INSERT', '30', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 30, \"nacionalidad\": \"V\", \"cedula\": 15246499, \"nombre_beneficiario\": \"Edgar Rafael Villalobos\", \"telefono\": \"0414-5103973\", \"id_comunidad\": 6, \"comunidad\": \"Santa Eduviges\", \"fecha_registro\": \"2026-03-16 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(56, NULL, 'beneficiarios', 'INSERT', '31', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 31, \"nacionalidad\": \"V\", \"cedula\": 15246930, \"nombre_beneficiario\": \"Yajaira Perez\", \"telefono\": \"0424-5104110\", \"id_comunidad\": 7, \"comunidad\": \"Bella Vista\", \"fecha_registro\": \"2026-03-17 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(57, NULL, 'beneficiarios', 'INSERT', '32', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 32, \"nacionalidad\": \"V\", \"cedula\": 15247361, \"nombre_beneficiario\": \"Alvaro Jose Pacheco\", \"telefono\": \"0426-5104247\", \"id_comunidad\": 8, \"comunidad\": \"Los Mangos\", \"fecha_registro\": \"2026-03-18 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(58, NULL, 'beneficiarios', 'INSERT', '33', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 33, \"nacionalidad\": \"V\", \"cedula\": 15247792, \"nombre_beneficiario\": \"Mireya del Carmen Ochoa\", \"telefono\": \"0412-5104384\", \"id_comunidad\": 9, \"comunidad\": \"La Herrerena\", \"fecha_registro\": \"2026-03-19 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(59, NULL, 'beneficiarios', 'INSERT', '34', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 34, \"nacionalidad\": \"V\", \"cedula\": 15248223, \"nombre_beneficiario\": \"Henry Alexander Briceno\", \"telefono\": \"0414-5104521\", \"id_comunidad\": 10, \"comunidad\": \"Urbanizacion La Esperanza\", \"fecha_registro\": \"2026-03-20 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(60, NULL, 'beneficiarios', 'INSERT', '35', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 35, \"nacionalidad\": \"V\", \"cedula\": 15248654, \"nombre_beneficiario\": \"Marlenis Tovar\", \"telefono\": \"0424-5104658\", \"id_comunidad\": 11, \"comunidad\": \"Triangulo El Oasis\", \"fecha_registro\": \"2026-03-21 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(61, NULL, 'beneficiarios', 'INSERT', '36', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 36, \"nacionalidad\": \"V\", \"cedula\": 15249085, \"nombre_beneficiario\": \"Jesus Alberto Moreno\", \"telefono\": \"0426-5104795\", \"id_comunidad\": 12, \"comunidad\": \"Hacienda Juana Paula\", \"fecha_registro\": \"2026-03-22 08:00:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(62, NULL, 'ayuda_social', 'INSERT', '1', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 1, \"ticket_interno\": \"AYU-20260218-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 1, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Medicas\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-02-18\", \"descripcion\": \"Apoyo con medicamentos antihipertensivos para adulto mayor en control regular.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(63, NULL, 'seguimientos_solicitudes', 'INSERT', '1', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 1, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 1, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-18 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(64, NULL, 'seguimientos_solicitudes', 'INSERT', '2', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 2, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 1, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-20 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(65, NULL, 'ayuda_social', 'INSERT', '2', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 2, \"ticket_interno\": \"AYU-20260220-000002\", \"id_beneficiario\": 2, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 2, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 2, \"tipo_ayuda\": \"Tecnicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-02-20\", \"descripcion\": \"Solicitud de silla de ruedas para paciente con movilidad reducida.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(66, NULL, 'seguimientos_solicitudes', 'INSERT', '3', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 3, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 2, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-20 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(67, NULL, 'seguimientos_solicitudes', 'INSERT', '4', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 4, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 2, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-20 11:30:00\", \"observacion\": \"Caso canalizado a la dependencia social para seguimiento.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(68, NULL, 'ayuda_social', 'INSERT', '3', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 3, \"ticket_interno\": \"AYU-20260222-000003\", \"id_beneficiario\": 3, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 3, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Sociales\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-02-22\", \"descripcion\": \"Apoyo alimentario temporal para nucleo familiar afectado por perdida de empleo.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(69, NULL, 'seguimientos_solicitudes', 'INSERT', '5', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 5, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 3, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-22 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(70, NULL, 'ayuda_social', 'INSERT', '4', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 4, \"ticket_interno\": \"AYU-20260224-000004\", \"id_beneficiario\": 4, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 6, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Traslado\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-02-24\", \"descripcion\": \"Coordinacion de traslado programado para consulta especializada en Valencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(71, NULL, 'seguimientos_solicitudes', 'INSERT', '6', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 6, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 4, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-24 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(72, NULL, 'seguimientos_solicitudes', 'INSERT', '7', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 7, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 4, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-26 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(73, NULL, 'ayuda_social', 'INSERT', '5', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 5, \"ticket_interno\": \"AYU-20260226-000005\", \"id_beneficiario\": 5, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 7, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 2, \"tipo_ayuda\": \"Atencion prehospitalaria\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-02-26\", \"descripcion\": \"Seguimiento para paciente cronico con necesidad de evaluacion domiciliaria.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(74, NULL, 'seguimientos_solicitudes', 'INSERT', '8', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 8, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 5, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-26 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(75, NULL, 'seguimientos_solicitudes', 'INSERT', '9', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 9, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 5, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-26 11:30:00\", \"observacion\": \"Caso canalizado a la dependencia social para seguimiento.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(76, NULL, 'ayuda_social', 'INSERT', '6', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 6, \"ticket_interno\": \"AYU-20260228-000006\", \"id_beneficiario\": 6, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 14, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Reubicacion de insectos\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-02-28\", \"descripcion\": \"Atencion por enjambre detectado en vivienda cercana a escuela basica.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(77, NULL, 'seguimientos_solicitudes', 'INSERT', '10', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 10, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 6, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-28 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(78, NULL, 'seguimientos_solicitudes', 'INSERT', '11', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 11, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 6, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-02 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(79, NULL, 'ayuda_social', 'INSERT', '7', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 7, \"ticket_interno\": \"AYU-20260302-000007\", \"id_beneficiario\": 7, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 1, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 4, \"tipo_ayuda\": \"Medicas\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-02\", \"descripcion\": \"Solicitud de tensiometro digital sin disponibilidad inmediata en inventario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(80, NULL, 'seguimientos_solicitudes', 'INSERT', '12', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 12, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 7, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-02 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(81, NULL, 'seguimientos_solicitudes', 'INSERT', '13', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 13, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 7, \"id_estado_solicitud\": 4, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-05 16:00:00\", \"observacion\": \"Solicitud cerrada sin disponibilidad operativa inmediata.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(82, NULL, 'ayuda_social', 'INSERT', '8', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 8, \"ticket_interno\": \"AYU-20260304-000008\", \"id_beneficiario\": 8, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 2, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Tecnicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-04\", \"descripcion\": \"Entrega de colchon antiescaras para adulto mayor encamado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(83, NULL, 'seguimientos_solicitudes', 'INSERT', '14', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 14, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 8, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-04 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(84, NULL, 'seguimientos_solicitudes', 'INSERT', '15', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 15, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 8, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-06 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(85, NULL, 'ayuda_social', 'INSERT', '9', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 9, \"ticket_interno\": \"AYU-20260306-000009\", \"id_beneficiario\": 9, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 3, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 2, \"tipo_ayuda\": \"Sociales\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-03-06\", \"descripcion\": \"Evaluacion socioeconomica para apoyo con canastilla y articulos de primera necesidad.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(86, NULL, 'seguimientos_solicitudes', 'INSERT', '16', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 16, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 9, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-06 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(87, NULL, 'seguimientos_solicitudes', 'INSERT', '17', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 17, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 9, \"id_estado_solicitud\": 2, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-06 11:30:00\", \"observacion\": \"Caso canalizado a la dependencia social para seguimiento.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(88, NULL, 'ayuda_social', 'INSERT', '10', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 10, \"ticket_interno\": \"AYU-20260308-000010\", \"id_beneficiario\": 10, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 6, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Traslado\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-08\", \"descripcion\": \"Solicitud de traslado para paciente oncologico a jornada de quimioterapia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(89, NULL, 'seguimientos_solicitudes', 'INSERT', '18', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 18, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 10, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-08 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(90, NULL, 'seguimientos_solicitudes', 'INSERT', '19', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 19, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 10, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-10 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(91, NULL, 'ayuda_social', 'INSERT', '11', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 11, \"ticket_interno\": \"AYU-20260310-000011\", \"id_beneficiario\": 11, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 1, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Medicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-10\", \"descripcion\": \"Requerimiento de nebulizador y medicinas para control respiratorio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(92, NULL, 'seguimientos_solicitudes', 'INSERT', '20', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 20, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 11, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-10 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(93, NULL, 'ayuda_social', 'INSERT', '12', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 12, \"ticket_interno\": \"AYU-20260312-000012\", \"id_beneficiario\": 12, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 2, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Tecnicas\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-03-12\", \"descripcion\": \"Suministro de muletas para joven lesionado en accidente domestico.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(94, NULL, 'seguimientos_solicitudes', 'INSERT', '21', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 21, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 12, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-12 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(95, NULL, 'seguimientos_solicitudes', 'INSERT', '22', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 22, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 12, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-14 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36');

INSERT INTO `bitacora_respaldo` (`id_bitacora`, `id_usuario`, `tabla_afectada`, `accion`, `id_registro`, `resumen`, `detalle`, `datos_antes`, `datos_despues`, `usuario_bd`, `ipaddr`, `moment`, `fecha_evento`, `estado`, `origen_bd`, `fecha_respaldo`) VALUES
(96, NULL, 'ayuda_social', 'INSERT', '13', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 13, \"ticket_interno\": \"AYU-20260314-000013\", \"id_beneficiario\": 13, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 3, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Sociales\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-14\", \"descripcion\": \"Canalizacion de apoyo para familia afectada por incendio parcial de vivienda.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(97, NULL, 'seguimientos_solicitudes', 'INSERT', '23', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 23, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 13, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-14 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(98, NULL, 'seguimientos_solicitudes', 'INSERT', '24', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 24, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 13, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-16 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(99, NULL, 'ayuda_social', 'INSERT', '14', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 14, \"ticket_interno\": \"AYU-20260316-000014\", \"id_beneficiario\": 14, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 7, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 4, \"tipo_ayuda\": \"Atencion prehospitalaria\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-16\", \"descripcion\": \"Caso referido a red regional por requerir cobertura externa al municipio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(100, NULL, 'seguimientos_solicitudes', 'INSERT', '25', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 25, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 14, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-16 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(101, NULL, 'seguimientos_solicitudes', 'INSERT', '26', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 26, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 14, \"id_estado_solicitud\": 4, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-19 16:00:00\", \"observacion\": \"Solicitud cerrada sin disponibilidad operativa inmediata.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(102, NULL, 'ayuda_social', 'INSERT', '15', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 15, \"ticket_interno\": \"AYU-20260318-000015\", \"id_beneficiario\": 15, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 14, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 2, \"tipo_ayuda\": \"Reubicacion de insectos\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-03-18\", \"descripcion\": \"Reporte de colmena en techo de casa de cuidado infantil.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(103, NULL, 'seguimientos_solicitudes', 'INSERT', '27', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 27, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 15, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-18 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(104, NULL, 'seguimientos_solicitudes', 'INSERT', '28', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 28, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 15, \"id_estado_solicitud\": 2, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-18 11:30:00\", \"observacion\": \"Caso canalizado a la dependencia social para seguimiento.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(105, NULL, 'ayuda_social', 'INSERT', '16', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 16, \"ticket_interno\": \"AYU-20260320-000016\", \"id_beneficiario\": 16, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 1, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Medicas\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-20\", \"descripcion\": \"Entrega de kit de curas para paciente con ulceras por presion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(106, NULL, 'seguimientos_solicitudes', 'INSERT', '29', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 29, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 16, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-20 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(107, NULL, 'seguimientos_solicitudes', 'INSERT', '30', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 30, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 16, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-22 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(108, NULL, 'ayuda_social', 'INSERT', '17', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 17, \"ticket_interno\": \"AYU-20260322-000017\", \"id_beneficiario\": 17, \"id_usuario\": 2, \"id_tipo_ayuda_social\": 2, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Tecnicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-22\", \"descripcion\": \"Solicitud de baston de cuatro puntas para persona adulta mayor.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(109, NULL, 'seguimientos_solicitudes', 'INSERT', '31', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 31, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 17, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-22 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(110, NULL, 'ayuda_social', 'INSERT', '18', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 18, \"ticket_interno\": \"AYU-20260324-000018\", \"id_beneficiario\": 18, \"id_usuario\": 3, \"id_tipo_ayuda_social\": 3, \"id_solicitud_ayuda_social\": 3, \"id_estado_solicitud\": 3, \"tipo_ayuda\": \"Sociales\", \"solicitud_ayuda\": \"Redes sociales\", \"fecha_ayuda\": \"2026-03-24\", \"descripcion\": \"Apoyo con alimentos y agua potable a familia afectada por colapso de tuberia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(111, NULL, 'seguimientos_solicitudes', 'INSERT', '32', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 32, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 18, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-24 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(112, NULL, 'seguimientos_solicitudes', 'INSERT', '33', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 33, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 18, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-26 14:00:00\", \"observacion\": \"Solicitud resuelta y apoyo entregado al beneficiario.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(113, NULL, 'servicios_publicos', 'INSERT', '1', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 1, \"ticket_interno\": \"SPU-20260219-000001\", \"id_beneficiario\": 6, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 1, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Agua\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-02-19\", \"descripcion\": \"Fuga de agua blanca en tuberia principal cercana a la escuela del sector.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(114, NULL, 'seguimientos_solicitudes', 'INSERT', '34', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 34, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 1, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-19 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(115, NULL, 'seguimientos_solicitudes', 'INSERT', '35', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 35, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 1, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-20 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(116, NULL, 'servicios_publicos', 'INSERT', '2', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 2, \"ticket_interno\": \"SPU-20260221-000002\", \"id_beneficiario\": 7, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 2, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 2, \"tipo_servicio\": \"Aguas Negras\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-02-21\", \"descripcion\": \"Desborde de aguas negras en calle ciega con afectacion de varias viviendas.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(117, NULL, 'seguimientos_solicitudes', 'INSERT', '36', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 36, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 2, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-21 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(118, NULL, 'seguimientos_solicitudes', 'INSERT', '37', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 37, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 2, \"id_estado_solicitud\": 2, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-21 10:45:00\", \"observacion\": \"Solicitud remitida a cuadrilla operativa para programacion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(119, NULL, 'servicios_publicos', 'INSERT', '3', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 3, \"ticket_interno\": \"SPU-20260223-000003\", \"id_beneficiario\": 8, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 3, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Alumbrado Publico\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-02-23\", \"descripcion\": \"Luminarias apagadas en corredor peatonal de alta circulacion nocturna.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(120, NULL, 'seguimientos_solicitudes', 'INSERT', '38', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 38, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 3, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-23 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(121, NULL, 'seguimientos_solicitudes', 'INSERT', '39', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 39, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 3, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-02-24 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(122, NULL, 'servicios_publicos', 'INSERT', '4', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 4, \"ticket_interno\": \"SPU-20260225-000004\", \"id_beneficiario\": 9, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 4, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 1, \"tipo_servicio\": \"Ambiente\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-02-25\", \"descripcion\": \"Acumulacion de desechos vegetales en espacio comunal.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(123, NULL, 'seguimientos_solicitudes', 'INSERT', '40', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 40, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 4, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-02-25 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(124, NULL, 'servicios_publicos', 'INSERT', '5', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 5, \"ticket_interno\": \"SPU-20260227-000005\", \"id_beneficiario\": 10, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 5, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 2, \"tipo_servicio\": \"Asfaltado\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-02-27\", \"descripcion\": \"Bache de gran tamano en vialidad principal con riesgo para motorizados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(125, NULL, 'seguimientos_solicitudes', 'INSERT', '41', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 41, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 5, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-27 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(126, NULL, 'seguimientos_solicitudes', 'INSERT', '42', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 42, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 5, \"id_estado_solicitud\": 2, \"id_usuario\": 3, \"fecha_gestion\": \"2026-02-27 10:45:00\", \"observacion\": \"Solicitud remitida a cuadrilla operativa para programacion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(127, NULL, 'servicios_publicos', 'INSERT', '6', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 6, \"ticket_interno\": \"SPU-20260301-000006\", \"id_beneficiario\": 11, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 6, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Canos y Embaulamiento\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-01\", \"descripcion\": \"Limpieza y desobstruccion de cano lateral antes del periodo de lluvias.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(128, NULL, 'seguimientos_solicitudes', 'INSERT', '43', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 43, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 6, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-01 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(129, NULL, 'seguimientos_solicitudes', 'INSERT', '44', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 44, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 6, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-02 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(130, NULL, 'servicios_publicos', 'INSERT', '7', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 7, \"ticket_interno\": \"SPU-20260303-000007\", \"id_beneficiario\": 12, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 7, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 4, \"tipo_servicio\": \"Energia\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-03-03\", \"descripcion\": \"Variacion de voltaje reportada en manzana con transformador sobrecargado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(131, NULL, 'seguimientos_solicitudes', 'INSERT', '45', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 45, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 7, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-03 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(132, NULL, 'seguimientos_solicitudes', 'INSERT', '46', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 46, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 7, \"id_estado_solicitud\": 4, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-06 17:00:00\", \"observacion\": \"Solicitud cerrada por falta de disponibilidad presupuestaria.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(133, NULL, 'servicios_publicos', 'INSERT', '8', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 8, \"ticket_interno\": \"SPU-20260305-000008\", \"id_beneficiario\": 13, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 8, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Infraestructura\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-05\", \"descripcion\": \"Reparacion de filtracion en techo de modulo comunal.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(134, NULL, 'seguimientos_solicitudes', 'INSERT', '47', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 47, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 8, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-05 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(135, NULL, 'seguimientos_solicitudes', 'INSERT', '48', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 48, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 8, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-06 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(136, NULL, 'servicios_publicos', 'INSERT', '9', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 9, \"ticket_interno\": \"SPU-20260307-000009\", \"id_beneficiario\": 14, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 9, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 2, \"tipo_servicio\": \"Pica y Poda\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-07\", \"descripcion\": \"Ramas sobre tendido electrico con riesgo de caida por vientos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(137, NULL, 'seguimientos_solicitudes', 'INSERT', '49', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 49, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 9, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-07 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(138, NULL, 'seguimientos_solicitudes', 'INSERT', '50', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 50, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 9, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-07 10:45:00\", \"observacion\": \"Solicitud remitida a cuadrilla operativa para programacion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(139, NULL, 'servicios_publicos', 'INSERT', '10', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 10, \"ticket_interno\": \"SPU-20260309-000010\", \"id_beneficiario\": 15, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 10, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Vial\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-03-09\", \"descripcion\": \"Se requiere demarcacion y reparacion parcial de paso peatonal.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(140, NULL, 'seguimientos_solicitudes', 'INSERT', '51', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 51, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 10, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-09 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(141, NULL, 'seguimientos_solicitudes', 'INSERT', '52', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 52, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 10, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-10 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(142, NULL, 'servicios_publicos', 'INSERT', '11', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 11, \"ticket_interno\": \"SPU-20260311-000011\", \"id_beneficiario\": 16, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 1, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 1, \"tipo_servicio\": \"Agua\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-11\", \"descripcion\": \"Baja presion de agua en zona alta de la comunidad durante la tarde.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(143, NULL, 'seguimientos_solicitudes', 'INSERT', '53', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 53, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 11, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-11 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(144, NULL, 'servicios_publicos', 'INSERT', '12', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 12, \"ticket_interno\": \"SPU-20260313-000012\", \"id_beneficiario\": 17, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 3, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Alumbrado Publico\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-13\", \"descripcion\": \"Reposicion de reflector en cancha multiple para jornada nocturna.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(145, NULL, 'seguimientos_solicitudes', 'INSERT', '54', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 54, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 12, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-13 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(146, NULL, 'seguimientos_solicitudes', 'INSERT', '55', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 55, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 12, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-14 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(147, NULL, 'servicios_publicos', 'INSERT', '13', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 13, \"ticket_interno\": \"SPU-20260315-000013\", \"id_beneficiario\": 18, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 5, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Asfaltado\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-03-15\", \"descripcion\": \"Hundimiento de calzada cerca de parada de transporte publico.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(148, NULL, 'seguimientos_solicitudes', 'INSERT', '56', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 56, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 13, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-15 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(149, NULL, 'seguimientos_solicitudes', 'INSERT', '57', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 57, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 13, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-16 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(150, NULL, 'servicios_publicos', 'INSERT', '14', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 14, \"ticket_interno\": \"SPU-20260317-000014\", \"id_beneficiario\": 19, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 8, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 4, \"tipo_servicio\": \"Infraestructura\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-17\", \"descripcion\": \"Solicitud de rehabilitacion integral de plaza sin presupuesto asignado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(151, NULL, 'seguimientos_solicitudes', 'INSERT', '58', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 58, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 14, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-17 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(152, NULL, 'seguimientos_solicitudes', 'INSERT', '59', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 59, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 14, \"id_estado_solicitud\": 4, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-20 17:00:00\", \"observacion\": \"Solicitud cerrada por falta de disponibilidad presupuestaria.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(153, NULL, 'servicios_publicos', 'INSERT', '15', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 15, \"ticket_interno\": \"SPU-20260319-000015\", \"id_beneficiario\": 20, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 9, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Pica y Poda\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-19\", \"descripcion\": \"Poda preventiva de arboles frente a preescolar municipal.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(154, NULL, 'seguimientos_solicitudes', 'INSERT', '60', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 60, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 15, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-19 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(155, NULL, 'seguimientos_solicitudes', 'INSERT', '61', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 61, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 15, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-20 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(156, NULL, 'servicios_publicos', 'INSERT', '16', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 16, \"ticket_interno\": \"SPU-20260321-000016\", \"id_beneficiario\": 21, \"id_usuario\": 2, \"id_tipo_servicio_publico\": 6, \"id_solicitud_servicio_publico\": 2, \"id_estado_solicitud\": 2, \"tipo_servicio\": \"Canos y Embaulamiento\", \"solicitud_servicio\": \"Atencion al ciudadano\", \"fecha_servicio\": \"2026-03-21\", \"descripcion\": \"Sedimentacion en embaulamiento con necesidad de maquinaria liviana.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(157, NULL, 'seguimientos_solicitudes', 'INSERT', '62', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 62, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 16, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-21 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(158, NULL, 'seguimientos_solicitudes', 'INSERT', '63', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 63, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 16, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-21 10:45:00\", \"observacion\": \"Solicitud remitida a cuadrilla operativa para programacion.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(159, NULL, 'servicios_publicos', 'INSERT', '17', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 17, \"ticket_interno\": \"SPU-20260323-000017\", \"id_beneficiario\": 22, \"id_usuario\": 3, \"id_tipo_servicio_publico\": 7, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 3, \"tipo_servicio\": \"Energia\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-23\", \"descripcion\": \"Reposicion de fusible y chequeo de acometida en sector residencial.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(160, NULL, 'seguimientos_solicitudes', 'INSERT', '64', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 64, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 17, \"id_estado_solicitud\": 1, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-23 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(161, NULL, 'seguimientos_solicitudes', 'INSERT', '65', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 65, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 17, \"id_estado_solicitud\": 3, \"id_usuario\": 3, \"fecha_gestion\": \"2026-03-24 15:15:00\", \"observacion\": \"Solicitud atendida y gestion cerrada en sitio.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(162, NULL, 'servicios_publicos', 'INSERT', '18', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 18, \"ticket_interno\": \"SPU-20260325-000018\", \"id_beneficiario\": 23, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 10, \"id_solicitud_servicio_publico\": 1, \"id_estado_solicitud\": 1, \"tipo_servicio\": \"Vial\", \"solicitud_servicio\": \"1X10\", \"fecha_servicio\": \"2026-03-25\", \"descripcion\": \"Solicitud de reductores de velocidad frente a centro educativo.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(163, NULL, 'seguimientos_solicitudes', 'INSERT', '66', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 66, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 18, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-25 08:30:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(164, NULL, 'unidades', 'INSERT', '1', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"Ambulancia Ford Transit\", \"placa\": \"AB7C21D\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"Hospital de Tocuyito\", \"referencia_actual\": \"Area de urgencias\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-22 20:22:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(165, NULL, 'unidades', 'INSERT', '2', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"Ambulancia Toyota Hiace\", \"placa\": \"AC4G91M\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"Urbanizacion Jose Rafael Pocaterra\", \"referencia_actual\": \"Frente al modulo policial\", \"prioridad_despacho\": 2, \"fecha_actualizacion_operativa\": \"2026-03-23 14:50:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(166, NULL, 'unidades', 'INSERT', '3', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 3, \"codigo_unidad\": \"AMB-003\", \"descripcion\": \"Ambulancia Iveco Daily\", \"placa\": \"AD2L44R\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"Base central\", \"referencia_actual\": \"Patio operacional\", \"prioridad_despacho\": 3, \"fecha_actualizacion_operativa\": \"2026-03-21 09:40:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(167, NULL, 'unidades', 'INSERT', '4', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 4, \"codigo_unidad\": \"AMB-004\", \"descripcion\": \"Ambulancia Mercedes Sprinter\", \"placa\": \"AE6J12K\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"CDI El Oasis\", \"referencia_actual\": \"Area de espera\", \"prioridad_despacho\": 4, \"fecha_actualizacion_operativa\": \"2026-03-20 16:30:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(168, NULL, 'unidades', 'INSERT', '5', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 5, \"codigo_unidad\": \"AMB-005\", \"descripcion\": \"Ambulancia Chevrolet Express\", \"placa\": \"AF8P33T\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"Parroquia Independencia\", \"referencia_actual\": \"Puesto sanitario movil\", \"prioridad_despacho\": 5, \"fecha_actualizacion_operativa\": \"2026-03-18 11:20:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(169, NULL, 'unidades', 'INSERT', '6', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 6, \"codigo_unidad\": \"AMB-006\", \"descripcion\": \"Unidad de respuesta rapida\", \"placa\": \"AG1N58Q\", \"estado\": 1, \"estado_operativo\": \"FUERA_SERVICIO\", \"ubicacion_actual\": \"Taller municipal\", \"referencia_actual\": \"Revision de frenos\", \"prioridad_despacho\": 6, \"fecha_actualizacion_operativa\": \"2026-03-17 08:10:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(170, NULL, 'choferes_ambulancia', 'INSERT', '1', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 1, \"id_empleado\": 1, \"numero_licencia\": \"LIC-14382513\", \"categoria_licencia\": \"5to grado\", \"vencimiento_licencia\": \"2030-08-14\", \"contacto_emergencia\": \"Andres Aguilar\", \"telefono_contacto_emergencia\": \"0412-7001122\", \"observaciones\": \"Chofer principal de guardia nocturna.\", \"estado\": 1, \"fecha_registro\": \"2026-02-14 07:10:00\", \"fecha_actualizacion\": \"2026-03-22 20:22:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(171, NULL, 'choferes_ambulancia', 'INSERT', '2', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 2, \"id_empleado\": 2, \"numero_licencia\": \"LIC-24329534\", \"categoria_licencia\": \"5to grado\", \"vencimiento_licencia\": \"2031-04-09\", \"contacto_emergencia\": \"Maria Franco\", \"telefono_contacto_emergencia\": \"0424-7012233\", \"observaciones\": \"Disponible para turnos rotativos y traslados largos.\", \"estado\": 1, \"fecha_registro\": \"2026-02-14 07:20:00\", \"fecha_actualizacion\": \"2026-03-23 14:50:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(172, NULL, 'choferes_ambulancia', 'INSERT', '3', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 3, \"id_empleado\": 7, \"numero_licencia\": \"LIC-19654321\", \"categoria_licencia\": \"5to grado\", \"vencimiento_licencia\": \"2032-01-18\", \"contacto_emergencia\": \"Julio Vargas\", \"telefono_contacto_emergencia\": \"0416-7023344\", \"observaciones\": \"Resguardo de unidad para operativos especiales.\", \"estado\": 1, \"fecha_registro\": \"2026-02-15 08:00:00\", \"fecha_actualizacion\": \"2026-03-21 09:40:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(173, NULL, 'choferes_ambulancia', 'INSERT', '4', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 4, \"id_empleado\": 8, \"numero_licencia\": \"LIC-21567890\", \"categoria_licencia\": \"4to grado\", \"vencimiento_licencia\": \"2031-11-02\", \"contacto_emergencia\": \"Laura Rivas\", \"telefono_contacto_emergencia\": \"0412-7034455\", \"observaciones\": \"Apoyo en guardias diurnas y relevo de ambulancias.\", \"estado\": 1, \"fecha_registro\": \"2026-02-15 08:15:00\", \"fecha_actualizacion\": \"2026-03-20 16:30:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(174, NULL, 'choferes_ambulancia', 'INSERT', '5', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 5, \"id_empleado\": 9, \"numero_licencia\": \"LIC-18345678\", \"categoria_licencia\": \"4to grado\", \"vencimiento_licencia\": \"2030-09-27\", \"contacto_emergencia\": \"Jose Salazar\", \"telefono_contacto_emergencia\": \"0414-7045566\", \"observaciones\": \"Conductora asignada a guardias comunitarias.\", \"estado\": 1, \"fecha_registro\": \"2026-02-16 09:00:00\", \"fecha_actualizacion\": \"2026-03-18 11:20:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(175, NULL, 'choferes_ambulancia', 'INSERT', '6', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 6, \"id_empleado\": 10, \"numero_licencia\": \"LIC-25432109\", \"categoria_licencia\": \"4to grado\", \"vencimiento_licencia\": \"2031-06-30\", \"contacto_emergencia\": \"Nelly Suarez\", \"telefono_contacto_emergencia\": \"0424-7056677\", \"observaciones\": \"Chofer de reserva para unidades en mantenimiento.\", \"estado\": 1, \"fecha_registro\": \"2026-02-16 09:20:00\", \"fecha_actualizacion\": \"2026-03-17 08:10:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(176, NULL, 'asignaciones_unidades_choferes', 'INSERT', '1', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 1, \"id_unidad\": 1, \"id_chofer_ambulancia\": 1, \"fecha_inicio\": \"2026-02-25 07:00:00\", \"fecha_fin\": null, \"observaciones\": \"Guardia activa en hospital de referencia.\", \"estado\": 1, \"fecha_registro\": \"2026-02-25 07:00:00\", \"fecha_actualizacion\": \"2026-03-22 20:22:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(177, NULL, 'asignaciones_unidades_choferes', 'INSERT', '2', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 2, \"id_unidad\": 2, \"id_chofer_ambulancia\": 2, \"fecha_inicio\": \"2026-02-25 07:15:00\", \"fecha_fin\": null, \"observaciones\": \"Guardia activa en eje Pocaterra.\", \"estado\": 1, \"fecha_registro\": \"2026-02-25 07:15:00\", \"fecha_actualizacion\": \"2026-03-23 14:50:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36');

INSERT INTO `bitacora_respaldo` (`id_bitacora`, `id_usuario`, `tabla_afectada`, `accion`, `id_registro`, `resumen`, `detalle`, `datos_antes`, `datos_despues`, `usuario_bd`, `ipaddr`, `moment`, `fecha_evento`, `estado`, `origen_bd`, `fecha_respaldo`) VALUES
(178, NULL, 'asignaciones_unidades_choferes', 'INSERT', '3', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 3, \"id_unidad\": 3, \"id_chofer_ambulancia\": 3, \"fecha_inicio\": \"2026-02-26 07:00:00\", \"fecha_fin\": null, \"observaciones\": \"Guardia diurna en base central.\", \"estado\": 1, \"fecha_registro\": \"2026-02-26 07:00:00\", \"fecha_actualizacion\": \"2026-03-21 09:40:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(179, NULL, 'asignaciones_unidades_choferes', 'INSERT', '4', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 4, \"id_unidad\": 4, \"id_chofer_ambulancia\": 4, \"fecha_inicio\": \"2026-02-26 07:10:00\", \"fecha_fin\": null, \"observaciones\": \"Guardia mixta para cobertura comunitaria.\", \"estado\": 1, \"fecha_registro\": \"2026-02-26 07:10:00\", \"fecha_actualizacion\": \"2026-03-20 16:30:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(180, NULL, 'asignaciones_unidades_choferes', 'INSERT', '5', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 5, \"id_unidad\": 5, \"id_chofer_ambulancia\": 5, \"fecha_inicio\": \"2026-02-26 07:20:00\", \"fecha_fin\": null, \"observaciones\": \"Cobertura preventiva en parroquia Independencia.\", \"estado\": 1, \"fecha_registro\": \"2026-02-26 07:20:00\", \"fecha_actualizacion\": \"2026-03-18 11:20:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(181, NULL, 'asignaciones_unidades_choferes', 'INSERT', '6', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 6, \"id_unidad\": 6, \"id_chofer_ambulancia\": 6, \"fecha_inicio\": \"2026-02-20 08:00:00\", \"fecha_fin\": \"2026-03-01 17:30:00\", \"observaciones\": \"Unidad retirada temporalmente por mantenimiento preventivo.\", \"estado\": 0, \"fecha_registro\": \"2026-02-20 08:00:00\", \"fecha_actualizacion\": \"2026-03-01 17:30:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(182, NULL, 'asignaciones_unidades_choferes', 'INSERT', '7', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 7, \"id_unidad\": 3, \"id_chofer_ambulancia\": 6, \"fecha_inicio\": \"2026-02-18 07:30:00\", \"fecha_fin\": \"2026-02-24 18:00:00\", \"observaciones\": \"Asignacion previa cerrada por relevo operativo.\", \"estado\": 0, \"fecha_registro\": \"2026-02-18 07:30:00\", \"fecha_actualizacion\": \"2026-02-24 18:00:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(183, NULL, 'seguridad', 'INSERT', '1', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260303-000001\", \"id_beneficiario\": 1, \"id_usuario\": 2, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-03 08:20:00\", \"descripcion\": \"Paciente femenina de 67 anos con crisis hipertensiva y mareos persistentes.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Sector 12 de Octubre, calle principal\", \"referencia_evento\": \"Frente al ambulatorio popular\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(184, NULL, 'seguimientos_solicitudes', 'INSERT', '67', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 67, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 1, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-03 08:20:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(185, NULL, 'despachos_unidades', 'INSERT', '1', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 1, \"id_seguridad\": 1, \"id_unidad\": 3, \"id_chofer_ambulancia\": 3, \"id_usuario_asigna\": 2, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"CERRADO\", \"fecha_asignacion\": \"2026-03-03 08:28:00\", \"fecha_cierre\": \"2026-03-03 10:10:00\", \"ubicacion_salida\": \"Base central\", \"ubicacion_evento\": \"Sector 12 de Octubre, calle principal\", \"ubicacion_cierre\": \"Hospital de Tocuyito\", \"observaciones\": \"Traslado estabilizado sin novedades durante el recorrido.\", \"fecha_registro\": \"2026-03-03 08:28:00\", \"fecha_actualizacion\": \"2026-03-03 10:10:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(186, NULL, 'seguimientos_solicitudes', 'INSERT', '68', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 68, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 1, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-03 08:28:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(187, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '1', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 1, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260303-000001_registro_20260303_082800_0001.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260303-000001_registro_20260303_082800_0001.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"carmen.vargas@situacional.demo\", \"fecha_envio\": \"2026-03-03 08:30:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-03 08:28:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(188, NULL, 'seguimientos_solicitudes', 'INSERT', '69', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 69, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 1, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-03 10:10:00\", \"observacion\": \"Solicitud finalizada con cierre operativo y traslado documentado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(189, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '2', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 2, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"tipo_reporte\": \"CIERRE\", \"nombre_archivo\": \"SEG-20260303-000001_cierre_20260303_101000_0001.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260303-000001_cierre_20260303_101000_0001.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"carmen.vargas@situacional.demo\", \"fecha_envio\": \"2026-03-03 10:14:00\", \"detalle_envio\": \"Reporte de cierre enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-03 10:10:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(190, NULL, 'reportes_traslado', 'INSERT', '1', 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, '{\"id_reporte\": 1, \"id_ayuda\": null, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"id_usuario_operador\": 2, \"id_empleado_chofer\": 7, \"id_unidad\": 3, \"ticket_interno\": \"SEG-20260303-000001\", \"fecha_hora\": \"2026-03-03 10:10:00\", \"diagnostico_paciente\": \"Paciente estabilizada y entregada en urgencias con signos vitales compensados.\", \"foto_evidencia\": \"uploads/reportes_traslado/seguridad_20260303_101000_0001.jpg\", \"km_salida\": 24120, \"km_llegada\": 24138, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(191, NULL, 'seguridad', 'INSERT', '2', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260305-000002\", \"id_beneficiario\": 6, \"id_usuario\": 1, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-05 18:05:00\", \"descripcion\": \"Adulto masculino lesionado por caida de moto con dolor en hombro y escoriaciones.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Avenida principal de La Honda\", \"referencia_evento\": \"Cerca del puente peatonal\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(192, NULL, 'seguimientos_solicitudes', 'INSERT', '70', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 70, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 2, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-05 18:05:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(193, NULL, 'despachos_unidades', 'INSERT', '2', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 2, \"id_seguridad\": 2, \"id_unidad\": 4, \"id_chofer_ambulancia\": 4, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"MANUAL\", \"estado_despacho\": \"CERRADO\", \"fecha_asignacion\": \"2026-03-05 18:12:00\", \"fecha_cierre\": \"2026-03-05 19:32:00\", \"ubicacion_salida\": \"CDI El Oasis\", \"ubicacion_evento\": \"Avenida principal de La Honda\", \"ubicacion_cierre\": \"Hospital de Tocuyito\", \"observaciones\": \"Atencion primaria en sitio y posterior traslado preventivo.\", \"fecha_registro\": \"2026-03-05 18:12:00\", \"fecha_actualizacion\": \"2026-03-05 19:32:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(194, NULL, 'seguimientos_solicitudes', 'INSERT', '71', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 71, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 2, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-05 18:12:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(195, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '3', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 3, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260305-000002_registro_20260305_181200_0002.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260305-000002_registro_20260305_181200_0002.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"pedro.rivas@situacional.demo\", \"fecha_envio\": \"2026-03-05 18:14:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-05 18:12:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(196, NULL, 'seguimientos_solicitudes', 'INSERT', '72', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 72, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 2, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-05 19:32:00\", \"observacion\": \"Solicitud finalizada con cierre operativo y traslado documentado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(197, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '4', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 4, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"tipo_reporte\": \"CIERRE\", \"nombre_archivo\": \"SEG-20260305-000002_cierre_20260305_193200_0002.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260305-000002_cierre_20260305_193200_0002.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"pedro.rivas@situacional.demo\", \"fecha_envio\": \"2026-03-05 19:36:00\", \"detalle_envio\": \"Reporte de cierre enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-05 19:32:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(198, NULL, 'reportes_traslado', 'INSERT', '2', 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, '{\"id_reporte\": 2, \"id_ayuda\": null, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"id_usuario_operador\": 1, \"id_empleado_chofer\": 8, \"id_unidad\": 4, \"ticket_interno\": \"SEG-20260305-000002\", \"fecha_hora\": \"2026-03-05 19:32:00\", \"diagnostico_paciente\": \"Traumatismo leve en hombro derecho, paciente referido para rayos X.\", \"foto_evidencia\": \"uploads/reportes_traslado/seguridad_20260305_193200_0002.png\", \"km_salida\": 18344, \"km_llegada\": 18360, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(199, NULL, 'seguridad', 'INSERT', '3', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 3, \"ticket_interno\": \"SEG-20260307-000003\", \"id_beneficiario\": 9, \"id_usuario\": 2, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-07 06:45:00\", \"descripcion\": \"Nino con dificultad respiratoria y antecedentes de asma bronquial.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Comunidad Nueva Villa\", \"referencia_evento\": \"Casa azul junto a la bodega\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(200, NULL, 'seguimientos_solicitudes', 'INSERT', '73', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 73, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 3, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-07 06:45:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(201, NULL, 'despachos_unidades', 'INSERT', '3', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 3, \"id_seguridad\": 3, \"id_unidad\": 5, \"id_chofer_ambulancia\": 5, \"id_usuario_asigna\": 2, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"CERRADO\", \"fecha_asignacion\": \"2026-03-07 06:51:00\", \"fecha_cierre\": \"2026-03-07 08:05:00\", \"ubicacion_salida\": \"Parroquia Independencia\", \"ubicacion_evento\": \"Comunidad Nueva Villa\", \"ubicacion_cierre\": \"Hospital de Tocuyito\", \"observaciones\": \"Se administro oxigeno de apoyo durante el recorrido.\", \"fecha_registro\": \"2026-03-07 06:51:00\", \"fecha_actualizacion\": \"2026-03-07 08:05:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(202, NULL, 'seguimientos_solicitudes', 'INSERT', '74', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 74, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 3, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-07 06:51:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(203, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '5', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 5, \"id_seguridad\": 3, \"id_despacho_unidad\": 3, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260307-000003_registro_20260307_065100_0003.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260307-000003_registro_20260307_065100_0003.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"ana.salazar@situacional.demo\", \"fecha_envio\": \"2026-03-07 06:53:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-07 06:51:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(204, NULL, 'seguimientos_solicitudes', 'INSERT', '75', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 75, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 3, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-07 08:05:00\", \"observacion\": \"Solicitud finalizada con cierre operativo y traslado documentado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(205, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '6', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 6, \"id_seguridad\": 3, \"id_despacho_unidad\": 3, \"tipo_reporte\": \"CIERRE\", \"nombre_archivo\": \"SEG-20260307-000003_cierre_20260307_080500_0003.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260307-000003_cierre_20260307_080500_0003.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"ana.salazar@situacional.demo\", \"fecha_envio\": \"2026-03-07 08:09:00\", \"detalle_envio\": \"Reporte de cierre enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-07 08:05:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(206, NULL, 'reportes_traslado', 'INSERT', '3', 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, '{\"id_reporte\": 3, \"id_ayuda\": null, \"id_seguridad\": 3, \"id_despacho_unidad\": 3, \"id_usuario_operador\": 2, \"id_empleado_chofer\": 9, \"id_unidad\": 5, \"ticket_interno\": \"SEG-20260307-000003\", \"fecha_hora\": \"2026-03-07 08:05:00\", \"diagnostico_paciente\": \"Crisis asmatica controlada con respuesta favorable a nebulizacion inicial.\", \"foto_evidencia\": \"uploads/reportes_traslado/seguridad_20260307_080500_0003.jpg\", \"km_salida\": 19872, \"km_llegada\": 19888, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(207, NULL, 'seguridad', 'INSERT', '4', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 4, \"ticket_interno\": \"SEG-20260310-000004\", \"id_beneficiario\": 13, \"id_usuario\": 1, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-10 11:30:00\", \"descripcion\": \"Gestante con contracciones regulares y dolor abdominal en fase activa.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Urbanizacion Villa Jardin\", \"referencia_evento\": \"Edificio 3, planta baja\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(208, NULL, 'seguimientos_solicitudes', 'INSERT', '76', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 76, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 4, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-10 11:30:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(209, NULL, 'despachos_unidades', 'INSERT', '4', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 4, \"id_seguridad\": 4, \"id_unidad\": 1, \"id_chofer_ambulancia\": 1, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"MANUAL\", \"estado_despacho\": \"CERRADO\", \"fecha_asignacion\": \"2026-03-10 11:37:00\", \"fecha_cierre\": \"2026-03-10 12:42:00\", \"ubicacion_salida\": \"Hospital de Tocuyito\", \"ubicacion_evento\": \"Urbanizacion Villa Jardin\", \"ubicacion_cierre\": \"Maternidad municipal\", \"observaciones\": \"Ingreso rapido y sin complicaciones durante el traslado.\", \"fecha_registro\": \"2026-03-10 11:37:00\", \"fecha_actualizacion\": \"2026-03-10 12:42:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(210, NULL, 'seguimientos_solicitudes', 'INSERT', '77', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 77, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 4, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-10 11:37:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(211, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '7', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 7, \"id_seguridad\": 4, \"id_despacho_unidad\": 4, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260310-000004_registro_20260310_113700_0004.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260310-000004_registro_20260310_113700_0004.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"meza.elsy@gmail.com\", \"fecha_envio\": \"2026-03-10 11:39:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-10 11:37:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(212, NULL, 'seguimientos_solicitudes', 'INSERT', '78', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 78, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 4, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-10 12:42:00\", \"observacion\": \"Solicitud finalizada con cierre operativo y traslado documentado.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(213, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '8', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 8, \"id_seguridad\": 4, \"id_despacho_unidad\": 4, \"tipo_reporte\": \"CIERRE\", \"nombre_archivo\": \"SEG-20260310-000004_cierre_20260310_124200_0004.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260310-000004_cierre_20260310_124200_0004.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"meza.elsy@gmail.com\", \"fecha_envio\": \"2026-03-10 12:46:00\", \"detalle_envio\": \"Reporte de cierre enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-10 12:42:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(214, NULL, 'reportes_traslado', 'INSERT', '4', 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, '{\"id_reporte\": 4, \"id_ayuda\": null, \"id_seguridad\": 4, \"id_despacho_unidad\": 4, \"id_usuario_operador\": 1, \"id_empleado_chofer\": 1, \"id_unidad\": 1, \"ticket_interno\": \"SEG-20260310-000004\", \"fecha_hora\": \"2026-03-10 12:42:00\", \"diagnostico_paciente\": \"Paciente entregada en sala de parto con signos estables.\", \"foto_evidencia\": \"uploads/reportes_traslado/seguridad_20260310_124200_0004.png\", \"km_salida\": 24138, \"km_llegada\": 24149, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(215, NULL, 'seguridad', 'INSERT', '5', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 5, \"ticket_interno\": \"SEG-20260322-000005\", \"id_beneficiario\": 15, \"id_usuario\": 2, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-22 20:15:00\", \"descripcion\": \"Adulto mayor con dolor toracico y dificultad para caminar.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"Casco Comercial de Tocuyito\", \"referencia_evento\": \"Frente a la farmacia principal\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(216, NULL, 'seguimientos_solicitudes', 'INSERT', '79', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 79, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 5, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-22 20:15:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(217, NULL, 'despachos_unidades', 'INSERT', '5', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 5, \"id_seguridad\": 5, \"id_unidad\": 1, \"id_chofer_ambulancia\": 1, \"id_usuario_asigna\": 2, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"ACTIVO\", \"fecha_asignacion\": \"2026-03-22 20:22:00\", \"fecha_cierre\": null, \"ubicacion_salida\": \"Hospital de Tocuyito\", \"ubicacion_evento\": \"Casco Comercial de Tocuyito\", \"ubicacion_cierre\": null, \"observaciones\": \"Unidad en ruta al sitio con prioridad uno.\", \"fecha_registro\": \"2026-03-22 20:22:00\", \"fecha_actualizacion\": \"2026-03-22 20:22:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(218, NULL, 'seguimientos_solicitudes', 'INSERT', '80', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 80, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 5, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-22 20:22:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(219, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '9', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 9, \"id_seguridad\": 5, \"id_despacho_unidad\": 5, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260322-000005_registro_20260322_202200_0005.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260322-000005_registro_20260322_202200_0005.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"meza.elsy@gmail.com\", \"fecha_envio\": \"2026-03-22 20:24:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 2, \"fecha_generacion\": \"2026-03-22 20:22:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(220, NULL, 'seguridad', 'INSERT', '6', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 6, \"ticket_interno\": \"SEG-20260323-000006\", \"id_beneficiario\": 18, \"id_usuario\": 1, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-23 14:40:00\", \"descripcion\": \"Paciente con hipoglucemia reportada por familiares y mareo intenso.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"Urbanizacion Jose Rafael Pocaterra\", \"referencia_evento\": \"Casa 14, calle A\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(221, NULL, 'seguimientos_solicitudes', 'INSERT', '81', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 81, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 6, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-23 14:40:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(222, NULL, 'despachos_unidades', 'INSERT', '6', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 6, \"id_seguridad\": 6, \"id_unidad\": 2, \"id_chofer_ambulancia\": 2, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"ACTIVO\", \"fecha_asignacion\": \"2026-03-23 14:50:00\", \"fecha_cierre\": null, \"ubicacion_salida\": \"Urbanizacion Jose Rafael Pocaterra\", \"ubicacion_evento\": \"Urbanizacion Jose Rafael Pocaterra\", \"ubicacion_cierre\": null, \"observaciones\": \"Unidad en atencion activa con reporte telefonico abierto.\", \"fecha_registro\": \"2026-03-23 14:50:00\", \"fecha_actualizacion\": \"2026-03-23 14:50:00\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(223, NULL, 'seguimientos_solicitudes', 'INSERT', '82', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 82, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 6, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-23 14:50:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(224, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '10', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 10, \"id_seguridad\": 6, \"id_despacho_unidad\": 6, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260323-000006_registro_20260323_145000_0006.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260323-000006_registro_20260323_145000_0006.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"flaura2705@gmail.com\", \"fecha_envio\": \"2026-03-23 14:52:00\", \"detalle_envio\": \"Reporte de salida enviado correctamente al correo del chofer.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-23 14:50:00\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(225, NULL, 'seguridad', 'INSERT', '7', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 7, \"ticket_interno\": \"SEG-20260323-000007\", \"id_beneficiario\": 21, \"id_usuario\": 2, \"id_tipo_seguridad\": 4, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-23 07:10:00\", \"descripcion\": \"Adulto mayor con sospecha de deshidratacion mientras se libera una unidad.\", \"estado_atencion\": \"PENDIENTE_UNIDAD\", \"ubicacion_evento\": \"Barrio El Oasis\", \"referencia_evento\": \"Cancha techada\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(226, NULL, 'seguimientos_solicitudes', 'INSERT', '83', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 83, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 7, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-23 07:10:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(227, NULL, 'seguimientos_solicitudes', 'INSERT', '84', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 84, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 7, \"id_estado_solicitud\": 2, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-23 07:20:00\", \"observacion\": \"Caso en espera de unidad operativa disponible.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(228, NULL, 'seguridad', 'INSERT', '8', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 8, \"ticket_interno\": \"SEG-20260312-000008\", \"id_beneficiario\": 23, \"id_usuario\": 4, \"id_tipo_seguridad\": 6, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Hurto\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-12 09:00:00\", \"descripcion\": \"Denuncia de hurto de cableado residencial con afectacion de servicio domestico.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Santa Eduviges\", \"referencia_evento\": \"Detras de la casa comunal\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(229, NULL, 'seguimientos_solicitudes', 'INSERT', '85', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 85, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 8, \"id_estado_solicitud\": 1, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-12 09:00:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(230, NULL, 'seguimientos_solicitudes', 'INSERT', '86', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 86, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 8, \"id_estado_solicitud\": 3, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-12 11:00:00\", \"observacion\": \"Gestion cerrada por el equipo operativo correspondiente.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(231, NULL, 'seguridad', 'INSERT', '9', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 9, \"ticket_interno\": \"SEG-20260313-000009\", \"id_beneficiario\": 24, \"id_usuario\": 4, \"id_tipo_seguridad\": 5, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Robo de vehiculo\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-13 22:10:00\", \"descripcion\": \"Reporte de robo de motocicleta al salir de jornada laboral nocturna.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Zanjon Dulce\", \"referencia_evento\": \"Cerca de la parada de autobuses\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(232, NULL, 'seguimientos_solicitudes', 'INSERT', '87', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 87, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 9, \"id_estado_solicitud\": 1, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-13 22:10:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(233, NULL, 'seguridad', 'INSERT', '10', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 10, \"ticket_interno\": \"SEG-20260315-000010\", \"id_beneficiario\": 25, \"id_usuario\": 2, \"id_tipo_seguridad\": 8, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Riesgo de vias publicas\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-15 17:35:00\", \"descripcion\": \"Arbol inclinado sobre vialidad con riesgo de caida sobre peatones.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Los Mangos\", \"referencia_evento\": \"Frente a la escuela tecnica\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(234, NULL, 'seguimientos_solicitudes', 'INSERT', '88', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 88, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 10, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-15 17:35:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(235, NULL, 'seguimientos_solicitudes', 'INSERT', '89', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 89, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 10, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-15 19:35:00\", \"observacion\": \"Gestion cerrada por el equipo operativo correspondiente.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(236, NULL, 'seguridad', 'INSERT', '11', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 11, \"ticket_interno\": \"SEG-20260316-000011\", \"id_beneficiario\": 26, \"id_usuario\": 2, \"id_tipo_seguridad\": 11, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Reubicacion de insectos\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-16 13:25:00\", \"descripcion\": \"Avispero activo en techo de vivienda multifamiliar.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Urbanizacion La Esperanza\", \"referencia_evento\": \"Casa esquinera color beige\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(237, NULL, 'seguimientos_solicitudes', 'INSERT', '90', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 90, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 11, \"id_estado_solicitud\": 1, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-16 13:25:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(238, NULL, 'seguimientos_solicitudes', 'INSERT', '91', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 91, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 11, \"id_estado_solicitud\": 3, \"id_usuario\": 2, \"fecha_gestion\": \"2026-03-16 15:25:00\", \"observacion\": \"Gestion cerrada por el equipo operativo correspondiente.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(239, NULL, 'seguridad', 'INSERT', '12', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 12, \"ticket_interno\": \"SEG-20260318-000012\", \"id_beneficiario\": 27, \"id_usuario\": 4, \"id_tipo_seguridad\": 9, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Maltrato domestico\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-18 19:10:00\", \"descripcion\": \"Vecinos reportan presunta situacion de violencia intrafamiliar.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Colinas del Rosario\", \"referencia_evento\": \"Pasillo 4 del conjunto residencial\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(240, NULL, 'seguimientos_solicitudes', 'INSERT', '92', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 92, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 12, \"id_estado_solicitud\": 1, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-18 19:10:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:25', '2026-03-23 22:36:25', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(241, NULL, 'seguridad', 'INSERT', '13', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 13, \"ticket_interno\": \"SEG-20260319-000013\", \"id_beneficiario\": 28, \"id_usuario\": 1, \"id_tipo_seguridad\": 1, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 3, \"tipo_seguridad\": \"Guardia y seguridad\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-19 06:30:00\", \"descripcion\": \"Solicitud de apoyo preventivo por evento comunitario con alta asistencia.\", \"estado_atencion\": \"FINALIZADO\", \"ubicacion_evento\": \"Comunidad Bicentenario\", \"referencia_evento\": \"Plaza central\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(242, NULL, 'seguimientos_solicitudes', 'INSERT', '93', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 93, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 13, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-19 06:30:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(243, NULL, 'seguimientos_solicitudes', 'INSERT', '94', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 94, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 13, \"id_estado_solicitud\": 3, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-19 08:30:00\", \"observacion\": \"Gestion cerrada por el equipo operativo correspondiente.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(244, NULL, 'seguridad', 'INSERT', '14', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 14, \"ticket_interno\": \"SEG-20260320-000014\", \"id_beneficiario\": 29, \"id_usuario\": 4, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 2, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Robo de inmueble\", \"tipo_solicitud\": \"Atencion al ciudadano\", \"fecha_seguridad\": \"2026-03-20 03:50:00\", \"descripcion\": \"Reporte de intrusion nocturna en vivienda desocupada parcialmente.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Banco Obrero Las Palmas\", \"referencia_evento\": \"Casa 8, vereda final\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(245, NULL, 'seguimientos_solicitudes', 'INSERT', '95', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 95, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 14, \"id_estado_solicitud\": 1, \"id_usuario\": 4, \"fecha_gestion\": \"2026-03-20 03:50:00\", \"observacion\": \"Solicitud registrada en seguridad y emergencia.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(246, 1, 'AUTENTICACION', 'LOGIN_OK', 'admin', 'Evento de autenticacion: LOGIN_OK', 'Inicio de sesion administrativo para revision de tableros.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(247, 2, 'AUTENTICACION', 'LOGIN_OK', 'operador.sala', 'Evento de autenticacion: LOGIN_OK', 'Ingreso del operador de sala para coordinacion operativa.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(248, 3, 'AUTENTICACION', 'LOGIN_OK', 'atencion.ciudadana', 'Evento de autenticacion: LOGIN_OK', 'Ingreso para carga de solicitudes ciudadanas.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(249, 4, 'AUTENTICACION', 'LOGIN_FAIL', 'consulta.tribunal', 'Evento de autenticacion: LOGIN_FAIL', 'Intento previo con clave vencida antes de la autenticacion correcta.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(250, 4, 'AUTENTICACION', 'LOGIN_OK', 'consulta.tribunal', 'Evento de autenticacion: LOGIN_OK', 'Ingreso de consulta para revision de bitacora institucional.', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-24 02:36:26', '2026-03-23 22:36:26', 1, 'sala_situacional', '2026-03-23 22:36:36'),
(251, 1, 'AUTENTICACION', 'LOGOUT', 'admin', 'Evento de autenticacion: LOGOUT', 'Cierre de sesion del usuario \'admin\'.', NULL, NULL, 'root@localhost', '::1', '2026-03-24 02:42:24', '2026-03-23 22:42:24', 1, 'sala_situacional', '2026-03-23 22:42:36');

INSERT INTO `bitacora_respaldo` (`id_bitacora`, `id_usuario`, `tabla_afectada`, `accion`, `id_registro`, `resumen`, `detalle`, `datos_antes`, `datos_despues`, `usuario_bd`, `ipaddr`, `moment`, `fecha_evento`, `estado`, `origen_bd`, `fecha_respaldo`) VALUES
(252, NULL, 'usuarios_seguridad_acceso', 'UPDATE', '2', 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-20 08:00:00\"}', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-23 22:42:55\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:42:55', '2026-03-23 22:42:55', 1, 'sala_situacional', '2026-03-23 22:43:36'),
(253, 2, 'AUTENTICACION', 'LOGIN_OK', 'operador.sala', 'Evento de autenticacion: LOGIN_OK', 'Inicio de sesion exitoso para el usuario \'operador.sala\'.', NULL, NULL, 'root@localhost', '::1', '2026-03-24 02:42:55', '2026-03-23 22:42:55', 1, 'sala_situacional', '2026-03-23 22:43:36'),
(254, NULL, 'tipos_seguridad_emergencia', 'UPDATE', '3', 'UPDATE en tipos_seguridad_emergencia', 'Se actualizo un registro en tipos_seguridad_emergencia', '{\"id_tipo_seguridad\": 3, \"nombre_tipo\": \"Traslado\", \"requiere_ambulancia\": 0, \"estado\": 1, \"fecha_registro\": \"2026-03-13 14:34:52\"}', '{\"id_tipo_seguridad\": 3, \"nombre_tipo\": \"Traslado\", \"requiere_ambulancia\": 1, \"estado\": 1, \"fecha_registro\": \"2026-03-13 14:34:52\"}', 'root@localhost', '127.0.0.1', '2026-03-24 02:45:13', '2026-03-23 22:45:13', 1, 'sala_situacional', '2026-03-23 22:45:36'),
(255, 2, 'SISTEMA', 'OPERACION', NULL, 'Operacion del sistema', 'CONFIGURACION ACTUALIZAR - Catalogo: tipos_seguridad_emergencia - Registro: 3', NULL, NULL, 'root@localhost', '::1', '2026-03-24 02:45:13', '2026-03-23 22:45:13', 1, 'sala_situacional', '2026-03-23 22:45:36');

INSERT INTO `control_respaldo_bitacora` (`id_control`, `ultimo_id_bitacora`, `registros_insertados`, `fecha_ultimo_respaldo`, `estado`) VALUES
(1, 255, 0, '2026-03-23 22:46:36', 'OK');

ALTER TABLE `bitacora_respaldo`
  ADD PRIMARY KEY (`id_bitacora`),
  ADD KEY `idx_bitacora_respaldo_fecha` (`fecha_evento`),
  ADD KEY `idx_bitacora_respaldo_origen` (`tabla_afectada`,`accion`);

ALTER TABLE `control_respaldo_bitacora`
  ADD PRIMARY KEY (`id_control`);

DELIMITER $$
CREATE PROCEDURE `sp_sync_bitacora_desde_operativa` ()   BEGIN
    DECLARE v_insertados INT DEFAULT 0;

    INSERT INTO `bitacora_respaldo` (
        `id_bitacora`,
        `id_usuario`,
        `tabla_afectada`,
        `accion`,
        `id_registro`,
        `resumen`,
        `detalle`,
        `datos_antes`,
        `datos_despues`,
        `usuario_bd`,
        `ipaddr`,
        `moment`,
        `fecha_evento`,
        `estado`,
        `origen_bd`,
        `fecha_respaldo`
    )
    SELECT
        b.`id_bitacora`,
        b.`id_usuario`,
        b.`tabla_afectada`,
        b.`accion`,
        b.`id_registro`,
        b.`resumen`,
        b.`detalle`,
        b.`datos_antes`,
        b.`datos_despues`,
        b.`usuario_bd`,
        b.`ipaddr`,
        b.`moment`,
        b.`fecha_evento`,
        b.`estado`,
        'sala_situacional',
        NOW()
    FROM `sala_situacional`.`bitacora` AS b
    LEFT JOIN `bitacora_respaldo` AS br
        ON br.`id_bitacora` = b.`id_bitacora`
    WHERE br.`id_bitacora` IS NULL
    ORDER BY b.`id_bitacora` ASC;

    SET v_insertados = ROW_COUNT();

    INSERT INTO `control_respaldo_bitacora` (
        `id_control`,
        `ultimo_id_bitacora`,
        `registros_insertados`,
        `fecha_ultimo_respaldo`,
        `estado`
    )
    VALUES (
        1,
        (SELECT COALESCE(MAX(`id_bitacora`), 0) FROM `bitacora_respaldo`),
        v_insertados,
        NOW(),
        'OK'
    )
    ON DUPLICATE KEY UPDATE
        `ultimo_id_bitacora` = VALUES(`ultimo_id_bitacora`),
        `registros_insertados` = VALUES(`registros_insertados`),
        `fecha_ultimo_respaldo` = VALUES(`fecha_ultimo_respaldo`),
        `estado` = VALUES(`estado`);
END$$

CREATE PROCEDURE `sp_respaldo_bitacora_resumen` ()   BEGIN
    SELECT
        COUNT(*) AS `total_registros`,
        MIN(`fecha_evento`) AS `primer_evento`,
        MAX(`fecha_evento`) AS `ultimo_evento`,
        MAX(`fecha_respaldo`) AS `ultimo_respaldo`,
        SUM(CASE WHEN `accion` IN ('LOGIN_FAIL', 'BLOQUEO_USUARIO') THEN 1 ELSE 0 END) AS `eventos_criticos`,
        COALESCE(
            (SELECT `estado`
             FROM `control_respaldo_bitacora`
             WHERE `id_control` = 1
             LIMIT 1),
            'SIN_DATOS'
        ) AS `estado_respaldo`
    FROM `bitacora_respaldo`;
END$$

CREATE EVENT `ev_backup_bitacora_cada_minuto` ON SCHEDULE EVERY 1 MINUTE STARTS CURRENT_TIMESTAMP + INTERVAL 1 MINUTE ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    CALL `sp_sync_bitacora_desde_operativa`();
END$$

DELIMITER ;

-- ============================================================
-- SEGURIDAD, ROLES, USUARIOS Y ACTIVACION DE EVENTOS
-- Esta sección requiere privilegios globales suficientes para
-- CREATE ROLE / CREATE USER / GRANT y, para la última línea,
-- capacidad de ejecutar SET GLOBAL event_scheduler = ON.
-- ============================================================
USE `sala_situacional`;

CREATE ROLE IF NOT EXISTS rol_lector;
CREATE ROLE IF NOT EXISTS rol_operador;
CREATE ROLE IF NOT EXISTS rol_auditor;
CREATE ROLE IF NOT EXISTS rol_respaldo;
CREATE ROLE IF NOT EXISTS rol_admin;
CREATE USER IF NOT EXISTS 'u_sala_lector'@'%' IDENTIFIED BY 'alcadia_1';
CREATE USER IF NOT EXISTS 'u_sala_operador'@'%' IDENTIFIED BY ' alcadia _2';
CREATE USER IF NOT EXISTS 'u_sala_auditor'@'%' IDENTIFIED BY ' alcadia _3';
CREATE USER IF NOT EXISTS 'u_sala_backup'@'%' IDENTIFIED BY ' alcadia_4';
CREATE USER IF NOT EXISTS 'u_sala_admin'@'%' IDENTIFIED BY ' alcadia_5';
CREATE USER IF NOT EXISTS 'usr_admin_upt'@'%' IDENTIFIED BY ' alcadia _6';
GRANT rol_lector TO 'u_sala_lector'@'%';
GRANT rol_operador TO 'u_sala_operador'@'%';
GRANT rol_auditor TO 'u_sala_auditor'@'%';
GRANT rol_respaldo TO 'u_sala_backup'@'%';
GRANT rol_admin TO 'u_sala_admin'@'%';
GRANT rol_admin TO 'usr_admin_upt'@'%';
SET DEFAULT ROLE rol_lector FOR 'u_sala_lector'@'%';
SET DEFAULT ROLE rol_operador FOR 'u_sala_operador'@'%';
SET DEFAULT ROLE rol_auditor FOR 'u_sala_auditor'@'%';
SET DEFAULT ROLE rol_respaldo FOR 'u_sala_backup'@'%';
SET DEFAULT ROLE rol_admin FOR 'u_sala_admin'@'%';
SET DEFAULT ROLE rol_admin FOR 'usr_admin_upt'@'%';
GRANT SELECT ON sala_situacional.* TO rol_lector;
GRANT SELECT ON sala_situacional_respaldo_bitacora.* TO rol_lector;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.beneficiarios TO rol_operador;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.ayuda_social TO rol_operador;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.servicios_publicos TO rol_operador;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.seguridad TO rol_operador;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.seguimientos_solicitudes TO rol_operador;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.despachos_unidades TO rol_operador;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.reportes_traslado TO rol_operador;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.reportes_solicitudes_ambulancia TO rol_operador;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.asignaciones_unidades_choferes TO rol_operador;
GRANT SELECT, INSERT, UPDATE ON sala_situacional.choferes_ambulancia TO rol_operador;
GRANT SELECT, UPDATE ON sala_situacional.unidades TO rol_operador;
GRANT SELECT, UPDATE ON sala_situacional.usuarios_seguridad_acceso TO rol_operador;
GRANT SELECT ON sala_situacional.comunidades TO rol_operador;
GRANT SELECT ON sala_situacional.dependencias TO rol_operador;
GRANT SELECT ON sala_situacional.empleados TO rol_operador;
GRANT SELECT ON sala_situacional.estados_solicitudes TO rol_operador;
GRANT SELECT ON sala_situacional.solicitudes_generales TO rol_operador;
GRANT SELECT ON sala_situacional.tipos_ayuda_social TO rol_operador;
GRANT SELECT ON sala_situacional.tipos_servicios_publicos TO rol_operador;
GRANT SELECT ON sala_situacional.tipos_seguridad_emergencia TO rol_operador;
GRANT SELECT ON sala_situacional.usuarios TO rol_operador;
GRANT SELECT ON sala_situacional.usuario_permisos TO rol_operador;
GRANT SELECT ON sala_situacional.bitacora TO rol_operador;
GRANT SELECT ON sala_situacional.vw_solicitudes_ciudadanas TO rol_operador;
GRANT SELECT ON sala_situacional.vw_usuarios_estado_acceso TO rol_operador;
GRANT SELECT ON sala_situacional.vw_bitacora_autenticacion TO rol_operador;
GRANT SELECT ON sala_situacional.vw_unidades_operativas_actuales TO rol_operador;
GRANT EXECUTE ON PROCEDURE sala_situacional.sp_dashboard_resumen_general TO rol_operador;
GRANT EXECUTE ON PROCEDURE sala_situacional.sp_bitacora_registrar_autenticacion TO rol_operador;
GRANT EXECUTE ON PROCEDURE sala_situacional.sp_bitacora_consultar_autenticacion TO rol_operador;
GRANT EXECUTE ON PROCEDURE sala_situacional.sp_usuarios_desbloquear_manual TO rol_operador;
GRANT SELECT ON sala_situacional.bitacora TO rol_auditor;
GRANT SELECT ON sala_situacional.vw_bitacora_autenticacion TO rol_auditor;
GRANT SELECT ON sala_situacional.vw_solicitudes_ciudadanas TO rol_auditor;
GRANT SELECT ON sala_situacional_respaldo_bitacora.* TO rol_auditor;
GRANT EXECUTE ON PROCEDURE sala_situacional.sp_bitacora_consultar_autenticacion TO rol_auditor;
GRANT EXECUTE ON PROCEDURE sala_situacional_respaldo_bitacora.sp_respaldo_bitacora_resumen TO rol_auditor;
GRANT SELECT ON sala_situacional.bitacora TO rol_respaldo;
GRANT SELECT, INSERT, UPDATE ON sala_situacional_respaldo_bitacora.bitacora_respaldo TO rol_respaldo;
GRANT SELECT, INSERT, UPDATE ON sala_situacional_respaldo_bitacora.control_respaldo_bitacora TO rol_respaldo;
GRANT EXECUTE ON PROCEDURE sala_situacional_respaldo_bitacora.sp_respaldo_bitacora_resumen TO rol_respaldo;
GRANT ALL PRIVILEGES ON sala_situacional.* TO rol_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON sala_situacional_respaldo_bitacora.* TO rol_admin WITH GRANT OPTION;

ALTER EVENT `sala_situacional_respaldo_bitacora`.`ev_backup_bitacora_cada_minuto` ENABLE;
SET GLOBAL event_scheduler = ON;

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;
SET SQL_MODE = @OLD_SQL_MODE;

-- FIN DEL INSTALADOR
