-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 22-02-2026 a las 19:07:11
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

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ejecutar_recuperacion` (IN `p_id_backup` INT)   BEGIN
    DECLARE v_tabla VARCHAR(50);
    DECLARE v_datos TEXT;
    DECLARE v_id_reg INT;

    -- 1. Obtenemos la información del backup
    SELECT tabla_nombre, datos_completos INTO v_tabla, v_datos
    FROM respaldos_internos 
    WHERE id_backup = p_id_backup;

    -- 2. Extraemos el ID del registro del texto (Ej: de 'ID:201|...' saca el 201)
    SET v_id_reg = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(v_datos, '|', 1), 'ID:', -1) AS UNSIGNED);

    -- 3. Lógica de restauración para Ayuda Social
    IF v_tabla = 'ayuda_social' THEN
        -- Extraemos el estatus viejo (PENDIENTE) del backup
        UPDATE ayuda_social 
        SET solicitud_ayuda = SUBSTRING_INDEX(v_datos, 'Status:', -1)
        WHERE id_ayuda = v_id_reg;
        
        -- Dejamos huella en la bitacora usando nombres correctos
        -- Nota: Asegúrate que la tabla 'auditoria' tenga la columna 'accion' o cámbiala a 'operacion'
        INSERT INTO auditoria (tabla, accion, id_registro, despues, usuario_bd) 
        VALUES ('SISTEMA', 'RECUPERACION', v_id_reg, CONCAT('Restaurado backup #', p_id_backup), CURRENT_USER());
        
        SELECT CONCAT('Éxito: Registro #', v_id_reg, ' devuelto a estado PENDIENTE.') AS Resultado;
    ELSE
        SELECT 'Error: Registro no encontrado.' AS Resultado;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_subir_evidencia` (IN `p_id_reporte` INT, IN `p_id_usuario` INT, IN `p_ruta_foto` VARCHAR(255))   BEGIN
    -- 1. Actualizamos el registro con la foto
    UPDATE `reportes_traslado` 
    SET `foto_evidencia` = p_ruta_foto 
    WHERE `id_reporte` = p_id_reporte;

    -- 2. Dejamos huella en la Bitácora (Nivel Visual/Sistema)
    INSERT INTO `bitacora` (`id_usuario`, `accion`, `fecha`)
    VALUES (p_id_usuario, CONCAT('Evidencia cargada en reporte #', p_id_reporte), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ver_ultimos_backups` ()   BEGIN
    SELECT * FROM `respaldos_internos` ORDER BY `fecha_generacion` DESC LIMIT 10;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alertas_seguridad`
--

CREATE TABLE `alertas_seguridad` (
  `id_alerta` int(11) NOT NULL,
  `tabla_afectada` varchar(50) DEFAULT NULL,
  `operacion_intentada` varchar(20) DEFAULT NULL,
  `usuario_bd` varchar(50) DEFAULT NULL,
  `intento_momento` datetime DEFAULT current_timestamp(),
  `detalle` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria`
--

CREATE TABLE `auditoria` (
  `id` int(11) NOT NULL,
  `tabla` varchar(50) DEFAULT NULL,
  `accion` varchar(20) DEFAULT NULL,
  `id_registro` int(11) DEFAULT NULL,
  `antes` text DEFAULT NULL COMMENT 'Estado del registro previo a la modificación (Formato JSON/Texto)',
  `despues` text DEFAULT NULL COMMENT 'Estado del registro posterior a la modificación (Trazabilidad)',
  `usuario_bd` varchar(50) DEFAULT NULL,
  `fecha` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria`
--

INSERT INTO `auditoria` (`id`, `tabla`, `accion`, `id_registro`, `antes`, `despues`, `usuario_bd`, `fecha`) VALUES
(1, 'AYUDA_SOCIAL', 'ACTUALIZAR', 201, 'Estatus: PENDIENTE', 'Estatus: ENTREGADO', 'root@localhost', '2026-02-22 00:06:21'),
(2, 'AYUDA_SOCIAL', 'ACTUALIZAR', 201, 'Estatus: ENTREGADO', 'Estatus: PENDIENTE', 'root@localhost', '2026-02-22 00:13:00'),
(3, 'AYUDA_SOCIAL', 'ACTUALIZAR', 201, 'Estatus: PENDIENTE', 'Estatus: PENDIENTE', 'root@localhost', '2026-02-22 00:14:19'),
(4, 'SISTEMA', 'RECUPERACION', 201, NULL, 'Restaurado backup #1', 'root@localhost', '2026-02-22 00:14:19'),
(5, 'SISTEMA', 'RECUPERACION', 201, NULL, 'Restaurado backup #2', 'root@localhost', '2026-02-22 11:04:37'),
(6, 'SISTEMA', 'RECUPERACION', 201, NULL, 'Restaurado backup #3', 'root@localhost', '2026-02-22 11:04:45');

--
-- Disparadores `auditoria`
--
DELIMITER $$
CREATE TRIGGER `tr_auditoria_inmutable_del` BEFORE DELETE ON `auditoria` FOR EACH ROW BEGIN
    INSERT INTO `alertas_seguridad` (`tabla_afectada`, `operacion_intentada`, `usuario_bd`, `detalle`)
    VALUES ('auditoria', 'BORRADO', CURRENT_USER(), 'Intento de eliminar rastro de auditoría');
    
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seguridad: El historial de Auditoría no puede ser eliminado.';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_auditoria_inmutable_upd` BEFORE UPDATE ON `auditoria` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seguridad: Los registros de Auditoría no pueden ser alterados.';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_no_borrar_auditoria` BEFORE DELETE ON `auditoria` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Los registros de auditoría son permanentes y no pueden ser eliminados.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ayuda_social`
--

CREATE TABLE `ayuda_social` (
  `id_ayuda` int(11) NOT NULL COMMENT 'Número correlativo de la solicitud',
  `ticket_interno` varchar(20) DEFAULT NULL,
  `id_beneficiario` int(11) NOT NULL COMMENT 'FK: Enlace con los datos personales del solicitante',
  `id_usuario` int(11) DEFAULT NULL,
  `tipo_ayuda` varchar(100) DEFAULT NULL,
  `solicitud_ayuda` varchar(100) DEFAULT NULL COMMENT 'Estado administrativo: PENDIENTE, ENTREGADO, EN ESPERA',
  `fecha_ayuda` date DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` int(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ayuda_social`
--

INSERT INTO `ayuda_social` (`id_ayuda`, `ticket_interno`, `id_beneficiario`, `id_usuario`, `tipo_ayuda`, `solicitud_ayuda`, `fecha_ayuda`, `descripcion`, `estado`) VALUES
(202, 'AYU-20260222-000202', 1, 1, 'Medicas', 'Atencion', '2026-02-22', 'dddd', 1);

--
-- Disparadores `ayuda_social`
--
DELIMITER $$
CREATE TRIGGER `tr_auditar_ayuda` AFTER UPDATE ON `ayuda_social` FOR EACH ROW BEGIN
    INSERT INTO `auditoria` (`tabla`, `accion`, `id_registro`, `antes`, `despues`, `usuario_bd`)
    VALUES (
        'AYUDA_SOCIAL', 
        'ACTUALIZAR', 
        OLD.id_ayuda, 
        CONCAT('Estatus: ', OLD.solicitud_ayuda), 
        CONCAT('Estatus: ', NEW.solicitud_ayuda),
        CURRENT_USER()
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_backup_automatico_ayuda` BEFORE UPDATE ON `ayuda_social` FOR EACH ROW BEGIN
    -- Guardamos el estado anterior en la tabla de respaldos
    INSERT INTO `respaldos_internos` (`tabla_nombre`, `datos_completos`, `motivo`)
    VALUES (
        'ayuda_social', 
        CONCAT('ID:', OLD.id_ayuda, '|Tipo:', OLD.tipo_ayuda, '|Status:', OLD.solicitud_ayuda),
        'Backup automático por edición de registro'
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `beneficiarios`
--

CREATE TABLE `beneficiarios` (
  `id_beneficiario` int(11) NOT NULL,
  `nacionalidad` enum('V','E') DEFAULT 'V',
  `cedula` int(11) NOT NULL,
  `nombre_beneficiario` varchar(150) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `comunidad` varchar(100) DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `beneficiarios`
--

INSERT INTO `beneficiarios` (`id_beneficiario`, `nacionalidad`, `cedula`, `nombre_beneficiario`, `telefono`, `comunidad`, `fecha_registro`, `activo`) VALUES
(1, 'V', 26634695, 'Alejandro Chirinos', '04244360489', 'tocuyito', '2026-02-21 18:44:33', 1),
(2, 'V', 24329534, 'Laura Franco', '04244668450', 'valencia', '2026-02-21 18:44:33', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacora`
--

CREATE TABLE `bitacora` (
  `id_bitacora` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `resumen` varchar(100) NOT NULL COMMENT 'Descripción breve de la acción realizada por el usuario',
  `detalle` text DEFAULT NULL,
  `ipaddr` varchar(45) DEFAULT '127.0.0.1' COMMENT 'Dirección IP desde donde se realizó la operación',
  `moment` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `bitacora`
--
DELIMITER $$
CREATE TRIGGER `tr_bitacora_inmutable_del` BEFORE DELETE ON `bitacora` FOR EACH ROW BEGIN
    INSERT INTO `alertas_seguridad` (`tabla_afectada`, `operacion_intentada`, `usuario_bd`, `detalle`)
    VALUES ('bitacora', 'BORRADO', CURRENT_USER(), 'Intento de eliminar registro histórico');
    
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seguridad: Los registros de Bitácora son inmutables.';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_bitacora_inmutable_upd` BEFORE UPDATE ON `bitacora` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seguridad: Los registros de Bitácora no pueden ser modificados.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dependencias`
--

CREATE TABLE `dependencias` (
  `id_dependencia` int(11) NOT NULL,
  `nombre_dependencia` varchar(100) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `dependencias`
--

INSERT INTO `dependencias` (`id_dependencia`, `nombre_dependencia`) VALUES
(1, 'Informática'),
(2, 'Atención al Ciudadano'),
(3, 'Catastro'),
(4, 'Sala Situacional'),
(5, 'Auditoría Interna'),
(6, 'Dirección General'),
(7, 'Registro Civil');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `id_empleado` int(11) NOT NULL,
  `cedula` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `cedula`, `nombre`, `apellido`, `telefono`, `direccion`) VALUES
(1, 24571601, 'Italo', 'Administrador', NULL, NULL),
(2, 26634695, 'Alejandro', 'Operador', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `id_permiso` int(11) NOT NULL,
  `nombre_permiso` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `permisos`
--

INSERT INTO `permisos` (`id_permiso`, `nombre_permiso`, `descripcion`) VALUES
(1, 'Escritorio', 'Dashboard principal'),
(2, 'Concepto', 'Configuraciones básicas'),
(3, 'Ayuda', 'Módulo Ayuda Social'),
(4, 'Emergencia', 'Módulo Seguridad'),
(5, 'Publicos', 'Módulo Servicios Públicos'),
(6, 'Usuarios', 'Gestión de Cuentas'),
(7, 'Tribunal', 'Módulo Legal'),
(8, 'Chofer', 'Permiso para realizar reportes de traslado y ambulancia');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reportes_traslado`
--

CREATE TABLE `reportes_traslado` (
  `id_reporte` int(11) NOT NULL,
  `id_ayuda` int(11) NOT NULL,
  `id_usuario_operador` int(11) NOT NULL,
  `id_unidad` int(11) NOT NULL,
  `ticket_interno` varchar(20) NOT NULL,
  `fecha_hora` datetime DEFAULT current_timestamp(),
  `diagnostico_paciente` text DEFAULT NULL,
  `foto_evidencia` varchar(255) DEFAULT NULL,
  `km_salida` int(11) DEFAULT NULL,
  `km_llegada` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `reportes_traslado`
--
DELIMITER $$
CREATE TRIGGER `tr_auditar_traslado` AFTER UPDATE ON `reportes_traslado` FOR EACH ROW BEGIN
    INSERT INTO `auditoria` (`tabla`, `accion`, `id_registro`, `antes`, `despues`, `usuario_bd`)
    VALUES (
        'REPORTES_TRASLADO', 
        'ACTUALIZAR', 
        OLD.id_reporte, 
        CONCAT('KM: ', OLD.km_llegada, ' | Foto: ', OLD.foto_evidencia), 
        CONCAT('KM: ', NEW.km_llegada, ' | Foto: ', NEW.foto_evidencia),
        CURRENT_USER()
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `respaldos_internos`
--

CREATE TABLE `respaldos_internos` (
  `id_backup` int(11) NOT NULL,
  `tabla_nombre` varchar(50) DEFAULT NULL,
  `datos_completos` longtext DEFAULT NULL,
  `fecha_generacion` datetime DEFAULT current_timestamp(),
  `motivo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `respaldos_internos`
--

INSERT INTO `respaldos_internos` (`id_backup`, `tabla_nombre`, `datos_completos`, `fecha_generacion`, `motivo`) VALUES
(1, 'ayuda_social', 'ID:201|Tipo:MEDICINA|Status:PENDIENTE', '2026-02-22 00:06:21', 'Backup automático por edición de registro'),
(2, 'ayuda_social', 'ID:201|Tipo:MEDICINA|Status:ENTREGADO', '2026-02-22 00:13:00', 'Backup automático por edición de registro'),
(3, 'ayuda_social', 'ID:201|Tipo:MEDICINA|Status:PENDIENTE', '2026-02-22 00:14:19', 'Backup automático por edición de registro');

--
-- Disparadores `respaldos_internos`
--
DELIMITER $$
CREATE TRIGGER `tr_respaldos_inmutable_del` BEFORE DELETE ON `respaldos_internos` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seguridad: Los Backups automáticos no pueden ser eliminados.';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_respaldos_inmutable_upd` BEFORE UPDATE ON `respaldos_internos` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seguridad: Los Backups no pueden ser modificados para garantizar integridad.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `seguridad`
--

CREATE TABLE `seguridad` (
  `id_seguridad` int(11) NOT NULL,
  `ticket_interno` varchar(20) DEFAULT NULL,
  `id_beneficiario` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `tipo_seguridad` varchar(100) DEFAULT NULL,
  `tipo_solicitud` varchar(100) DEFAULT NULL,
  `fecha_seguridad` date DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` int(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicios_publicos`
--

CREATE TABLE `servicios_publicos` (
  `id_servicio` int(11) NOT NULL,
  `ticket_interno` varchar(20) DEFAULT NULL,
  `id_beneficiario` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `tipo_servicio` varchar(100) DEFAULT NULL,
  `solicitud_servicio` varchar(100) DEFAULT NULL,
  `fecha_servicio` date DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` int(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidades`
--

CREATE TABLE `unidades` (
  `id_unidad` int(11) NOT NULL,
  `codigo_unidad` varchar(20) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `placa` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `unidades`
--

INSERT INTO `unidades` (`id_unidad`, `codigo_unidad`, `descripcion`, `placa`) VALUES
(1, 'AMB-01', 'Ambulancia Ford Transit', 'ABC-123');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL COMMENT 'Clave primaria: Identificador único del sistema',
  `id_empleado` int(11) NOT NULL,
  `id_dependencia` int(11) NOT NULL COMMENT 'FK: Vincula al usuario con su oficina de adscripción',
  `usuario` varchar(50) NOT NULL,
  `password` varchar(64) NOT NULL,
  `rol` enum('ADMIN','OPERADOR','CONSULTOR') DEFAULT 'OPERADOR' COMMENT 'Nivel de acceso: ADMIN(Total), OPERADOR(Escritura), CONSULTOR(Lectura)',
  `estado` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `id_empleado`, `id_dependencia`, `usuario`, `password`, `rol`, `estado`) VALUES
(1, 1, 1, 'prueba', '655e786674d9d3e77bc05ed1de37b4b6bc89f788829f9f3c679e7687b410c89b', 'ADMIN', 1),
(2, 2, 2, 'operador1', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'OPERADOR', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_permisos`
--

CREATE TABLE `usuario_permisos` (
  `id_usuario_permiso` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_permiso` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario_permisos`
--

INSERT INTO `usuario_permisos` (`id_usuario_permiso`, `id_usuario`, `id_permiso`) VALUES
(15, 2, 8);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_dashboard_alcaldia`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_dashboard_alcaldia` (
`Oficina` varchar(100)
,`Total_Solicitudes` bigint(21)
,`Atendidos` decimal(22,0)
,`En_Espera` decimal(22,0)
,`Eficiencia` varchar(30)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_gestion_alcaldia`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_gestion_alcaldia` (
`Oficina` varchar(100)
,`Total_Solicitudes` bigint(21)
,`Atendidos` decimal(22,0)
,`En_Espera` decimal(22,0)
,`Eficiencia` varchar(31)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_monitoreo_backups`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_monitoreo_backups` (
`Fecha` datetime
,`Tabla` varchar(50)
,`Evento` varchar(100)
,`Tipo` varchar(10)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_dashboard_alcaldia`
--
DROP TABLE IF EXISTS `vista_dashboard_alcaldia`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_dashboard_alcaldia`  AS SELECT `d`.`nombre_dependencia` AS `Oficina`, count(`a`.`id_ayuda`) AS `Total_Solicitudes`, sum(case when `a`.`solicitud_ayuda` = 'ENTREGADO' then 1 else 0 end) AS `Atendidos`, sum(case when `a`.`solicitud_ayuda` = 'PENDIENTE' then 1 else 0 end) AS `En_Espera`, concat(round(sum(case when `a`.`solicitud_ayuda` = 'ENTREGADO' then 1 else 0 end) / count(`a`.`id_ayuda`) * 100,1),'%') AS `Eficiencia` FROM ((`dependencias` `d` left join `usuarios` `u` on(`d`.`id_dependencia` = `u`.`id_dependencia`)) left join `ayuda_social` `a` on(`u`.`id_usuario` = `a`.`id_usuario`)) GROUP BY `d`.`nombre_dependencia` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_gestion_alcaldia`
--
DROP TABLE IF EXISTS `vista_gestion_alcaldia`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_gestion_alcaldia`  AS SELECT `d`.`nombre_dependencia` AS `Oficina`, count(`a`.`id_ayuda`) AS `Total_Solicitudes`, sum(case when `a`.`solicitud_ayuda` = 'ENTREGADO' then 1 else 0 end) AS `Atendidos`, sum(case when `a`.`solicitud_ayuda` = 'PENDIENTE' then 1 else 0 end) AS `En_Espera`, concat(round(sum(case when `a`.`solicitud_ayuda` = 'ENTREGADO' then 1 else 0 end) / count(`a`.`id_ayuda`) * 100,2),'%') AS `Eficiencia` FROM ((`dependencias` `d` left join `usuarios` `u` on(`d`.`id_dependencia` = `u`.`id_dependencia`)) left join `ayuda_social` `a` on(`u`.`id_usuario` = `a`.`id_usuario`)) GROUP BY `d`.`nombre_dependencia` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_monitoreo_backups`
--
DROP TABLE IF EXISTS `vista_monitoreo_backups`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_monitoreo_backups`  AS SELECT `r`.`fecha_generacion` AS `Fecha`, `r`.`tabla_nombre` AS `Tabla`, `r`.`motivo` AS `Evento`, 'AUTOMÁTICO' AS `Tipo` FROM `respaldos_internos` AS `r`union all select `a`.`fecha` AS `Fecha`,`a`.`tabla` AS `Tabla`,concat(`a`.`accion`,' por ',`a`.`usuario_bd`) AS `Evento`,'AUDITORÍA' AS `Tipo` from `auditoria` `a` order by `Fecha` desc  ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alertas_seguridad`
--
ALTER TABLE `alertas_seguridad`
  ADD PRIMARY KEY (`id_alerta`);

--
-- Indices de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ayuda_social`
--
ALTER TABLE `ayuda_social`
  ADD PRIMARY KEY (`id_ayuda`),
  ADD KEY `fk_as_benef` (`id_beneficiario`),
  ADD KEY `fk_as_user` (`id_usuario`);

--
-- Indices de la tabla `beneficiarios`
--
ALTER TABLE `beneficiarios`
  ADD PRIMARY KEY (`id_beneficiario`),
  ADD UNIQUE KEY `cedula` (`cedula`);

--
-- Indices de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD PRIMARY KEY (`id_bitacora`),
  ADD KEY `fk_bit_user` (`id_usuario`);

--
-- Indices de la tabla `dependencias`
--
ALTER TABLE `dependencias`
  ADD PRIMARY KEY (`id_dependencia`),
  ADD UNIQUE KEY `uk_dependencias_nombre` (`nombre_dependencia`),
  ADD KEY `idx_dependencias_estado_nombre` (`estado`,`nombre_dependencia`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`id_empleado`),
  ADD UNIQUE KEY `cedula` (`cedula`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`id_permiso`),
  ADD UNIQUE KEY `nombre_permiso` (`nombre_permiso`),
  ADD KEY `idx_permisos_estado_nombre` (`estado`,`nombre_permiso`);

--
-- Indices de la tabla `reportes_traslado`
--
ALTER TABLE `reportes_traslado`
  ADD PRIMARY KEY (`id_reporte`),
  ADD KEY `fk_rep_ayuda_final` (`id_ayuda`),
  ADD KEY `fk_rep_user_final` (`id_usuario_operador`),
  ADD KEY `fk_rep_unit_final` (`id_unidad`);

--
-- Indices de la tabla `respaldos_internos`
--
ALTER TABLE `respaldos_internos`
  ADD PRIMARY KEY (`id_backup`);

--
-- Indices de la tabla `seguridad`
--
ALTER TABLE `seguridad`
  ADD PRIMARY KEY (`id_seguridad`),
  ADD KEY `fk_seg_benef` (`id_beneficiario`);

--
-- Indices de la tabla `servicios_publicos`
--
ALTER TABLE `servicios_publicos`
  ADD PRIMARY KEY (`id_servicio`),
  ADD KEY `fk_ser_benef` (`id_beneficiario`);

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
  ADD KEY `fk_user_emp` (`id_empleado`),
  ADD KEY `fk_user_dep` (`id_dependencia`);

--
-- Indices de la tabla `usuario_permisos`
--
ALTER TABLE `usuario_permisos`
  ADD PRIMARY KEY (`id_usuario_permiso`),
  ADD KEY `fk_p_permisos` (`id_permiso`),
  ADD KEY `fk_u_permisos` (`id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alertas_seguridad`
--
ALTER TABLE `alertas_seguridad`
  MODIFY `id_alerta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `ayuda_social`
--
ALTER TABLE `ayuda_social`
  MODIFY `id_ayuda` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Número correlativo de la solicitud', AUTO_INCREMENT=203;

--
-- AUTO_INCREMENT de la tabla `beneficiarios`
--
ALTER TABLE `beneficiarios`
  MODIFY `id_beneficiario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  MODIFY `id_bitacora` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `dependencias`
--
ALTER TABLE `dependencias`
  MODIFY `id_dependencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `id_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `reportes_traslado`
--
ALTER TABLE `reportes_traslado`
  MODIFY `id_reporte` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `respaldos_internos`
--
ALTER TABLE `respaldos_internos`
  MODIFY `id_backup` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `seguridad`
--
ALTER TABLE `seguridad`
  MODIFY `id_seguridad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `servicios_publicos`
--
ALTER TABLE `servicios_publicos`
  MODIFY `id_servicio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `unidades`
--
ALTER TABLE `unidades`
  MODIFY `id_unidad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria: Identificador único del sistema', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuario_permisos`
--
ALTER TABLE `usuario_permisos`
  MODIFY `id_usuario_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `ayuda_social`
--
ALTER TABLE `ayuda_social`
  ADD CONSTRAINT `fk_as_benef` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiarios` (`id_beneficiario`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_as_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD CONSTRAINT `fk_bit_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL;

--
-- Filtros para la tabla `reportes_traslado`
--
ALTER TABLE `reportes_traslado`
  ADD CONSTRAINT `fk_rep_ayuda_final` FOREIGN KEY (`id_ayuda`) REFERENCES `ayuda_social` (`id_ayuda`),
  ADD CONSTRAINT `fk_rep_unit_final` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id_unidad`),
  ADD CONSTRAINT `fk_rep_user_final` FOREIGN KEY (`id_usuario_operador`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `seguridad`
--
ALTER TABLE `seguridad`
  ADD CONSTRAINT `fk_seg_benef` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiarios` (`id_beneficiario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `servicios_publicos`
--
ALTER TABLE `servicios_publicos`
  ADD CONSTRAINT `fk_ser_benef` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiarios` (`id_beneficiario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_user_dep` FOREIGN KEY (`id_dependencia`) REFERENCES `dependencias` (`id_dependencia`),
  ADD CONSTRAINT `fk_user_emp` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`);

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
