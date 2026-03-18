-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 18-03-2026 a las 16:12:51
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sala03v2_4`
--
CREATE DATABASE IF NOT EXISTS `sala03v2_4` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `sala03v2_4`;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignaciones_unidades_choferes`
--

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

--
-- Volcado de datos para la tabla `asignaciones_unidades_choferes`
--

INSERT INTO `asignaciones_unidades_choferes` (`id_asignacion_unidad_chofer`, `id_unidad`, `id_chofer_ambulancia`, `fecha_inicio`, `fecha_fin`, `observaciones`, `estado`, `fecha_registro`, `fecha_actualizacion`) VALUES
(1, 1, 1, '2026-03-18 02:18:55', NULL, 'Asignacion directa desde el formulario de chofer operativo.', 1, '2026-03-17 21:18:55', '2026-03-17 21:18:55'),
(2, 2, 2, '2026-03-18 02:19:53', NULL, 'Asignacion directa desde el formulario de chofer operativo.', 1, '2026-03-17 21:19:53', '2026-03-17 21:19:53');

--
-- Disparadores `asignaciones_unidades_choferes`
--
DELIMITER $$
CREATE TRIGGER `tr_asignaciones_unidades_choferes_ai_audit` AFTER INSERT ON `asignaciones_unidades_choferes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'asignaciones_unidades_choferes', 'INSERT', CAST(NEW.id_asignacion_unidad_chofer AS CHAR), 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, JSON_OBJECT('id_asignacion_unidad_chofer', NEW.id_asignacion_unidad_chofer, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'fecha_inicio', NEW.fecha_inicio, 'fecha_fin', NEW.fecha_fin, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_asignaciones_unidades_choferes_au_audit` AFTER UPDATE ON `asignaciones_unidades_choferes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'asignaciones_unidades_choferes', 'UPDATE', CAST(NEW.id_asignacion_unidad_chofer AS CHAR), 'UPDATE en asignaciones_unidades_choferes', 'Se actualizo un registro en asignaciones_unidades_choferes', JSON_OBJECT('id_asignacion_unidad_chofer', OLD.id_asignacion_unidad_chofer, 'id_unidad', OLD.id_unidad, 'id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'fecha_inicio', OLD.fecha_inicio, 'fecha_fin', OLD.fecha_fin, 'observaciones', OLD.observaciones, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_asignacion_unidad_chofer', NEW.id_asignacion_unidad_chofer, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'fecha_inicio', NEW.fecha_inicio, 'fecha_fin', NEW.fecha_fin, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_asignaciones_unidades_choferes_bd_block_delete` BEFORE DELETE ON `asignaciones_unidades_choferes` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla asignaciones_unidades_choferes. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ayuda_social`
--

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

--
-- Volcado de datos para la tabla `ayuda_social`
--

INSERT INTO `ayuda_social` (`id_ayuda`, `ticket_interno`, `id_beneficiario`, `id_usuario`, `id_tipo_ayuda_social`, `id_solicitud_ayuda_social`, `id_estado_solicitud`, `tipo_ayuda`, `solicitud_ayuda`, `fecha_ayuda`, `descripcion`, `estado`) VALUES
(1, 'AYU-20260317-000001', 1, 1, 14, 2, 1, 'Reubicacion de insectos', 'Atencion al ciudadano', '2026-03-17', 'plaga de mosquitos', 1),
(2, 'AYU-20260317-000002', 2, 1, 11, 1, 1, 'Riesgo de vias publicas', '1X10', '2026-03-17', 'Mucho baches en la via', 1),
(3, 'AYU-20260318-000003', 1, 1, 9, 2, 1, 'Hurto', 'Atencion al ciudadano', '2026-03-18', 'descripcion breve', 1);

--
-- Disparadores `ayuda_social`
--
DELIMITER $$
CREATE TRIGGER `tr_ayuda_social_ai_audit` AFTER INSERT ON `ayuda_social` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'ayuda_social', 'INSERT', CAST(NEW.id_ayuda AS CHAR), 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, JSON_OBJECT('id_ayuda', NEW.id_ayuda, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'id_solicitud_ayuda_social', NEW.id_solicitud_ayuda_social, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_ayuda', NEW.tipo_ayuda, 'solicitud_ayuda', NEW.solicitud_ayuda, 'fecha_ayuda', NEW.fecha_ayuda, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_ayuda_social_au_audit` AFTER UPDATE ON `ayuda_social` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'ayuda_social', 'UPDATE', CAST(NEW.id_ayuda AS CHAR), 'UPDATE en ayuda_social', 'Se actualizo un registro en ayuda_social', JSON_OBJECT('id_ayuda', OLD.id_ayuda, 'ticket_interno', OLD.ticket_interno, 'id_beneficiario', OLD.id_beneficiario, 'id_usuario', OLD.id_usuario, 'id_tipo_ayuda_social', OLD.id_tipo_ayuda_social, 'id_solicitud_ayuda_social', OLD.id_solicitud_ayuda_social, 'id_estado_solicitud', OLD.id_estado_solicitud, 'tipo_ayuda', OLD.tipo_ayuda, 'solicitud_ayuda', OLD.solicitud_ayuda, 'fecha_ayuda', OLD.fecha_ayuda, 'descripcion', OLD.descripcion, 'estado', OLD.estado), JSON_OBJECT('id_ayuda', NEW.id_ayuda, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'id_solicitud_ayuda_social', NEW.id_solicitud_ayuda_social, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_ayuda', NEW.tipo_ayuda, 'solicitud_ayuda', NEW.solicitud_ayuda, 'fecha_ayuda', NEW.fecha_ayuda, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_ayuda_social_bd_block_delete` BEFORE DELETE ON `ayuda_social` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla ayuda_social. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `beneficiarios`
--

CREATE TABLE `beneficiarios` (
  `id_beneficiario` int(11) NOT NULL COMMENT 'Campo id_beneficiario de la tabla beneficiarios.',
  `nacionalidad` enum('V','E') DEFAULT 'V' COMMENT 'Campo nacionalidad de la tabla beneficiarios.',
  `cedula` int(11) NOT NULL COMMENT 'Campo cedula de la tabla beneficiarios.',
  `nombre_beneficiario` varchar(150) NOT NULL COMMENT 'Campo nombre_beneficiario de la tabla beneficiarios.',
  `telefono` varchar(20) DEFAULT NULL COMMENT 'Campo telefono de la tabla beneficiarios.',
  `id_comunidad` int(11) NOT NULL COMMENT 'Campo id_comunidad de la tabla beneficiarios.',
  `comunidad` varchar(100) DEFAULT NULL COMMENT 'Campo comunidad de la tabla beneficiarios.',
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla beneficiarios.',
  `hora_registro_12h` char(11) DEFAULT NULL COMMENT 'Campo hora_registro_12h de la tabla beneficiarios.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla beneficiarios.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `beneficiarios`
--

INSERT INTO `beneficiarios` (`id_beneficiario`, `nacionalidad`, `cedula`, `nombre_beneficiario`, `telefono`, `id_comunidad`, `comunidad`, `fecha_registro`, `hora_registro_12h`, `estado`) VALUES
(1, 'V', 123456789, 'Elsy Meza', '04269390643', 24, '12 de Octubre', '2026-03-18 01:11:15', '09:11:15 PM', 1),
(2, 'V', 223344556, 'Laura Franco', '04244668450', 42, 'Barrio Manuelita Saenz', '2026-03-18 01:12:17', '09:12:17 PM', 1);

--
-- Disparadores `beneficiarios`
--
DELIMITER $$
CREATE TRIGGER `tr_beneficiarios_ai_audit` AFTER INSERT ON `beneficiarios` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'beneficiarios', 'INSERT', CAST(NEW.id_beneficiario AS CHAR), 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, JSON_OBJECT('id_beneficiario', NEW.id_beneficiario, 'nacionalidad', NEW.nacionalidad, 'cedula', NEW.cedula, 'nombre_beneficiario', NEW.nombre_beneficiario, 'telefono', NEW.telefono, 'id_comunidad', NEW.id_comunidad, 'comunidad', NEW.comunidad, 'fecha_registro', NEW.fecha_registro, 'hora_registro_12h', NEW.hora_registro_12h, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_beneficiarios_au_audit` AFTER UPDATE ON `beneficiarios` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'beneficiarios', 'UPDATE', CAST(NEW.id_beneficiario AS CHAR), 'UPDATE en beneficiarios', 'Se actualizo un registro en beneficiarios', JSON_OBJECT('id_beneficiario', OLD.id_beneficiario, 'nacionalidad', OLD.nacionalidad, 'cedula', OLD.cedula, 'nombre_beneficiario', OLD.nombre_beneficiario, 'telefono', OLD.telefono, 'id_comunidad', OLD.id_comunidad, 'comunidad', OLD.comunidad, 'fecha_registro', OLD.fecha_registro, 'hora_registro_12h', OLD.hora_registro_12h, 'estado', OLD.estado), JSON_OBJECT('id_beneficiario', NEW.id_beneficiario, 'nacionalidad', NEW.nacionalidad, 'cedula', NEW.cedula, 'nombre_beneficiario', NEW.nombre_beneficiario, 'telefono', NEW.telefono, 'id_comunidad', NEW.id_comunidad, 'comunidad', NEW.comunidad, 'fecha_registro', NEW.fecha_registro, 'hora_registro_12h', NEW.hora_registro_12h, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_beneficiarios_bd_block_delete` BEFORE DELETE ON `beneficiarios` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla beneficiarios. Use eliminacion logica.';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_beneficiarios_bi_hora12` BEFORE INSERT ON `beneficiarios` FOR EACH ROW BEGIN
    IF NEW.fecha_registro IS NULL THEN
        SET NEW.fecha_registro = NOW();
    END IF;
    SET NEW.hora_registro_12h = DATE_FORMAT(NEW.fecha_registro, '%r');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_beneficiarios_bu_hora12` BEFORE UPDATE ON `beneficiarios` FOR EACH ROW BEGIN
    IF NEW.fecha_registro IS NULL THEN
        SET NEW.fecha_registro = NOW();
    END IF;
    SET NEW.hora_registro_12h = DATE_FORMAT(NEW.fecha_registro, '%r');
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacora`
--

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

--
-- Volcado de datos para la tabla `bitacora`
--

INSERT INTO `bitacora` (`id_bitacora`, `id_usuario`, `tabla_afectada`, `accion`, `id_registro`, `resumen`, `detalle`, `datos_antes`, `datos_despues`, `usuario_bd`, `ipaddr`, `moment`, `fecha_evento`, `estado`) VALUES
(1, NULL, 'configuracion_smtp', 'UPDATE', '1', 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"aliguerrerodev@gmail.com\", \"clave\": \"smskqlowxtrxivmk\", \"correo_remitente\": \"aliguerrerodev@gmail.com\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"2026-03-17 11:25:10\", \"fecha_actualizacion\": \"2026-03-17 14:16:51\"}', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"smskqlowxtrxivmk\", \"correo_remitente\": \"aliguerrerodev@gmail.com\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"2026-03-17 11:25:10\", \"fecha_actualizacion\": \"2026-03-17 20:17:42\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:17:42', '2026-03-17 20:17:42', 1),
(2, NULL, 'configuracion_smtp', 'UPDATE', '1', 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"smskqlowxtrxivmk\", \"correo_remitente\": \"aliguerrerodev@gmail.com\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"2026-03-17 11:25:10\", \"fecha_actualizacion\": \"2026-03-17 20:17:42\"}', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"aliguerrerodev@gmail.com\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"2026-03-17 11:25:10\", \"fecha_actualizacion\": \"2026-03-17 20:17:45\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:17:45', '2026-03-17 20:17:45', 1),
(3, NULL, 'configuracion_smtp', 'UPDATE', '1', 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"aliguerrerodev@gmail.com\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"2026-03-17 11:25:10\", \"fecha_actualizacion\": \"2026-03-17 20:17:45\"}', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"2026-03-17 11:25:10\", \"fecha_actualizacion\": \"2026-03-17 20:17:48\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:17:48', '2026-03-17 20:17:48', 1),
(4, NULL, 'configuracion_smtp', 'UPDATE', '1', 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"2026-03-17 11:25:10\", \"fecha_actualizacion\": \"2026-03-17 20:17:48\"}', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:17:53\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:17:53', '2026-03-17 20:17:53', 1),
(5, NULL, 'configuracion_smtp', 'UPDATE', '1', 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:17:53\"}', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:17:55\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:17:55', '2026-03-17 20:17:55', 1),
(6, NULL, 'configuracion_smtp', 'UPDATE', '1', 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:17:53\"}', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:17:57\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:17:57', '2026-03-17 20:17:57', 1),
(7, NULL, 'configuracion_smtp', 'UPDATE', '1', 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:17:53\"}', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:17:59\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:17:59', '2026-03-17 20:17:59', 1),
(8, NULL, 'configuracion_smtp', 'UPDATE', '1', 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:17:53\"}', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:18:00\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:18:00', '2026-03-17 20:18:00', 1),
(9, NULL, 'empleados', 'INSERT', '1', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 1, \"cedula\": 123456789, \"nombre\": \"Elsy\", \"apellido\": \"Meza\", \"id_dependencia\": 6, \"telefono\": null, \"correo\": \"meza.elsy@gmail.com\", \"direccion\": null, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(10, NULL, 'usuarios', 'INSERT', '1', 'INSERT en usuarios', 'Se inserto un registro en usuarios', NULL, '{\"id_usuario\": 1, \"id_empleado\": 1, \"id_dependencia\": 6, \"usuario\": \"admin\", \"password\": \"15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225\", \"rol\": \"ADMIN\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(11, NULL, 'usuarios_seguridad_acceso', 'INSERT', '1', 'INSERT en usuarios_seguridad_acceso', 'Se inserto un registro en usuarios_seguridad_acceso', NULL, '{\"id_usuario\": 1, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 20:34:52\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(12, NULL, 'usuarios_seguridad_acceso', 'UPDATE', '1', 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', '{\"id_usuario\": 1, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 20:34:52\"}', '{\"id_usuario\": 1, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 20:34:52\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(13, NULL, 'permisos', 'UPDATE', '99', 'UPDATE en permisos', 'Se actualizo un registro en permisos', '{\"id_permiso\": 99, \"nombre_permiso\": \"Acceso total del sistema\", \"descripcion\": \"Permiso exclusivo para acceso completo a todos los modulos; solo puede transferirse a otro usuario administrador.\", \"estado\": 1}', '{\"id_permiso\": 99, \"nombre_permiso\": \"Acceso total del sistema\", \"descripcion\": \"Permiso exclusivo para acceso completo a todos los modulos; solo puede transferirse a otro usuario administrador.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(14, NULL, 'usuario_permisos', 'INSERT', '1', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 1, \"id_usuario\": 1, \"id_permiso\": 1, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(15, NULL, 'usuario_permisos', 'INSERT', '2', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 2, \"id_usuario\": 1, \"id_permiso\": 2, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(16, NULL, 'usuario_permisos', 'INSERT', '3', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 3, \"id_usuario\": 1, \"id_permiso\": 3, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(17, NULL, 'usuario_permisos', 'INSERT', '4', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 4, \"id_usuario\": 1, \"id_permiso\": 4, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(18, NULL, 'usuario_permisos', 'INSERT', '5', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 5, \"id_usuario\": 1, \"id_permiso\": 5, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(19, NULL, 'usuario_permisos', 'INSERT', '6', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 6, \"id_usuario\": 1, \"id_permiso\": 6, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(20, NULL, 'usuario_permisos', 'INSERT', '7', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 7, \"id_usuario\": 1, \"id_permiso\": 7, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(21, NULL, 'usuario_permisos', 'INSERT', '8', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 8, \"id_usuario\": 1, \"id_permiso\": 8, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(22, NULL, 'usuario_permisos', 'INSERT', '9', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 9, \"id_usuario\": 1, \"id_permiso\": 99, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 00:34:52', '2026-03-17 20:34:52', 1),
(23, NULL, 'configuracion_smtp', 'UPDATE', '1', 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"\", \"clave\": \"\", \"correo_remitente\": \"\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:17:53\"}', '{\"id_configuracion_smtp\": 1, \"host\": \"smtp.gmail.com\", \"puerto\": 587, \"usuario\": \"meza.elsy@gmail.com\", \"clave\": \"mqmrsujmyabwpgbv\", \"correo_remitente\": \"meza.elsy@gmail.com\", \"nombre_remitente\": \"Sala Situacional\", \"usar_tls\": 1, \"estado\": 1, \"id_usuario_actualiza\": 1, \"fecha_registro\": \"0000-00-00 00:00:00\", \"fecha_actualizacion\": \"2026-03-17 20:47:17\"}', 'root@localhost', '127.0.0.1', '2026-03-18 00:47:17', '2026-03-17 20:47:17', 1),
(24, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'SMTP ACTUALIZAR CONFIGURACION', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 00:47:17', '2026-03-17 20:47:17', 1),
(25, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'SMTP ENVIO PRUEBA - Destino: aliguerrero102@gmail.com', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 00:47:33', '2026-03-17 20:47:33', 1),
(26, NULL, 'empleados', 'INSERT', '2', 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, '{\"id_empleado\": 2, \"cedula\": 22222222, \"nombre\": \"Laura\", \"apellido\": \"Franco\", \"id_dependencia\": 3, \"telefono\": \"04244668450\", \"correo\": \"flaura2705@gmail.com\", \"direccion\": \"Libetrador - tocuyito\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:05:55', '2026-03-17 21:05:55', 1),
(27, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'EMPLEADOS CREAR - Empleado ID 2', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:05:55', '2026-03-17 21:05:55', 1),
(28, NULL, 'empleados', 'UPDATE', '1', 'UPDATE en empleados', 'Se actualizo un registro en empleados', '{\"id_empleado\": 1, \"cedula\": 123456789, \"nombre\": \"Elsy\", \"apellido\": \"Meza\", \"id_dependencia\": 6, \"telefono\": null, \"correo\": \"meza.elsy@gmail.com\", \"direccion\": null, \"estado\": 1}', '{\"id_empleado\": 1, \"cedula\": 123456789, \"nombre\": \"Elsy\", \"apellido\": \"Meza\", \"id_dependencia\": 6, \"telefono\": \"04269390643\", \"correo\": \"meza.elsy@gmail.com\", \"direccion\": \"San Diego\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:06:35', '2026-03-17 21:06:35', 1),
(29, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'EMPLEADOS ACTUALIZAR - Empleado ID 1', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:06:35', '2026-03-17 21:06:35', 1),
(30, NULL, 'usuarios', 'INSERT', '2', 'INSERT en usuarios', 'Se inserto un registro en usuarios', NULL, '{\"id_usuario\": 2, \"id_empleado\": 2, \"id_dependencia\": 4, \"usuario\": \"laura\", \"password\": \"15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225\", \"rol\": \"OPERADOR\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:08:06', '2026-03-17 21:08:06', 1),
(31, NULL, 'usuario_permisos', 'INSERT', '10', 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, '{\"id_usuario_permiso\": 10, \"id_usuario\": 2, \"id_permiso\": 3, \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:08:06', '2026-03-17 21:08:06', 1),
(32, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'USUARIOS CREAR - Usuario ID 2', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:08:06', '2026-03-17 21:08:06', 1),
(33, NULL, 'beneficiarios', 'INSERT', '1', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 1, \"nacionalidad\": \"V\", \"cedula\": 123456789, \"nombre_beneficiario\": \"Maria Perez\", \"telefono\": \"04269390643\", \"id_comunidad\": 24, \"comunidad\": \"12 de Octubre\", \"fecha_registro\": \"2026-03-17 21:11:15\", \"hora_registro_12h\": \"09:11:15 PM\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:11:15', '2026-03-17 21:11:15', 1),
(34, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Beneficiario ID 1 - V-123456789 - Maria Perez', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:11:15', '2026-03-17 21:11:15', 1),
(35, NULL, 'beneficiarios', 'INSERT', '2', 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, '{\"id_beneficiario\": 2, \"nacionalidad\": \"V\", \"cedula\": 223344556, \"nombre_beneficiario\": \"Laura Franco\", \"telefono\": \"04244668450\", \"id_comunidad\": 42, \"comunidad\": \"Barrio Manuelita Saenz\", \"fecha_registro\": \"2026-03-17 21:12:17\", \"hora_registro_12h\": \"09:12:17 PM\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:12:17', '2026-03-17 21:12:17', 1),
(36, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Beneficiario ID 2 - V-223344556 - Laura Franco', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:12:17', '2026-03-17 21:12:17', 1),
(37, NULL, 'beneficiarios', 'UPDATE', '2', 'UPDATE en beneficiarios', 'Se actualizo un registro en beneficiarios', '{\"id_beneficiario\": 2, \"nacionalidad\": \"V\", \"cedula\": 223344556, \"nombre_beneficiario\": \"Laura Franco\", \"telefono\": \"04244668450\", \"id_comunidad\": 42, \"comunidad\": \"Barrio Manuelita Saenz\", \"fecha_registro\": \"2026-03-17 21:12:17\", \"hora_registro_12h\": \"09:12:17 PM\", \"estado\": 1}', '{\"id_beneficiario\": 2, \"nacionalidad\": \"V\", \"cedula\": 223344556, \"nombre_beneficiario\": \"Elsy Meza\", \"telefono\": \"04244668450\", \"id_comunidad\": 42, \"comunidad\": \"Barrio Manuelita Saenz\", \"fecha_registro\": \"2026-03-17 21:12:17\", \"hora_registro_12h\": \"09:12:17 PM\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:12:27', '2026-03-17 21:12:27', 1),
(38, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'ACTUALIZAR Beneficiario ID 2 - V-223344556 - Elsy Meza', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:12:28', '2026-03-17 21:12:28', 1),
(39, NULL, 'beneficiarios', 'UPDATE', '1', 'UPDATE en beneficiarios', 'Se actualizo un registro en beneficiarios', '{\"id_beneficiario\": 1, \"nacionalidad\": \"V\", \"cedula\": 123456789, \"nombre_beneficiario\": \"Maria Perez\", \"telefono\": \"04269390643\", \"id_comunidad\": 24, \"comunidad\": \"12 de Octubre\", \"fecha_registro\": \"2026-03-17 21:11:15\", \"hora_registro_12h\": \"09:11:15 PM\", \"estado\": 1}', '{\"id_beneficiario\": 1, \"nacionalidad\": \"V\", \"cedula\": 123456789, \"nombre_beneficiario\": \"Elsy Meza\", \"telefono\": \"04269390643\", \"id_comunidad\": 24, \"comunidad\": \"12 de Octubre\", \"fecha_registro\": \"2026-03-17 21:11:15\", \"hora_registro_12h\": \"09:11:15 PM\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:13:00', '2026-03-17 21:13:00', 1),
(40, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'ACTUALIZAR Beneficiario ID 1 - V-123456789 - Elsy Meza', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:13:00', '2026-03-17 21:13:00', 1),
(41, NULL, 'beneficiarios', 'UPDATE', '2', 'UPDATE en beneficiarios', 'Se actualizo un registro en beneficiarios', '{\"id_beneficiario\": 2, \"nacionalidad\": \"V\", \"cedula\": 223344556, \"nombre_beneficiario\": \"Elsy Meza\", \"telefono\": \"04244668450\", \"id_comunidad\": 42, \"comunidad\": \"Barrio Manuelita Saenz\", \"fecha_registro\": \"2026-03-17 21:12:17\", \"hora_registro_12h\": \"09:12:17 PM\", \"estado\": 1}', '{\"id_beneficiario\": 2, \"nacionalidad\": \"V\", \"cedula\": 223344556, \"nombre_beneficiario\": \"Laura Franco\", \"telefono\": \"04244668450\", \"id_comunidad\": 42, \"comunidad\": \"Barrio Manuelita Saenz\", \"fecha_registro\": \"2026-03-17 21:12:17\", \"hora_registro_12h\": \"09:12:17 PM\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:13:14', '2026-03-17 21:13:14', 1),
(42, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'ACTUALIZAR Beneficiario ID 2 - V-223344556 - Laura Franco', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:13:14', '2026-03-17 21:13:14', 1),
(43, NULL, 'ayuda_social', 'INSERT', '1', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 1, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 14, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Reubicacion de insectos\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-17\", \"descripcion\": \"plaga de mosquitos\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:14:05', '2026-03-17 21:14:05', 1),
(44, NULL, 'ayuda_social', 'UPDATE', '1', 'UPDATE en ayuda_social', 'Se actualizo un registro en ayuda_social', '{\"id_ayuda\": 1, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 14, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Reubicacion de insectos\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-17\", \"descripcion\": \"plaga de mosquitos\", \"estado\": 1}', '{\"id_ayuda\": 1, \"ticket_interno\": \"AYU-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 14, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Reubicacion de insectos\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-17\", \"descripcion\": \"plaga de mosquitos\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:14:05', '2026-03-17 21:14:05', 1),
(45, NULL, 'seguimientos_solicitudes', 'INSERT', '1', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 1, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 1, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-17 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:14:05', '2026-03-17 21:14:05', 1),
(46, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Ayuda Social - Beneficiario: 1 - Tipo ID: 14 - Solicitud ID: 2', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:14:05', '2026-03-17 21:14:05', 1),
(47, NULL, 'ayuda_social', 'INSERT', '2', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 2, \"ticket_interno\": \"\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 11, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Riesgo de vias publicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-17\", \"descripcion\": \"Mucho baches en la via\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:15:59', '2026-03-17 21:15:59', 1),
(48, NULL, 'ayuda_social', 'UPDATE', '2', 'UPDATE en ayuda_social', 'Se actualizo un registro en ayuda_social', '{\"id_ayuda\": 2, \"ticket_interno\": \"\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 11, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Riesgo de vias publicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-17\", \"descripcion\": \"Mucho baches en la via\", \"estado\": 1}', '{\"id_ayuda\": 2, \"ticket_interno\": \"AYU-20260317-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 11, \"id_solicitud_ayuda_social\": 1, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Riesgo de vias publicas\", \"solicitud_ayuda\": \"1X10\", \"fecha_ayuda\": \"2026-03-17\", \"descripcion\": \"Mucho baches en la via\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:15:59', '2026-03-17 21:15:59', 1),
(49, NULL, 'seguimientos_solicitudes', 'INSERT', '2', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 2, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 2, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-17 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:15:59', '2026-03-17 21:15:59', 1),
(50, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Ayuda Social - Beneficiario: 2 - Tipo ID: 11 - Solicitud ID: 1', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:15:59', '2026-03-17 21:15:59', 1),
(51, NULL, 'unidades', 'INSERT', '1', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"AMBULANCIA FORD\", \"placa\": \"14M-14K\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"BASE CENTRAL\", \"referencia_actual\": \"FRENTE AL CDI\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:17:07\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:17:07', '2026-03-17 21:17:07', 1),
(52, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'GUARDAR unidad operativa de ambulancia', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:17:07', '2026-03-17 21:17:07', 1),
(53, NULL, 'unidades', 'INSERT', '2', 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"AMBULANCIA 0800 BIGOTE\", \"placa\": \"IUT-OYUP9\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"FLOR AMARILLO\", \"referencia_actual\": \"FLOR AMARILLO\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:17:58\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:17:58', '2026-03-17 21:17:58', 1),
(54, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'GUARDAR unidad operativa de ambulancia', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:17:58', '2026-03-17 21:17:58', 1),
(55, NULL, 'choferes_ambulancia', 'INSERT', '1', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 1, \"id_empleado\": 1, \"numero_licencia\": \"LIC-00215\", \"categoria_licencia\": \"4to grado\", \"vencimiento_licencia\": \"2032-05-04\", \"contacto_emergencia\": \"ANDRES AGULAR\", \"telefono_contacto_emergencia\": \"0412000000\", \"observaciones\": \"S/E\", \"estado\": 1, \"fecha_registro\": \"2026-03-17 21:18:55\", \"fecha_actualizacion\": \"2026-03-17 21:18:55\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:18:55', '2026-03-17 21:18:55', 1),
(56, NULL, 'asignaciones_unidades_choferes', 'INSERT', '1', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 1, \"id_unidad\": 1, \"id_chofer_ambulancia\": 1, \"fecha_inicio\": \"2026-03-18 02:18:55\", \"fecha_fin\": null, \"observaciones\": \"Asignacion directa desde el formulario de chofer operativo.\", \"estado\": 1, \"fecha_registro\": \"2026-03-17 21:18:55\", \"fecha_actualizacion\": \"2026-03-17 21:18:55\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:18:55', '2026-03-17 21:18:55', 1),
(57, NULL, 'unidades', 'UPDATE', '1', 'UPDATE en unidades', 'Se actualizo un registro en unidades', '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"AMBULANCIA FORD\", \"placa\": \"14M-14K\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"BASE CENTRAL\", \"referencia_actual\": \"FRENTE AL CDI\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:17:07\"}', '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"AMBULANCIA FORD\", \"placa\": \"14M-14K\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"BASE CENTRAL\", \"referencia_actual\": \"FRENTE AL CDI\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:18:55\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:18:55', '2026-03-17 21:18:55', 1),
(58, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'GUARDAR perfil operativo de chofer', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:18:55', '2026-03-17 21:18:55', 1),
(59, NULL, 'choferes_ambulancia', 'INSERT', '2', 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, '{\"id_chofer_ambulancia\": 2, \"id_empleado\": 2, \"numero_licencia\": \"LIC-8749\", \"categoria_licencia\": \"5to grado\", \"vencimiento_licencia\": \"2029-06-12\", \"contacto_emergencia\": \"MANUEL\", \"telefono_contacto_emergencia\": \"042612345678\", \"observaciones\": \"S/E\", \"estado\": 1, \"fecha_registro\": \"2026-03-17 21:19:53\", \"fecha_actualizacion\": \"2026-03-17 21:19:53\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:19:53', '2026-03-17 21:19:53', 1),
(60, NULL, 'asignaciones_unidades_choferes', 'INSERT', '2', 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, '{\"id_asignacion_unidad_chofer\": 2, \"id_unidad\": 2, \"id_chofer_ambulancia\": 2, \"fecha_inicio\": \"2026-03-18 02:19:53\", \"fecha_fin\": null, \"observaciones\": \"Asignacion directa desde el formulario de chofer operativo.\", \"estado\": 1, \"fecha_registro\": \"2026-03-17 21:19:53\", \"fecha_actualizacion\": \"2026-03-17 21:19:53\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:19:53', '2026-03-17 21:19:53', 1),
(61, NULL, 'unidades', 'UPDATE', '2', 'UPDATE en unidades', 'Se actualizo un registro en unidades', '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"AMBULANCIA 0800 BIGOTE\", \"placa\": \"IUT-OYUP9\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"FLOR AMARILLO\", \"referencia_actual\": \"FLOR AMARILLO\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:17:58\"}', '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"AMBULANCIA 0800 BIGOTE\", \"placa\": \"IUT-OYUP9\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"FLOR AMARILLO\", \"referencia_actual\": \"FLOR AMARILLO\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:19:53\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:19:53', '2026-03-17 21:19:53', 1),
(62, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'GUARDAR perfil operativo de chofer', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:19:53', '2026-03-17 21:19:53', 1),
(63, NULL, 'servicios_publicos', 'INSERT', '1', 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, '{\"id_servicio\": 1, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 3, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 1, \"tipo_servicio\": \"Alumbrado Publico\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-17\", \"descripcion\": \"FALTA DE ELIMINACION EN LA AREAS DE LA COMUNIDAD - LA HONDA\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:20:39', '2026-03-17 21:20:39', 1),
(64, NULL, 'servicios_publicos', 'UPDATE', '1', 'UPDATE en servicios_publicos', 'Se actualizo un registro en servicios_publicos', '{\"id_servicio\": 1, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 3, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 1, \"tipo_servicio\": \"Alumbrado Publico\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-17\", \"descripcion\": \"FALTA DE ELIMINACION EN LA AREAS DE LA COMUNIDAD - LA HONDA\", \"estado\": 1}', '{\"id_servicio\": 1, \"ticket_interno\": \"SPU-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_servicio_publico\": 3, \"id_solicitud_servicio_publico\": 3, \"id_estado_solicitud\": 1, \"tipo_servicio\": \"Alumbrado Publico\", \"solicitud_servicio\": \"Redes sociales\", \"fecha_servicio\": \"2026-03-17\", \"descripcion\": \"FALTA DE ELIMINACION EN LA AREAS DE LA COMUNIDAD - LA HONDA\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:20:39', '2026-03-17 21:20:39', 1),
(65, NULL, 'seguimientos_solicitudes', 'INSERT', '3', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 3, \"modulo\": \"SERVICIOS_PUBLICOS\", \"id_referencia\": 1, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-17 08:00:00\", \"observacion\": \"Solicitud registrada en servicios publicos.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:20:39', '2026-03-17 21:20:39', 1),
(66, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Servicios Publicos - Beneficiario: 1 - Tipo ID: 3 - Solicitud ID: 3', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:20:39', '2026-03-17 21:20:39', 1),
(67, NULL, 'usuarios_seguridad_acceso', 'INSERT', '2', 'INSERT en usuarios_seguridad_acceso', 'Se inserto un registro en usuarios_seguridad_acceso', NULL, '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 21:22:18\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:22:18', '2026-03-17 21:22:18', 1),
(68, NULL, 'usuarios_seguridad_acceso', 'UPDATE', '1', 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', '{\"id_usuario\": 1, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 20:34:52\"}', '{\"id_usuario\": 1, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 21:23:05\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:23:05', '2026-03-17 21:23:05', 1),
(69, NULL, 'seguridad', 'INSERT', '1', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 1, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:23:00\", \"descripcion\": \"atención médica de urgencia.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"AV. PRINCIPAL\", \"referencia_evento\": \"frente a la gobernación\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:24:48', '2026-03-17 21:24:48', 1),
(70, NULL, 'seguridad', 'UPDATE', '1', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 1, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:23:00\", \"descripcion\": \"atención médica de urgencia.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"AV. PRINCIPAL\", \"referencia_evento\": \"frente a la gobernación\", \"estado\": 1}', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:23:00\", \"descripcion\": \"atención médica de urgencia.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"AV. PRINCIPAL\", \"referencia_evento\": \"frente a la gobernación\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:24:48', '2026-03-17 21:24:48', 1),
(71, NULL, 'unidades', 'UPDATE', '1', 'UPDATE en unidades', 'Se actualizo un registro en unidades', '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"AMBULANCIA FORD\", \"placa\": \"14M-14K\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"BASE CENTRAL\", \"referencia_actual\": \"FRENTE AL CDI\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:18:55\"}', '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"AMBULANCIA FORD\", \"placa\": \"14M-14K\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"BASE CENTRAL\", \"referencia_actual\": \"FRENTE AL CDI\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:24:48\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:24:48', '2026-03-17 21:24:48', 1),
(72, NULL, 'despachos_unidades', 'INSERT', '1', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 1, \"id_seguridad\": 1, \"id_unidad\": 1, \"id_chofer_ambulancia\": 1, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"ACTIVO\", \"fecha_asignacion\": \"2026-03-17 21:24:48\", \"fecha_cierre\": null, \"ubicacion_salida\": \"BASE CENTRAL\", \"ubicacion_evento\": \"AV. PRINCIPAL\", \"ubicacion_cierre\": null, \"observaciones\": \"Asignacion automatica al guardar la solicitud.\", \"fecha_registro\": \"2026-03-17 21:24:48\", \"fecha_actualizacion\": \"2026-03-17 21:24:48\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:24:48', '2026-03-17 21:24:48', 1),
(73, NULL, 'seguridad', 'UPDATE', '1', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:23:00\", \"descripcion\": \"atención médica de urgencia.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"AV. PRINCIPAL\", \"referencia_evento\": \"frente a la gobernación\", \"estado\": 1}', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:23:00\", \"descripcion\": \"atención médica de urgencia.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"AV. PRINCIPAL\", \"referencia_evento\": \"frente a la gobernación\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:24:48', '2026-03-17 21:24:48', 1),
(74, NULL, 'seguridad', 'UPDATE', '1', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:23:00\", \"descripcion\": \"atención médica de urgencia.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"AV. PRINCIPAL\", \"referencia_evento\": \"frente a la gobernación\", \"estado\": 1}', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:23:00\", \"descripcion\": \"atención médica de urgencia.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"AV. PRINCIPAL\", \"referencia_evento\": \"frente a la gobernación\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:24:48', '2026-03-17 21:24:48', 1),
(75, NULL, 'seguimientos_solicitudes', 'INSERT', '4', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 4, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 1, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-17 21:23:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:24:48', '2026-03-17 21:24:48', 1),
(76, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '1', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 1, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260317-000001_registro_20260318_022448_1068.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260317-000001_registro_20260318_022448_1068.pdf\", \"estado_envio\": \"NO_APLICA\", \"correo_destino\": null, \"fecha_envio\": null, \"detalle_envio\": \"Envio no solicitado.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-17 21:24:49\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:24:49', '2026-03-17 21:24:49', 1),
(77, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Seguridad y Emergencia - Ticket: SEG-20260317-000001 - Estado: DESPACHADO', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:24:49', '2026-03-17 21:24:49', 1),
(78, NULL, 'seguridad', 'INSERT', '2', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 2, \"ticket_interno\": \"\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 6, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Traslado\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-17 21:26:00\", \"descripcion\": \"posible choque.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Autopista\", \"referencia_evento\": \"Mayorista\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:27:19', '2026-03-17 21:27:19', 1),
(79, NULL, 'seguridad', 'UPDATE', '2', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 2, \"ticket_interno\": \"\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 6, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Traslado\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-17 21:26:00\", \"descripcion\": \"posible choque.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Autopista\", \"referencia_evento\": \"Mayorista\", \"estado\": 1}', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260317-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 6, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Traslado\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-17 21:26:00\", \"descripcion\": \"posible choque.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Autopista\", \"referencia_evento\": \"Mayorista\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:27:19', '2026-03-17 21:27:19', 1),
(80, NULL, 'unidades', 'UPDATE', '2', 'UPDATE en unidades', 'Se actualizo un registro en unidades', '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"AMBULANCIA 0800 BIGOTE\", \"placa\": \"IUT-OYUP9\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"FLOR AMARILLO\", \"referencia_actual\": \"FLOR AMARILLO\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:19:53\"}', '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"AMBULANCIA 0800 BIGOTE\", \"placa\": \"IUT-OYUP9\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"FLOR AMARILLO\", \"referencia_actual\": \"FLOR AMARILLO\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:27:19\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:27:19', '2026-03-17 21:27:19', 1),
(81, NULL, 'despachos_unidades', 'INSERT', '2', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 2, \"id_seguridad\": 2, \"id_unidad\": 2, \"id_chofer_ambulancia\": 2, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"ACTIVO\", \"fecha_asignacion\": \"2026-03-17 21:27:19\", \"fecha_cierre\": null, \"ubicacion_salida\": \"FLOR AMARILLO\", \"ubicacion_evento\": \"Autopista\", \"ubicacion_cierre\": null, \"observaciones\": \"Asignacion automatica al guardar la solicitud.\", \"fecha_registro\": \"2026-03-17 21:27:19\", \"fecha_actualizacion\": \"2026-03-17 21:27:19\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:27:19', '2026-03-17 21:27:19', 1),
(82, NULL, 'seguridad', 'UPDATE', '2', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260317-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 6, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Traslado\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-17 21:26:00\", \"descripcion\": \"posible choque.\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"Autopista\", \"referencia_evento\": \"Mayorista\", \"estado\": 1}', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260317-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 6, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Traslado\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-17 21:26:00\", \"descripcion\": \"posible choque.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"Autopista\", \"referencia_evento\": \"Mayorista\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:27:19', '2026-03-17 21:27:19', 1),
(83, NULL, 'seguridad', 'UPDATE', '2', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260317-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 6, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Traslado\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-17 21:26:00\", \"descripcion\": \"posible choque.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"Autopista\", \"referencia_evento\": \"Mayorista\", \"estado\": 1}', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260317-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 6, \"id_solicitud_seguridad\": 3, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Traslado\", \"tipo_solicitud\": \"Redes sociales\", \"fecha_seguridad\": \"2026-03-17 21:26:00\", \"descripcion\": \"posible choque.\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"Autopista\", \"referencia_evento\": \"Mayorista\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:27:19', '2026-03-17 21:27:19', 1),
(84, NULL, 'seguimientos_solicitudes', 'INSERT', '5', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 5, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 2, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-17 21:26:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:27:19', '2026-03-17 21:27:19', 1),
(85, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '2', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 2, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260317-000002_registro_20260318_022719_5673.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260317-000002_registro_20260318_022719_5673.pdf\", \"estado_envio\": \"NO_APLICA\", \"correo_destino\": null, \"fecha_envio\": null, \"detalle_envio\": \"Envio no solicitado.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-17 21:27:19\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:27:19', '2026-03-17 21:27:19', 1),
(86, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Seguridad y Emergencia - Ticket: SEG-20260317-000002 - Estado: DESPACHADO', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:27:19', '2026-03-17 21:27:19', 1);
INSERT INTO `bitacora` (`id_bitacora`, `id_usuario`, `tabla_afectada`, `accion`, `id_registro`, `resumen`, `detalle`, `datos_antes`, `datos_despues`, `usuario_bd`, `ipaddr`, `moment`, `fecha_evento`, `estado`) VALUES
(87, NULL, 'reportes_solicitudes_ambulancia', 'UPDATE', '2', 'UPDATE en reportes_solicitudes_ambulancia', 'Se actualizo un registro en reportes_solicitudes_ambulancia', '{\"id_reporte_solicitud\": 2, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260317-000002_registro_20260318_022719_5673.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260317-000002_registro_20260318_022719_5673.pdf\", \"estado_envio\": \"NO_APLICA\", \"correo_destino\": null, \"fecha_envio\": null, \"detalle_envio\": \"Envio no solicitado.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-17 21:27:19\", \"estado\": 1}', '{\"id_reporte_solicitud\": 2, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260317-000002_registro_20260318_022719_5673.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260317-000002_registro_20260318_022719_5673.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"flaura2705@gmail.com\", \"fecha_envio\": \"2026-03-18 02:28:48\", \"detalle_envio\": \"Reporte enviado correctamente al correo del chofer con archivo adjunto.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-17 21:27:19\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:28:48', '2026-03-17 21:28:48', 1),
(88, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'REENVIAR reporte al correo del chofer en solicitud ID 2', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:28:48', '2026-03-17 21:28:48', 1),
(89, NULL, 'unidades', 'UPDATE', '1', 'UPDATE en unidades', 'Se actualizo un registro en unidades', '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"AMBULANCIA FORD\", \"placa\": \"14M-14K\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"BASE CENTRAL\", \"referencia_actual\": \"FRENTE AL CDI\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:24:48\"}', '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"AMBULANCIA FORD\", \"placa\": \"14M-14K\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"BASE CENTRAL\", \"referencia_actual\": \"FRENTE AL CDI\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:49:23\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:49:23', '2026-03-17 21:49:23', 1),
(90, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'GUARDAR unidad operativa de ambulancia', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:49:23', '2026-03-17 21:49:23', 1),
(91, NULL, 'unidades', 'UPDATE', '2', 'UPDATE en unidades', 'Se actualizo un registro en unidades', '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"AMBULANCIA 0800 BIGOTE\", \"placa\": \"IUT-OYUP9\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"FLOR AMARILLO\", \"referencia_actual\": \"FLOR AMARILLO\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:27:19\"}', '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"AMBULANCIA 0800 BIGOTE\", \"placa\": \"IUT-OYUP9\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"FLOR AMARILLO\", \"referencia_actual\": \"FLOR AMARILLO\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:49:34\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:49:34', '2026-03-17 21:49:34', 1),
(92, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'GUARDAR unidad operativa de ambulancia', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:49:34', '2026-03-17 21:49:34', 1),
(93, NULL, 'seguridad', 'INSERT', '1', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 1, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:49:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"AV principal\", \"referencia_evento\": \"Autopista\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:50:24', '2026-03-17 21:50:24', 1),
(94, NULL, 'seguridad', 'UPDATE', '1', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 1, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:49:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"AV principal\", \"referencia_evento\": \"Autopista\", \"estado\": 1}', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:49:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"AV principal\", \"referencia_evento\": \"Autopista\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:50:24', '2026-03-17 21:50:24', 1),
(95, NULL, 'unidades', 'UPDATE', '1', 'UPDATE en unidades', 'Se actualizo un registro en unidades', '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"AMBULANCIA FORD\", \"placa\": \"14M-14K\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"BASE CENTRAL\", \"referencia_actual\": \"FRENTE AL CDI\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:49:23\"}', '{\"id_unidad\": 1, \"codigo_unidad\": \"AMB-001\", \"descripcion\": \"AMBULANCIA FORD\", \"placa\": \"14M-14K\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"BASE CENTRAL\", \"referencia_actual\": \"FRENTE AL CDI\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:50:24\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:50:24', '2026-03-17 21:50:24', 1),
(96, NULL, 'despachos_unidades', 'INSERT', '1', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 1, \"id_seguridad\": 1, \"id_unidad\": 1, \"id_chofer_ambulancia\": 1, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"ACTIVO\", \"fecha_asignacion\": \"2026-03-17 21:50:24\", \"fecha_cierre\": null, \"ubicacion_salida\": \"BASE CENTRAL\", \"ubicacion_evento\": \"AV principal\", \"ubicacion_cierre\": null, \"observaciones\": \"Asignacion automatica al guardar la solicitud.\", \"fecha_registro\": \"2026-03-17 21:50:24\", \"fecha_actualizacion\": \"2026-03-17 21:50:24\"}', 'root@localhost', '127.0.0.1', '2026-03-18 01:50:24', '2026-03-17 21:50:24', 1),
(97, NULL, 'seguridad', 'UPDATE', '1', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:49:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"AV principal\", \"referencia_evento\": \"Autopista\", \"estado\": 1}', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:49:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"AV principal\", \"referencia_evento\": \"Autopista\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:50:24', '2026-03-17 21:50:24', 1),
(98, NULL, 'seguridad', 'UPDATE', '1', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:49:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"AV principal\", \"referencia_evento\": \"Autopista\", \"estado\": 1}', '{\"id_seguridad\": 1, \"ticket_interno\": \"SEG-20260317-000001\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-17 21:49:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"AV principal\", \"referencia_evento\": \"Autopista\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:50:24', '2026-03-17 21:50:24', 1),
(99, NULL, 'seguimientos_solicitudes', 'INSERT', '1', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 1, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 1, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-17 21:49:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:50:24', '2026-03-17 21:50:24', 1),
(100, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '1', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 1, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260317-000001_registro_20260318_025024_1406.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260317-000001_registro_20260318_025024_1406.pdf\", \"estado_envio\": \"NO_APLICA\", \"correo_destino\": null, \"fecha_envio\": null, \"detalle_envio\": \"Envio no solicitado.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-17 21:50:24\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:50:24', '2026-03-17 21:50:24', 1),
(101, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Seguridad y Emergencia - Ticket: SEG-20260317-000001 - Estado: DESPACHADO', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:50:24', '2026-03-17 21:50:24', 1),
(102, NULL, 'reportes_solicitudes_ambulancia', 'UPDATE', '1', 'UPDATE en reportes_solicitudes_ambulancia', 'Se actualizo un registro en reportes_solicitudes_ambulancia', '{\"id_reporte_solicitud\": 1, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260317-000001_registro_20260318_025024_1406.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260317-000001_registro_20260318_025024_1406.pdf\", \"estado_envio\": \"NO_APLICA\", \"correo_destino\": null, \"fecha_envio\": null, \"detalle_envio\": \"Envio no solicitado.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-17 21:50:24\", \"estado\": 1}', '{\"id_reporte_solicitud\": 1, \"id_seguridad\": 1, \"id_despacho_unidad\": 1, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260317-000001_registro_20260318_025024_1406.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260317-000001_registro_20260318_025024_1406.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"meza.elsy@gmail.com\", \"fecha_envio\": \"2026-03-18 02:50:53\", \"detalle_envio\": \"Reporte enviado correctamente al correo del chofer con archivo adjunto.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-17 21:50:24\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 01:50:53', '2026-03-17 21:50:53', 1),
(103, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'REENVIAR reporte al correo del chofer en solicitud ID 1', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 01:50:53', '2026-03-17 21:50:53', 1),
(104, NULL, 'usuarios_seguridad_acceso', 'UPDATE', '1', 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', '{\"id_usuario\": 1, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 20:34:52\"}', '{\"id_usuario\": 1, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 22:21:17\"}', 'root@localhost', '127.0.0.1', '2026-03-18 02:21:17', '2026-03-17 22:21:17', 1),
(105, NULL, 'usuarios_seguridad_acceso', 'UPDATE', '2', 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 21:22:18\"}', '{\"id_usuario\": 2, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 22:31:18\"}', 'root@localhost', '127.0.0.1', '2026-03-18 02:31:18', '2026-03-17 22:31:18', 1),
(106, NULL, 'usuarios_seguridad_acceso', 'UPDATE', '1', 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', '{\"id_usuario\": 1, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-17 20:34:52\"}', '{\"id_usuario\": 1, \"intentos_fallidos\": 0, \"bloqueado\": 0, \"fecha_bloqueo\": null, \"password_temporal\": 0, \"fecha_password_temporal\": null, \"fecha_actualizacion\": \"2026-03-18 09:11:11\"}', 'root@localhost', '127.0.0.1', '2026-03-18 13:11:11', '2026-03-18 09:11:11', 1),
(107, NULL, 'seguridad', 'INSERT', '2', 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, '{\"id_seguridad\": 2, \"ticket_interno\": \"\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-18 09:28:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"comunidad los chirritos\", \"referencia_evento\": \"fente a barrio bueno\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 13:29:39', '2026-03-18 09:29:39', 1),
(108, NULL, 'seguridad', 'UPDATE', '2', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 2, \"ticket_interno\": \"\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-18 09:28:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"comunidad los chirritos\", \"referencia_evento\": \"fente a barrio bueno\", \"estado\": 1}', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260318-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-18 09:28:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"comunidad los chirritos\", \"referencia_evento\": \"fente a barrio bueno\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 13:29:39', '2026-03-18 09:29:39', 1),
(109, NULL, 'unidades', 'UPDATE', '2', 'UPDATE en unidades', 'Se actualizo un registro en unidades', '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"AMBULANCIA 0800 BIGOTE\", \"placa\": \"IUT-OYUP9\", \"estado\": 1, \"estado_operativo\": \"DISPONIBLE\", \"ubicacion_actual\": \"FLOR AMARILLO\", \"referencia_actual\": \"FLOR AMARILLO\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-17 21:49:34\"}', '{\"id_unidad\": 2, \"codigo_unidad\": \"AMB-002\", \"descripcion\": \"AMBULANCIA 0800 BIGOTE\", \"placa\": \"IUT-OYUP9\", \"estado\": 1, \"estado_operativo\": \"EN_SERVICIO\", \"ubicacion_actual\": \"FLOR AMARILLO\", \"referencia_actual\": \"FLOR AMARILLO\", \"prioridad_despacho\": 1, \"fecha_actualizacion_operativa\": \"2026-03-18 09:29:39\"}', 'root@localhost', '127.0.0.1', '2026-03-18 13:29:39', '2026-03-18 09:29:39', 1),
(110, NULL, 'despachos_unidades', 'INSERT', '2', 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, '{\"id_despacho_unidad\": 2, \"id_seguridad\": 2, \"id_unidad\": 2, \"id_chofer_ambulancia\": 2, \"id_usuario_asigna\": 1, \"modo_asignacion\": \"AUTO\", \"estado_despacho\": \"ACTIVO\", \"fecha_asignacion\": \"2026-03-18 09:29:39\", \"fecha_cierre\": null, \"ubicacion_salida\": \"FLOR AMARILLO\", \"ubicacion_evento\": \"comunidad los chirritos\", \"ubicacion_cierre\": null, \"observaciones\": \"Asignacion automatica al guardar la solicitud.\", \"fecha_registro\": \"2026-03-18 09:29:39\", \"fecha_actualizacion\": \"2026-03-18 09:29:39\"}', 'root@localhost', '127.0.0.1', '2026-03-18 13:29:39', '2026-03-18 09:29:39', 1),
(111, NULL, 'seguridad', 'UPDATE', '2', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260318-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-18 09:28:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"REGISTRADO\", \"ubicacion_evento\": \"comunidad los chirritos\", \"referencia_evento\": \"fente a barrio bueno\", \"estado\": 1}', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260318-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-18 09:28:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"comunidad los chirritos\", \"referencia_evento\": \"fente a barrio bueno\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 13:29:39', '2026-03-18 09:29:39', 1),
(112, NULL, 'seguridad', 'UPDATE', '2', 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260318-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 1, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-18 09:28:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"comunidad los chirritos\", \"referencia_evento\": \"fente a barrio bueno\", \"estado\": 1}', '{\"id_seguridad\": 2, \"ticket_interno\": \"SEG-20260318-000002\", \"id_beneficiario\": 2, \"id_usuario\": 1, \"id_tipo_seguridad\": 7, \"id_solicitud_seguridad\": 1, \"id_estado_solicitud\": 2, \"tipo_seguridad\": \"Atencion prehospitalaria\", \"tipo_solicitud\": \"1X10\", \"fecha_seguridad\": \"2026-03-18 09:28:00\", \"descripcion\": \"S/E\", \"estado_atencion\": \"DESPACHADO\", \"ubicacion_evento\": \"comunidad los chirritos\", \"referencia_evento\": \"fente a barrio bueno\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 13:29:39', '2026-03-18 09:29:39', 1),
(113, NULL, 'seguimientos_solicitudes', 'INSERT', '2', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 2, \"modulo\": \"SEGURIDAD\", \"id_referencia\": 2, \"id_estado_solicitud\": 2, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-18 09:28:00\", \"observacion\": \"Solicitud en gestion operativa con unidad y chofer asignados.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 13:29:39', '2026-03-18 09:29:39', 1),
(114, NULL, 'reportes_solicitudes_ambulancia', 'INSERT', '2', 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, '{\"id_reporte_solicitud\": 2, \"id_seguridad\": 2, \"id_despacho_unidad\": 2, \"tipo_reporte\": \"REGISTRO\", \"nombre_archivo\": \"SEG-20260318-000002_registro_20260318_142939_2281.pdf\", \"ruta_archivo\": \"uploads/reportes_solicitudes_ambulancia/SEG-20260318-000002_registro_20260318_142939_2281.pdf\", \"estado_envio\": \"ENVIADO\", \"correo_destino\": \"flaura2705@gmail.com\", \"fecha_envio\": \"2026-03-18 14:29:46\", \"detalle_envio\": \"Reporte enviado correctamente al correo del chofer con archivo adjunto.\", \"id_usuario_genera\": 1, \"fecha_generacion\": \"2026-03-18 09:29:46\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 13:29:46', '2026-03-18 09:29:46', 1),
(115, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Seguridad y Emergencia - Ticket: SEG-20260318-000002 - Estado: DESPACHADO', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 13:29:46', '2026-03-18 09:29:46', 1),
(116, NULL, 'ayuda_social', 'INSERT', '3', 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, '{\"id_ayuda\": 3, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 9, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Hurto\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-18\", \"descripcion\": \"descripcion breve\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 14:36:00', '2026-03-18 10:36:00', 1),
(117, NULL, 'ayuda_social', 'UPDATE', '3', 'UPDATE en ayuda_social', 'Se actualizo un registro en ayuda_social', '{\"id_ayuda\": 3, \"ticket_interno\": \"\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 9, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Hurto\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-18\", \"descripcion\": \"descripcion breve\", \"estado\": 1}', '{\"id_ayuda\": 3, \"ticket_interno\": \"AYU-20260318-000003\", \"id_beneficiario\": 1, \"id_usuario\": 1, \"id_tipo_ayuda_social\": 9, \"id_solicitud_ayuda_social\": 2, \"id_estado_solicitud\": 1, \"tipo_ayuda\": \"Hurto\", \"solicitud_ayuda\": \"Atencion al ciudadano\", \"fecha_ayuda\": \"2026-03-18\", \"descripcion\": \"descripcion breve\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 14:36:00', '2026-03-18 10:36:00', 1),
(118, NULL, 'seguimientos_solicitudes', 'INSERT', '3', 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, '{\"id_seguimiento_solicitud\": 3, \"modulo\": \"AYUDA_SOCIAL\", \"id_referencia\": 3, \"id_estado_solicitud\": 1, \"id_usuario\": 1, \"fecha_gestion\": \"2026-03-18 08:00:00\", \"observacion\": \"Solicitud registrada en ayuda social.\", \"estado\": 1}', 'root@localhost', '127.0.0.1', '2026-03-18 14:36:00', '2026-03-18 10:36:00', 1),
(119, 1, 'SISTEMA', 'LEGACY', NULL, 'Operacion del sistema', 'INSERTAR Ayuda Social - Beneficiario: 1 - Tipo ID: 9 - Solicitud ID: 2', NULL, NULL, 'root@localhost', '127.0.0.1', '2026-03-18 14:36:00', '2026-03-18 10:36:00', 1);

--
-- Disparadores `bitacora`
--
DELIMITER $$
CREATE TRIGGER `tr_bitacora_bd_lock` BEFORE DELETE ON `bitacora` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bitacora inmutable: no se permite DELETE.';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_bitacora_bi_defaults` BEFORE INSERT ON `bitacora` FOR EACH ROW BEGIN
  SET NEW.accion = COALESCE(NULLIF(NEW.accion, ''), 'LEGACY');
  SET NEW.tabla_afectada = COALESCE(NULLIF(NEW.tabla_afectada, ''), 'SISTEMA');
  SET NEW.usuario_bd = COALESCE(NULLIF(NEW.usuario_bd, ''), CURRENT_USER());
  SET NEW.fecha_evento = COALESCE(NEW.fecha_evento, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_bitacora_bu_lock` BEFORE UPDATE ON `bitacora` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bitacora inmutable: no se permite UPDATE.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `choferes_ambulancia`
--

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

--
-- Volcado de datos para la tabla `choferes_ambulancia`
--

INSERT INTO `choferes_ambulancia` (`id_chofer_ambulancia`, `id_empleado`, `numero_licencia`, `categoria_licencia`, `vencimiento_licencia`, `contacto_emergencia`, `telefono_contacto_emergencia`, `observaciones`, `estado`, `fecha_registro`, `fecha_actualizacion`) VALUES
(1, 1, 'LIC-00215', '4to grado', '2032-05-04', 'ANDRES AGULAR', '0412000000', 'S/E', 1, '2026-03-17 21:18:55', '2026-03-17 21:18:55'),
(2, 2, 'LIC-8749', '5to grado', '2029-06-12', 'MANUEL', '042612345678', 'S/E', 1, '2026-03-17 21:19:53', '2026-03-17 21:19:53');

--
-- Disparadores `choferes_ambulancia`
--
DELIMITER $$
CREATE TRIGGER `tr_choferes_ambulancia_ai_audit` AFTER INSERT ON `choferes_ambulancia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'choferes_ambulancia', 'INSERT', CAST(NEW.id_chofer_ambulancia AS CHAR), 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, JSON_OBJECT('id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_empleado', NEW.id_empleado, 'numero_licencia', NEW.numero_licencia, 'categoria_licencia', NEW.categoria_licencia, 'vencimiento_licencia', NEW.vencimiento_licencia, 'contacto_emergencia', NEW.contacto_emergencia, 'telefono_contacto_emergencia', NEW.telefono_contacto_emergencia, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_choferes_ambulancia_au_audit` AFTER UPDATE ON `choferes_ambulancia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'choferes_ambulancia', 'UPDATE', CAST(NEW.id_chofer_ambulancia AS CHAR), 'UPDATE en choferes_ambulancia', 'Se actualizo un registro en choferes_ambulancia', JSON_OBJECT('id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'id_empleado', OLD.id_empleado, 'numero_licencia', OLD.numero_licencia, 'categoria_licencia', OLD.categoria_licencia, 'vencimiento_licencia', OLD.vencimiento_licencia, 'contacto_emergencia', OLD.contacto_emergencia, 'telefono_contacto_emergencia', OLD.telefono_contacto_emergencia, 'observaciones', OLD.observaciones, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_empleado', NEW.id_empleado, 'numero_licencia', NEW.numero_licencia, 'categoria_licencia', NEW.categoria_licencia, 'vencimiento_licencia', NEW.vencimiento_licencia, 'contacto_emergencia', NEW.contacto_emergencia, 'telefono_contacto_emergencia', NEW.telefono_contacto_emergencia, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_choferes_ambulancia_bd_block_delete` BEFORE DELETE ON `choferes_ambulancia` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla choferes_ambulancia. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comunidades`
--

CREATE TABLE `comunidades` (
  `id_comunidad` int(11) NOT NULL COMMENT 'Campo id_comunidad de la tabla comunidades.',
  `nombre_comunidad` varchar(120) NOT NULL COMMENT 'Campo nombre_comunidad de la tabla comunidades.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla comunidades.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla comunidades.',
  `hora_registro_12h` char(11) NOT NULL DEFAULT '' COMMENT 'Campo hora_registro_12h de la tabla comunidades.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `comunidades`
--

INSERT INTO `comunidades` (`id_comunidad`, `nombre_comunidad`, `estado`, `fecha_registro`, `hora_registro_12h`) VALUES
(1, 'Casco Comercial de Tocuyito', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(2, 'Urbanizacion Valles de San Francisco', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(3, 'Conjunto Residencial Los Trescientos', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(4, 'Urbanizacion Jose Rafael Pocaterra', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(5, 'Centro Penitenciario Tocuyito', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(6, 'Santa Eduviges', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(7, 'Bella Vista', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(8, 'Los Mangos', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(9, 'La Herrerena', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(10, 'Urbanizacion La Esperanza', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(11, 'Triangulo El Oasis', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(12, 'Hacienda Juana Paula', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(13, 'Encrucijada de Carabobo', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(14, 'Urbanizacion Santa Paula', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(15, 'Hacienda La Trinidad', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(16, 'Hacienda El Rosario', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(17, 'El Rosario', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(18, 'El Rosal', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(19, 'Los Rosales', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(20, 'Colinas del Rosario', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(21, 'Barrio La Trinidad', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(22, 'Zanjon Dulce', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(23, 'Escuela de Cadafe', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(24, '12 de Octubre', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(25, '9 de Diciembre', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(26, 'La Honda', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(27, 'Altos de La Honda', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(28, 'Banco Obrero Las Palmas', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(29, 'Simon Bolivar', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(30, 'Urbanizacion El Libertador', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(31, 'Jardines del Cementerio El Oasis', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(32, 'Parque Agrinco', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(33, 'San Pablo Valley', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(34, 'El Encanto', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(35, 'Barrio El Oasis', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(36, 'Urbanizacion Villa Jardin', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(37, 'Avicola La Guasima', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(38, 'La Guasima I y II', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(39, 'Comunidad Bicentenario', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(40, 'Comunidad Nueva Villa', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(41, 'Comunidad Alexis Cravo', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(42, 'Barrio Manuelita Saenz', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(43, 'Comunidad Los Chaguaramos', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(44, 'Vertedero La Guasima', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(45, 'Fundacion CAP', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(46, 'Barrio Bueno', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(47, 'Los Chorritos', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(48, 'Urbanizacion El Molino', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(49, 'Comunidad Juncalito', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(50, 'Urbanizacion Altos de Uslar', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(51, 'Urbanizacion Negra Matea', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(52, 'Comunidad Brisas de Guataparo', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(53, 'Comunidad La Vega', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(54, 'Comunidad El Vigia', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(55, 'Comunidad El Charal', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(56, 'Comunidad 23 de Enero', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(57, 'Mayorista', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(58, 'Colina de Carrizales', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(59, 'Barrerita', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(60, 'Safari Country Club', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(61, 'Barrio Nueva Valencia', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(62, 'Barrio Jardines de San Luis', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(63, 'Urbanizacion San Luis', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(64, 'Terrenos Propios del Municipio Libertador', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(65, 'Urbanizacion Los Cardones', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(66, 'Campamento Bautista', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(67, 'Parcelamiento Los Aguacatales', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(68, 'Hato Barrera', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(69, 'Santa Isabel', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(70, 'Hacienda San Rafael', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(71, 'Comunidad La Yaguara', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(72, 'Terrenos Inmediatos al Dique de Guataparo', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(73, 'Hacienda Country Club', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(74, 'Colinas de Carabobo', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(75, 'Hector Pereda', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(76, 'La Alegria', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(77, 'Negro Primero', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(78, 'Las Americas Jose Luis Martinez', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(79, 'Barrera Norte', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(80, 'Barrera Centro', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(81, 'Hato Residencial La Gran Sabana', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(82, 'Parcelamiento Sabana del Medio', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(83, 'Campo de Carabobo', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(84, 'Barrio El Cementerio', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(85, 'Barrio del Rincon', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(86, 'Barrio Sucre', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(87, 'Barrio Union', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(88, 'Brisas del Campo', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(89, 'La Pica', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(90, 'Las Manzanas', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(91, 'Pueblo Nuevo', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(92, 'Nuevo Carabobo', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(93, 'El Rincon', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(94, 'Los Chorros', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(95, 'La Cuesta', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(96, 'Manzana de Oro', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(97, 'Los Cocos', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(98, 'Las Manzanitas', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(99, 'Ruiz Pineda', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(100, 'Barrio Josefina', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(101, '7 de Octubre', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(102, 'San Antonio', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(103, 'El Chaguaramal', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(104, 'Barrio El Carmen', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(105, 'Eulalia Buroz', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(106, 'Barrio La Adobera', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(107, 'La Florida', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(108, 'Barrio Palotal', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(109, 'Urbanizacion Los Jabilos', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(110, 'Urbanizacion Los Chaguaramos', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(111, 'Urbanizacion Tucan', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(112, 'Conjunto Residencial Las Palmas', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(113, 'Conjunto Residencial Cachiri', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(114, 'Urbanizacion La Honda', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(115, 'Urbanizacion El Rosario', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(116, 'Urbanizacion Alto de Jalisco', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(117, 'Urbanizacion Libertador', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(118, 'Urbanizacion Jose Hernandez', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(119, 'Urbanizacion El Rincon', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(120, 'Urbanizacion Cantarrana', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(121, 'Urbanizacion Los Cedros', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(122, 'Urbanizacion Manzana de Oro', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(123, 'Urbanizacion La Adobera', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(124, 'Urbanizacion Palotal', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(125, 'Casco de Tocuyito', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(126, 'Cantarrana Tocuyito', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(127, 'Tocuyito', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(128, 'No Especificada', 1, '2026-03-13 12:17:31', '12:17:31 PM'),
(129, 'valencia', 0, '2026-03-13 12:17:31', '12:17:31 PM');

--
-- Disparadores `comunidades`
--
DELIMITER $$
CREATE TRIGGER `tr_comunidades_ai_audit` AFTER INSERT ON `comunidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'comunidades', 'INSERT', CAST(NEW.id_comunidad AS CHAR), 'INSERT en comunidades', 'Se inserto un registro en comunidades', NULL, JSON_OBJECT('id_comunidad', NEW.id_comunidad, 'nombre_comunidad', NEW.nombre_comunidad, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'hora_registro_12h', NEW.hora_registro_12h), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_comunidades_au_audit` AFTER UPDATE ON `comunidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'comunidades', 'UPDATE', CAST(NEW.id_comunidad AS CHAR), 'UPDATE en comunidades', 'Se actualizo un registro en comunidades', JSON_OBJECT('id_comunidad', OLD.id_comunidad, 'nombre_comunidad', OLD.nombre_comunidad, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro, 'hora_registro_12h', OLD.hora_registro_12h), JSON_OBJECT('id_comunidad', NEW.id_comunidad, 'nombre_comunidad', NEW.nombre_comunidad, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'hora_registro_12h', NEW.hora_registro_12h), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_comunidades_bd_block_delete` BEFORE DELETE ON `comunidades` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla comunidades. Use eliminacion logica.';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_comunidades_bi_hora12` BEFORE INSERT ON `comunidades` FOR EACH ROW BEGIN
    IF NEW.fecha_registro IS NULL THEN
        SET NEW.fecha_registro = NOW();
    END IF;
    SET NEW.hora_registro_12h = DATE_FORMAT(NEW.fecha_registro, '%r');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_comunidades_bu_hora12` BEFORE UPDATE ON `comunidades` FOR EACH ROW BEGIN
    IF NEW.fecha_registro IS NULL THEN
        SET NEW.fecha_registro = NOW();
    END IF;
    SET NEW.hora_registro_12h = DATE_FORMAT(NEW.fecha_registro, '%r');
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion_smtp`
--

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

--
-- Volcado de datos para la tabla `configuracion_smtp`
--

INSERT INTO `configuracion_smtp` (`id_configuracion_smtp`, `host`, `puerto`, `usuario`, `clave`, `correo_remitente`, `nombre_remitente`, `usar_tls`, `estado`, `id_usuario_actualiza`, `fecha_registro`, `fecha_actualizacion`) VALUES
(1, 'smtp.gmail.com', 587, 'meza.elsy@gmail.com', 'mqmrsujmyabwpgbv', 'meza.elsy@gmail.com', 'Sala Situacional', 1, 1, 1, '0000-00-00 00:00:00', '2026-03-17 20:47:17');

--
-- Disparadores `configuracion_smtp`
--
DELIMITER $$
CREATE TRIGGER `tr_configuracion_smtp_ai_audit` AFTER INSERT ON `configuracion_smtp` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'configuracion_smtp', 'INSERT', CAST(NEW.id_configuracion_smtp AS CHAR), 'INSERT en configuracion_smtp', 'Se inserto un registro en configuracion_smtp', NULL, JSON_OBJECT('id_configuracion_smtp', NEW.id_configuracion_smtp, 'host', NEW.host, 'puerto', NEW.puerto, 'usuario', NEW.usuario, 'clave', NEW.clave, 'correo_remitente', NEW.correo_remitente, 'nombre_remitente', NEW.nombre_remitente, 'usar_tls', NEW.usar_tls, 'estado', NEW.estado, 'id_usuario_actualiza', NEW.id_usuario_actualiza, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_configuracion_smtp_au_audit` AFTER UPDATE ON `configuracion_smtp` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'configuracion_smtp', 'UPDATE', CAST(NEW.id_configuracion_smtp AS CHAR), 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', JSON_OBJECT('id_configuracion_smtp', OLD.id_configuracion_smtp, 'host', OLD.host, 'puerto', OLD.puerto, 'usuario', OLD.usuario, 'clave', OLD.clave, 'correo_remitente', OLD.correo_remitente, 'nombre_remitente', OLD.nombre_remitente, 'usar_tls', OLD.usar_tls, 'estado', OLD.estado, 'id_usuario_actualiza', OLD.id_usuario_actualiza, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_configuracion_smtp', NEW.id_configuracion_smtp, 'host', NEW.host, 'puerto', NEW.puerto, 'usuario', NEW.usuario, 'clave', NEW.clave, 'correo_remitente', NEW.correo_remitente, 'nombre_remitente', NEW.nombre_remitente, 'usar_tls', NEW.usar_tls, 'estado', NEW.estado, 'id_usuario_actualiza', NEW.id_usuario_actualiza, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_configuracion_smtp_bd_block_delete` BEFORE DELETE ON `configuracion_smtp` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla configuracion_smtp. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dependencias`
--

CREATE TABLE `dependencias` (
  `id_dependencia` int(11) NOT NULL COMMENT 'Campo id_dependencia de la tabla dependencias.',
  `nombre_dependencia` varchar(100) NOT NULL COMMENT 'Campo nombre_dependencia de la tabla dependencias.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla dependencias.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `dependencias`
--

INSERT INTO `dependencias` (`id_dependencia`, `nombre_dependencia`, `estado`) VALUES
(2, 'Atención al Ciudadano', 1),
(5, 'Auditoría Interna', 1),
(3, 'Catastro', 1),
(6, 'Dirección General', 1),
(1, 'Informática', 1),
(7, 'Registro Civil', 1),
(4, 'Sala Situacional', 1);

--
-- Disparadores `dependencias`
--
DELIMITER $$
CREATE TRIGGER `tr_dependencias_ai_audit` AFTER INSERT ON `dependencias` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'dependencias', 'INSERT', CAST(NEW.id_dependencia AS CHAR), 'INSERT en dependencias', 'Se inserto un registro en dependencias', NULL, JSON_OBJECT('id_dependencia', NEW.id_dependencia, 'nombre_dependencia', NEW.nombre_dependencia, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_dependencias_au_audit` AFTER UPDATE ON `dependencias` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'dependencias', 'UPDATE', CAST(NEW.id_dependencia AS CHAR), 'UPDATE en dependencias', 'Se actualizo un registro en dependencias', JSON_OBJECT('id_dependencia', OLD.id_dependencia, 'nombre_dependencia', OLD.nombre_dependencia, 'estado', OLD.estado), JSON_OBJECT('id_dependencia', NEW.id_dependencia, 'nombre_dependencia', NEW.nombre_dependencia, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_dependencias_bd_block_delete` BEFORE DELETE ON `dependencias` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla dependencias. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `despachos_unidades`
--

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

--
-- Volcado de datos para la tabla `despachos_unidades`
--

INSERT INTO `despachos_unidades` (`id_despacho_unidad`, `id_seguridad`, `id_unidad`, `id_chofer_ambulancia`, `id_usuario_asigna`, `modo_asignacion`, `estado_despacho`, `fecha_asignacion`, `fecha_cierre`, `ubicacion_salida`, `ubicacion_evento`, `ubicacion_cierre`, `observaciones`, `fecha_registro`, `fecha_actualizacion`) VALUES
(1, 1, 1, 1, 1, 'AUTO', 'ACTIVO', '2026-03-17 21:50:24', NULL, 'BASE CENTRAL', 'AV principal', NULL, 'Asignacion automatica al guardar la solicitud.', '2026-03-17 21:50:24', '2026-03-17 21:50:24'),
(2, 2, 2, 2, 1, 'AUTO', 'ACTIVO', '2026-03-18 09:29:39', NULL, 'FLOR AMARILLO', 'comunidad los chirritos', NULL, 'Asignacion automatica al guardar la solicitud.', '2026-03-18 09:29:39', '2026-03-18 09:29:39');

--
-- Disparadores `despachos_unidades`
--
DELIMITER $$
CREATE TRIGGER `tr_despachos_unidades_ai_audit` AFTER INSERT ON `despachos_unidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'despachos_unidades', 'INSERT', CAST(NEW.id_despacho_unidad AS CHAR), 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, JSON_OBJECT('id_despacho_unidad', NEW.id_despacho_unidad, 'id_seguridad', NEW.id_seguridad, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_usuario_asigna', NEW.id_usuario_asigna, 'modo_asignacion', NEW.modo_asignacion, 'estado_despacho', NEW.estado_despacho, 'fecha_asignacion', NEW.fecha_asignacion, 'fecha_cierre', NEW.fecha_cierre, 'ubicacion_salida', NEW.ubicacion_salida, 'ubicacion_evento', NEW.ubicacion_evento, 'ubicacion_cierre', NEW.ubicacion_cierre, 'observaciones', NEW.observaciones, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_despachos_unidades_au_audit` AFTER UPDATE ON `despachos_unidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'despachos_unidades', 'UPDATE', CAST(NEW.id_despacho_unidad AS CHAR), 'UPDATE en despachos_unidades', 'Se actualizo un registro en despachos_unidades', JSON_OBJECT('id_despacho_unidad', OLD.id_despacho_unidad, 'id_seguridad', OLD.id_seguridad, 'id_unidad', OLD.id_unidad, 'id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'id_usuario_asigna', OLD.id_usuario_asigna, 'modo_asignacion', OLD.modo_asignacion, 'estado_despacho', OLD.estado_despacho, 'fecha_asignacion', OLD.fecha_asignacion, 'fecha_cierre', OLD.fecha_cierre, 'ubicacion_salida', OLD.ubicacion_salida, 'ubicacion_evento', OLD.ubicacion_evento, 'ubicacion_cierre', OLD.ubicacion_cierre, 'observaciones', OLD.observaciones, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_despacho_unidad', NEW.id_despacho_unidad, 'id_seguridad', NEW.id_seguridad, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_usuario_asigna', NEW.id_usuario_asigna, 'modo_asignacion', NEW.modo_asignacion, 'estado_despacho', NEW.estado_despacho, 'fecha_asignacion', NEW.fecha_asignacion, 'fecha_cierre', NEW.fecha_cierre, 'ubicacion_salida', NEW.ubicacion_salida, 'ubicacion_evento', NEW.ubicacion_evento, 'ubicacion_cierre', NEW.ubicacion_cierre, 'observaciones', NEW.observaciones, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_despachos_unidades_bd_block_delete` BEFORE DELETE ON `despachos_unidades` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla despachos_unidades. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

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

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `cedula`, `nombre`, `apellido`, `id_dependencia`, `telefono`, `correo`, `direccion`, `estado`) VALUES
(1, 123456789, 'Elsy', 'Meza', 6, '04269390643', 'meza.elsy@gmail.com', 'San Diego', 1),
(2, 22222222, 'Laura', 'Franco', 3, '04244668450', 'flaura2705@gmail.com', 'Libetrador - tocuyito', 1);

--
-- Disparadores `empleados`
--
DELIMITER $$
CREATE TRIGGER `tr_empleados_ai_audit` AFTER INSERT ON `empleados` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'empleados', 'INSERT', CAST(NEW.id_empleado AS CHAR), 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, JSON_OBJECT('id_empleado', NEW.id_empleado, 'cedula', NEW.cedula, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'id_dependencia', NEW.id_dependencia, 'telefono', NEW.telefono, 'correo', NEW.correo, 'direccion', NEW.direccion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_empleados_au_audit` AFTER UPDATE ON `empleados` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'empleados', 'UPDATE', CAST(NEW.id_empleado AS CHAR), 'UPDATE en empleados', 'Se actualizo un registro en empleados', JSON_OBJECT('id_empleado', OLD.id_empleado, 'cedula', OLD.cedula, 'nombre', OLD.nombre, 'apellido', OLD.apellido, 'id_dependencia', OLD.id_dependencia, 'telefono', OLD.telefono, 'correo', OLD.correo, 'direccion', OLD.direccion, 'estado', OLD.estado), JSON_OBJECT('id_empleado', NEW.id_empleado, 'cedula', NEW.cedula, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'id_dependencia', NEW.id_dependencia, 'telefono', NEW.telefono, 'correo', NEW.correo, 'direccion', NEW.direccion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_empleados_bd_block_delete` BEFORE DELETE ON `empleados` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla empleados. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados_solicitudes`
--

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

--
-- Volcado de datos para la tabla `estados_solicitudes`
--

INSERT INTO `estados_solicitudes` (`id_estado_solicitud`, `codigo_estado`, `nombre_estado`, `descripcion`, `clase_badge`, `es_atendida`, `orden_visual`, `estado`) VALUES
(1, 'REGISTRADA', 'Registrada', 'Solicitud creada y pendiente por gestion.', 'draft', 0, 1, 1),
(2, 'EN_GESTION', 'En gestion', 'Solicitud en proceso de atencion o seguimiento.', 'info', 0, 2, 1),
(3, 'ATENDIDA', 'Atendida', 'Solicitud atendida y cerrada satisfactoriamente.', 'active', 1, 3, 1),
(4, 'NO_ATENDIDA', 'No atendida', 'Solicitud cerrada sin atencion satisfactoria.', 'warning', 0, 4, 1);

--
-- Disparadores `estados_solicitudes`
--
DELIMITER $$
CREATE TRIGGER `tr_estados_solicitudes_ai_audit` AFTER INSERT ON `estados_solicitudes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'estados_solicitudes', 'INSERT', CAST(NEW.id_estado_solicitud AS CHAR), 'INSERT en estados_solicitudes', 'Se inserto un registro en estados_solicitudes', NULL, JSON_OBJECT('id_estado_solicitud', NEW.id_estado_solicitud, 'codigo_estado', NEW.codigo_estado, 'nombre_estado', NEW.nombre_estado, 'descripcion', NEW.descripcion, 'clase_badge', NEW.clase_badge, 'es_atendida', NEW.es_atendida, 'orden_visual', NEW.orden_visual, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_estados_solicitudes_au_audit` AFTER UPDATE ON `estados_solicitudes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'estados_solicitudes', 'UPDATE', CAST(NEW.id_estado_solicitud AS CHAR), 'UPDATE en estados_solicitudes', 'Se actualizo un registro en estados_solicitudes', JSON_OBJECT('id_estado_solicitud', OLD.id_estado_solicitud, 'codigo_estado', OLD.codigo_estado, 'nombre_estado', OLD.nombre_estado, 'descripcion', OLD.descripcion, 'clase_badge', OLD.clase_badge, 'es_atendida', OLD.es_atendida, 'orden_visual', OLD.orden_visual, 'estado', OLD.estado), JSON_OBJECT('id_estado_solicitud', NEW.id_estado_solicitud, 'codigo_estado', NEW.codigo_estado, 'nombre_estado', NEW.nombre_estado, 'descripcion', NEW.descripcion, 'clase_badge', NEW.clase_badge, 'es_atendida', NEW.es_atendida, 'orden_visual', NEW.orden_visual, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_estados_solicitudes_bd_block_delete` BEFORE DELETE ON `estados_solicitudes` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla estados_solicitudes. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `id_permiso` int(11) NOT NULL COMMENT 'Campo id_permiso de la tabla permisos.',
  `nombre_permiso` varchar(100) NOT NULL COMMENT 'Campo nombre_permiso de la tabla permisos.',
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Campo descripcion de la tabla permisos.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla permisos.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `permisos`
--

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

--
-- Disparadores `permisos`
--
DELIMITER $$
CREATE TRIGGER `tr_permisos_ai_audit` AFTER INSERT ON `permisos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'permisos', 'INSERT', CAST(NEW.id_permiso AS CHAR), 'INSERT en permisos', 'Se inserto un registro en permisos', NULL, JSON_OBJECT('id_permiso', NEW.id_permiso, 'nombre_permiso', NEW.nombre_permiso, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_permisos_au_audit` AFTER UPDATE ON `permisos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'permisos', 'UPDATE', CAST(NEW.id_permiso AS CHAR), 'UPDATE en permisos', 'Se actualizo un registro en permisos', JSON_OBJECT('id_permiso', OLD.id_permiso, 'nombre_permiso', OLD.nombre_permiso, 'descripcion', OLD.descripcion, 'estado', OLD.estado), JSON_OBJECT('id_permiso', NEW.id_permiso, 'nombre_permiso', NEW.nombre_permiso, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_permisos_bd_block_delete` BEFORE DELETE ON `permisos` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla permisos. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reportes_solicitudes_ambulancia`
--

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

--
-- Volcado de datos para la tabla `reportes_solicitudes_ambulancia`
--

INSERT INTO `reportes_solicitudes_ambulancia` (`id_reporte_solicitud`, `id_seguridad`, `id_despacho_unidad`, `tipo_reporte`, `nombre_archivo`, `ruta_archivo`, `estado_envio`, `correo_destino`, `fecha_envio`, `detalle_envio`, `id_usuario_genera`, `fecha_generacion`, `estado`) VALUES
(1, 1, 1, 'REGISTRO', 'SEG-20260317-000001_registro_20260318_025024_1406.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260317-000001_registro_20260318_025024_1406.pdf', 'ENVIADO', 'meza.elsy@gmail.com', '2026-03-18 02:50:53', 'Reporte enviado correctamente al correo del chofer con archivo adjunto.', 1, '2026-03-17 21:50:24', 1),
(2, 2, 2, 'REGISTRO', 'SEG-20260318-000002_registro_20260318_142939_2281.pdf', 'uploads/reportes_solicitudes_ambulancia/SEG-20260318-000002_registro_20260318_142939_2281.pdf', 'ENVIADO', 'flaura2705@gmail.com', '2026-03-18 14:29:46', 'Reporte enviado correctamente al correo del chofer con archivo adjunto.', 1, '2026-03-18 09:29:46', 1);

--
-- Disparadores `reportes_solicitudes_ambulancia`
--
DELIMITER $$
CREATE TRIGGER `tr_reportes_solicitudes_ambulancia_ai_audit` AFTER INSERT ON `reportes_solicitudes_ambulancia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_solicitudes_ambulancia', 'INSERT', CAST(NEW.id_reporte_solicitud AS CHAR), 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, JSON_OBJECT('id_reporte_solicitud', NEW.id_reporte_solicitud, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'tipo_reporte', NEW.tipo_reporte, 'nombre_archivo', NEW.nombre_archivo, 'ruta_archivo', NEW.ruta_archivo, 'estado_envio', NEW.estado_envio, 'correo_destino', NEW.correo_destino, 'fecha_envio', NEW.fecha_envio, 'detalle_envio', NEW.detalle_envio, 'id_usuario_genera', NEW.id_usuario_genera, 'fecha_generacion', NEW.fecha_generacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_reportes_solicitudes_ambulancia_au_audit` AFTER UPDATE ON `reportes_solicitudes_ambulancia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_solicitudes_ambulancia', 'UPDATE', CAST(NEW.id_reporte_solicitud AS CHAR), 'UPDATE en reportes_solicitudes_ambulancia', 'Se actualizo un registro en reportes_solicitudes_ambulancia', JSON_OBJECT('id_reporte_solicitud', OLD.id_reporte_solicitud, 'id_seguridad', OLD.id_seguridad, 'id_despacho_unidad', OLD.id_despacho_unidad, 'tipo_reporte', OLD.tipo_reporte, 'nombre_archivo', OLD.nombre_archivo, 'ruta_archivo', OLD.ruta_archivo, 'estado_envio', OLD.estado_envio, 'correo_destino', OLD.correo_destino, 'fecha_envio', OLD.fecha_envio, 'detalle_envio', OLD.detalle_envio, 'id_usuario_genera', OLD.id_usuario_genera, 'fecha_generacion', OLD.fecha_generacion, 'estado', OLD.estado), JSON_OBJECT('id_reporte_solicitud', NEW.id_reporte_solicitud, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'tipo_reporte', NEW.tipo_reporte, 'nombre_archivo', NEW.nombre_archivo, 'ruta_archivo', NEW.ruta_archivo, 'estado_envio', NEW.estado_envio, 'correo_destino', NEW.correo_destino, 'fecha_envio', NEW.fecha_envio, 'detalle_envio', NEW.detalle_envio, 'id_usuario_genera', NEW.id_usuario_genera, 'fecha_generacion', NEW.fecha_generacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_reportes_solicitudes_ambulancia_bd_block_delete` BEFORE DELETE ON `reportes_solicitudes_ambulancia` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla reportes_solicitudes_ambulancia. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reportes_traslado`
--

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

--
-- Disparadores `reportes_traslado`
--
DELIMITER $$
CREATE TRIGGER `tr_reportes_traslado_ai_audit` AFTER INSERT ON `reportes_traslado` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_traslado', 'INSERT', CAST(NEW.id_reporte AS CHAR), 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, JSON_OBJECT('id_reporte', NEW.id_reporte, 'id_ayuda', NEW.id_ayuda, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'id_usuario_operador', NEW.id_usuario_operador, 'id_empleado_chofer', NEW.id_empleado_chofer, 'id_unidad', NEW.id_unidad, 'ticket_interno', NEW.ticket_interno, 'fecha_hora', NEW.fecha_hora, 'diagnostico_paciente', NEW.diagnostico_paciente, 'foto_evidencia', NEW.foto_evidencia, 'km_salida', NEW.km_salida, 'km_llegada', NEW.km_llegada, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_reportes_traslado_au_audit` AFTER UPDATE ON `reportes_traslado` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_traslado', 'UPDATE', CAST(NEW.id_reporte AS CHAR), 'UPDATE en reportes_traslado', 'Se actualizo un registro en reportes_traslado', JSON_OBJECT('id_reporte', OLD.id_reporte, 'id_ayuda', OLD.id_ayuda, 'id_seguridad', OLD.id_seguridad, 'id_despacho_unidad', OLD.id_despacho_unidad, 'id_usuario_operador', OLD.id_usuario_operador, 'id_empleado_chofer', OLD.id_empleado_chofer, 'id_unidad', OLD.id_unidad, 'ticket_interno', OLD.ticket_interno, 'fecha_hora', OLD.fecha_hora, 'diagnostico_paciente', OLD.diagnostico_paciente, 'foto_evidencia', OLD.foto_evidencia, 'km_salida', OLD.km_salida, 'km_llegada', OLD.km_llegada, 'estado', OLD.estado), JSON_OBJECT('id_reporte', NEW.id_reporte, 'id_ayuda', NEW.id_ayuda, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'id_usuario_operador', NEW.id_usuario_operador, 'id_empleado_chofer', NEW.id_empleado_chofer, 'id_unidad', NEW.id_unidad, 'ticket_interno', NEW.ticket_interno, 'fecha_hora', NEW.fecha_hora, 'diagnostico_paciente', NEW.diagnostico_paciente, 'foto_evidencia', NEW.foto_evidencia, 'km_salida', NEW.km_salida, 'km_llegada', NEW.km_llegada, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_reportes_traslado_bd_block_delete` BEFORE DELETE ON `reportes_traslado` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla reportes_traslado. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `seguimientos_solicitudes`
--

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

--
-- Volcado de datos para la tabla `seguimientos_solicitudes`
--

INSERT INTO `seguimientos_solicitudes` (`id_seguimiento_solicitud`, `modulo`, `id_referencia`, `id_estado_solicitud`, `id_usuario`, `fecha_gestion`, `observacion`, `estado`) VALUES
(1, 'SEGURIDAD', 1, 2, 1, '2026-03-17 21:49:00', 'Solicitud en gestion operativa con unidad y chofer asignados.', 1),
(2, 'SEGURIDAD', 2, 2, 1, '2026-03-18 09:28:00', 'Solicitud en gestion operativa con unidad y chofer asignados.', 1),
(3, 'AYUDA_SOCIAL', 3, 1, 1, '2026-03-18 08:00:00', 'Solicitud registrada en ayuda social.', 1);

--
-- Disparadores `seguimientos_solicitudes`
--
DELIMITER $$
CREATE TRIGGER `tr_seguimientos_solicitudes_ai_audit` AFTER INSERT ON `seguimientos_solicitudes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguimientos_solicitudes', 'INSERT', CAST(NEW.id_seguimiento_solicitud AS CHAR), 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, JSON_OBJECT('id_seguimiento_solicitud', NEW.id_seguimiento_solicitud, 'modulo', NEW.modulo, 'id_referencia', NEW.id_referencia, 'id_estado_solicitud', NEW.id_estado_solicitud, 'id_usuario', NEW.id_usuario, 'fecha_gestion', NEW.fecha_gestion, 'observacion', NEW.observacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_seguimientos_solicitudes_au_audit` AFTER UPDATE ON `seguimientos_solicitudes` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguimientos_solicitudes', 'UPDATE', CAST(NEW.id_seguimiento_solicitud AS CHAR), 'UPDATE en seguimientos_solicitudes', 'Se actualizo un registro en seguimientos_solicitudes', JSON_OBJECT('id_seguimiento_solicitud', OLD.id_seguimiento_solicitud, 'modulo', OLD.modulo, 'id_referencia', OLD.id_referencia, 'id_estado_solicitud', OLD.id_estado_solicitud, 'id_usuario', OLD.id_usuario, 'fecha_gestion', OLD.fecha_gestion, 'observacion', OLD.observacion, 'estado', OLD.estado), JSON_OBJECT('id_seguimiento_solicitud', NEW.id_seguimiento_solicitud, 'modulo', NEW.modulo, 'id_referencia', NEW.id_referencia, 'id_estado_solicitud', NEW.id_estado_solicitud, 'id_usuario', NEW.id_usuario, 'fecha_gestion', NEW.fecha_gestion, 'observacion', NEW.observacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_seguimientos_solicitudes_bd_block_delete` BEFORE DELETE ON `seguimientos_solicitudes` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla seguimientos_solicitudes. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `seguridad`
--

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

--
-- Volcado de datos para la tabla `seguridad`
--

INSERT INTO `seguridad` (`id_seguridad`, `ticket_interno`, `id_beneficiario`, `id_usuario`, `id_tipo_seguridad`, `id_solicitud_seguridad`, `id_estado_solicitud`, `tipo_seguridad`, `tipo_solicitud`, `fecha_seguridad`, `descripcion`, `estado_atencion`, `ubicacion_evento`, `referencia_evento`, `estado`) VALUES
(1, 'SEG-20260317-000001', 1, 1, 7, 1, 2, 'Atencion prehospitalaria', '1X10', '2026-03-17 21:49:00', 'S/E', 'DESPACHADO', 'AV principal', 'Autopista', 1),
(2, 'SEG-20260318-000002', 2, 1, 7, 1, 2, 'Atencion prehospitalaria', '1X10', '2026-03-18 09:28:00', 'S/E', 'DESPACHADO', 'comunidad los chirritos', 'fente a barrio bueno', 1);

--
-- Disparadores `seguridad`
--
DELIMITER $$
CREATE TRIGGER `tr_seguridad_ai_audit` AFTER INSERT ON `seguridad` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguridad', 'INSERT', CAST(NEW.id_seguridad AS CHAR), 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, JSON_OBJECT('id_seguridad', NEW.id_seguridad, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_seguridad', NEW.id_tipo_seguridad, 'id_solicitud_seguridad', NEW.id_solicitud_seguridad, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_seguridad', NEW.tipo_seguridad, 'tipo_solicitud', NEW.tipo_solicitud, 'fecha_seguridad', NEW.fecha_seguridad, 'descripcion', NEW.descripcion, 'estado_atencion', NEW.estado_atencion, 'ubicacion_evento', NEW.ubicacion_evento, 'referencia_evento', NEW.referencia_evento, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_seguridad_au_audit` AFTER UPDATE ON `seguridad` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguridad', 'UPDATE', CAST(NEW.id_seguridad AS CHAR), 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', JSON_OBJECT('id_seguridad', OLD.id_seguridad, 'ticket_interno', OLD.ticket_interno, 'id_beneficiario', OLD.id_beneficiario, 'id_usuario', OLD.id_usuario, 'id_tipo_seguridad', OLD.id_tipo_seguridad, 'id_solicitud_seguridad', OLD.id_solicitud_seguridad, 'id_estado_solicitud', OLD.id_estado_solicitud, 'tipo_seguridad', OLD.tipo_seguridad, 'tipo_solicitud', OLD.tipo_solicitud, 'fecha_seguridad', OLD.fecha_seguridad, 'descripcion', OLD.descripcion, 'estado_atencion', OLD.estado_atencion, 'ubicacion_evento', OLD.ubicacion_evento, 'referencia_evento', OLD.referencia_evento, 'estado', OLD.estado), JSON_OBJECT('id_seguridad', NEW.id_seguridad, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_seguridad', NEW.id_tipo_seguridad, 'id_solicitud_seguridad', NEW.id_solicitud_seguridad, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_seguridad', NEW.tipo_seguridad, 'tipo_solicitud', NEW.tipo_solicitud, 'fecha_seguridad', NEW.fecha_seguridad, 'descripcion', NEW.descripcion, 'estado_atencion', NEW.estado_atencion, 'ubicacion_evento', NEW.ubicacion_evento, 'referencia_evento', NEW.referencia_evento, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_seguridad_bd_block_delete` BEFORE DELETE ON `seguridad` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla seguridad. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicios_publicos`
--

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

--
-- Volcado de datos para la tabla `servicios_publicos`
--

INSERT INTO `servicios_publicos` (`id_servicio`, `ticket_interno`, `id_beneficiario`, `id_usuario`, `id_tipo_servicio_publico`, `id_solicitud_servicio_publico`, `id_estado_solicitud`, `tipo_servicio`, `solicitud_servicio`, `fecha_servicio`, `descripcion`, `estado`) VALUES
(1, 'SPU-20260317-000001', 1, 1, 3, 3, 1, 'Alumbrado Publico', 'Redes sociales', '2026-03-17', 'FALTA DE ELIMINACION EN LA AREAS DE LA COMUNIDAD - LA HONDA', 1);

--
-- Disparadores `servicios_publicos`
--
DELIMITER $$
CREATE TRIGGER `tr_servicios_publicos_ai_audit` AFTER INSERT ON `servicios_publicos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'servicios_publicos', 'INSERT', CAST(NEW.id_servicio AS CHAR), 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, JSON_OBJECT('id_servicio', NEW.id_servicio, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'id_solicitud_servicio_publico', NEW.id_solicitud_servicio_publico, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_servicio', NEW.tipo_servicio, 'solicitud_servicio', NEW.solicitud_servicio, 'fecha_servicio', NEW.fecha_servicio, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_servicios_publicos_au_audit` AFTER UPDATE ON `servicios_publicos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'servicios_publicos', 'UPDATE', CAST(NEW.id_servicio AS CHAR), 'UPDATE en servicios_publicos', 'Se actualizo un registro en servicios_publicos', JSON_OBJECT('id_servicio', OLD.id_servicio, 'ticket_interno', OLD.ticket_interno, 'id_beneficiario', OLD.id_beneficiario, 'id_usuario', OLD.id_usuario, 'id_tipo_servicio_publico', OLD.id_tipo_servicio_publico, 'id_solicitud_servicio_publico', OLD.id_solicitud_servicio_publico, 'id_estado_solicitud', OLD.id_estado_solicitud, 'tipo_servicio', OLD.tipo_servicio, 'solicitud_servicio', OLD.solicitud_servicio, 'fecha_servicio', OLD.fecha_servicio, 'descripcion', OLD.descripcion, 'estado', OLD.estado), JSON_OBJECT('id_servicio', NEW.id_servicio, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'id_solicitud_servicio_publico', NEW.id_solicitud_servicio_publico, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_servicio', NEW.tipo_servicio, 'solicitud_servicio', NEW.solicitud_servicio, 'fecha_servicio', NEW.fecha_servicio, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_servicios_publicos_bd_block_delete` BEFORE DELETE ON `servicios_publicos` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla servicios_publicos. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitudes_generales`
--

CREATE TABLE `solicitudes_generales` (
  `id_solicitud_general` int(11) NOT NULL COMMENT 'Campo id_solicitud_general de la tabla solicitudes_generales.',
  `codigo_solicitud` varchar(20) NOT NULL COMMENT 'Campo codigo_solicitud de la tabla solicitudes_generales.',
  `nombre_solicitud` varchar(120) NOT NULL COMMENT 'Campo nombre_solicitud de la tabla solicitudes_generales.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla solicitudes_generales.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla solicitudes_generales.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `solicitudes_generales`
--

INSERT INTO `solicitudes_generales` (`id_solicitud_general`, `codigo_solicitud`, `nombre_solicitud`, `estado`, `fecha_registro`) VALUES
(1, 'SOL-1X10', '1X10', 1, '2026-03-13 23:43:24'),
(2, 'SOL-ATC', 'Atencion al ciudadano', 1, '2026-03-13 23:43:24'),
(3, 'SOL-RDS', 'Redes sociales', 1, '2026-03-13 23:43:24');

--
-- Disparadores `solicitudes_generales`
--
DELIMITER $$
CREATE TRIGGER `tr_solicitudes_generales_ai_audit` AFTER INSERT ON `solicitudes_generales` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'solicitudes_generales', 'INSERT', CAST(NEW.id_solicitud_general AS CHAR), 'INSERT en solicitudes_generales', 'Se inserto un registro en solicitudes_generales', NULL, JSON_OBJECT('id_solicitud_general', NEW.id_solicitud_general, 'codigo_solicitud', NEW.codigo_solicitud, 'nombre_solicitud', NEW.nombre_solicitud, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_solicitudes_generales_au_audit` AFTER UPDATE ON `solicitudes_generales` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'solicitudes_generales', 'UPDATE', CAST(NEW.id_solicitud_general AS CHAR), 'UPDATE en solicitudes_generales', 'Se actualizo un registro en solicitudes_generales', JSON_OBJECT('id_solicitud_general', OLD.id_solicitud_general, 'codigo_solicitud', OLD.codigo_solicitud, 'nombre_solicitud', OLD.nombre_solicitud, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_solicitud_general', NEW.id_solicitud_general, 'codigo_solicitud', NEW.codigo_solicitud, 'nombre_solicitud', NEW.nombre_solicitud, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_solicitudes_generales_bd_block_delete` BEFORE DELETE ON `solicitudes_generales` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla solicitudes_generales. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_ayuda_social`
--

CREATE TABLE `tipos_ayuda_social` (
  `id_tipo_ayuda_social` int(11) NOT NULL COMMENT 'Campo id_tipo_ayuda_social de la tabla tipos_ayuda_social.',
  `nombre_tipo_ayuda` varchar(120) NOT NULL COMMENT 'Campo nombre_tipo_ayuda de la tabla tipos_ayuda_social.',
  `requiere_ambulancia` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Campo requiere_ambulancia de la tabla tipos_ayuda_social.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla tipos_ayuda_social.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla tipos_ayuda_social.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipos_ayuda_social`
--

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

--
-- Disparadores `tipos_ayuda_social`
--
DELIMITER $$
CREATE TRIGGER `tr_tipos_ayuda_social_ai_audit` AFTER INSERT ON `tipos_ayuda_social` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_ayuda_social', 'INSERT', CAST(NEW.id_tipo_ayuda_social AS CHAR), 'INSERT en tipos_ayuda_social', 'Se inserto un registro en tipos_ayuda_social', NULL, JSON_OBJECT('id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'nombre_tipo_ayuda', NEW.nombre_tipo_ayuda, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_tipos_ayuda_social_au_audit` AFTER UPDATE ON `tipos_ayuda_social` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_ayuda_social', 'UPDATE', CAST(NEW.id_tipo_ayuda_social AS CHAR), 'UPDATE en tipos_ayuda_social', 'Se actualizo un registro en tipos_ayuda_social', JSON_OBJECT('id_tipo_ayuda_social', OLD.id_tipo_ayuda_social, 'nombre_tipo_ayuda', OLD.nombre_tipo_ayuda, 'requiere_ambulancia', OLD.requiere_ambulancia, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'nombre_tipo_ayuda', NEW.nombre_tipo_ayuda, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_tipos_ayuda_social_bd_block_delete` BEFORE DELETE ON `tipos_ayuda_social` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_ayuda_social. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_seguridad_emergencia`
--

CREATE TABLE `tipos_seguridad_emergencia` (
  `id_tipo_seguridad` int(11) NOT NULL COMMENT 'Campo id_tipo_seguridad de la tabla tipos_seguridad_emergencia.',
  `nombre_tipo` varchar(120) NOT NULL COMMENT 'Campo nombre_tipo de la tabla tipos_seguridad_emergencia.',
  `requiere_ambulancia` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Campo requiere_ambulancia de la tabla tipos_seguridad_emergencia.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla tipos_seguridad_emergencia.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla tipos_seguridad_emergencia.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipos_seguridad_emergencia`
--

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

--
-- Disparadores `tipos_seguridad_emergencia`
--
DELIMITER $$
CREATE TRIGGER `tr_tipos_seguridad_emergencia_ai_audit` AFTER INSERT ON `tipos_seguridad_emergencia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_seguridad_emergencia', 'INSERT', CAST(NEW.id_tipo_seguridad AS CHAR), 'INSERT en tipos_seguridad_emergencia', 'Se inserto un registro en tipos_seguridad_emergencia', NULL, JSON_OBJECT('id_tipo_seguridad', NEW.id_tipo_seguridad, 'nombre_tipo', NEW.nombre_tipo, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_tipos_seguridad_emergencia_au_audit` AFTER UPDATE ON `tipos_seguridad_emergencia` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_seguridad_emergencia', 'UPDATE', CAST(NEW.id_tipo_seguridad AS CHAR), 'UPDATE en tipos_seguridad_emergencia', 'Se actualizo un registro en tipos_seguridad_emergencia', JSON_OBJECT('id_tipo_seguridad', OLD.id_tipo_seguridad, 'nombre_tipo', OLD.nombre_tipo, 'requiere_ambulancia', OLD.requiere_ambulancia, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_tipo_seguridad', NEW.id_tipo_seguridad, 'nombre_tipo', NEW.nombre_tipo, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_tipos_seguridad_emergencia_bd_block_delete` BEFORE DELETE ON `tipos_seguridad_emergencia` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_seguridad_emergencia. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_servicios_publicos`
--

CREATE TABLE `tipos_servicios_publicos` (
  `id_tipo_servicio_publico` int(11) NOT NULL COMMENT 'Campo id_tipo_servicio_publico de la tabla tipos_servicios_publicos.',
  `codigo_tipo_servicio_publico` varchar(20) NOT NULL COMMENT 'Campo codigo_tipo_servicio_publico de la tabla tipos_servicios_publicos.',
  `nombre_tipo_servicio` varchar(120) NOT NULL COMMENT 'Campo nombre_tipo_servicio de la tabla tipos_servicios_publicos.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla tipos_servicios_publicos.',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Campo fecha_registro de la tabla tipos_servicios_publicos.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipos_servicios_publicos`
--

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

--
-- Disparadores `tipos_servicios_publicos`
--
DELIMITER $$
CREATE TRIGGER `tr_tipos_servicios_publicos_ai_audit` AFTER INSERT ON `tipos_servicios_publicos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_servicios_publicos', 'INSERT', CAST(NEW.id_tipo_servicio_publico AS CHAR), 'INSERT en tipos_servicios_publicos', 'Se inserto un registro en tipos_servicios_publicos', NULL, JSON_OBJECT('id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'codigo_tipo_servicio_publico', NEW.codigo_tipo_servicio_publico, 'nombre_tipo_servicio', NEW.nombre_tipo_servicio, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_tipos_servicios_publicos_au_audit` AFTER UPDATE ON `tipos_servicios_publicos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_servicios_publicos', 'UPDATE', CAST(NEW.id_tipo_servicio_publico AS CHAR), 'UPDATE en tipos_servicios_publicos', 'Se actualizo un registro en tipos_servicios_publicos', JSON_OBJECT('id_tipo_servicio_publico', OLD.id_tipo_servicio_publico, 'codigo_tipo_servicio_publico', OLD.codigo_tipo_servicio_publico, 'nombre_tipo_servicio', OLD.nombre_tipo_servicio, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'codigo_tipo_servicio_publico', NEW.codigo_tipo_servicio_publico, 'nombre_tipo_servicio', NEW.nombre_tipo_servicio, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_tipos_servicios_publicos_bd_block_delete` BEFORE DELETE ON `tipos_servicios_publicos` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_servicios_publicos. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidades`
--

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

--
-- Volcado de datos para la tabla `unidades`
--

INSERT INTO `unidades` (`id_unidad`, `codigo_unidad`, `descripcion`, `placa`, `estado`, `estado_operativo`, `ubicacion_actual`, `referencia_actual`, `prioridad_despacho`, `fecha_actualizacion_operativa`) VALUES
(1, 'AMB-001', 'AMBULANCIA FORD', '14M-14K', 1, 'EN_SERVICIO', 'BASE CENTRAL', 'FRENTE AL CDI', 1, '2026-03-17 21:50:24'),
(2, 'AMB-002', 'AMBULANCIA 0800 BIGOTE', 'IUT-OYUP9', 1, 'EN_SERVICIO', 'FLOR AMARILLO', 'FLOR AMARILLO', 1, '2026-03-18 09:29:39');

--
-- Disparadores `unidades`
--
DELIMITER $$
CREATE TRIGGER `tr_unidades_ai_audit` AFTER INSERT ON `unidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'unidades', 'INSERT', CAST(NEW.id_unidad AS CHAR), 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, JSON_OBJECT('id_unidad', NEW.id_unidad, 'codigo_unidad', NEW.codigo_unidad, 'descripcion', NEW.descripcion, 'placa', NEW.placa, 'estado', NEW.estado, 'estado_operativo', NEW.estado_operativo, 'ubicacion_actual', NEW.ubicacion_actual, 'referencia_actual', NEW.referencia_actual, 'prioridad_despacho', NEW.prioridad_despacho, 'fecha_actualizacion_operativa', NEW.fecha_actualizacion_operativa), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_unidades_au_audit` AFTER UPDATE ON `unidades` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'unidades', 'UPDATE', CAST(NEW.id_unidad AS CHAR), 'UPDATE en unidades', 'Se actualizo un registro en unidades', JSON_OBJECT('id_unidad', OLD.id_unidad, 'codigo_unidad', OLD.codigo_unidad, 'descripcion', OLD.descripcion, 'placa', OLD.placa, 'estado', OLD.estado, 'estado_operativo', OLD.estado_operativo, 'ubicacion_actual', OLD.ubicacion_actual, 'referencia_actual', OLD.referencia_actual, 'prioridad_despacho', OLD.prioridad_despacho, 'fecha_actualizacion_operativa', OLD.fecha_actualizacion_operativa), JSON_OBJECT('id_unidad', NEW.id_unidad, 'codigo_unidad', NEW.codigo_unidad, 'descripcion', NEW.descripcion, 'placa', NEW.placa, 'estado', NEW.estado, 'estado_operativo', NEW.estado_operativo, 'ubicacion_actual', NEW.ubicacion_actual, 'referencia_actual', NEW.referencia_actual, 'prioridad_despacho', NEW.prioridad_despacho, 'fecha_actualizacion_operativa', NEW.fecha_actualizacion_operativa), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_unidades_bd_block_delete` BEFORE DELETE ON `unidades` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla unidades. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL COMMENT 'Clave primaria: Identificador único del sistema',
  `id_empleado` int(11) NOT NULL COMMENT 'Campo id_empleado de la tabla usuarios.',
  `usuario` varchar(50) NOT NULL COMMENT 'Campo usuario de la tabla usuarios.',
  `password` varchar(64) NOT NULL COMMENT 'Campo password de la tabla usuarios.',
  `rol` enum('ADMIN','OPERADOR','CONSULTOR') DEFAULT 'OPERADOR' COMMENT 'Nivel de acceso: ADMIN(Total), OPERADOR(Escritura), CONSULTOR(Lectura)',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla usuarios.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `id_empleado`, `usuario`, `password`, `rol`, `estado`) VALUES
(1, 1, 'admin', '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225', 'ADMIN', 1),
(2, 2, 'laura', '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225', 'OPERADOR', 1);

--
-- Disparadores `usuarios`
--
DELIMITER $$
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
DELIMITER ;
DELIMITER $$
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
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_usuarios_bd_block_delete` BEFORE DELETE ON `usuarios` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuarios. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios_seguridad_acceso`
--

CREATE TABLE `usuarios_seguridad_acceso` (
  `id_usuario` int(11) NOT NULL COMMENT 'Campo id_usuario de la tabla usuarios_seguridad_acceso.',
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0 COMMENT 'Campo intentos_fallidos de la tabla usuarios_seguridad_acceso.',
  `bloqueado` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Campo bloqueado de la tabla usuarios_seguridad_acceso.',
  `fecha_bloqueo` datetime DEFAULT NULL COMMENT 'Campo fecha_bloqueo de la tabla usuarios_seguridad_acceso.',
  `password_temporal` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Campo password_temporal de la tabla usuarios_seguridad_acceso.',
  `fecha_password_temporal` datetime DEFAULT NULL COMMENT 'Campo fecha_password_temporal de la tabla usuarios_seguridad_acceso.',
  `fecha_actualizacion` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Campo fecha_actualizacion de la tabla usuarios_seguridad_acceso.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios_seguridad_acceso`
--

INSERT INTO `usuarios_seguridad_acceso` (`id_usuario`, `intentos_fallidos`, `bloqueado`, `fecha_bloqueo`, `password_temporal`, `fecha_password_temporal`, `fecha_actualizacion`) VALUES
(1, 0, 0, NULL, 0, NULL, '2026-03-17 20:34:52'),
(2, 0, 0, NULL, 0, NULL, '2026-03-17 21:22:18');

--
-- Disparadores `usuarios_seguridad_acceso`
--
DELIMITER $$
CREATE TRIGGER `tr_usuarios_seguridad_acceso_ai_audit` AFTER INSERT ON `usuarios_seguridad_acceso` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuarios_seguridad_acceso', 'INSERT', CAST(NEW.id_usuario AS CHAR), 'INSERT en usuarios_seguridad_acceso', 'Se inserto un registro en usuarios_seguridad_acceso', NULL, JSON_OBJECT('id_usuario', NEW.id_usuario, 'intentos_fallidos', NEW.intentos_fallidos, 'bloqueado', NEW.bloqueado, 'fecha_bloqueo', NEW.fecha_bloqueo, 'password_temporal', NEW.password_temporal, 'fecha_password_temporal', NEW.fecha_password_temporal, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_usuarios_seguridad_acceso_au_audit` AFTER UPDATE ON `usuarios_seguridad_acceso` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuarios_seguridad_acceso', 'UPDATE', CAST(NEW.id_usuario AS CHAR), 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', JSON_OBJECT('id_usuario', OLD.id_usuario, 'intentos_fallidos', OLD.intentos_fallidos, 'bloqueado', OLD.bloqueado, 'fecha_bloqueo', OLD.fecha_bloqueo, 'password_temporal', OLD.password_temporal, 'fecha_password_temporal', OLD.fecha_password_temporal, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_usuario', NEW.id_usuario, 'intentos_fallidos', NEW.intentos_fallidos, 'bloqueado', NEW.bloqueado, 'fecha_bloqueo', NEW.fecha_bloqueo, 'password_temporal', NEW.password_temporal, 'fecha_password_temporal', NEW.fecha_password_temporal, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_usuarios_seguridad_acceso_bd_block_delete` BEFORE DELETE ON `usuarios_seguridad_acceso` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuarios_seguridad_acceso. Use eliminacion logica.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_permisos`
--

CREATE TABLE `usuario_permisos` (
  `id_usuario_permiso` int(11) NOT NULL COMMENT 'Campo id_usuario_permiso de la tabla usuario_permisos.',
  `id_usuario` int(11) NOT NULL COMMENT 'Campo id_usuario de la tabla usuario_permisos.',
  `id_permiso` int(11) NOT NULL COMMENT 'Campo id_permiso de la tabla usuario_permisos.',
  `estado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Campo estado de la tabla usuario_permisos.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario_permisos`
--

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
(10, 2, 3, 1);

--
-- Disparadores `usuario_permisos`
--
DELIMITER $$
CREATE TRIGGER `tr_usuario_permisos_ai_audit` AFTER INSERT ON `usuario_permisos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuario_permisos', 'INSERT', CAST(NEW.id_usuario_permiso AS CHAR), 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, JSON_OBJECT('id_usuario_permiso', NEW.id_usuario_permiso, 'id_usuario', NEW.id_usuario, 'id_permiso', NEW.id_permiso, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_usuario_permisos_au_audit` AFTER UPDATE ON `usuario_permisos` FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuario_permisos', 'UPDATE', CAST(NEW.id_usuario_permiso AS CHAR), 'UPDATE en usuario_permisos', 'Se actualizo un registro en usuario_permisos', JSON_OBJECT('id_usuario_permiso', OLD.id_usuario_permiso, 'id_usuario', OLD.id_usuario, 'id_permiso', OLD.id_permiso, 'estado', OLD.estado), JSON_OBJECT('id_usuario_permiso', NEW.id_usuario_permiso, 'id_usuario', NEW.id_usuario, 'id_permiso', NEW.id_permiso, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_usuario_permisos_bd_block_delete` BEFORE DELETE ON `usuario_permisos` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuario_permisos. Use eliminacion logica.';
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `asignaciones_unidades_choferes`
--
ALTER TABLE `asignaciones_unidades_choferes`
  ADD PRIMARY KEY (`id_asignacion_unidad_chofer`),
  ADD KEY `idx_asignaciones_unidades_choferes_unidad` (`id_unidad`,`estado`),
  ADD KEY `idx_asignaciones_unidades_choferes_chofer` (`id_chofer_ambulancia`,`estado`);

--
-- Indices de la tabla `ayuda_social`
--
ALTER TABLE `ayuda_social`
  ADD PRIMARY KEY (`id_ayuda`),
  ADD KEY `fk_as_benef` (`id_beneficiario`),
  ADD KEY `fk_as_user` (`id_usuario`),
  ADD KEY `idx_ayuda_social_id_tipo_ayuda_social` (`id_tipo_ayuda_social`),
  ADD KEY `idx_ayuda_social_id_solicitud_ayuda_social` (`id_solicitud_ayuda_social`),
  ADD KEY `idx_ayuda_social_estado_solicitud` (`id_estado_solicitud`);

--
-- Indices de la tabla `beneficiarios`
--
ALTER TABLE `beneficiarios`
  ADD PRIMARY KEY (`id_beneficiario`),
  ADD UNIQUE KEY `cedula` (`cedula`),
  ADD KEY `idx_beneficiarios_id_comunidad` (`id_comunidad`);

--
-- Indices de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD PRIMARY KEY (`id_bitacora`),
  ADD KEY `fk_bit_user` (`id_usuario`),
  ADD KEY `idx_bitacora_tabla_accion_fecha` (`tabla_afectada`,`accion`,`fecha_evento`),
  ADD KEY `idx_bitacora_tabla_registro` (`tabla_afectada`,`id_registro`);

--
-- Indices de la tabla `choferes_ambulancia`
--
ALTER TABLE `choferes_ambulancia`
  ADD PRIMARY KEY (`id_chofer_ambulancia`),
  ADD UNIQUE KEY `uk_choferes_ambulancia_empleado` (`id_empleado`),
  ADD KEY `idx_choferes_ambulancia_estado` (`estado`,`id_empleado`);

--
-- Indices de la tabla `comunidades`
--
ALTER TABLE `comunidades`
  ADD PRIMARY KEY (`id_comunidad`),
  ADD UNIQUE KEY `uk_comunidad_nombre` (`nombre_comunidad`),
  ADD KEY `idx_comunidades_estado_nombre` (`estado`,`nombre_comunidad`);

--
-- Indices de la tabla `configuracion_smtp`
--
ALTER TABLE `configuracion_smtp`
  ADD PRIMARY KEY (`id_configuracion_smtp`),
  ADD KEY `idx_configuracion_smtp_estado` (`estado`,`id_configuracion_smtp`),
  ADD KEY `idx_configuracion_smtp_usuario` (`id_usuario_actualiza`);

--
-- Indices de la tabla `dependencias`
--
ALTER TABLE `dependencias`
  ADD PRIMARY KEY (`id_dependencia`),
  ADD UNIQUE KEY `uk_dependencias_nombre` (`nombre_dependencia`),
  ADD KEY `idx_dependencias_estado_nombre` (`estado`,`nombre_dependencia`);

--
-- Indices de la tabla `despachos_unidades`
--
ALTER TABLE `despachos_unidades`
  ADD PRIMARY KEY (`id_despacho_unidad`),
  ADD KEY `idx_despachos_unidades_seguridad` (`id_seguridad`,`estado_despacho`),
  ADD KEY `idx_despachos_unidades_unidad` (`id_unidad`,`estado_despacho`),
  ADD KEY `idx_despachos_unidades_chofer` (`id_chofer_ambulancia`,`estado_despacho`),
  ADD KEY `fk_despachos_usuarios` (`id_usuario_asigna`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`id_empleado`),
  ADD UNIQUE KEY `cedula` (`cedula`),
  ADD KEY `fk_emp_dependencia` (`id_dependencia`),
  ADD KEY `idx_empleados_estado_nombre` (`estado`,`apellido`,`nombre`),
  ADD KEY `idx_empleados_dependencia` (`id_dependencia`);

--
-- Indices de la tabla `estados_solicitudes`
--
ALTER TABLE `estados_solicitudes`
  ADD PRIMARY KEY (`id_estado_solicitud`),
  ADD UNIQUE KEY `uk_estados_solicitudes_codigo` (`codigo_estado`),
  ADD UNIQUE KEY `uk_estados_solicitudes_nombre` (`nombre_estado`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`id_permiso`),
  ADD UNIQUE KEY `nombre_permiso` (`nombre_permiso`),
  ADD KEY `idx_permisos_estado_nombre` (`estado`,`nombre_permiso`);

--
-- Indices de la tabla `reportes_solicitudes_ambulancia`
--
ALTER TABLE `reportes_solicitudes_ambulancia`
  ADD PRIMARY KEY (`id_reporte_solicitud`),
  ADD KEY `idx_rsa_seguridad` (`id_seguridad`,`estado`,`tipo_reporte`),
  ADD KEY `idx_rsa_despacho` (`id_despacho_unidad`),
  ADD KEY `idx_rsa_usuario` (`id_usuario_genera`),
  ADD KEY `idx_rsa_envio` (`estado_envio`,`fecha_envio`);

--
-- Indices de la tabla `reportes_traslado`
--
ALTER TABLE `reportes_traslado`
  ADD PRIMARY KEY (`id_reporte`),
  ADD KEY `fk_rep_ayuda_final` (`id_ayuda`),
  ADD KEY `fk_rep_user_final` (`id_usuario_operador`),
  ADD KEY `fk_rep_unit_final` (`id_unidad`),
  ADD KEY `fk_rep_seguridad` (`id_seguridad`),
  ADD KEY `fk_rep_chofer_emp` (`id_empleado_chofer`),
  ADD KEY `idx_reportes_traslado_id_despacho_unidad` (`id_despacho_unidad`);

--
-- Indices de la tabla `seguimientos_solicitudes`
--
ALTER TABLE `seguimientos_solicitudes`
  ADD PRIMARY KEY (`id_seguimiento_solicitud`),
  ADD KEY `idx_seguimientos_modulo_referencia` (`modulo`,`id_referencia`),
  ADD KEY `idx_seguimientos_estado` (`id_estado_solicitud`),
  ADD KEY `idx_seguimientos_usuario` (`id_usuario`);

--
-- Indices de la tabla `seguridad`
--
ALTER TABLE `seguridad`
  ADD PRIMARY KEY (`id_seguridad`),
  ADD KEY `fk_seg_benef` (`id_beneficiario`),
  ADD KEY `idx_seg_id_usuario` (`id_usuario`),
  ADD KEY `idx_seguridad_id_tipo_seguridad` (`id_tipo_seguridad`),
  ADD KEY `idx_seguridad_id_solicitud_seguridad` (`id_solicitud_seguridad`),
  ADD KEY `idx_seguridad_estado_solicitud` (`id_estado_solicitud`);

--
-- Indices de la tabla `servicios_publicos`
--
ALTER TABLE `servicios_publicos`
  ADD PRIMARY KEY (`id_servicio`),
  ADD KEY `fk_ser_benef` (`id_beneficiario`),
  ADD KEY `idx_ser_id_usuario` (`id_usuario`),
  ADD KEY `idx_servicios_publicos_id_tipo_servicio_publico` (`id_tipo_servicio_publico`),
  ADD KEY `idx_servicios_publicos_id_solicitud_servicio_publico` (`id_solicitud_servicio_publico`),
  ADD KEY `idx_servicios_publicos_estado_solicitud` (`id_estado_solicitud`);

--
-- Indices de la tabla `solicitudes_generales`
--
ALTER TABLE `solicitudes_generales`
  ADD PRIMARY KEY (`id_solicitud_general`),
  ADD UNIQUE KEY `uk_solicitudes_generales_codigo` (`codigo_solicitud`),
  ADD UNIQUE KEY `uk_solicitudes_generales_nombre` (`nombre_solicitud`),
  ADD KEY `idx_solicitudes_generales_estado_codigo_nombre` (`estado`,`codigo_solicitud`,`nombre_solicitud`);

--
-- Indices de la tabla `tipos_ayuda_social`
--
ALTER TABLE `tipos_ayuda_social`
  ADD PRIMARY KEY (`id_tipo_ayuda_social`),
  ADD UNIQUE KEY `uk_tipos_ayuda_social_nombre` (`nombre_tipo_ayuda`),
  ADD KEY `idx_tipos_ayuda_social_estado_nombre` (`estado`,`nombre_tipo_ayuda`);

--
-- Indices de la tabla `tipos_seguridad_emergencia`
--
ALTER TABLE `tipos_seguridad_emergencia`
  ADD PRIMARY KEY (`id_tipo_seguridad`),
  ADD UNIQUE KEY `uk_tipos_seguridad_emergencia_nombre` (`nombre_tipo`),
  ADD KEY `idx_tipos_seguridad_emergencia_estado` (`estado`,`nombre_tipo`);

--
-- Indices de la tabla `tipos_servicios_publicos`
--
ALTER TABLE `tipos_servicios_publicos`
  ADD PRIMARY KEY (`id_tipo_servicio_publico`),
  ADD UNIQUE KEY `uk_tipos_servicios_publicos_codigo` (`codigo_tipo_servicio_publico`),
  ADD UNIQUE KEY `uk_tipos_servicios_publicos_nombre` (`nombre_tipo_servicio`),
  ADD KEY `idx_tipos_servicios_publicos_estado_codigo_nombre` (`estado`,`codigo_tipo_servicio_publico`,`nombre_tipo_servicio`);

--
-- Indices de la tabla `unidades`
--
ALTER TABLE `unidades`
  ADD PRIMARY KEY (`id_unidad`),
  ADD UNIQUE KEY `codigo_unidad` (`codigo_unidad`),
  ADD UNIQUE KEY `placa` (`placa`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `usuario` (`usuario`),
  ADD KEY `fk_user_emp` (`id_empleado`);

--
-- Indices de la tabla `usuarios_seguridad_acceso`
--
ALTER TABLE `usuarios_seguridad_acceso`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `idx_usuarios_seguridad_bloqueo` (`bloqueado`,`intentos_fallidos`);

--
-- Indices de la tabla `usuario_permisos`
--
ALTER TABLE `usuario_permisos`
  ADD PRIMARY KEY (`id_usuario_permiso`),
  ADD UNIQUE KEY `uk_usuario_permiso` (`id_usuario`,`id_permiso`),
  ADD KEY `fk_p_permisos` (`id_permiso`),
  ADD KEY `fk_u_permisos` (`id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `asignaciones_unidades_choferes`
--
ALTER TABLE `asignaciones_unidades_choferes`
  MODIFY `id_asignacion_unidad_chofer` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_asignacion_unidad_chofer de la tabla asignaciones_unidades_choferes.', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `ayuda_social`
--
ALTER TABLE `ayuda_social`
  MODIFY `id_ayuda` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Número correlativo de la solicitud', AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `beneficiarios`
--
ALTER TABLE `beneficiarios`
  MODIFY `id_beneficiario` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_beneficiario de la tabla beneficiarios.', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  MODIFY `id_bitacora` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_bitacora de la tabla bitacora.', AUTO_INCREMENT=120;

--
-- AUTO_INCREMENT de la tabla `choferes_ambulancia`
--
ALTER TABLE `choferes_ambulancia`
  MODIFY `id_chofer_ambulancia` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_chofer_ambulancia de la tabla choferes_ambulancia.', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `comunidades`
--
ALTER TABLE `comunidades`
  MODIFY `id_comunidad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_comunidad de la tabla comunidades.', AUTO_INCREMENT=131;

--
-- AUTO_INCREMENT de la tabla `configuracion_smtp`
--
ALTER TABLE `configuracion_smtp`
  MODIFY `id_configuracion_smtp` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_configuracion_smtp de la tabla configuracion_smtp.', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `dependencias`
--
ALTER TABLE `dependencias`
  MODIFY `id_dependencia` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_dependencia de la tabla dependencias.', AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `despachos_unidades`
--
ALTER TABLE `despachos_unidades`
  MODIFY `id_despacho_unidad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_despacho_unidad de la tabla despachos_unidades.', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_empleado de la tabla empleados.', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `estados_solicitudes`
--
ALTER TABLE `estados_solicitudes`
  MODIFY `id_estado_solicitud` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_estado_solicitud de la tabla estados_solicitudes.', AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `id_permiso` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_permiso de la tabla permisos.', AUTO_INCREMENT=100;

--
-- AUTO_INCREMENT de la tabla `reportes_solicitudes_ambulancia`
--
ALTER TABLE `reportes_solicitudes_ambulancia`
  MODIFY `id_reporte_solicitud` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_reporte_solicitud de la tabla reportes_solicitudes_ambulancia.', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `reportes_traslado`
--
ALTER TABLE `reportes_traslado`
  MODIFY `id_reporte` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_reporte de la tabla reportes_traslado.';

--
-- AUTO_INCREMENT de la tabla `seguimientos_solicitudes`
--
ALTER TABLE `seguimientos_solicitudes`
  MODIFY `id_seguimiento_solicitud` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_seguimiento_solicitud de la tabla seguimientos_solicitudes.', AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `seguridad`
--
ALTER TABLE `seguridad`
  MODIFY `id_seguridad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_seguridad de la tabla seguridad.', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `servicios_publicos`
--
ALTER TABLE `servicios_publicos`
  MODIFY `id_servicio` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_servicio de la tabla servicios_publicos.', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `solicitudes_generales`
--
ALTER TABLE `solicitudes_generales`
  MODIFY `id_solicitud_general` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_solicitud_general de la tabla solicitudes_generales.', AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `tipos_ayuda_social`
--
ALTER TABLE `tipos_ayuda_social`
  MODIFY `id_tipo_ayuda_social` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_tipo_ayuda_social de la tabla tipos_ayuda_social.', AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `tipos_seguridad_emergencia`
--
ALTER TABLE `tipos_seguridad_emergencia`
  MODIFY `id_tipo_seguridad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_tipo_seguridad de la tabla tipos_seguridad_emergencia.', AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `tipos_servicios_publicos`
--
ALTER TABLE `tipos_servicios_publicos`
  MODIFY `id_tipo_servicio_publico` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_tipo_servicio_publico de la tabla tipos_servicios_publicos.', AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `unidades`
--
ALTER TABLE `unidades`
  MODIFY `id_unidad` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_unidad de la tabla unidades.', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria: Identificador único del sistema', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuario_permisos`
--
ALTER TABLE `usuario_permisos`
  MODIFY `id_usuario_permiso` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Campo id_usuario_permiso de la tabla usuario_permisos.', AUTO_INCREMENT=11;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `asignaciones_unidades_choferes`
--
ALTER TABLE `asignaciones_unidades_choferes`
  ADD CONSTRAINT `fk_asignaciones_choferes` FOREIGN KEY (`id_chofer_ambulancia`) REFERENCES `choferes_ambulancia` (`id_chofer_ambulancia`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_asignaciones_unidades` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `ayuda_social`
--
ALTER TABLE `ayuda_social`
  ADD CONSTRAINT `fk_as_benef` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiarios` (`id_beneficiario`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_as_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `fk_ayuda_social_estado_solicitud` FOREIGN KEY (`id_estado_solicitud`) REFERENCES `estados_solicitudes` (`id_estado_solicitud`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ayuda_social_solicitudes_generales` FOREIGN KEY (`id_solicitud_ayuda_social`) REFERENCES `solicitudes_generales` (`id_solicitud_general`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ayuda_social_tipos` FOREIGN KEY (`id_tipo_ayuda_social`) REFERENCES `tipos_ayuda_social` (`id_tipo_ayuda_social`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `beneficiarios`
--
ALTER TABLE `beneficiarios`
  ADD CONSTRAINT `fk_beneficiarios_comunidades` FOREIGN KEY (`id_comunidad`) REFERENCES `comunidades` (`id_comunidad`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD CONSTRAINT `fk_bit_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL;

--
-- Filtros para la tabla `choferes_ambulancia`
--
ALTER TABLE `choferes_ambulancia`
  ADD CONSTRAINT `fk_choferes_ambulancia_empleados` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `configuracion_smtp`
--
ALTER TABLE `configuracion_smtp`
  ADD CONSTRAINT `fk_config_smtp_usuario` FOREIGN KEY (`id_usuario_actualiza`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `despachos_unidades`
--
ALTER TABLE `despachos_unidades`
  ADD CONSTRAINT `fk_despachos_choferes` FOREIGN KEY (`id_chofer_ambulancia`) REFERENCES `choferes_ambulancia` (`id_chofer_ambulancia`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_despachos_seguridad` FOREIGN KEY (`id_seguridad`) REFERENCES `seguridad` (`id_seguridad`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_despachos_unidades` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_despachos_usuarios` FOREIGN KEY (`id_usuario_asigna`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD CONSTRAINT `fk_emp_dependencia` FOREIGN KEY (`id_dependencia`) REFERENCES `dependencias` (`id_dependencia`);

--
-- Filtros para la tabla `reportes_solicitudes_ambulancia`
--
ALTER TABLE `reportes_solicitudes_ambulancia`
  ADD CONSTRAINT `fk_rsa_despacho` FOREIGN KEY (`id_despacho_unidad`) REFERENCES `despachos_unidades` (`id_despacho_unidad`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rsa_seguridad` FOREIGN KEY (`id_seguridad`) REFERENCES `seguridad` (`id_seguridad`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rsa_usuario` FOREIGN KEY (`id_usuario_genera`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `reportes_traslado`
--
ALTER TABLE `reportes_traslado`
  ADD CONSTRAINT `fk_rep_ayuda_final` FOREIGN KEY (`id_ayuda`) REFERENCES `ayuda_social` (`id_ayuda`),
  ADD CONSTRAINT `fk_rep_chofer_emp` FOREIGN KEY (`id_empleado_chofer`) REFERENCES `empleados` (`id_empleado`),
  ADD CONSTRAINT `fk_rep_seguridad` FOREIGN KEY (`id_seguridad`) REFERENCES `seguridad` (`id_seguridad`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_rep_unit_final` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`),
  ADD CONSTRAINT `fk_rep_user_final` FOREIGN KEY (`id_usuario_operador`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `fk_reportes_traslado_despacho` FOREIGN KEY (`id_despacho_unidad`) REFERENCES `despachos_unidades` (`id_despacho_unidad`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `seguimientos_solicitudes`
--
ALTER TABLE `seguimientos_solicitudes`
  ADD CONSTRAINT `fk_seguimientos_estados_solicitudes` FOREIGN KEY (`id_estado_solicitud`) REFERENCES `estados_solicitudes` (`id_estado_solicitud`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seguimientos_usuarios` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `seguridad`
--
ALTER TABLE `seguridad`
  ADD CONSTRAINT `fk_seg_benef` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiarios` (`id_beneficiario`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_seg_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seguridad_estado_solicitud` FOREIGN KEY (`id_estado_solicitud`) REFERENCES `estados_solicitudes` (`id_estado_solicitud`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seguridad_solicitudes_generales` FOREIGN KEY (`id_solicitud_seguridad`) REFERENCES `solicitudes_generales` (`id_solicitud_general`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seguridad_tipos_ayuda_social` FOREIGN KEY (`id_tipo_seguridad`) REFERENCES `tipos_ayuda_social` (`id_tipo_ayuda_social`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `servicios_publicos`
--
ALTER TABLE `servicios_publicos`
  ADD CONSTRAINT `fk_ser_benef` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiarios` (`id_beneficiario`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ser_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_servicios_publicos_estado_solicitud` FOREIGN KEY (`id_estado_solicitud`) REFERENCES `estados_solicitudes` (`id_estado_solicitud`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_servicios_publicos_solicitudes_generales` FOREIGN KEY (`id_solicitud_servicio_publico`) REFERENCES `solicitudes_generales` (`id_solicitud_general`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_servicios_publicos_tipos` FOREIGN KEY (`id_tipo_servicio_publico`) REFERENCES `tipos_servicios_publicos` (`id_tipo_servicio_publico`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_user_emp` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`);

--
-- Filtros para la tabla `usuarios_seguridad_acceso`
--
ALTER TABLE `usuarios_seguridad_acceso`
  ADD CONSTRAINT `fk_usuarios_seguridad_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario_permisos`
--
ALTER TABLE `usuario_permisos`
  ADD CONSTRAINT `fk_p_permisos` FOREIGN KEY (`id_permiso`) REFERENCES `permisos` (`id_permiso`),
  ADD CONSTRAINT `fk_u_permisos` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
