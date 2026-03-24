USE `sala03v2_4`;

DROP VIEW IF EXISTS `vw_bitacora_sistema`;
DROP VIEW IF EXISTS `vw_seguridad_operativa`;

DROP PROCEDURE IF EXISTS `sp_bitacora_registrar_evento`;
DROP PROCEDURE IF EXISTS `sp_usuarios_incrementar_intento_fallido`;
DROP PROCEDURE IF EXISTS `sp_usuarios_reiniciar_seguridad_acceso`;
DROP PROCEDURE IF EXISTS `sp_usuarios_marcar_bloqueado`;

DROP TRIGGER IF EXISTS `tr_beneficiarios_bi_hora12`;
DROP TRIGGER IF EXISTS `tr_beneficiarios_bu_hora12`;
DROP TRIGGER IF EXISTS `tr_comunidades_bi_hora12`;
DROP TRIGGER IF EXISTS `tr_comunidades_bu_hora12`;

DROP TRIGGER IF EXISTS `tr_beneficiarios_ai_audit`;
DROP TRIGGER IF EXISTS `tr_beneficiarios_au_audit`;
DROP TRIGGER IF EXISTS `tr_comunidades_ai_audit`;
DROP TRIGGER IF EXISTS `tr_comunidades_au_audit`;

ALTER TABLE `beneficiarios`
    DROP COLUMN IF EXISTS `hora_registro_12h`;

ALTER TABLE `comunidades`
    DROP COLUMN IF EXISTS `hora_registro_12h`;

DELIMITER //

CREATE TRIGGER `tr_beneficiarios_ai_audit`
AFTER INSERT ON `beneficiarios`
FOR EACH ROW
BEGIN
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
END//

CREATE TRIGGER `tr_beneficiarios_au_audit`
AFTER UPDATE ON `beneficiarios`
FOR EACH ROW
BEGIN
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
END//

CREATE TRIGGER `tr_comunidades_ai_audit`
AFTER INSERT ON `comunidades`
FOR EACH ROW
BEGIN
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
END//

CREATE TRIGGER `tr_comunidades_au_audit`
AFTER UPDATE ON `comunidades`
FOR EACH ROW
BEGIN
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
END//

CREATE PROCEDURE `sp_bitacora_registrar_evento`(
    IN p_id_usuario INT,
    IN p_tabla_afectada VARCHAR(64),
    IN p_accion VARCHAR(20),
    IN p_id_registro VARCHAR(64),
    IN p_resumen VARCHAR(100),
    IN p_detalle TEXT,
    IN p_datos_antes LONGTEXT,
    IN p_datos_despues LONGTEXT,
    IN p_ipaddr VARCHAR(45),
    IN p_estado TINYINT
)
BEGIN
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
END//

CREATE PROCEDURE `sp_usuarios_incrementar_intento_fallido`(
    IN p_id_usuario INT
)
BEGIN
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
END//

CREATE PROCEDURE `sp_usuarios_reiniciar_seguridad_acceso`(
    IN p_id_usuario INT
)
BEGIN
    UPDATE `usuarios_seguridad_acceso`
       SET `intentos_fallidos` = 0,
           `bloqueado` = 0,
           `fecha_bloqueo` = NULL
     WHERE `id_usuario` = p_id_usuario;
END//

CREATE PROCEDURE `sp_usuarios_marcar_bloqueado`(
    IN p_id_usuario INT
)
BEGIN
    UPDATE `usuarios_seguridad_acceso`
       SET `bloqueado` = 1,
           `fecha_bloqueo` = NOW()
     WHERE `id_usuario` = p_id_usuario;
END//

DELIMITER ;

CREATE OR REPLACE VIEW `vw_bitacora_sistema` AS
SELECT
    b.`id_bitacora`,
    b.`id_usuario`,
    u.`usuario` AS `usuario_login`,
    TRIM(CONCAT(IFNULL(e.`nombre`, ''), ' ', IFNULL(e.`apellido`, ''))) AS `usuario_nombre`,
    CASE
        WHEN u.`id_usuario` IS NOT NULL AND TRIM(CONCAT(IFNULL(e.`nombre`, ''), ' ', IFNULL(e.`apellido`, ''))) <> ''
            THEN CONCAT(u.`usuario`, ' - ', TRIM(CONCAT(IFNULL(e.`nombre`, ''), ' ', IFNULL(e.`apellido`, ''))))
        WHEN u.`id_usuario` IS NOT NULL
            THEN u.`usuario`
        WHEN COALESCE(b.`usuario_bd`, '') <> ''
            THEN CONCAT('Sistema - ', b.`usuario_bd`)
        ELSE 'Sistema'
    END AS `usuario_mostrar`,
    b.`tabla_afectada`,
    b.`accion`,
    CONCAT(COALESCE(b.`tabla_afectada`, 'SISTEMA'), ' / ', COALESCE(b.`accion`, 'LEGACY')) AS `origen_evento`,
    b.`id_registro`,
    b.`resumen`,
    b.`detalle`,
    b.`datos_antes`,
    b.`datos_despues`,
    b.`usuario_bd`,
    b.`ipaddr`,
    b.`moment`,
    b.`fecha_evento`,
    DATE_FORMAT(b.`fecha_evento`, '%d/%m/%Y %h:%i %p') AS `fecha_evento_formateada`,
    b.`estado`
FROM `bitacora` AS b
LEFT JOIN `usuarios` AS u
    ON u.`id_usuario` = b.`id_usuario`
LEFT JOIN `empleados` AS e
    ON e.`id_empleado` = u.`id_empleado`;

