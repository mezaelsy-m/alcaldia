USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

ALTER TABLE empleados
    ADD COLUMN IF NOT EXISTS estado TINYINT(1) NOT NULL DEFAULT 1 AFTER direccion;

ALTER TABLE empleados
    ADD COLUMN IF NOT EXISTS id_dependencia INT(11) NULL AFTER apellido;

ALTER TABLE empleados
    ADD COLUMN IF NOT EXISTS correo VARCHAR(150) NULL AFTER telefono;

UPDATE empleados
SET estado = 1
WHERE estado IS NULL;

SET @dependencia_default := (
    SELECT id_dependencia
    FROM dependencias
    WHERE IFNULL(estado, 1) = 1
    ORDER BY id_dependencia ASC
    LIMIT 1
);
SET @dependencia_default := IFNULL(@dependencia_default, 1);

SET @usuarios_tiene_dependencia := (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'usuarios'
      AND column_name = 'id_dependencia'
);

SET @sql := IF(
    @usuarios_tiene_dependencia > 0,
    'UPDATE empleados e
     INNER JOIN usuarios u
        ON u.id_empleado = e.id_empleado
     SET e.id_dependencia = u.id_dependencia
     WHERE (e.id_dependencia IS NULL OR e.id_dependencia = 0)
       AND u.id_dependencia IS NOT NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE empleados
SET id_dependencia = @dependencia_default
WHERE id_dependencia IS NULL
   OR id_dependencia = 0;

ALTER TABLE empleados
    MODIFY COLUMN id_dependencia INT(11) NOT NULL;

SET @sql := (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE empleados ADD UNIQUE KEY uk_empleados_cedula (cedula)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'empleados'
      AND column_name = 'cedula'
      AND non_unique = 0
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE empleados ADD KEY idx_empleados_estado_nombre (estado, apellido, nombre)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'empleados'
      AND index_name = 'idx_empleados_estado_nombre'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE empleados ADD KEY idx_empleados_dependencia (id_dependencia)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'empleados'
      AND index_name = 'idx_empleados_dependencia'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_empleados_dependencia := (
    SELECT COUNT(*)
    FROM information_schema.key_column_usage
    WHERE table_schema = DATABASE()
      AND table_name = 'empleados'
      AND column_name = 'id_dependencia'
      AND referenced_table_name = 'dependencias'
      AND referenced_column_name = 'id_dependencia'
);

SET @sql := IF(
    @fk_empleados_dependencia = 0,
    'ALTER TABLE empleados ADD CONSTRAINT fk_emp_dependencia FOREIGN KEY (id_dependencia) REFERENCES dependencias(id_dependencia)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS configuracion_smtp (
    id_configuracion_smtp INT(11) NOT NULL AUTO_INCREMENT,
    host VARCHAR(150) NOT NULL DEFAULT 'smtp.gmail.com',
    puerto INT(11) NOT NULL DEFAULT 587,
    usuario VARCHAR(150) NOT NULL,
    clave VARCHAR(255) NOT NULL,
    correo_remitente VARCHAR(150) NOT NULL,
    nombre_remitente VARCHAR(150) DEFAULT NULL,
    usar_tls TINYINT(1) NOT NULL DEFAULT 1,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    id_usuario_actualiza INT(11) DEFAULT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_configuracion_smtp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE configuracion_smtp
    ADD COLUMN IF NOT EXISTS host VARCHAR(150) NOT NULL DEFAULT 'smtp.gmail.com' AFTER id_configuracion_smtp,
    ADD COLUMN IF NOT EXISTS puerto INT(11) NOT NULL DEFAULT 587 AFTER host,
    ADD COLUMN IF NOT EXISTS usuario VARCHAR(150) NOT NULL AFTER puerto,
    ADD COLUMN IF NOT EXISTS clave VARCHAR(255) NOT NULL AFTER usuario,
    ADD COLUMN IF NOT EXISTS correo_remitente VARCHAR(150) NOT NULL AFTER clave,
    ADD COLUMN IF NOT EXISTS nombre_remitente VARCHAR(150) NULL AFTER correo_remitente,
    ADD COLUMN IF NOT EXISTS usar_tls TINYINT(1) NOT NULL DEFAULT 1 AFTER nombre_remitente,
    ADD COLUMN IF NOT EXISTS estado TINYINT(1) NOT NULL DEFAULT 1 AFTER usar_tls,
    ADD COLUMN IF NOT EXISTS id_usuario_actualiza INT(11) NULL AFTER estado,
    ADD COLUMN IF NOT EXISTS fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER id_usuario_actualiza,
    ADD COLUMN IF NOT EXISTS fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER fecha_registro;

UPDATE configuracion_smtp
SET estado = 1
WHERE estado IS NULL;

SET @sql := (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE configuracion_smtp ADD KEY idx_configuracion_smtp_estado (estado, id_configuracion_smtp)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'configuracion_smtp'
      AND index_name = 'idx_configuracion_smtp_estado'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE configuracion_smtp ADD KEY idx_configuracion_smtp_usuario (id_usuario_actualiza)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'configuracion_smtp'
      AND index_name = 'idx_configuracion_smtp_usuario'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_smtp_usuario := (
    SELECT COUNT(*)
    FROM information_schema.key_column_usage
    WHERE table_schema = DATABASE()
      AND table_name = 'configuracion_smtp'
      AND column_name = 'id_usuario_actualiza'
      AND referenced_table_name = 'usuarios'
      AND referenced_column_name = 'id_usuario'
);

SET @sql := IF(
    @fk_smtp_usuario = 0,
    'ALTER TABLE configuracion_smtp ADD CONSTRAINT fk_config_smtp_usuario FOREIGN KEY (id_usuario_actualiza) REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

INSERT INTO configuracion_smtp (
    host,
    puerto,
    usuario,
    clave,
    correo_remitente,
    nombre_remitente,
    usar_tls,
    estado
)
SELECT
    'smtp.gmail.com',
    587,
    '',
    '',
    '',
    NULL,
    1,
    1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM configuracion_smtp
);
