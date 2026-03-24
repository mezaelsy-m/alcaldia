USE `sala_situacional`;

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
