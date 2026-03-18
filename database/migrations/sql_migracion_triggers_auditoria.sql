USE sala03v2_4;

DELIMITER //

DROP TRIGGER IF EXISTS `tr_auditoria_ai_audit`//
CREATE TRIGGER `tr_auditoria_ai_audit` AFTER INSERT ON `auditoria`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'auditoria',
    'INSERT',
    CAST(NEW.`id` AS CHAR),
    CONCAT('AUDIT INSERT ', 'auditoria'),
    CONCAT('Insercion en auditoria [ID=', CAST(NEW.`id` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id', NEW.`id`, 'tabla', NEW.`tabla`, 'accion', NEW.`accion`, 'id_registro', NEW.`id_registro`, 'antes', NEW.`antes`, 'despues', NEW.`despues`, 'usuario_bd', NEW.`usuario_bd`, 'fecha', NEW.`fecha`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_auditoria_au_audit`//
CREATE TRIGGER `tr_auditoria_au_audit` AFTER UPDATE ON `auditoria`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'auditoria',
    v_accion,
    CAST(NEW.`id` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'auditoria'),
    CONCAT(v_accion, ' en auditoria [ID=', CAST(NEW.`id` AS CHAR), ']'),
    JSON_OBJECT('id', OLD.`id`, 'tabla', OLD.`tabla`, 'accion', OLD.`accion`, 'id_registro', OLD.`id_registro`, 'antes', OLD.`antes`, 'despues', OLD.`despues`, 'usuario_bd', OLD.`usuario_bd`, 'fecha', OLD.`fecha`, 'estado', OLD.`estado`),
    JSON_OBJECT('id', NEW.`id`, 'tabla', NEW.`tabla`, 'accion', NEW.`accion`, 'id_registro', NEW.`id_registro`, 'antes', NEW.`antes`, 'despues', NEW.`despues`, 'usuario_bd', NEW.`usuario_bd`, 'fecha', NEW.`fecha`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_auditoria_bd_block_delete`//
CREATE TRIGGER `tr_auditoria_bd_block_delete` BEFORE DELETE ON `auditoria`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla auditoria. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_ayuda_social_ai_audit`//
CREATE TRIGGER `tr_ayuda_social_ai_audit` AFTER INSERT ON `ayuda_social`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'ayuda_social',
    'INSERT',
    CAST(NEW.`id_ayuda` AS CHAR),
    CONCAT('AUDIT INSERT ', 'ayuda_social'),
    CONCAT('Insercion en ayuda_social [ID=', CAST(NEW.`id_ayuda` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_ayuda', NEW.`id_ayuda`, 'ticket_interno', NEW.`ticket_interno`, 'id_beneficiario', NEW.`id_beneficiario`, 'id_usuario', NEW.`id_usuario`, 'tipo_ayuda', NEW.`tipo_ayuda`, 'solicitud_ayuda', NEW.`solicitud_ayuda`, 'fecha_ayuda', NEW.`fecha_ayuda`, 'descripcion', NEW.`descripcion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_ayuda_social_au_audit`//
CREATE TRIGGER `tr_ayuda_social_au_audit` AFTER UPDATE ON `ayuda_social`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'ayuda_social',
    v_accion,
    CAST(NEW.`id_ayuda` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'ayuda_social'),
    CONCAT(v_accion, ' en ayuda_social [ID=', CAST(NEW.`id_ayuda` AS CHAR), ']'),
    JSON_OBJECT('id_ayuda', OLD.`id_ayuda`, 'ticket_interno', OLD.`ticket_interno`, 'id_beneficiario', OLD.`id_beneficiario`, 'id_usuario', OLD.`id_usuario`, 'tipo_ayuda', OLD.`tipo_ayuda`, 'solicitud_ayuda', OLD.`solicitud_ayuda`, 'fecha_ayuda', OLD.`fecha_ayuda`, 'descripcion', OLD.`descripcion`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_ayuda', NEW.`id_ayuda`, 'ticket_interno', NEW.`ticket_interno`, 'id_beneficiario', NEW.`id_beneficiario`, 'id_usuario', NEW.`id_usuario`, 'tipo_ayuda', NEW.`tipo_ayuda`, 'solicitud_ayuda', NEW.`solicitud_ayuda`, 'fecha_ayuda', NEW.`fecha_ayuda`, 'descripcion', NEW.`descripcion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_ayuda_social_bd_block_delete`//
CREATE TRIGGER `tr_ayuda_social_bd_block_delete` BEFORE DELETE ON `ayuda_social`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla ayuda_social. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_beneficiarios_ai_audit`//
CREATE TRIGGER `tr_beneficiarios_ai_audit` AFTER INSERT ON `beneficiarios`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'beneficiarios',
    'INSERT',
    CAST(NEW.`id_beneficiario` AS CHAR),
    CONCAT('AUDIT INSERT ', 'beneficiarios'),
    CONCAT('Insercion en beneficiarios [ID=', CAST(NEW.`id_beneficiario` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_beneficiario', NEW.`id_beneficiario`, 'nacionalidad', NEW.`nacionalidad`, 'cedula', NEW.`cedula`, 'nombre_beneficiario', NEW.`nombre_beneficiario`, 'telefono', NEW.`telefono`, 'comunidad', NEW.`comunidad`, 'fecha_registro', NEW.`fecha_registro`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_beneficiarios_au_audit`//
CREATE TRIGGER `tr_beneficiarios_au_audit` AFTER UPDATE ON `beneficiarios`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'beneficiarios',
    v_accion,
    CAST(NEW.`id_beneficiario` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'beneficiarios'),
    CONCAT(v_accion, ' en beneficiarios [ID=', CAST(NEW.`id_beneficiario` AS CHAR), ']'),
    JSON_OBJECT('id_beneficiario', OLD.`id_beneficiario`, 'nacionalidad', OLD.`nacionalidad`, 'cedula', OLD.`cedula`, 'nombre_beneficiario', OLD.`nombre_beneficiario`, 'telefono', OLD.`telefono`, 'comunidad', OLD.`comunidad`, 'fecha_registro', OLD.`fecha_registro`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_beneficiario', NEW.`id_beneficiario`, 'nacionalidad', NEW.`nacionalidad`, 'cedula', NEW.`cedula`, 'nombre_beneficiario', NEW.`nombre_beneficiario`, 'telefono', NEW.`telefono`, 'comunidad', NEW.`comunidad`, 'fecha_registro', NEW.`fecha_registro`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_beneficiarios_bd_block_delete`//
CREATE TRIGGER `tr_beneficiarios_bd_block_delete` BEFORE DELETE ON `beneficiarios`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla beneficiarios. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_dependencias_ai_audit`//
CREATE TRIGGER `tr_dependencias_ai_audit` AFTER INSERT ON `dependencias`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'dependencias',
    'INSERT',
    CAST(NEW.`id_dependencia` AS CHAR),
    CONCAT('AUDIT INSERT ', 'dependencias'),
    CONCAT('Insercion en dependencias [ID=', CAST(NEW.`id_dependencia` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_dependencia', NEW.`id_dependencia`, 'nombre_dependencia', NEW.`nombre_dependencia`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_dependencias_au_audit`//
CREATE TRIGGER `tr_dependencias_au_audit` AFTER UPDATE ON `dependencias`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'dependencias',
    v_accion,
    CAST(NEW.`id_dependencia` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'dependencias'),
    CONCAT(v_accion, ' en dependencias [ID=', CAST(NEW.`id_dependencia` AS CHAR), ']'),
    JSON_OBJECT('id_dependencia', OLD.`id_dependencia`, 'nombre_dependencia', OLD.`nombre_dependencia`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_dependencia', NEW.`id_dependencia`, 'nombre_dependencia', NEW.`nombre_dependencia`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_dependencias_bd_block_delete`//
CREATE TRIGGER `tr_dependencias_bd_block_delete` BEFORE DELETE ON `dependencias`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla dependencias. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_empleados_ai_audit`//
CREATE TRIGGER `tr_empleados_ai_audit` AFTER INSERT ON `empleados`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'empleados',
    'INSERT',
    CAST(NEW.`id_empleado` AS CHAR),
    CONCAT('AUDIT INSERT ', 'empleados'),
    CONCAT('Insercion en empleados [ID=', CAST(NEW.`id_empleado` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_empleado', NEW.`id_empleado`, 'cedula', NEW.`cedula`, 'nombre', NEW.`nombre`, 'apellido', NEW.`apellido`, 'id_dependencia', NEW.`id_dependencia`, 'telefono', NEW.`telefono`, 'direccion', NEW.`direccion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_empleados_au_audit`//
CREATE TRIGGER `tr_empleados_au_audit` AFTER UPDATE ON `empleados`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'empleados',
    v_accion,
    CAST(NEW.`id_empleado` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'empleados'),
    CONCAT(v_accion, ' en empleados [ID=', CAST(NEW.`id_empleado` AS CHAR), ']'),
    JSON_OBJECT('id_empleado', OLD.`id_empleado`, 'cedula', OLD.`cedula`, 'nombre', OLD.`nombre`, 'apellido', OLD.`apellido`, 'id_dependencia', OLD.`id_dependencia`, 'telefono', OLD.`telefono`, 'direccion', OLD.`direccion`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_empleado', NEW.`id_empleado`, 'cedula', NEW.`cedula`, 'nombre', NEW.`nombre`, 'apellido', NEW.`apellido`, 'id_dependencia', NEW.`id_dependencia`, 'telefono', NEW.`telefono`, 'direccion', NEW.`direccion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_empleados_bd_block_delete`//
CREATE TRIGGER `tr_empleados_bd_block_delete` BEFORE DELETE ON `empleados`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla empleados. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_permisos_ai_audit`//
CREATE TRIGGER `tr_permisos_ai_audit` AFTER INSERT ON `permisos`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'permisos',
    'INSERT',
    CAST(NEW.`id_permiso` AS CHAR),
    CONCAT('AUDIT INSERT ', 'permisos'),
    CONCAT('Insercion en permisos [ID=', CAST(NEW.`id_permiso` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_permiso', NEW.`id_permiso`, 'nombre_permiso', NEW.`nombre_permiso`, 'descripcion', NEW.`descripcion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_permisos_au_audit`//
CREATE TRIGGER `tr_permisos_au_audit` AFTER UPDATE ON `permisos`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'permisos',
    v_accion,
    CAST(NEW.`id_permiso` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'permisos'),
    CONCAT(v_accion, ' en permisos [ID=', CAST(NEW.`id_permiso` AS CHAR), ']'),
    JSON_OBJECT('id_permiso', OLD.`id_permiso`, 'nombre_permiso', OLD.`nombre_permiso`, 'descripcion', OLD.`descripcion`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_permiso', NEW.`id_permiso`, 'nombre_permiso', NEW.`nombre_permiso`, 'descripcion', NEW.`descripcion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_permisos_bd_block_delete`//
CREATE TRIGGER `tr_permisos_bd_block_delete` BEFORE DELETE ON `permisos`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla permisos. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_reportes_traslado_ai_audit`//
CREATE TRIGGER `tr_reportes_traslado_ai_audit` AFTER INSERT ON `reportes_traslado`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'reportes_traslado',
    'INSERT',
    CAST(NEW.`id_reporte` AS CHAR),
    CONCAT('AUDIT INSERT ', 'reportes_traslado'),
    CONCAT('Insercion en reportes_traslado [ID=', CAST(NEW.`id_reporte` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_reporte', NEW.`id_reporte`, 'id_ayuda', NEW.`id_ayuda`, 'id_seguridad', NEW.`id_seguridad`, 'id_usuario_operador', NEW.`id_usuario_operador`, 'id_empleado_chofer', NEW.`id_empleado_chofer`, 'id_unidad', NEW.`id_unidad`, 'ticket_interno', NEW.`ticket_interno`, 'fecha_hora', NEW.`fecha_hora`, 'diagnostico_paciente', NEW.`diagnostico_paciente`, 'foto_evidencia', NEW.`foto_evidencia`, 'km_salida', NEW.`km_salida`, 'km_llegada', NEW.`km_llegada`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_reportes_traslado_au_audit`//
CREATE TRIGGER `tr_reportes_traslado_au_audit` AFTER UPDATE ON `reportes_traslado`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'reportes_traslado',
    v_accion,
    CAST(NEW.`id_reporte` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'reportes_traslado'),
    CONCAT(v_accion, ' en reportes_traslado [ID=', CAST(NEW.`id_reporte` AS CHAR), ']'),
    JSON_OBJECT('id_reporte', OLD.`id_reporte`, 'id_ayuda', OLD.`id_ayuda`, 'id_seguridad', OLD.`id_seguridad`, 'id_usuario_operador', OLD.`id_usuario_operador`, 'id_empleado_chofer', OLD.`id_empleado_chofer`, 'id_unidad', OLD.`id_unidad`, 'ticket_interno', OLD.`ticket_interno`, 'fecha_hora', OLD.`fecha_hora`, 'diagnostico_paciente', OLD.`diagnostico_paciente`, 'foto_evidencia', OLD.`foto_evidencia`, 'km_salida', OLD.`km_salida`, 'km_llegada', OLD.`km_llegada`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_reporte', NEW.`id_reporte`, 'id_ayuda', NEW.`id_ayuda`, 'id_seguridad', NEW.`id_seguridad`, 'id_usuario_operador', NEW.`id_usuario_operador`, 'id_empleado_chofer', NEW.`id_empleado_chofer`, 'id_unidad', NEW.`id_unidad`, 'ticket_interno', NEW.`ticket_interno`, 'fecha_hora', NEW.`fecha_hora`, 'diagnostico_paciente', NEW.`diagnostico_paciente`, 'foto_evidencia', NEW.`foto_evidencia`, 'km_salida', NEW.`km_salida`, 'km_llegada', NEW.`km_llegada`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_reportes_traslado_bd_block_delete`//
CREATE TRIGGER `tr_reportes_traslado_bd_block_delete` BEFORE DELETE ON `reportes_traslado`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla reportes_traslado. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_seguridad_ai_audit`//
CREATE TRIGGER `tr_seguridad_ai_audit` AFTER INSERT ON `seguridad`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'seguridad',
    'INSERT',
    CAST(NEW.`id_seguridad` AS CHAR),
    CONCAT('AUDIT INSERT ', 'seguridad'),
    CONCAT('Insercion en seguridad [ID=', CAST(NEW.`id_seguridad` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_seguridad', NEW.`id_seguridad`, 'ticket_interno', NEW.`ticket_interno`, 'id_beneficiario', NEW.`id_beneficiario`, 'id_usuario', NEW.`id_usuario`, 'tipo_seguridad', NEW.`tipo_seguridad`, 'tipo_solicitud', NEW.`tipo_solicitud`, 'fecha_seguridad', NEW.`fecha_seguridad`, 'descripcion', NEW.`descripcion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_seguridad_au_audit`//
CREATE TRIGGER `tr_seguridad_au_audit` AFTER UPDATE ON `seguridad`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'seguridad',
    v_accion,
    CAST(NEW.`id_seguridad` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'seguridad'),
    CONCAT(v_accion, ' en seguridad [ID=', CAST(NEW.`id_seguridad` AS CHAR), ']'),
    JSON_OBJECT('id_seguridad', OLD.`id_seguridad`, 'ticket_interno', OLD.`ticket_interno`, 'id_beneficiario', OLD.`id_beneficiario`, 'id_usuario', OLD.`id_usuario`, 'tipo_seguridad', OLD.`tipo_seguridad`, 'tipo_solicitud', OLD.`tipo_solicitud`, 'fecha_seguridad', OLD.`fecha_seguridad`, 'descripcion', OLD.`descripcion`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_seguridad', NEW.`id_seguridad`, 'ticket_interno', NEW.`ticket_interno`, 'id_beneficiario', NEW.`id_beneficiario`, 'id_usuario', NEW.`id_usuario`, 'tipo_seguridad', NEW.`tipo_seguridad`, 'tipo_solicitud', NEW.`tipo_solicitud`, 'fecha_seguridad', NEW.`fecha_seguridad`, 'descripcion', NEW.`descripcion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_seguridad_bd_block_delete`//
CREATE TRIGGER `tr_seguridad_bd_block_delete` BEFORE DELETE ON `seguridad`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla seguridad. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_servicios_publicos_ai_audit`//
CREATE TRIGGER `tr_servicios_publicos_ai_audit` AFTER INSERT ON `servicios_publicos`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'servicios_publicos',
    'INSERT',
    CAST(NEW.`id_servicio` AS CHAR),
    CONCAT('AUDIT INSERT ', 'servicios_publicos'),
    CONCAT('Insercion en servicios_publicos [ID=', CAST(NEW.`id_servicio` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_servicio', NEW.`id_servicio`, 'ticket_interno', NEW.`ticket_interno`, 'id_beneficiario', NEW.`id_beneficiario`, 'id_usuario', NEW.`id_usuario`, 'tipo_servicio', NEW.`tipo_servicio`, 'solicitud_servicio', NEW.`solicitud_servicio`, 'fecha_servicio', NEW.`fecha_servicio`, 'descripcion', NEW.`descripcion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_servicios_publicos_au_audit`//
CREATE TRIGGER `tr_servicios_publicos_au_audit` AFTER UPDATE ON `servicios_publicos`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'servicios_publicos',
    v_accion,
    CAST(NEW.`id_servicio` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'servicios_publicos'),
    CONCAT(v_accion, ' en servicios_publicos [ID=', CAST(NEW.`id_servicio` AS CHAR), ']'),
    JSON_OBJECT('id_servicio', OLD.`id_servicio`, 'ticket_interno', OLD.`ticket_interno`, 'id_beneficiario', OLD.`id_beneficiario`, 'id_usuario', OLD.`id_usuario`, 'tipo_servicio', OLD.`tipo_servicio`, 'solicitud_servicio', OLD.`solicitud_servicio`, 'fecha_servicio', OLD.`fecha_servicio`, 'descripcion', OLD.`descripcion`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_servicio', NEW.`id_servicio`, 'ticket_interno', NEW.`ticket_interno`, 'id_beneficiario', NEW.`id_beneficiario`, 'id_usuario', NEW.`id_usuario`, 'tipo_servicio', NEW.`tipo_servicio`, 'solicitud_servicio', NEW.`solicitud_servicio`, 'fecha_servicio', NEW.`fecha_servicio`, 'descripcion', NEW.`descripcion`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_servicios_publicos_bd_block_delete`//
CREATE TRIGGER `tr_servicios_publicos_bd_block_delete` BEFORE DELETE ON `servicios_publicos`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla servicios_publicos. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_unidades_ai_audit`//
CREATE TRIGGER `tr_unidades_ai_audit` AFTER INSERT ON `unidades`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'unidades',
    'INSERT',
    CAST(NEW.`id_unidad` AS CHAR),
    CONCAT('AUDIT INSERT ', 'unidades'),
    CONCAT('Insercion en unidades [ID=', CAST(NEW.`id_unidad` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_unidad', NEW.`id_unidad`, 'codigo_unidad', NEW.`codigo_unidad`, 'descripcion', NEW.`descripcion`, 'placa', NEW.`placa`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_unidades_au_audit`//
CREATE TRIGGER `tr_unidades_au_audit` AFTER UPDATE ON `unidades`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'unidades',
    v_accion,
    CAST(NEW.`id_unidad` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'unidades'),
    CONCAT(v_accion, ' en unidades [ID=', CAST(NEW.`id_unidad` AS CHAR), ']'),
    JSON_OBJECT('id_unidad', OLD.`id_unidad`, 'codigo_unidad', OLD.`codigo_unidad`, 'descripcion', OLD.`descripcion`, 'placa', OLD.`placa`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_unidad', NEW.`id_unidad`, 'codigo_unidad', NEW.`codigo_unidad`, 'descripcion', NEW.`descripcion`, 'placa', NEW.`placa`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_unidades_bd_block_delete`//
CREATE TRIGGER `tr_unidades_bd_block_delete` BEFORE DELETE ON `unidades`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla unidades. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_usuarios_ai_audit`//
CREATE TRIGGER `tr_usuarios_ai_audit` AFTER INSERT ON `usuarios`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'usuarios',
    'INSERT',
    CAST(NEW.`id_usuario` AS CHAR),
    CONCAT('AUDIT INSERT ', 'usuarios'),
    CONCAT('Insercion en usuarios [ID=', CAST(NEW.`id_usuario` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_usuario', NEW.`id_usuario`, 'id_empleado', NEW.`id_empleado`, 'usuario', NEW.`usuario`, 'password', NEW.`password`, 'rol', NEW.`rol`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_usuarios_au_audit`//
CREATE TRIGGER `tr_usuarios_au_audit` AFTER UPDATE ON `usuarios`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'usuarios',
    v_accion,
    CAST(NEW.`id_usuario` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'usuarios'),
    CONCAT(v_accion, ' en usuarios [ID=', CAST(NEW.`id_usuario` AS CHAR), ']'),
    JSON_OBJECT('id_usuario', OLD.`id_usuario`, 'id_empleado', OLD.`id_empleado`, 'usuario', OLD.`usuario`, 'password', OLD.`password`, 'rol', OLD.`rol`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_usuario', NEW.`id_usuario`, 'id_empleado', NEW.`id_empleado`, 'usuario', NEW.`usuario`, 'password', NEW.`password`, 'rol', NEW.`rol`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_usuarios_bd_block_delete`//
CREATE TRIGGER `tr_usuarios_bd_block_delete` BEFORE DELETE ON `usuarios`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuarios. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_usuario_permisos_ai_audit`//
CREATE TRIGGER `tr_usuario_permisos_ai_audit` AFTER INSERT ON `usuario_permisos`
FOR EACH ROW BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'usuario_permisos',
    'INSERT',
    CAST(NEW.`id_usuario_permiso` AS CHAR),
    CONCAT('AUDIT INSERT ', 'usuario_permisos'),
    CONCAT('Insercion en usuario_permisos [ID=', CAST(NEW.`id_usuario_permiso` AS CHAR), ']'),
    NULL,
    JSON_OBJECT('id_usuario_permiso', NEW.`id_usuario_permiso`, 'id_usuario', NEW.`id_usuario`, 'id_permiso', NEW.`id_permiso`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_usuario_permisos_au_audit`//
CREATE TRIGGER `tr_usuario_permisos_au_audit` AFTER UPDATE ON `usuario_permisos`
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);
  IF OLD.`estado` = 1 AND NEW.`estado` = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.`estado` = 0 AND NEW.`estado` = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, ipaddr, moment, fecha_evento)
  VALUES (
    NULL,
    'usuario_permisos',
    v_accion,
    CAST(NEW.`id_usuario_permiso` AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'usuario_permisos'),
    CONCAT(v_accion, ' en usuario_permisos [ID=', CAST(NEW.`id_usuario_permiso` AS CHAR), ']'),
    JSON_OBJECT('id_usuario_permiso', OLD.`id_usuario_permiso`, 'id_usuario', OLD.`id_usuario`, 'id_permiso', OLD.`id_permiso`, 'estado', OLD.`estado`),
    JSON_OBJECT('id_usuario_permiso', NEW.`id_usuario_permiso`, 'id_usuario', NEW.`id_usuario`, 'id_permiso', NEW.`id_permiso`, 'estado', NEW.`estado`),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

DROP TRIGGER IF EXISTS `tr_usuario_permisos_bd_block_delete`//
CREATE TRIGGER `tr_usuario_permisos_bd_block_delete` BEFORE DELETE ON `usuario_permisos`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuario_permisos. Use estado=0 para softdelete.';
END//

DROP TRIGGER IF EXISTS `tr_bitacora_bi_defaults`//
CREATE TRIGGER `tr_bitacora_bi_defaults` BEFORE INSERT ON `bitacora`
FOR EACH ROW BEGIN
  SET NEW.accion = COALESCE(NULLIF(NEW.accion, ''), 'LEGACY');
  SET NEW.tabla_afectada = COALESCE(NULLIF(NEW.tabla_afectada, ''), 'SISTEMA');
  SET NEW.usuario_bd = COALESCE(NULLIF(NEW.usuario_bd, ''), CURRENT_USER());
  SET NEW.fecha_evento = COALESCE(NEW.fecha_evento, NOW());
END//

DROP TRIGGER IF EXISTS `tr_bitacora_bu_lock`//
CREATE TRIGGER `tr_bitacora_bu_lock` BEFORE UPDATE ON `bitacora`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bitacora inmutable: no se permite UPDATE.';
END//

DROP TRIGGER IF EXISTS `tr_bitacora_bd_lock`//
CREATE TRIGGER `tr_bitacora_bd_lock` BEFORE DELETE ON `bitacora`
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bitacora inmutable: no se permite DELETE.';
END//

DELIMITER ;
