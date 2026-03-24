USE `sala_situacional`;

DROP PROCEDURE IF EXISTS `sp_dashboard_resumen_general`;
DROP PROCEDURE IF EXISTS `sp_bitacora_registrar_autenticacion`;
DROP PROCEDURE IF EXISTS `sp_usuarios_desbloquear_manual`;
DROP PROCEDURE IF EXISTS `sp_bitacora_consultar_autenticacion`;

CREATE OR REPLACE VIEW `vw_solicitudes_ciudadanas` AS
SELECT
    'AYUDA_SOCIAL' AS `modulo`,
    a.`id_ayuda` AS `id_registro`,
    a.`ticket_interno`,
    a.`id_beneficiario`,
    CONCAT(b.`nacionalidad`, '-', b.`cedula`, ' ', b.`nombre_beneficiario`) AS `beneficiario`,
    COALESCE(ta.`nombre_tipo_ayuda`, a.`tipo_ayuda`) AS `tipo_registro`,
    COALESCE(sg.`nombre_solicitud`, a.`solicitud_ayuda`) AS `solicitud`,
    COALESCE(es.`nombre_estado`, 'Registrada') AS `estado_solicitud`,
    COALESCE(es.`codigo_estado`, 'REGISTRADA') AS `codigo_estado_solicitud`,
    CAST(a.`fecha_ayuda` AS DATETIME) AS `fecha_evento`,
    DATE_FORMAT(CAST(a.`fecha_ayuda` AS DATETIME), '%d/%m/%Y %h:%i %p') AS `fecha_evento_formateada`,
    u.`usuario` AS `usuario_registra`,
    a.`estado`
FROM `ayuda_social` AS a
LEFT JOIN `beneficiarios` AS b
    ON b.`id_beneficiario` = a.`id_beneficiario`
LEFT JOIN `tipos_ayuda_social` AS ta
    ON ta.`id_tipo_ayuda_social` = a.`id_tipo_ayuda_social`
LEFT JOIN `solicitudes_generales` AS sg
    ON sg.`id_solicitud_general` = a.`id_solicitud_ayuda_social`
LEFT JOIN `estados_solicitudes` AS es
    ON es.`id_estado_solicitud` = a.`id_estado_solicitud`
LEFT JOIN `usuarios` AS u
    ON u.`id_usuario` = a.`id_usuario`

UNION ALL

SELECT
    'SERVICIOS_PUBLICOS' AS `modulo`,
    sp.`id_servicio` AS `id_registro`,
    sp.`ticket_interno`,
    sp.`id_beneficiario`,
    CONCAT(b.`nacionalidad`, '-', b.`cedula`, ' ', b.`nombre_beneficiario`) AS `beneficiario`,
    COALESCE(tsp.`nombre_tipo_servicio`, sp.`tipo_servicio`) AS `tipo_registro`,
    COALESCE(sg.`nombre_solicitud`, sp.`solicitud_servicio`) AS `solicitud`,
    COALESCE(es.`nombre_estado`, 'Registrada') AS `estado_solicitud`,
    COALESCE(es.`codigo_estado`, 'REGISTRADA') AS `codigo_estado_solicitud`,
    CAST(sp.`fecha_servicio` AS DATETIME) AS `fecha_evento`,
    DATE_FORMAT(CAST(sp.`fecha_servicio` AS DATETIME), '%d/%m/%Y %h:%i %p') AS `fecha_evento_formateada`,
    u.`usuario` AS `usuario_registra`,
    sp.`estado`
FROM `servicios_publicos` AS sp
LEFT JOIN `beneficiarios` AS b
    ON b.`id_beneficiario` = sp.`id_beneficiario`
LEFT JOIN `tipos_servicios_publicos` AS tsp
    ON tsp.`id_tipo_servicio_publico` = sp.`id_tipo_servicio_publico`
LEFT JOIN `solicitudes_generales` AS sg
    ON sg.`id_solicitud_general` = sp.`id_solicitud_servicio_publico`
LEFT JOIN `estados_solicitudes` AS es
    ON es.`id_estado_solicitud` = sp.`id_estado_solicitud`
LEFT JOIN `usuarios` AS u
    ON u.`id_usuario` = sp.`id_usuario`

UNION ALL

