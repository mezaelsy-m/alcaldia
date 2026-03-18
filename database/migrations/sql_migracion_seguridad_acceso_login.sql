USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

CREATE TABLE IF NOT EXISTS usuarios_seguridad_acceso (
    id_usuario INT(11) NOT NULL,
    intentos_fallidos INT(11) NOT NULL DEFAULT 0,
    bloqueado TINYINT(1) NOT NULL DEFAULT 0,
    fecha_bloqueo DATETIME NULL,
    password_temporal TINYINT(1) NOT NULL DEFAULT 0,
    fecha_password_temporal DATETIME NULL,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario),
    KEY idx_usuarios_seguridad_bloqueo (bloqueado, intentos_fallidos),
    CONSTRAINT fk_usuarios_seguridad_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE usuarios_seguridad_acceso
    ADD COLUMN IF NOT EXISTS id_usuario INT(11) NOT NULL FIRST,
    ADD COLUMN IF NOT EXISTS intentos_fallidos INT(11) NOT NULL DEFAULT 0 AFTER id_usuario,
    ADD COLUMN IF NOT EXISTS bloqueado TINYINT(1) NOT NULL DEFAULT 0 AFTER intentos_fallidos,
    ADD COLUMN IF NOT EXISTS fecha_bloqueo DATETIME NULL AFTER bloqueado,
    ADD COLUMN IF NOT EXISTS password_temporal TINYINT(1) NOT NULL DEFAULT 0 AFTER fecha_bloqueo,
    ADD COLUMN IF NOT EXISTS fecha_password_temporal DATETIME NULL AFTER password_temporal,
    ADD COLUMN IF NOT EXISTS fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER fecha_password_temporal;

SET @pk_seguridad_existe := (
    SELECT COUNT(*)
    FROM information_schema.table_constraints
    WHERE table_schema = DATABASE()
      AND table_name = 'usuarios_seguridad_acceso'
      AND constraint_type = 'PRIMARY KEY'
);

SET @sql := IF(
    @pk_seguridad_existe = 0,
    'ALTER TABLE usuarios_seguridad_acceso ADD PRIMARY KEY (id_usuario)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_seguridad_bloqueo_existe := (
    SELECT COUNT(*)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'usuarios_seguridad_acceso'
      AND index_name = 'idx_usuarios_seguridad_bloqueo'
);

SET @sql := IF(
    @idx_seguridad_bloqueo_existe = 0,
    'ALTER TABLE usuarios_seguridad_acceso ADD KEY idx_usuarios_seguridad_bloqueo (bloqueado, intentos_fallidos)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_seguridad_usuario_existe := (
    SELECT COUNT(*)
    FROM information_schema.key_column_usage
    WHERE table_schema = DATABASE()
      AND table_name = 'usuarios_seguridad_acceso'
      AND column_name = 'id_usuario'
      AND referenced_table_name = 'usuarios'
      AND referenced_column_name = 'id_usuario'
);

SET @sql := IF(
    @fk_seguridad_usuario_existe = 0,
    'ALTER TABLE usuarios_seguridad_acceso ADD CONSTRAINT fk_usuarios_seguridad_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE usuarios_seguridad_acceso
SET intentos_fallidos = 0
WHERE intentos_fallidos IS NULL;

UPDATE usuarios_seguridad_acceso
SET bloqueado = 0
WHERE bloqueado IS NULL;

UPDATE usuarios_seguridad_acceso
SET password_temporal = 0
WHERE password_temporal IS NULL;

INSERT INTO usuarios_seguridad_acceso (id_usuario)
SELECT u.id_usuario
FROM usuarios u
LEFT JOIN usuarios_seguridad_acceso usa
    ON usa.id_usuario = u.id_usuario
WHERE usa.id_usuario IS NULL;
