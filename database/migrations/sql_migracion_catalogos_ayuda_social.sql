USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

CREATE TABLE IF NOT EXISTS tipos_ayuda_social (
    id_tipo_ayuda_social INT(11) NOT NULL AUTO_INCREMENT,
    nombre_tipo_ayuda VARCHAR(120) NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_tipo_ayuda_social),
    UNIQUE KEY uk_tipos_ayuda_social_nombre (nombre_tipo_ayuda),
    KEY idx_tipos_ayuda_social_estado_nombre (estado, nombre_tipo_ayuda)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO tipos_ayuda_social (nombre_tipo_ayuda, estado) VALUES
('Medicas', 1),
('Tecnicas', 1),
('Sociales', 1);

CREATE TABLE IF NOT EXISTS solicitudes_ayuda_social (
    id_solicitud_ayuda_social INT(11) NOT NULL AUTO_INCREMENT,
    nombre_solicitud_ayuda VARCHAR(120) NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_solicitud_ayuda_social),
    UNIQUE KEY uk_solicitudes_ayuda_social_nombre (nombre_solicitud_ayuda),
    KEY idx_solicitudes_ayuda_social_estado_nombre (estado, nombre_solicitud_ayuda)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO solicitudes_ayuda_social (nombre_solicitud_ayuda, estado) VALUES
('1X10', 1),
('Atencion al ciudadano', 1),
('Redes sociales', 1);

ALTER TABLE ayuda_social
    ADD COLUMN IF NOT EXISTS id_tipo_ayuda_social INT(11) NULL AFTER id_usuario,
    ADD COLUMN IF NOT EXISTS id_solicitud_ayuda_social INT(11) NULL AFTER id_tipo_ayuda_social;

UPDATE ayuda_social AS a
INNER JOIN tipos_ayuda_social AS t
    ON UPPER(TRIM(t.nombre_tipo_ayuda)) = UPPER(TRIM(a.tipo_ayuda))
SET a.id_tipo_ayuda_social = t.id_tipo_ayuda_social
WHERE a.id_tipo_ayuda_social IS NULL
  AND a.tipo_ayuda IS NOT NULL
  AND TRIM(a.tipo_ayuda) <> '';

UPDATE ayuda_social AS a
INNER JOIN solicitudes_ayuda_social AS s
    ON UPPER(TRIM(s.nombre_solicitud_ayuda)) = CASE
        WHEN UPPER(TRIM(a.solicitud_ayuda)) IN ('ATENCION', 'ATENCION CLIENTE', 'ATENCION AL CIUDADANO') THEN 'ATENCION AL CIUDADANO'
        WHEN UPPER(TRIM(a.solicitud_ayuda)) IN ('REDES', 'REDES SOCIALES') THEN 'REDES SOCIALES'
        WHEN UPPER(TRIM(a.solicitud_ayuda)) = '1X10' THEN '1X10'
        ELSE UPPER(TRIM(a.solicitud_ayuda))
    END
SET a.id_solicitud_ayuda_social = s.id_solicitud_ayuda_social
WHERE a.id_solicitud_ayuda_social IS NULL
  AND a.solicitud_ayuda IS NOT NULL
  AND TRIM(a.solicitud_ayuda) <> '';

UPDATE ayuda_social AS a
INNER JOIN tipos_ayuda_social AS t
    ON t.id_tipo_ayuda_social = a.id_tipo_ayuda_social
SET a.tipo_ayuda = t.nombre_tipo_ayuda
WHERE a.id_tipo_ayuda_social IS NOT NULL;

UPDATE ayuda_social AS a
INNER JOIN solicitudes_ayuda_social AS s
    ON s.id_solicitud_ayuda_social = a.id_solicitud_ayuda_social
SET a.solicitud_ayuda = s.nombre_solicitud_ayuda
WHERE a.id_solicitud_ayuda_social IS NOT NULL;

SET @idx_tipo_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'ayuda_social'
      AND INDEX_NAME = 'idx_ayuda_social_id_tipo_ayuda_social'
);
SET @sql_idx_tipo := IF(
    @idx_tipo_exists = 0,
    'ALTER TABLE ayuda_social ADD INDEX idx_ayuda_social_id_tipo_ayuda_social (id_tipo_ayuda_social)',
    'SELECT 1'
);
PREPARE stmt_idx_tipo FROM @sql_idx_tipo;
EXECUTE stmt_idx_tipo;
DEALLOCATE PREPARE stmt_idx_tipo;

SET @idx_sol_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'ayuda_social'
      AND INDEX_NAME = 'idx_ayuda_social_id_solicitud_ayuda_social'
);
SET @sql_idx_sol := IF(
    @idx_sol_exists = 0,
    'ALTER TABLE ayuda_social ADD INDEX idx_ayuda_social_id_solicitud_ayuda_social (id_solicitud_ayuda_social)',
    'SELECT 1'
);
PREPARE stmt_idx_sol FROM @sql_idx_sol;
EXECUTE stmt_idx_sol;
DEALLOCATE PREPARE stmt_idx_sol;

SET @fk_tipo_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'ayuda_social'
      AND CONSTRAINT_NAME = 'fk_ayuda_social_tipos'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_tipo := IF(
    @fk_tipo_exists = 0,
    'ALTER TABLE ayuda_social ADD CONSTRAINT fk_ayuda_social_tipos FOREIGN KEY (id_tipo_ayuda_social) REFERENCES tipos_ayuda_social(id_tipo_ayuda_social) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_tipo FROM @sql_fk_tipo;
EXECUTE stmt_fk_tipo;
DEALLOCATE PREPARE stmt_fk_tipo;

SET @fk_sol_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'ayuda_social'
      AND CONSTRAINT_NAME = 'fk_ayuda_social_solicitudes'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_sol := IF(
    @fk_sol_exists = 0,
    'ALTER TABLE ayuda_social ADD CONSTRAINT fk_ayuda_social_solicitudes FOREIGN KEY (id_solicitud_ayuda_social) REFERENCES solicitudes_ayuda_social(id_solicitud_ayuda_social) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_sol FROM @sql_fk_sol;
EXECUTE stmt_fk_sol;
DEALLOCATE PREPARE stmt_fk_sol;