CREATE OR REPLACE VIEW `vw_seguridad_operativa` AS
SELECT
    s.`id_seguridad`,
    s.`ticket_interno`,
    s.`id_beneficiario`,
    s.`id_usuario`,
    s.`id_tipo_seguridad`,
    s.`id_solicitud_seguridad`,
    s.`id_estado_solicitud`,
    COALESCE(tse.`nombre_tipo`, s.`tipo_seguridad`) AS `tipo_seguridad`,
    COALESCE(tse.`requiere_ambulancia`, 0) AS `requiere_ambulancia`,
    COALESCE(sg.`nombre_solicitud`, s.`tipo_solicitud`) AS `tipo_solicitud`,
    COALESCE(es.`nombre_estado`, 'Registrada') AS `estado_solicitud`,
    COALESCE(es.`codigo_estado`, 'REGISTRADA') AS `codigo_estado_solicitud`,
    COALESCE(es.`clase_badge`, 'draft') AS `clase_badge_estado_solicitud`,
    COALESCE(es.`es_atendida`, 0) AS `es_atendida`,
    s.`fecha_seguridad`,
    DATE_FORMAT(s.`fecha_seguridad`, '%Y-%m-%dT%H:%i') AS `fecha_seguridad_input`,
    DATE_FORMAT(s.`fecha_seguridad`, '%d/%m/%Y %h:%i %p') AS `fecha_seguridad_formateada`,
    s.`descripcion`,
    s.`estado`,
    s.`estado_atencion`,
    s.`ubicacion_evento`,
    s.`referencia_evento`,
    b.`nacionalidad`,
    b.`cedula`,
    b.`nombre_beneficiario`,
    b.`telefono`,
    CONCAT(b.`nacionalidad`, '-', b.`cedula`, ' ', b.`nombre_beneficiario`) AS `beneficiario`,
    du.`id_despacho_unidad`,
    du.`estado_despacho`,
    du.`modo_asignacion`,
    du.`fecha_asignacion`,
    u.`id_unidad`,
    u.`codigo_unidad`,
    u.`descripcion` AS `descripcion_unidad`,
    u.`placa`,
    u.`ubicacion_actual`,
    u.`referencia_actual`,
    ca.`id_chofer_ambulancia`,
    ca.`numero_licencia`,
    ca.`categoria_licencia`,
    ca.`vencimiento_licencia`,
    e.`id_empleado`,
    e.`cedula` AS `cedula_chofer`,
    CONCAT(e.`nombre`, ' ', e.`apellido`) AS `nombre_chofer`,
    e.`telefono` AS `telefono_chofer`,
    e.`correo` AS `correo_chofer`
FROM `seguridad` AS s
LEFT JOIN `tipos_seguridad_emergencia` AS tse
    ON tse.`id_tipo_seguridad` = s.`id_tipo_seguridad`
LEFT JOIN `solicitudes_generales` AS sg
    ON sg.`id_solicitud_general` = s.`id_solicitud_seguridad`
LEFT JOIN `estados_solicitudes` AS es
    ON es.`id_estado_solicitud` = s.`id_estado_solicitud`
LEFT JOIN `beneficiarios` AS b
    ON b.`id_beneficiario` = s.`id_beneficiario`
LEFT JOIN (
    SELECT d1.*
      FROM `despachos_unidades` AS d1
      INNER JOIN (
          SELECT `id_seguridad`, MAX(`id_despacho_unidad`) AS `max_id`
            FROM `despachos_unidades`
           GROUP BY `id_seguridad`
      ) AS dm
        ON dm.`max_id` = d1.`id_despacho_unidad`
) AS du
    ON du.`id_seguridad` = s.`id_seguridad`
LEFT JOIN `unidades` AS u
    ON u.`id_unidad` = du.`id_unidad`
LEFT JOIN `choferes_ambulancia` AS ca
    ON ca.`id_chofer_ambulancia` = du.`id_chofer_ambulancia`
LEFT JOIN `empleados` AS e
    ON e.`id_empleado` = ca.`id_empleado`;

CREATE DATABASE IF NOT EXISTS `sala03v2_4_respaldo_bitacora`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE `sala03v2_4_respaldo_bitacora`;

CREATE TABLE IF NOT EXISTS `bitacora_respaldo` (
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
  `origen_bd` varchar(64) NOT NULL DEFAULT 'sala03v2_4',
  `fecha_respaldo` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_bitacora`),
  KEY `idx_bitacora_respaldo_fecha` (`fecha_evento`),
  KEY `idx_bitacora_respaldo_origen` (`tabla_afectada`, `accion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `control_respaldo_bitacora` (
  `id_control` tinyint(1) NOT NULL,
  `ultimo_id_bitacora` int(11) NOT NULL DEFAULT 0,
  `registros_insertados` int(11) NOT NULL DEFAULT 0,
  `fecha_ultimo_respaldo` datetime DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'PENDIENTE',
  PRIMARY KEY (`id_control`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP PROCEDURE IF EXISTS `sp_sync_bitacora_desde_operativa`;
DROP EVENT IF EXISTS `ev_backup_bitacora_cada_minuto`;

DELIMITER //

CREATE PROCEDURE `sp_sync_bitacora_desde_operativa`()
BEGIN
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
        'sala03v2_4',
        NOW()
    FROM `sala03v2_4`.`bitacora` AS b
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
END//

CREATE EVENT `ev_backup_bitacora_cada_minuto`
    ON SCHEDULE EVERY 1 MINUTE
    STARTS CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
    DO
BEGIN
    CALL `sp_sync_bitacora_desde_operativa`();
END//

DELIMITER ;

CALL `sp_sync_bitacora_desde_operativa`();

USE `sala03v2_4`;