SELECT
    'SEGURIDAD_EMERGENCIA' AS `modulo`,
    s.`id_seguridad` AS `id_registro`,
    s.`ticket_interno`,
    s.`id_beneficiario`,
    CONCAT(b.`nacionalidad`, '-', b.`cedula`, ' ', b.`nombre_beneficiario`) AS `beneficiario`,
    COALESCE(tse.`nombre_tipo`, s.`tipo_seguridad`) AS `tipo_registro`,
    COALESCE(sg.`nombre_solicitud`, s.`tipo_solicitud`) AS `solicitud`,
    COALESCE(es.`nombre_estado`, 'Registrada') AS `estado_solicitud`,
    COALESCE(es.`codigo_estado`, 'REGISTRADA') AS `codigo_estado_solicitud`,
    s.`fecha_seguridad` AS `fecha_evento`,
    DATE_FORMAT(s.`fecha_seguridad`, '%d/%m/%Y %h:%i %p') AS `fecha_evento_formateada`,
    u.`usuario` AS `usuario_registra`,
    s.`estado`
FROM `seguridad` AS s
LEFT JOIN `beneficiarios` AS b
    ON b.`id_beneficiario` = s.`id_beneficiario`
LEFT JOIN `tipos_seguridad_emergencia` AS tse
    ON tse.`id_tipo_seguridad` = s.`id_tipo_seguridad`
LEFT JOIN `solicitudes_generales` AS sg
    ON sg.`id_solicitud_general` = s.`id_solicitud_seguridad`
LEFT JOIN `estados_solicitudes` AS es
    ON es.`id_estado_solicitud` = s.`id_estado_solicitud`
LEFT JOIN `usuarios` AS u
    ON u.`id_usuario` = s.`id_usuario`;

CREATE OR REPLACE VIEW `vw_usuarios_estado_acceso` AS
SELECT
    u.`id_usuario`,
    u.`id_empleado`,
    e.`id_dependencia`,
    u.`usuario`,
    u.`rol`,
    IFNULL(u.`estado`, 1) AS `estado`,
    e.`cedula`,
    TRIM(CONCAT(COALESCE(e.`nombre`, ''), ' ', COALESCE(e.`apellido`, ''))) AS `empleado`,
    d.`nombre_dependencia`,
    IFNULL(usa.`intentos_fallidos`, 0) AS `intentos_fallidos`,
    IFNULL(usa.`bloqueado`, 0) AS `bloqueado`,
    IFNULL(usa.`password_temporal`, 0) AS `password_temporal`,
    usa.`fecha_bloqueo`,
    usa.`fecha_password_temporal`,
    usa.`fecha_actualizacion`
FROM `usuarios` AS u
INNER JOIN `empleados` AS e
    ON e.`id_empleado` = u.`id_empleado`
LEFT JOIN `dependencias` AS d
    ON d.`id_dependencia` = e.`id_dependencia`
LEFT JOIN `usuarios_seguridad_acceso` AS usa
    ON usa.`id_usuario` = u.`id_usuario`;

CREATE OR REPLACE VIEW `vw_bitacora_autenticacion` AS
SELECT
    b.`id_bitacora`,
    b.`id_usuario`,
    b.`usuario_login`,
    b.`usuario_nombre`,
    b.`usuario_mostrar`,
    b.`tabla_afectada`,
    b.`accion`,
    b.`origen_evento`,
    b.`id_registro`,
    b.`resumen`,
    b.`detalle`,
    b.`ipaddr`,
    b.`fecha_evento`,
    b.`fecha_evento_formateada`,
    b.`estado`
FROM `vw_bitacora_sistema` AS b
WHERE b.`tabla_afectada` = 'AUTENTICACION'
   OR b.`accion` IN ('LOGIN_OK', 'LOGIN_FAIL', 'LOGOUT', 'BLOQUEO_USUARIO', 'DESBLOQUEO_USUARIO');

CREATE OR REPLACE VIEW `vw_unidades_operativas_actuales` AS
SELECT
    u.`id_unidad`,
    u.`codigo_unidad`,
    u.`descripcion`,
    u.`placa`,
    u.`estado`,
    u.`estado_operativo`,
    u.`ubicacion_actual`,
    u.`referencia_actual`,
    u.`prioridad_despacho`,
    au.`id_asignacion_unidad_chofer`,
    ca.`id_chofer_ambulancia`,
    ca.`numero_licencia`,
    ca.`categoria_licencia`,
    ca.`vencimiento_licencia`,
    e.`id_empleado`,
    e.`cedula` AS `cedula_chofer`,
    CONCAT(COALESCE(e.`nombre`, ''), ' ', COALESCE(e.`apellido`, '')) AS `nombre_chofer`,
    e.`telefono` AS `telefono_chofer`,
    du.`id_despacho_unidad`,
    du.`estado_despacho`,
    du.`fecha_asignacion`,
    du.`id_seguridad`,
    s.`ticket_interno`
