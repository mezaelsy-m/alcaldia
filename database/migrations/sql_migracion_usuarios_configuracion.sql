START TRANSACTION;

SET @tabla_usuario_permisos_existe := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'usuario_permisos'
);

SET @sql_estado_usuario_permisos := IF(
    @tabla_usuario_permisos_existe = 1 AND (
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'usuario_permisos'
          AND COLUMN_NAME = 'estado'
    ) = 0,
    'ALTER TABLE usuario_permisos ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1 AFTER id_permiso',
    'SELECT 1'
);
PREPARE stmt_estado_usuario_permisos FROM @sql_estado_usuario_permisos;
EXECUTE stmt_estado_usuario_permisos;
DEALLOCATE PREPARE stmt_estado_usuario_permisos;

UPDATE usuario_permisos
SET estado = 1
WHERE estado IS NULL;

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 99,
       'Acceso total del sistema',
       'Permiso exclusivo transferible por administradores para habilitar acceso total.',
       1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 99
       OR UPPER(TRIM(nombre_permiso)) IN ('ACCESO TOTAL DEL SISTEMA', 'ACCESO TOTAL SISTEMA')
);

UPDATE permisos
SET nombre_permiso = 'Acceso total del sistema',
    descripcion = 'Permiso exclusivo transferible por administradores para habilitar acceso total.',
    estado = 1
WHERE id_permiso = 99
   OR UPPER(TRIM(nombre_permiso)) IN ('ACCESO TOTAL DEL SISTEMA', 'ACCESO TOTAL SISTEMA');

DELETE up1
FROM usuario_permisos up1
INNER JOIN usuario_permisos up2
    ON up1.id_usuario_permiso > up2.id_usuario_permiso
   AND up1.id_usuario = up2.id_usuario
   AND up1.id_permiso = up2.id_permiso;

SET @uk_usuario_permiso_existe := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'usuario_permisos'
      AND INDEX_NAME = 'uk_usuario_permiso'
);

SET @sql_uk_usuario_permiso := IF(
    @tabla_usuario_permisos_existe = 1 AND @uk_usuario_permiso_existe = 0,
    'ALTER TABLE usuario_permisos ADD UNIQUE KEY uk_usuario_permiso (id_usuario, id_permiso)',
    'SELECT 1'
);
PREPARE stmt_uk_usuario_permiso FROM @sql_uk_usuario_permiso;
EXECUTE stmt_uk_usuario_permiso;
DEALLOCATE PREPARE stmt_uk_usuario_permiso;

COMMIT;
