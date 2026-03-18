USE sala03v2_4;

SET @tiene_codigo_ayuda := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'ayuda_social'
      AND COLUMN_NAME = 'codigo_ayuda'
);

DROP TRIGGER IF EXISTS tr_ayuda_social_ai_audit;
DROP TRIGGER IF EXISTS tr_ayuda_social_au_audit;
DROP TRIGGER IF EXISTS tr_ayuda_social_bd_block_delete;

SET @sql := IF(
    @tiene_codigo_ayuda > 0,
    "UPDATE ayuda_social
        SET ticket_interno = TRIM(codigo_ayuda)
      WHERE (ticket_interno IS NULL OR TRIM(ticket_interno) = '')
        AND codigo_ayuda IS NOT NULL
        AND TRIM(codigo_ayuda) <> ''",
    "SELECT 1"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE ayuda_social
   SET ticket_interno = CONCAT(
        'AYU-',
        DATE_FORMAT(COALESCE(fecha_ayuda, CURDATE()), '%Y%m%d'),
        '-',
        LPAD(id_ayuda, 6, '0')
   )
 WHERE ticket_interno IS NULL
    OR TRIM(ticket_interno) = '';

SET @sql := IF(
    @tiene_codigo_ayuda > 0,
    "ALTER TABLE ayuda_social DROP COLUMN codigo_ayuda",
    "SELECT 1"
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DELIMITER //

CREATE TRIGGER tr_ayuda_social_ai_audit AFTER INSERT ON ayuda_social
FOR EACH ROW BEGIN
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
    ipaddr,
    moment,
    fecha_evento
  )
  VALUES (
    NULL,
    'ayuda_social',
    'INSERT',
    CAST(NEW.id_ayuda AS CHAR),
    CONCAT('AUDIT INSERT ', 'ayuda_social'),
    CONCAT('Insercion en ayuda_social [ID=', CAST(NEW.id_ayuda AS CHAR), ']'),
    NULL,
    JSON_OBJECT(
      'id_ayuda', NEW.id_ayuda,
      'ticket_interno', NEW.ticket_interno,
      'id_beneficiario', NEW.id_beneficiario,
      'id_usuario', NEW.id_usuario,
      'tipo_ayuda', NEW.tipo_ayuda,
      'solicitud_ayuda', NEW.solicitud_ayuda,
      'fecha_ayuda', NEW.fecha_ayuda,
      'descripcion', NEW.descripcion,
      'estado', NEW.estado
    ),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

CREATE TRIGGER tr_ayuda_social_au_audit AFTER UPDATE ON ayuda_social
FOR EACH ROW BEGIN
  DECLARE v_accion VARCHAR(20);

  IF OLD.estado = 1 AND NEW.estado = 0 THEN
    SET v_accion = 'SOFTDELETE';
  ELSEIF OLD.estado = 0 AND NEW.estado = 1 THEN
    SET v_accion = 'RESTORE';
  ELSE
    SET v_accion = 'UPDATE';
  END IF;

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
    ipaddr,
    moment,
    fecha_evento
  )
  VALUES (
    NULL,
    'ayuda_social',
    v_accion,
    CAST(NEW.id_ayuda AS CHAR),
    CONCAT('AUDIT ', v_accion, ' ', 'ayuda_social'),
    CONCAT(v_accion, ' en ayuda_social [ID=', CAST(NEW.id_ayuda AS CHAR), ']'),
    JSON_OBJECT(
      'id_ayuda', OLD.id_ayuda,
      'ticket_interno', OLD.ticket_interno,
      'id_beneficiario', OLD.id_beneficiario,
      'id_usuario', OLD.id_usuario,
      'tipo_ayuda', OLD.tipo_ayuda,
      'solicitud_ayuda', OLD.solicitud_ayuda,
      'fecha_ayuda', OLD.fecha_ayuda,
      'descripcion', OLD.descripcion,
      'estado', OLD.estado
    ),
    JSON_OBJECT(
      'id_ayuda', NEW.id_ayuda,
      'ticket_interno', NEW.ticket_interno,
      'id_beneficiario', NEW.id_beneficiario,
      'id_usuario', NEW.id_usuario,
      'tipo_ayuda', NEW.tipo_ayuda,
      'solicitud_ayuda', NEW.solicitud_ayuda,
      'fecha_ayuda', NEW.fecha_ayuda,
      'descripcion', NEW.descripcion,
      'estado', NEW.estado
    ),
    CURRENT_USER(),
    SUBSTRING_INDEX(USER(), '@', -1),
    NOW(),
    NOW()
  );
END//

CREATE TRIGGER tr_ayuda_social_bd_block_delete BEFORE DELETE ON ayuda_social
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla ayuda_social. Use estado=0 para softdelete.';
END//

DELIMITER ;