FROM `unidades` AS u
LEFT JOIN (
    SELECT a1.*
    FROM `asignaciones_unidades_choferes` AS a1
    INNER JOIN (
        SELECT `id_unidad`, MAX(`id_asignacion_unidad_chofer`) AS `max_id`
        FROM `asignaciones_unidades_choferes`
        WHERE `estado` = 1
          AND `fecha_fin` IS NULL
        GROUP BY `id_unidad`
    ) AS am
        ON am.`max_id` = a1.`id_asignacion_unidad_chofer`
) AS au
    ON au.`id_unidad` = u.`id_unidad`
LEFT JOIN `choferes_ambulancia` AS ca
    ON ca.`id_chofer_ambulancia` = au.`id_chofer_ambulancia`
LEFT JOIN `empleados` AS e
    ON e.`id_empleado` = ca.`id_empleado`
LEFT JOIN (
    SELECT d1.*
    FROM `despachos_unidades` AS d1
    INNER JOIN (
        SELECT `id_unidad`, MAX(`id_despacho_unidad`) AS `max_id`
        FROM `despachos_unidades`
        WHERE `estado_despacho` = 'ACTIVO'
        GROUP BY `id_unidad`
    ) AS dm
        ON dm.`max_id` = d1.`id_despacho_unidad`
) AS du
    ON du.`id_unidad` = u.`id_unidad`
LEFT JOIN `seguridad` AS s
    ON s.`id_seguridad` = du.`id_seguridad`
WHERE u.`estado` = 1;

DELIMITER //

CREATE PROCEDURE `sp_dashboard_resumen_general`()
BEGIN
    SELECT
        (SELECT COUNT(*) FROM `beneficiarios` WHERE IFNULL(`estado`, 1) = 1) AS `total_beneficiarios`,
        (SELECT COUNT(*) FROM `ayuda_social` WHERE IFNULL(`estado`, 1) = 1) AS `total_ayudas`,
        (SELECT COUNT(*) FROM `servicios_publicos` WHERE IFNULL(`estado`, 1) = 1) AS `total_servicios`,
        (SELECT COUNT(*) FROM `seguridad` WHERE IFNULL(`estado`, 1) = 1) AS `total_seguridad`,
        (SELECT COUNT(*) FROM `usuarios` WHERE IFNULL(`estado`, 1) = 1) AS `total_usuarios_activos`,
        (SELECT COUNT(*) FROM `usuarios_seguridad_acceso` WHERE IFNULL(`bloqueado`, 0) = 1) AS `total_usuarios_bloqueados`,
        (SELECT COUNT(*) FROM `unidades` WHERE IFNULL(`estado`, 1) = 1 AND `estado_operativo` = 'DISPONIBLE') AS `total_unidades_disponibles`;
END//

CREATE PROCEDURE `sp_bitacora_registrar_autenticacion`(
    IN p_id_usuario INT,
    IN p_usuario VARCHAR(50),
    IN p_accion VARCHAR(20),
    IN p_detalle TEXT,
    IN p_ipaddr VARCHAR(45)
)
BEGIN
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
END//

CREATE PROCEDURE `sp_usuarios_desbloquear_manual`(
    IN p_id_usuario INT,
    IN p_id_usuario_admin INT,
    IN p_motivo VARCHAR(255)
)
BEGIN
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
END//

CREATE PROCEDURE `sp_bitacora_consultar_autenticacion`(
    IN p_fecha_desde DATETIME,
    IN p_fecha_hasta DATETIME,
    IN p_usuario VARCHAR(50),
    IN p_accion VARCHAR(20)
)
BEGIN
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
END//

DELIMITER ;

USE `sala_situacional_respaldo_bitacora`;

DROP PROCEDURE IF EXISTS `sp_respaldo_bitacora_resumen`;

ALTER TABLE `bitacora_respaldo`
    MODIFY `origen_bd` VARCHAR(64) NOT NULL DEFAULT 'sala_situacional';

UPDATE `bitacora_respaldo`
   SET `origen_bd` = 'sala_situacional'
 WHERE `origen_bd` = 'sala03v2_4';

DELIMITER //

CREATE PROCEDURE `sp_respaldo_bitacora_resumen`()
BEGIN
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
END//

DELIMITER ;
