USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

-- Se recrean triggers de usuarios para quitar referencias a id_dependencia.
DROP TRIGGER IF EXISTS tr_usuarios_ai_audit;
DROP TRIGGER IF EXISTS tr_usuarios_au_audit;

-- Si existe FK de usuarios.id_dependencia -> dependencias, se elimina.
SET @fk_usuarios_dependencia := (
    SELECT kcu.CONSTRAINT_NAME
    FROM information_schema.KEY_COLUMN_USAGE kcu
    WHERE kcu.TABLE_SCHEMA = DATABASE()
      AND kcu.TABLE_NAME = 'usuarios'
      AND kcu.COLUMN_NAME = 'id_dependencia'
      AND kcu.REFERENCED_TABLE_NAME = 'dependencias'
      AND kcu.REFERENCED_COLUMN_NAME = 'id_dependencia'
    LIMIT 1
);

SET @sql := IF(
    @fk_usuarios_dependencia IS NOT NULL AND @fk_usuarios_dependencia <> '',
    CONCAT('ALTER TABLE usuarios DROP FOREIGN KEY `', REPLACE(@fk_usuarios_dependencia, '`', '``'), '`'),
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Si la columna existe, se elimina de la tabla usuarios.
SET @usuarios_tiene_dependencia := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'usuarios'
      AND COLUMN_NAME = 'id_dependencia'
);

SET @sql := IF(
    @usuarios_tiene_dependencia > 0,
    'ALTER TABLE usuarios DROP COLUMN id_dependencia',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DELIMITER //

DROP TRIGGER IF EXISTS tr_usuarios_ai_audit//
CREATE TRIGGER tr_usuarios_ai_audit AFTER INSERT ON usuarios FOR EACH ROW
BEGIN
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
END//

DROP TRIGGER IF EXISTS tr_usuarios_au_audit//
CREATE TRIGGER tr_usuarios_au_audit AFTER UPDATE ON usuarios FOR EACH ROW
BEGIN
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
END//

DELIMITER ;
