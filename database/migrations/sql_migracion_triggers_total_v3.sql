USE sala03v2_4;
SET SESSION sql_safe_updates = 0;
SET SESSION group_concat_max_len = 1000000;

DROP TRIGGER IF EXISTS tr_asignaciones_unidades_choferes_ai_audit;
DROP TRIGGER IF EXISTS tr_asignaciones_unidades_choferes_au_audit;
DROP TRIGGER IF EXISTS tr_choferes_ambulancia_ai_audit;
DROP TRIGGER IF EXISTS tr_choferes_ambulancia_au_audit;
DROP TRIGGER IF EXISTS tr_despachos_unidades_ai_audit;
DROP TRIGGER IF EXISTS tr_despachos_unidades_au_audit;
DROP TRIGGER IF EXISTS tr_tipos_seguridad_emergencia_ai_audit;
DROP TRIGGER IF EXISTS tr_tipos_seguridad_emergencia_au_audit;
DROP TABLE IF EXISTS auditoria;

DELIMITER //
DROP TRIGGER IF EXISTS tr_asignaciones_unidades_choferes_ai_audit//
CREATE TRIGGER tr_asignaciones_unidades_choferes_ai_audit AFTER INSERT ON asignaciones_unidades_choferes FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'asignaciones_unidades_choferes', 'INSERT', CAST(NEW.id_asignacion_unidad_chofer AS CHAR), 'INSERT en asignaciones_unidades_choferes', 'Se inserto un registro en asignaciones_unidades_choferes', NULL, JSON_OBJECT('id_asignacion_unidad_chofer', NEW.id_asignacion_unidad_chofer, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'fecha_inicio', NEW.fecha_inicio, 'fecha_fin', NEW.fecha_fin, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_asignaciones_unidades_choferes_au_audit//
CREATE TRIGGER tr_asignaciones_unidades_choferes_au_audit AFTER UPDATE ON asignaciones_unidades_choferes FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'asignaciones_unidades_choferes', 'UPDATE', CAST(NEW.id_asignacion_unidad_chofer AS CHAR), 'UPDATE en asignaciones_unidades_choferes', 'Se actualizo un registro en asignaciones_unidades_choferes', JSON_OBJECT('id_asignacion_unidad_chofer', OLD.id_asignacion_unidad_chofer, 'id_unidad', OLD.id_unidad, 'id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'fecha_inicio', OLD.fecha_inicio, 'fecha_fin', OLD.fecha_fin, 'observaciones', OLD.observaciones, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_asignacion_unidad_chofer', NEW.id_asignacion_unidad_chofer, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'fecha_inicio', NEW.fecha_inicio, 'fecha_fin', NEW.fecha_fin, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_asignaciones_unidades_choferes_bd_block_delete//
CREATE TRIGGER tr_asignaciones_unidades_choferes_bd_block_delete BEFORE DELETE ON asignaciones_unidades_choferes FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla asignaciones_unidades_choferes. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_ayuda_social_ai_audit//
CREATE TRIGGER tr_ayuda_social_ai_audit AFTER INSERT ON ayuda_social FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'ayuda_social', 'INSERT', CAST(NEW.id_ayuda AS CHAR), 'INSERT en ayuda_social', 'Se inserto un registro en ayuda_social', NULL, JSON_OBJECT('id_ayuda', NEW.id_ayuda, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'id_solicitud_ayuda_social', NEW.id_solicitud_ayuda_social, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_ayuda', NEW.tipo_ayuda, 'solicitud_ayuda', NEW.solicitud_ayuda, 'fecha_ayuda', NEW.fecha_ayuda, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_ayuda_social_au_audit//
CREATE TRIGGER tr_ayuda_social_au_audit AFTER UPDATE ON ayuda_social FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'ayuda_social', 'UPDATE', CAST(NEW.id_ayuda AS CHAR), 'UPDATE en ayuda_social', 'Se actualizo un registro en ayuda_social', JSON_OBJECT('id_ayuda', OLD.id_ayuda, 'ticket_interno', OLD.ticket_interno, 'id_beneficiario', OLD.id_beneficiario, 'id_usuario', OLD.id_usuario, 'id_tipo_ayuda_social', OLD.id_tipo_ayuda_social, 'id_solicitud_ayuda_social', OLD.id_solicitud_ayuda_social, 'id_estado_solicitud', OLD.id_estado_solicitud, 'tipo_ayuda', OLD.tipo_ayuda, 'solicitud_ayuda', OLD.solicitud_ayuda, 'fecha_ayuda', OLD.fecha_ayuda, 'descripcion', OLD.descripcion, 'estado', OLD.estado), JSON_OBJECT('id_ayuda', NEW.id_ayuda, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'id_solicitud_ayuda_social', NEW.id_solicitud_ayuda_social, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_ayuda', NEW.tipo_ayuda, 'solicitud_ayuda', NEW.solicitud_ayuda, 'fecha_ayuda', NEW.fecha_ayuda, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_ayuda_social_bd_block_delete//
CREATE TRIGGER tr_ayuda_social_bd_block_delete BEFORE DELETE ON ayuda_social FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla ayuda_social. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_beneficiarios_ai_audit//
CREATE TRIGGER tr_beneficiarios_ai_audit AFTER INSERT ON beneficiarios FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'beneficiarios', 'INSERT', CAST(NEW.id_beneficiario AS CHAR), 'INSERT en beneficiarios', 'Se inserto un registro en beneficiarios', NULL, JSON_OBJECT('id_beneficiario', NEW.id_beneficiario, 'nacionalidad', NEW.nacionalidad, 'cedula', NEW.cedula, 'nombre_beneficiario', NEW.nombre_beneficiario, 'telefono', NEW.telefono, 'id_comunidad', NEW.id_comunidad, 'comunidad', NEW.comunidad, 'fecha_registro', NEW.fecha_registro, 'hora_registro_12h', NEW.hora_registro_12h, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_beneficiarios_au_audit//
CREATE TRIGGER tr_beneficiarios_au_audit AFTER UPDATE ON beneficiarios FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'beneficiarios', 'UPDATE', CAST(NEW.id_beneficiario AS CHAR), 'UPDATE en beneficiarios', 'Se actualizo un registro en beneficiarios', JSON_OBJECT('id_beneficiario', OLD.id_beneficiario, 'nacionalidad', OLD.nacionalidad, 'cedula', OLD.cedula, 'nombre_beneficiario', OLD.nombre_beneficiario, 'telefono', OLD.telefono, 'id_comunidad', OLD.id_comunidad, 'comunidad', OLD.comunidad, 'fecha_registro', OLD.fecha_registro, 'hora_registro_12h', OLD.hora_registro_12h, 'estado', OLD.estado), JSON_OBJECT('id_beneficiario', NEW.id_beneficiario, 'nacionalidad', NEW.nacionalidad, 'cedula', NEW.cedula, 'nombre_beneficiario', NEW.nombre_beneficiario, 'telefono', NEW.telefono, 'id_comunidad', NEW.id_comunidad, 'comunidad', NEW.comunidad, 'fecha_registro', NEW.fecha_registro, 'hora_registro_12h', NEW.hora_registro_12h, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_beneficiarios_bd_block_delete//
CREATE TRIGGER tr_beneficiarios_bd_block_delete BEFORE DELETE ON beneficiarios FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla beneficiarios. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_choferes_ambulancia_ai_audit//
CREATE TRIGGER tr_choferes_ambulancia_ai_audit AFTER INSERT ON choferes_ambulancia FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'choferes_ambulancia', 'INSERT', CAST(NEW.id_chofer_ambulancia AS CHAR), 'INSERT en choferes_ambulancia', 'Se inserto un registro en choferes_ambulancia', NULL, JSON_OBJECT('id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_empleado', NEW.id_empleado, 'numero_licencia', NEW.numero_licencia, 'categoria_licencia', NEW.categoria_licencia, 'vencimiento_licencia', NEW.vencimiento_licencia, 'contacto_emergencia', NEW.contacto_emergencia, 'telefono_contacto_emergencia', NEW.telefono_contacto_emergencia, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_choferes_ambulancia_au_audit//
CREATE TRIGGER tr_choferes_ambulancia_au_audit AFTER UPDATE ON choferes_ambulancia FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'choferes_ambulancia', 'UPDATE', CAST(NEW.id_chofer_ambulancia AS CHAR), 'UPDATE en choferes_ambulancia', 'Se actualizo un registro en choferes_ambulancia', JSON_OBJECT('id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'id_empleado', OLD.id_empleado, 'numero_licencia', OLD.numero_licencia, 'categoria_licencia', OLD.categoria_licencia, 'vencimiento_licencia', OLD.vencimiento_licencia, 'contacto_emergencia', OLD.contacto_emergencia, 'telefono_contacto_emergencia', OLD.telefono_contacto_emergencia, 'observaciones', OLD.observaciones, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_empleado', NEW.id_empleado, 'numero_licencia', NEW.numero_licencia, 'categoria_licencia', NEW.categoria_licencia, 'vencimiento_licencia', NEW.vencimiento_licencia, 'contacto_emergencia', NEW.contacto_emergencia, 'telefono_contacto_emergencia', NEW.telefono_contacto_emergencia, 'observaciones', NEW.observaciones, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_choferes_ambulancia_bd_block_delete//
CREATE TRIGGER tr_choferes_ambulancia_bd_block_delete BEFORE DELETE ON choferes_ambulancia FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla choferes_ambulancia. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_comunidades_ai_audit//
CREATE TRIGGER tr_comunidades_ai_audit AFTER INSERT ON comunidades FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'comunidades', 'INSERT', CAST(NEW.id_comunidad AS CHAR), 'INSERT en comunidades', 'Se inserto un registro en comunidades', NULL, JSON_OBJECT('id_comunidad', NEW.id_comunidad, 'nombre_comunidad', NEW.nombre_comunidad, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'hora_registro_12h', NEW.hora_registro_12h), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_comunidades_au_audit//
CREATE TRIGGER tr_comunidades_au_audit AFTER UPDATE ON comunidades FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'comunidades', 'UPDATE', CAST(NEW.id_comunidad AS CHAR), 'UPDATE en comunidades', 'Se actualizo un registro en comunidades', JSON_OBJECT('id_comunidad', OLD.id_comunidad, 'nombre_comunidad', OLD.nombre_comunidad, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro, 'hora_registro_12h', OLD.hora_registro_12h), JSON_OBJECT('id_comunidad', NEW.id_comunidad, 'nombre_comunidad', NEW.nombre_comunidad, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro, 'hora_registro_12h', NEW.hora_registro_12h), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_comunidades_bd_block_delete//
CREATE TRIGGER tr_comunidades_bd_block_delete BEFORE DELETE ON comunidades FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla comunidades. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_configuracion_smtp_ai_audit//
CREATE TRIGGER tr_configuracion_smtp_ai_audit AFTER INSERT ON configuracion_smtp FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'configuracion_smtp', 'INSERT', CAST(NEW.id_configuracion_smtp AS CHAR), 'INSERT en configuracion_smtp', 'Se inserto un registro en configuracion_smtp', NULL, JSON_OBJECT('id_configuracion_smtp', NEW.id_configuracion_smtp, 'host', NEW.host, 'puerto', NEW.puerto, 'usuario', NEW.usuario, 'clave', NEW.clave, 'correo_remitente', NEW.correo_remitente, 'nombre_remitente', NEW.nombre_remitente, 'usar_tls', NEW.usar_tls, 'estado', NEW.estado, 'id_usuario_actualiza', NEW.id_usuario_actualiza, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_configuracion_smtp_au_audit//
CREATE TRIGGER tr_configuracion_smtp_au_audit AFTER UPDATE ON configuracion_smtp FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'configuracion_smtp', 'UPDATE', CAST(NEW.id_configuracion_smtp AS CHAR), 'UPDATE en configuracion_smtp', 'Se actualizo un registro en configuracion_smtp', JSON_OBJECT('id_configuracion_smtp', OLD.id_configuracion_smtp, 'host', OLD.host, 'puerto', OLD.puerto, 'usuario', OLD.usuario, 'clave', OLD.clave, 'correo_remitente', OLD.correo_remitente, 'nombre_remitente', OLD.nombre_remitente, 'usar_tls', OLD.usar_tls, 'estado', OLD.estado, 'id_usuario_actualiza', OLD.id_usuario_actualiza, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_configuracion_smtp', NEW.id_configuracion_smtp, 'host', NEW.host, 'puerto', NEW.puerto, 'usuario', NEW.usuario, 'clave', NEW.clave, 'correo_remitente', NEW.correo_remitente, 'nombre_remitente', NEW.nombre_remitente, 'usar_tls', NEW.usar_tls, 'estado', NEW.estado, 'id_usuario_actualiza', NEW.id_usuario_actualiza, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_configuracion_smtp_bd_block_delete//
CREATE TRIGGER tr_configuracion_smtp_bd_block_delete BEFORE DELETE ON configuracion_smtp FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla configuracion_smtp. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_dependencias_ai_audit//
CREATE TRIGGER tr_dependencias_ai_audit AFTER INSERT ON dependencias FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'dependencias', 'INSERT', CAST(NEW.id_dependencia AS CHAR), 'INSERT en dependencias', 'Se inserto un registro en dependencias', NULL, JSON_OBJECT('id_dependencia', NEW.id_dependencia, 'nombre_dependencia', NEW.nombre_dependencia, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_dependencias_au_audit//
CREATE TRIGGER tr_dependencias_au_audit AFTER UPDATE ON dependencias FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'dependencias', 'UPDATE', CAST(NEW.id_dependencia AS CHAR), 'UPDATE en dependencias', 'Se actualizo un registro en dependencias', JSON_OBJECT('id_dependencia', OLD.id_dependencia, 'nombre_dependencia', OLD.nombre_dependencia, 'estado', OLD.estado), JSON_OBJECT('id_dependencia', NEW.id_dependencia, 'nombre_dependencia', NEW.nombre_dependencia, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_dependencias_bd_block_delete//
CREATE TRIGGER tr_dependencias_bd_block_delete BEFORE DELETE ON dependencias FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla dependencias. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_despachos_unidades_ai_audit//
CREATE TRIGGER tr_despachos_unidades_ai_audit AFTER INSERT ON despachos_unidades FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'despachos_unidades', 'INSERT', CAST(NEW.id_despacho_unidad AS CHAR), 'INSERT en despachos_unidades', 'Se inserto un registro en despachos_unidades', NULL, JSON_OBJECT('id_despacho_unidad', NEW.id_despacho_unidad, 'id_seguridad', NEW.id_seguridad, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_usuario_asigna', NEW.id_usuario_asigna, 'modo_asignacion', NEW.modo_asignacion, 'estado_despacho', NEW.estado_despacho, 'fecha_asignacion', NEW.fecha_asignacion, 'fecha_cierre', NEW.fecha_cierre, 'ubicacion_salida', NEW.ubicacion_salida, 'ubicacion_evento', NEW.ubicacion_evento, 'ubicacion_cierre', NEW.ubicacion_cierre, 'observaciones', NEW.observaciones, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_despachos_unidades_au_audit//
CREATE TRIGGER tr_despachos_unidades_au_audit AFTER UPDATE ON despachos_unidades FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'despachos_unidades', 'UPDATE', CAST(NEW.id_despacho_unidad AS CHAR), 'UPDATE en despachos_unidades', 'Se actualizo un registro en despachos_unidades', JSON_OBJECT('id_despacho_unidad', OLD.id_despacho_unidad, 'id_seguridad', OLD.id_seguridad, 'id_unidad', OLD.id_unidad, 'id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'id_usuario_asigna', OLD.id_usuario_asigna, 'modo_asignacion', OLD.modo_asignacion, 'estado_despacho', OLD.estado_despacho, 'fecha_asignacion', OLD.fecha_asignacion, 'fecha_cierre', OLD.fecha_cierre, 'ubicacion_salida', OLD.ubicacion_salida, 'ubicacion_evento', OLD.ubicacion_evento, 'ubicacion_cierre', OLD.ubicacion_cierre, 'observaciones', OLD.observaciones, 'fecha_registro', OLD.fecha_registro, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_despacho_unidad', NEW.id_despacho_unidad, 'id_seguridad', NEW.id_seguridad, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_usuario_asigna', NEW.id_usuario_asigna, 'modo_asignacion', NEW.modo_asignacion, 'estado_despacho', NEW.estado_despacho, 'fecha_asignacion', NEW.fecha_asignacion, 'fecha_cierre', NEW.fecha_cierre, 'ubicacion_salida', NEW.ubicacion_salida, 'ubicacion_evento', NEW.ubicacion_evento, 'ubicacion_cierre', NEW.ubicacion_cierre, 'observaciones', NEW.observaciones, 'fecha_registro', NEW.fecha_registro, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_despachos_unidades_bd_block_delete//
CREATE TRIGGER tr_despachos_unidades_bd_block_delete BEFORE DELETE ON despachos_unidades FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla despachos_unidades. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_empleados_ai_audit//
CREATE TRIGGER tr_empleados_ai_audit AFTER INSERT ON empleados FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'empleados', 'INSERT', CAST(NEW.id_empleado AS CHAR), 'INSERT en empleados', 'Se inserto un registro en empleados', NULL, JSON_OBJECT('id_empleado', NEW.id_empleado, 'cedula', NEW.cedula, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'id_dependencia', NEW.id_dependencia, 'telefono', NEW.telefono, 'correo', NEW.correo, 'direccion', NEW.direccion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_empleados_au_audit//
CREATE TRIGGER tr_empleados_au_audit AFTER UPDATE ON empleados FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'empleados', 'UPDATE', CAST(NEW.id_empleado AS CHAR), 'UPDATE en empleados', 'Se actualizo un registro en empleados', JSON_OBJECT('id_empleado', OLD.id_empleado, 'cedula', OLD.cedula, 'nombre', OLD.nombre, 'apellido', OLD.apellido, 'id_dependencia', OLD.id_dependencia, 'telefono', OLD.telefono, 'correo', OLD.correo, 'direccion', OLD.direccion, 'estado', OLD.estado), JSON_OBJECT('id_empleado', NEW.id_empleado, 'cedula', NEW.cedula, 'nombre', NEW.nombre, 'apellido', NEW.apellido, 'id_dependencia', NEW.id_dependencia, 'telefono', NEW.telefono, 'correo', NEW.correo, 'direccion', NEW.direccion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_empleados_bd_block_delete//
CREATE TRIGGER tr_empleados_bd_block_delete BEFORE DELETE ON empleados FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla empleados. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_estados_solicitudes_ai_audit//
CREATE TRIGGER tr_estados_solicitudes_ai_audit AFTER INSERT ON estados_solicitudes FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'estados_solicitudes', 'INSERT', CAST(NEW.id_estado_solicitud AS CHAR), 'INSERT en estados_solicitudes', 'Se inserto un registro en estados_solicitudes', NULL, JSON_OBJECT('id_estado_solicitud', NEW.id_estado_solicitud, 'codigo_estado', NEW.codigo_estado, 'nombre_estado', NEW.nombre_estado, 'descripcion', NEW.descripcion, 'clase_badge', NEW.clase_badge, 'es_atendida', NEW.es_atendida, 'orden_visual', NEW.orden_visual, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_estados_solicitudes_au_audit//
CREATE TRIGGER tr_estados_solicitudes_au_audit AFTER UPDATE ON estados_solicitudes FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'estados_solicitudes', 'UPDATE', CAST(NEW.id_estado_solicitud AS CHAR), 'UPDATE en estados_solicitudes', 'Se actualizo un registro en estados_solicitudes', JSON_OBJECT('id_estado_solicitud', OLD.id_estado_solicitud, 'codigo_estado', OLD.codigo_estado, 'nombre_estado', OLD.nombre_estado, 'descripcion', OLD.descripcion, 'clase_badge', OLD.clase_badge, 'es_atendida', OLD.es_atendida, 'orden_visual', OLD.orden_visual, 'estado', OLD.estado), JSON_OBJECT('id_estado_solicitud', NEW.id_estado_solicitud, 'codigo_estado', NEW.codigo_estado, 'nombre_estado', NEW.nombre_estado, 'descripcion', NEW.descripcion, 'clase_badge', NEW.clase_badge, 'es_atendida', NEW.es_atendida, 'orden_visual', NEW.orden_visual, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_estados_solicitudes_bd_block_delete//
CREATE TRIGGER tr_estados_solicitudes_bd_block_delete BEFORE DELETE ON estados_solicitudes FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla estados_solicitudes. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_permisos_ai_audit//
CREATE TRIGGER tr_permisos_ai_audit AFTER INSERT ON permisos FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'permisos', 'INSERT', CAST(NEW.id_permiso AS CHAR), 'INSERT en permisos', 'Se inserto un registro en permisos', NULL, JSON_OBJECT('id_permiso', NEW.id_permiso, 'nombre_permiso', NEW.nombre_permiso, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_permisos_au_audit//
CREATE TRIGGER tr_permisos_au_audit AFTER UPDATE ON permisos FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'permisos', 'UPDATE', CAST(NEW.id_permiso AS CHAR), 'UPDATE en permisos', 'Se actualizo un registro en permisos', JSON_OBJECT('id_permiso', OLD.id_permiso, 'nombre_permiso', OLD.nombre_permiso, 'descripcion', OLD.descripcion, 'estado', OLD.estado), JSON_OBJECT('id_permiso', NEW.id_permiso, 'nombre_permiso', NEW.nombre_permiso, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_permisos_bd_block_delete//
CREATE TRIGGER tr_permisos_bd_block_delete BEFORE DELETE ON permisos FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla permisos. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_reportes_solicitudes_ambulancia_ai_audit//
CREATE TRIGGER tr_reportes_solicitudes_ambulancia_ai_audit AFTER INSERT ON reportes_solicitudes_ambulancia FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_solicitudes_ambulancia', 'INSERT', CAST(NEW.id_reporte_solicitud AS CHAR), 'INSERT en reportes_solicitudes_ambulancia', 'Se inserto un registro en reportes_solicitudes_ambulancia', NULL, JSON_OBJECT('id_reporte_solicitud', NEW.id_reporte_solicitud, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'tipo_reporte', NEW.tipo_reporte, 'nombre_archivo', NEW.nombre_archivo, 'ruta_archivo', NEW.ruta_archivo, 'estado_envio', NEW.estado_envio, 'correo_destino', NEW.correo_destino, 'fecha_envio', NEW.fecha_envio, 'detalle_envio', NEW.detalle_envio, 'id_usuario_genera', NEW.id_usuario_genera, 'fecha_generacion', NEW.fecha_generacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_reportes_solicitudes_ambulancia_au_audit//
CREATE TRIGGER tr_reportes_solicitudes_ambulancia_au_audit AFTER UPDATE ON reportes_solicitudes_ambulancia FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_solicitudes_ambulancia', 'UPDATE', CAST(NEW.id_reporte_solicitud AS CHAR), 'UPDATE en reportes_solicitudes_ambulancia', 'Se actualizo un registro en reportes_solicitudes_ambulancia', JSON_OBJECT('id_reporte_solicitud', OLD.id_reporte_solicitud, 'id_seguridad', OLD.id_seguridad, 'id_despacho_unidad', OLD.id_despacho_unidad, 'tipo_reporte', OLD.tipo_reporte, 'nombre_archivo', OLD.nombre_archivo, 'ruta_archivo', OLD.ruta_archivo, 'estado_envio', OLD.estado_envio, 'correo_destino', OLD.correo_destino, 'fecha_envio', OLD.fecha_envio, 'detalle_envio', OLD.detalle_envio, 'id_usuario_genera', OLD.id_usuario_genera, 'fecha_generacion', OLD.fecha_generacion, 'estado', OLD.estado), JSON_OBJECT('id_reporte_solicitud', NEW.id_reporte_solicitud, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'tipo_reporte', NEW.tipo_reporte, 'nombre_archivo', NEW.nombre_archivo, 'ruta_archivo', NEW.ruta_archivo, 'estado_envio', NEW.estado_envio, 'correo_destino', NEW.correo_destino, 'fecha_envio', NEW.fecha_envio, 'detalle_envio', NEW.detalle_envio, 'id_usuario_genera', NEW.id_usuario_genera, 'fecha_generacion', NEW.fecha_generacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_reportes_solicitudes_ambulancia_bd_block_delete//
CREATE TRIGGER tr_reportes_solicitudes_ambulancia_bd_block_delete BEFORE DELETE ON reportes_solicitudes_ambulancia FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla reportes_solicitudes_ambulancia. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_reportes_traslado_ai_audit//
CREATE TRIGGER tr_reportes_traslado_ai_audit AFTER INSERT ON reportes_traslado FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_traslado', 'INSERT', CAST(NEW.id_reporte AS CHAR), 'INSERT en reportes_traslado', 'Se inserto un registro en reportes_traslado', NULL, JSON_OBJECT('id_reporte', NEW.id_reporte, 'id_ayuda', NEW.id_ayuda, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'id_usuario_operador', NEW.id_usuario_operador, 'id_empleado_chofer', NEW.id_empleado_chofer, 'id_unidad', NEW.id_unidad, 'ticket_interno', NEW.ticket_interno, 'fecha_hora', NEW.fecha_hora, 'diagnostico_paciente', NEW.diagnostico_paciente, 'foto_evidencia', NEW.foto_evidencia, 'km_salida', NEW.km_salida, 'km_llegada', NEW.km_llegada, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_reportes_traslado_au_audit//
CREATE TRIGGER tr_reportes_traslado_au_audit AFTER UPDATE ON reportes_traslado FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'reportes_traslado', 'UPDATE', CAST(NEW.id_reporte AS CHAR), 'UPDATE en reportes_traslado', 'Se actualizo un registro en reportes_traslado', JSON_OBJECT('id_reporte', OLD.id_reporte, 'id_ayuda', OLD.id_ayuda, 'id_seguridad', OLD.id_seguridad, 'id_despacho_unidad', OLD.id_despacho_unidad, 'id_usuario_operador', OLD.id_usuario_operador, 'id_empleado_chofer', OLD.id_empleado_chofer, 'id_unidad', OLD.id_unidad, 'ticket_interno', OLD.ticket_interno, 'fecha_hora', OLD.fecha_hora, 'diagnostico_paciente', OLD.diagnostico_paciente, 'foto_evidencia', OLD.foto_evidencia, 'km_salida', OLD.km_salida, 'km_llegada', OLD.km_llegada, 'estado', OLD.estado), JSON_OBJECT('id_reporte', NEW.id_reporte, 'id_ayuda', NEW.id_ayuda, 'id_seguridad', NEW.id_seguridad, 'id_despacho_unidad', NEW.id_despacho_unidad, 'id_usuario_operador', NEW.id_usuario_operador, 'id_empleado_chofer', NEW.id_empleado_chofer, 'id_unidad', NEW.id_unidad, 'ticket_interno', NEW.ticket_interno, 'fecha_hora', NEW.fecha_hora, 'diagnostico_paciente', NEW.diagnostico_paciente, 'foto_evidencia', NEW.foto_evidencia, 'km_salida', NEW.km_salida, 'km_llegada', NEW.km_llegada, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_reportes_traslado_bd_block_delete//
CREATE TRIGGER tr_reportes_traslado_bd_block_delete BEFORE DELETE ON reportes_traslado FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla reportes_traslado. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_seguimientos_solicitudes_ai_audit//
CREATE TRIGGER tr_seguimientos_solicitudes_ai_audit AFTER INSERT ON seguimientos_solicitudes FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguimientos_solicitudes', 'INSERT', CAST(NEW.id_seguimiento_solicitud AS CHAR), 'INSERT en seguimientos_solicitudes', 'Se inserto un registro en seguimientos_solicitudes', NULL, JSON_OBJECT('id_seguimiento_solicitud', NEW.id_seguimiento_solicitud, 'modulo', NEW.modulo, 'id_referencia', NEW.id_referencia, 'id_estado_solicitud', NEW.id_estado_solicitud, 'id_usuario', NEW.id_usuario, 'fecha_gestion', NEW.fecha_gestion, 'observacion', NEW.observacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_seguimientos_solicitudes_au_audit//
CREATE TRIGGER tr_seguimientos_solicitudes_au_audit AFTER UPDATE ON seguimientos_solicitudes FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguimientos_solicitudes', 'UPDATE', CAST(NEW.id_seguimiento_solicitud AS CHAR), 'UPDATE en seguimientos_solicitudes', 'Se actualizo un registro en seguimientos_solicitudes', JSON_OBJECT('id_seguimiento_solicitud', OLD.id_seguimiento_solicitud, 'modulo', OLD.modulo, 'id_referencia', OLD.id_referencia, 'id_estado_solicitud', OLD.id_estado_solicitud, 'id_usuario', OLD.id_usuario, 'fecha_gestion', OLD.fecha_gestion, 'observacion', OLD.observacion, 'estado', OLD.estado), JSON_OBJECT('id_seguimiento_solicitud', NEW.id_seguimiento_solicitud, 'modulo', NEW.modulo, 'id_referencia', NEW.id_referencia, 'id_estado_solicitud', NEW.id_estado_solicitud, 'id_usuario', NEW.id_usuario, 'fecha_gestion', NEW.fecha_gestion, 'observacion', NEW.observacion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_seguimientos_solicitudes_bd_block_delete//
CREATE TRIGGER tr_seguimientos_solicitudes_bd_block_delete BEFORE DELETE ON seguimientos_solicitudes FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla seguimientos_solicitudes. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_seguridad_ai_audit//
CREATE TRIGGER tr_seguridad_ai_audit AFTER INSERT ON seguridad FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguridad', 'INSERT', CAST(NEW.id_seguridad AS CHAR), 'INSERT en seguridad', 'Se inserto un registro en seguridad', NULL, JSON_OBJECT('id_seguridad', NEW.id_seguridad, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_seguridad', NEW.id_tipo_seguridad, 'id_solicitud_seguridad', NEW.id_solicitud_seguridad, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_seguridad', NEW.tipo_seguridad, 'tipo_solicitud', NEW.tipo_solicitud, 'fecha_seguridad', NEW.fecha_seguridad, 'descripcion', NEW.descripcion, 'estado_atencion', NEW.estado_atencion, 'ubicacion_evento', NEW.ubicacion_evento, 'referencia_evento', NEW.referencia_evento, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_seguridad_au_audit//
CREATE TRIGGER tr_seguridad_au_audit AFTER UPDATE ON seguridad FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'seguridad', 'UPDATE', CAST(NEW.id_seguridad AS CHAR), 'UPDATE en seguridad', 'Se actualizo un registro en seguridad', JSON_OBJECT('id_seguridad', OLD.id_seguridad, 'ticket_interno', OLD.ticket_interno, 'id_beneficiario', OLD.id_beneficiario, 'id_usuario', OLD.id_usuario, 'id_tipo_seguridad', OLD.id_tipo_seguridad, 'id_solicitud_seguridad', OLD.id_solicitud_seguridad, 'id_estado_solicitud', OLD.id_estado_solicitud, 'tipo_seguridad', OLD.tipo_seguridad, 'tipo_solicitud', OLD.tipo_solicitud, 'fecha_seguridad', OLD.fecha_seguridad, 'descripcion', OLD.descripcion, 'estado_atencion', OLD.estado_atencion, 'ubicacion_evento', OLD.ubicacion_evento, 'referencia_evento', OLD.referencia_evento, 'estado', OLD.estado), JSON_OBJECT('id_seguridad', NEW.id_seguridad, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_seguridad', NEW.id_tipo_seguridad, 'id_solicitud_seguridad', NEW.id_solicitud_seguridad, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_seguridad', NEW.tipo_seguridad, 'tipo_solicitud', NEW.tipo_solicitud, 'fecha_seguridad', NEW.fecha_seguridad, 'descripcion', NEW.descripcion, 'estado_atencion', NEW.estado_atencion, 'ubicacion_evento', NEW.ubicacion_evento, 'referencia_evento', NEW.referencia_evento, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_seguridad_bd_block_delete//
CREATE TRIGGER tr_seguridad_bd_block_delete BEFORE DELETE ON seguridad FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla seguridad. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_servicios_publicos_ai_audit//
CREATE TRIGGER tr_servicios_publicos_ai_audit AFTER INSERT ON servicios_publicos FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'servicios_publicos', 'INSERT', CAST(NEW.id_servicio AS CHAR), 'INSERT en servicios_publicos', 'Se inserto un registro en servicios_publicos', NULL, JSON_OBJECT('id_servicio', NEW.id_servicio, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'id_solicitud_servicio_publico', NEW.id_solicitud_servicio_publico, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_servicio', NEW.tipo_servicio, 'solicitud_servicio', NEW.solicitud_servicio, 'fecha_servicio', NEW.fecha_servicio, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_servicios_publicos_au_audit//
CREATE TRIGGER tr_servicios_publicos_au_audit AFTER UPDATE ON servicios_publicos FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'servicios_publicos', 'UPDATE', CAST(NEW.id_servicio AS CHAR), 'UPDATE en servicios_publicos', 'Se actualizo un registro en servicios_publicos', JSON_OBJECT('id_servicio', OLD.id_servicio, 'ticket_interno', OLD.ticket_interno, 'id_beneficiario', OLD.id_beneficiario, 'id_usuario', OLD.id_usuario, 'id_tipo_servicio_publico', OLD.id_tipo_servicio_publico, 'id_solicitud_servicio_publico', OLD.id_solicitud_servicio_publico, 'id_estado_solicitud', OLD.id_estado_solicitud, 'tipo_servicio', OLD.tipo_servicio, 'solicitud_servicio', OLD.solicitud_servicio, 'fecha_servicio', OLD.fecha_servicio, 'descripcion', OLD.descripcion, 'estado', OLD.estado), JSON_OBJECT('id_servicio', NEW.id_servicio, 'ticket_interno', NEW.ticket_interno, 'id_beneficiario', NEW.id_beneficiario, 'id_usuario', NEW.id_usuario, 'id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'id_solicitud_servicio_publico', NEW.id_solicitud_servicio_publico, 'id_estado_solicitud', NEW.id_estado_solicitud, 'tipo_servicio', NEW.tipo_servicio, 'solicitud_servicio', NEW.solicitud_servicio, 'fecha_servicio', NEW.fecha_servicio, 'descripcion', NEW.descripcion, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_servicios_publicos_bd_block_delete//
CREATE TRIGGER tr_servicios_publicos_bd_block_delete BEFORE DELETE ON servicios_publicos FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla servicios_publicos. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_solicitudes_generales_ai_audit//
CREATE TRIGGER tr_solicitudes_generales_ai_audit AFTER INSERT ON solicitudes_generales FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'solicitudes_generales', 'INSERT', CAST(NEW.id_solicitud_general AS CHAR), 'INSERT en solicitudes_generales', 'Se inserto un registro en solicitudes_generales', NULL, JSON_OBJECT('id_solicitud_general', NEW.id_solicitud_general, 'codigo_solicitud', NEW.codigo_solicitud, 'nombre_solicitud', NEW.nombre_solicitud, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_solicitudes_generales_au_audit//
CREATE TRIGGER tr_solicitudes_generales_au_audit AFTER UPDATE ON solicitudes_generales FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'solicitudes_generales', 'UPDATE', CAST(NEW.id_solicitud_general AS CHAR), 'UPDATE en solicitudes_generales', 'Se actualizo un registro en solicitudes_generales', JSON_OBJECT('id_solicitud_general', OLD.id_solicitud_general, 'codigo_solicitud', OLD.codigo_solicitud, 'nombre_solicitud', OLD.nombre_solicitud, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_solicitud_general', NEW.id_solicitud_general, 'codigo_solicitud', NEW.codigo_solicitud, 'nombre_solicitud', NEW.nombre_solicitud, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_solicitudes_generales_bd_block_delete//
CREATE TRIGGER tr_solicitudes_generales_bd_block_delete BEFORE DELETE ON solicitudes_generales FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla solicitudes_generales. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_tipos_ayuda_social_ai_audit//
CREATE TRIGGER tr_tipos_ayuda_social_ai_audit AFTER INSERT ON tipos_ayuda_social FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_ayuda_social', 'INSERT', CAST(NEW.id_tipo_ayuda_social AS CHAR), 'INSERT en tipos_ayuda_social', 'Se inserto un registro en tipos_ayuda_social', NULL, JSON_OBJECT('id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'nombre_tipo_ayuda', NEW.nombre_tipo_ayuda, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_tipos_ayuda_social_au_audit//
CREATE TRIGGER tr_tipos_ayuda_social_au_audit AFTER UPDATE ON tipos_ayuda_social FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_ayuda_social', 'UPDATE', CAST(NEW.id_tipo_ayuda_social AS CHAR), 'UPDATE en tipos_ayuda_social', 'Se actualizo un registro en tipos_ayuda_social', JSON_OBJECT('id_tipo_ayuda_social', OLD.id_tipo_ayuda_social, 'nombre_tipo_ayuda', OLD.nombre_tipo_ayuda, 'requiere_ambulancia', OLD.requiere_ambulancia, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_tipo_ayuda_social', NEW.id_tipo_ayuda_social, 'nombre_tipo_ayuda', NEW.nombre_tipo_ayuda, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_tipos_ayuda_social_bd_block_delete//
CREATE TRIGGER tr_tipos_ayuda_social_bd_block_delete BEFORE DELETE ON tipos_ayuda_social FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_ayuda_social. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_tipos_seguridad_emergencia_ai_audit//
CREATE TRIGGER tr_tipos_seguridad_emergencia_ai_audit AFTER INSERT ON tipos_seguridad_emergencia FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_seguridad_emergencia', 'INSERT', CAST(NEW.id_tipo_seguridad AS CHAR), 'INSERT en tipos_seguridad_emergencia', 'Se inserto un registro en tipos_seguridad_emergencia', NULL, JSON_OBJECT('id_tipo_seguridad', NEW.id_tipo_seguridad, 'nombre_tipo', NEW.nombre_tipo, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_tipos_seguridad_emergencia_au_audit//
CREATE TRIGGER tr_tipos_seguridad_emergencia_au_audit AFTER UPDATE ON tipos_seguridad_emergencia FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_seguridad_emergencia', 'UPDATE', CAST(NEW.id_tipo_seguridad AS CHAR), 'UPDATE en tipos_seguridad_emergencia', 'Se actualizo un registro en tipos_seguridad_emergencia', JSON_OBJECT('id_tipo_seguridad', OLD.id_tipo_seguridad, 'nombre_tipo', OLD.nombre_tipo, 'requiere_ambulancia', OLD.requiere_ambulancia, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_tipo_seguridad', NEW.id_tipo_seguridad, 'nombre_tipo', NEW.nombre_tipo, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_tipos_seguridad_emergencia_bd_block_delete//
CREATE TRIGGER tr_tipos_seguridad_emergencia_bd_block_delete BEFORE DELETE ON tipos_seguridad_emergencia FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_seguridad_emergencia. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_tipos_servicios_publicos_ai_audit//
CREATE TRIGGER tr_tipos_servicios_publicos_ai_audit AFTER INSERT ON tipos_servicios_publicos FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_servicios_publicos', 'INSERT', CAST(NEW.id_tipo_servicio_publico AS CHAR), 'INSERT en tipos_servicios_publicos', 'Se inserto un registro en tipos_servicios_publicos', NULL, JSON_OBJECT('id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'codigo_tipo_servicio_publico', NEW.codigo_tipo_servicio_publico, 'nombre_tipo_servicio', NEW.nombre_tipo_servicio, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_tipos_servicios_publicos_au_audit//
CREATE TRIGGER tr_tipos_servicios_publicos_au_audit AFTER UPDATE ON tipos_servicios_publicos FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'tipos_servicios_publicos', 'UPDATE', CAST(NEW.id_tipo_servicio_publico AS CHAR), 'UPDATE en tipos_servicios_publicos', 'Se actualizo un registro en tipos_servicios_publicos', JSON_OBJECT('id_tipo_servicio_publico', OLD.id_tipo_servicio_publico, 'codigo_tipo_servicio_publico', OLD.codigo_tipo_servicio_publico, 'nombre_tipo_servicio', OLD.nombre_tipo_servicio, 'estado', OLD.estado, 'fecha_registro', OLD.fecha_registro), JSON_OBJECT('id_tipo_servicio_publico', NEW.id_tipo_servicio_publico, 'codigo_tipo_servicio_publico', NEW.codigo_tipo_servicio_publico, 'nombre_tipo_servicio', NEW.nombre_tipo_servicio, 'estado', NEW.estado, 'fecha_registro', NEW.fecha_registro), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_tipos_servicios_publicos_bd_block_delete//
CREATE TRIGGER tr_tipos_servicios_publicos_bd_block_delete BEFORE DELETE ON tipos_servicios_publicos FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_servicios_publicos. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_unidades_ai_audit//
CREATE TRIGGER tr_unidades_ai_audit AFTER INSERT ON unidades FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'unidades', 'INSERT', CAST(NEW.id_unidad AS CHAR), 'INSERT en unidades', 'Se inserto un registro en unidades', NULL, JSON_OBJECT('id_unidad', NEW.id_unidad, 'codigo_unidad', NEW.codigo_unidad, 'descripcion', NEW.descripcion, 'placa', NEW.placa, 'estado', NEW.estado, 'estado_operativo', NEW.estado_operativo, 'ubicacion_actual', NEW.ubicacion_actual, 'referencia_actual', NEW.referencia_actual, 'prioridad_despacho', NEW.prioridad_despacho, 'fecha_actualizacion_operativa', NEW.fecha_actualizacion_operativa), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_unidades_au_audit//
CREATE TRIGGER tr_unidades_au_audit AFTER UPDATE ON unidades FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'unidades', 'UPDATE', CAST(NEW.id_unidad AS CHAR), 'UPDATE en unidades', 'Se actualizo un registro en unidades', JSON_OBJECT('id_unidad', OLD.id_unidad, 'codigo_unidad', OLD.codigo_unidad, 'descripcion', OLD.descripcion, 'placa', OLD.placa, 'estado', OLD.estado, 'estado_operativo', OLD.estado_operativo, 'ubicacion_actual', OLD.ubicacion_actual, 'referencia_actual', OLD.referencia_actual, 'prioridad_despacho', OLD.prioridad_despacho, 'fecha_actualizacion_operativa', OLD.fecha_actualizacion_operativa), JSON_OBJECT('id_unidad', NEW.id_unidad, 'codigo_unidad', NEW.codigo_unidad, 'descripcion', NEW.descripcion, 'placa', NEW.placa, 'estado', NEW.estado, 'estado_operativo', NEW.estado_operativo, 'ubicacion_actual', NEW.ubicacion_actual, 'referencia_actual', NEW.referencia_actual, 'prioridad_despacho', NEW.prioridad_despacho, 'fecha_actualizacion_operativa', NEW.fecha_actualizacion_operativa), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_unidades_bd_block_delete//
CREATE TRIGGER tr_unidades_bd_block_delete BEFORE DELETE ON unidades FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla unidades. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_usuarios_ai_audit//
CREATE TRIGGER tr_usuarios_ai_audit AFTER INSERT ON usuarios FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuarios', 'INSERT', CAST(NEW.id_usuario AS CHAR), 'INSERT en usuarios', 'Se inserto un registro en usuarios', NULL, JSON_OBJECT('id_usuario', NEW.id_usuario, 'id_empleado', NEW.id_empleado, 'id_dependencia', NEW.id_dependencia, 'usuario', NEW.usuario, 'password', NEW.password, 'rol', NEW.rol, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_usuarios_au_audit//
CREATE TRIGGER tr_usuarios_au_audit AFTER UPDATE ON usuarios FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuarios', 'UPDATE', CAST(NEW.id_usuario AS CHAR), 'UPDATE en usuarios', 'Se actualizo un registro en usuarios', JSON_OBJECT('id_usuario', OLD.id_usuario, 'id_empleado', OLD.id_empleado, 'id_dependencia', OLD.id_dependencia, 'usuario', OLD.usuario, 'password', OLD.password, 'rol', OLD.rol, 'estado', OLD.estado), JSON_OBJECT('id_usuario', NEW.id_usuario, 'id_empleado', NEW.id_empleado, 'id_dependencia', NEW.id_dependencia, 'usuario', NEW.usuario, 'password', NEW.password, 'rol', NEW.rol, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_usuarios_bd_block_delete//
CREATE TRIGGER tr_usuarios_bd_block_delete BEFORE DELETE ON usuarios FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuarios. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_usuarios_seguridad_acceso_ai_audit//
CREATE TRIGGER tr_usuarios_seguridad_acceso_ai_audit AFTER INSERT ON usuarios_seguridad_acceso FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuarios_seguridad_acceso', 'INSERT', CAST(NEW.id_usuario AS CHAR), 'INSERT en usuarios_seguridad_acceso', 'Se inserto un registro en usuarios_seguridad_acceso', NULL, JSON_OBJECT('id_usuario', NEW.id_usuario, 'intentos_fallidos', NEW.intentos_fallidos, 'bloqueado', NEW.bloqueado, 'fecha_bloqueo', NEW.fecha_bloqueo, 'password_temporal', NEW.password_temporal, 'fecha_password_temporal', NEW.fecha_password_temporal, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_usuarios_seguridad_acceso_au_audit//
CREATE TRIGGER tr_usuarios_seguridad_acceso_au_audit AFTER UPDATE ON usuarios_seguridad_acceso FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuarios_seguridad_acceso', 'UPDATE', CAST(NEW.id_usuario AS CHAR), 'UPDATE en usuarios_seguridad_acceso', 'Se actualizo un registro en usuarios_seguridad_acceso', JSON_OBJECT('id_usuario', OLD.id_usuario, 'intentos_fallidos', OLD.intentos_fallidos, 'bloqueado', OLD.bloqueado, 'fecha_bloqueo', OLD.fecha_bloqueo, 'password_temporal', OLD.password_temporal, 'fecha_password_temporal', OLD.fecha_password_temporal, 'fecha_actualizacion', OLD.fecha_actualizacion), JSON_OBJECT('id_usuario', NEW.id_usuario, 'intentos_fallidos', NEW.intentos_fallidos, 'bloqueado', NEW.bloqueado, 'fecha_bloqueo', NEW.fecha_bloqueo, 'password_temporal', NEW.password_temporal, 'fecha_password_temporal', NEW.fecha_password_temporal, 'fecha_actualizacion', NEW.fecha_actualizacion), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_usuarios_seguridad_acceso_bd_block_delete//
CREATE TRIGGER tr_usuarios_seguridad_acceso_bd_block_delete BEFORE DELETE ON usuarios_seguridad_acceso FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuarios_seguridad_acceso. Use eliminacion logica.';
END//

DROP TRIGGER IF EXISTS tr_usuario_permisos_ai_audit//
CREATE TRIGGER tr_usuario_permisos_ai_audit AFTER INSERT ON usuario_permisos FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuario_permisos', 'INSERT', CAST(NEW.id_usuario_permiso AS CHAR), 'INSERT en usuario_permisos', 'Se inserto un registro en usuario_permisos', NULL, JSON_OBJECT('id_usuario_permiso', NEW.id_usuario_permiso, 'id_usuario', NEW.id_usuario, 'id_permiso', NEW.id_permiso, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_usuario_permisos_au_audit//
CREATE TRIGGER tr_usuario_permisos_au_audit AFTER UPDATE ON usuario_permisos FOR EACH ROW
BEGIN
  INSERT INTO bitacora (id_usuario, tabla_afectada, accion, id_registro, resumen, detalle, datos_antes, datos_despues, usuario_bd, fecha_evento, estado)
  VALUES (NULL, 'usuario_permisos', 'UPDATE', CAST(NEW.id_usuario_permiso AS CHAR), 'UPDATE en usuario_permisos', 'Se actualizo un registro en usuario_permisos', JSON_OBJECT('id_usuario_permiso', OLD.id_usuario_permiso, 'id_usuario', OLD.id_usuario, 'id_permiso', OLD.id_permiso, 'estado', OLD.estado), JSON_OBJECT('id_usuario_permiso', NEW.id_usuario_permiso, 'id_usuario', NEW.id_usuario, 'id_permiso', NEW.id_permiso, 'estado', NEW.estado), CURRENT_USER(), NOW(), 1);
END//
DROP TRIGGER IF EXISTS tr_usuario_permisos_bd_block_delete//
CREATE TRIGGER tr_usuario_permisos_bd_block_delete BEFORE DELETE ON usuario_permisos FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla usuario_permisos. Use eliminacion logica.';
END//

DELIMITER ;
