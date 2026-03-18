USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

CREATE TABLE IF NOT EXISTS tipos_servicios_publicos (
    id_tipo_servicio_publico INT(11) NOT NULL AUTO_INCREMENT,
    codigo_tipo_servicio_publico VARCHAR(20) NOT NULL,
    nombre_tipo_servicio VARCHAR(120) NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_tipo_servicio_publico),
    UNIQUE KEY uk_tipos_servicios_publicos_codigo (codigo_tipo_servicio_publico),
    UNIQUE KEY uk_tipos_servicios_publicos_nombre (nombre_tipo_servicio),
    KEY idx_tipos_servicios_publicos_estado_codigo_nombre (estado, codigo_tipo_servicio_publico, nombre_tipo_servicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO tipos_servicios_publicos (codigo_tipo_servicio_publico, nombre_tipo_servicio, estado) VALUES
('SP-AGU', 'Agua', 1),
('SP-AGN', 'Aguas Negras', 1),
('SP-ALU', 'Alumbrado Publico', 1),
('SP-AMB', 'Ambiente', 1),
('SP-ASF', 'Asfaltado', 1),
('SP-CAN', 'Canos y Embaulamiento', 1),
('SP-ENE', 'Energia', 1),
('SP-INF', 'Infraestructura', 1),
('SP-PYP', 'Pica y Poda', 1),
('SP-VIA', 'Vial', 1);

CREATE TABLE IF NOT EXISTS solicitudes_servicios_publicos (
    id_solicitud_servicio_publico INT(11) NOT NULL AUTO_INCREMENT,
    codigo_solicitud_servicio_publico VARCHAR(20) NOT NULL,
    nombre_solicitud_servicio VARCHAR(120) NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_solicitud_servicio_publico),
    UNIQUE KEY uk_solicitudes_servicios_publicos_codigo (codigo_solicitud_servicio_publico),
    UNIQUE KEY uk_solicitudes_servicios_publicos_nombre (nombre_solicitud_servicio),
    KEY idx_solicitudes_servicios_publicos_estado_codigo_nombre (estado, codigo_solicitud_servicio_publico, nombre_solicitud_servicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO solicitudes_servicios_publicos (codigo_solicitud_servicio_publico, nombre_solicitud_servicio, estado) VALUES
('SOL-1X10', '1X10', 1),
('SOL-ATC', 'Atencion al ciudadano', 1),
('SOL-RDS', 'Redes Sociales', 1);

ALTER TABLE servicios_publicos
    ADD COLUMN IF NOT EXISTS id_tipo_servicio_publico INT(11) NULL AFTER id_usuario,
    ADD COLUMN IF NOT EXISTS id_solicitud_servicio_publico INT(11) NULL AFTER id_tipo_servicio_publico;

UPDATE servicios_publicos AS sp
INNER JOIN tipos_servicios_publicos AS tsp
    ON UPPER(TRIM(tsp.nombre_tipo_servicio)) = CASE
        WHEN UPPER(TRIM(sp.tipo_servicio)) = 'ENERGIA' THEN 'ENERGIA'
        WHEN UPPER(TRIM(sp.tipo_servicio)) = 'AGUA' THEN 'AGUA'
        WHEN UPPER(TRIM(sp.tipo_servicio)) = 'VIAL' THEN 'VIAL'
        WHEN UPPER(TRIM(sp.tipo_servicio)) = 'PICA Y PODA' THEN 'PICA Y PODA'
        WHEN UPPER(TRIM(sp.tipo_servicio)) = 'INFRAESTRUCTURA' THEN 'INFRAESTRUCTURA'
        WHEN UPPER(TRIM(sp.tipo_servicio)) = 'AGUAS NEGRAS' THEN 'AGUAS NEGRAS'
        WHEN UPPER(TRIM(sp.tipo_servicio)) = 'ASFALTADO' THEN 'ASFALTADO'
        WHEN UPPER(TRIM(sp.tipo_servicio)) IN ('CANOS Y EMBAULAMIENTO', 'CANOS Y EMBAULAMIENTOS') THEN 'CANOS Y EMBAULAMIENTO'
        WHEN UPPER(TRIM(sp.tipo_servicio)) = 'ALUMBRADO PUBLICO' THEN 'ALUMBRADO PUBLICO'
        WHEN UPPER(TRIM(sp.tipo_servicio)) = 'AMBIENTE' THEN 'AMBIENTE'
        ELSE UPPER(TRIM(sp.tipo_servicio))
    END
SET sp.id_tipo_servicio_publico = tsp.id_tipo_servicio_publico
WHERE sp.id_tipo_servicio_publico IS NULL
  AND sp.tipo_servicio IS NOT NULL
  AND TRIM(sp.tipo_servicio) <> '';

UPDATE servicios_publicos AS sp
INNER JOIN solicitudes_servicios_publicos AS ssp
    ON UPPER(TRIM(ssp.nombre_solicitud_servicio)) = CASE
        WHEN UPPER(TRIM(sp.solicitud_servicio)) IN ('ATENCION', 'ATENCION AL CIUDADANO') THEN 'ATENCION AL CIUDADANO'
        WHEN UPPER(TRIM(sp.solicitud_servicio)) IN ('REDES', 'REDES SOCIALES') THEN 'REDES SOCIALES'
        WHEN UPPER(TRIM(sp.solicitud_servicio)) = '1X10' THEN '1X10'
        ELSE UPPER(TRIM(sp.solicitud_servicio))
    END
SET sp.id_solicitud_servicio_publico = ssp.id_solicitud_servicio_publico
WHERE sp.id_solicitud_servicio_publico IS NULL
  AND sp.solicitud_servicio IS NOT NULL
  AND TRIM(sp.solicitud_servicio) <> '';

UPDATE servicios_publicos AS sp
INNER JOIN tipos_servicios_publicos AS tsp
    ON tsp.id_tipo_servicio_publico = sp.id_tipo_servicio_publico
SET sp.tipo_servicio = tsp.nombre_tipo_servicio
WHERE sp.id_tipo_servicio_publico IS NOT NULL;

UPDATE servicios_publicos AS sp
INNER JOIN solicitudes_servicios_publicos AS ssp
    ON ssp.id_solicitud_servicio_publico = sp.id_solicitud_servicio_publico
SET sp.solicitud_servicio = ssp.nombre_solicitud_servicio
WHERE sp.id_solicitud_servicio_publico IS NOT NULL;

SET @idx_tipo_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'servicios_publicos'
      AND INDEX_NAME = 'idx_servicios_publicos_id_tipo_servicio_publico'
);
SET @sql_idx_tipo := IF(
    @idx_tipo_exists = 0,
    'ALTER TABLE servicios_publicos ADD INDEX idx_servicios_publicos_id_tipo_servicio_publico (id_tipo_servicio_publico)',
    'SELECT 1'
);
PREPARE stmt_idx_tipo FROM @sql_idx_tipo;
EXECUTE stmt_idx_tipo;
DEALLOCATE PREPARE stmt_idx_tipo;

SET @idx_sol_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'servicios_publicos'
      AND INDEX_NAME = 'idx_servicios_publicos_id_solicitud_servicio_publico'
);
SET @sql_idx_sol := IF(
    @idx_sol_exists = 0,
    'ALTER TABLE servicios_publicos ADD INDEX idx_servicios_publicos_id_solicitud_servicio_publico (id_solicitud_servicio_publico)',
    'SELECT 1'
);
PREPARE stmt_idx_sol FROM @sql_idx_sol;
EXECUTE stmt_idx_sol;
DEALLOCATE PREPARE stmt_idx_sol;

SET @fk_tipo_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'servicios_publicos'
      AND CONSTRAINT_NAME = 'fk_servicios_publicos_tipos'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_tipo := IF(
    @fk_tipo_exists = 0,
    'ALTER TABLE servicios_publicos ADD CONSTRAINT fk_servicios_publicos_tipos FOREIGN KEY (id_tipo_servicio_publico) REFERENCES tipos_servicios_publicos(id_tipo_servicio_publico) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_tipo FROM @sql_fk_tipo;
EXECUTE stmt_fk_tipo;
DEALLOCATE PREPARE stmt_fk_tipo;

SET @fk_sol_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'servicios_publicos'
      AND CONSTRAINT_NAME = 'fk_servicios_publicos_solicitudes'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_sol := IF(
    @fk_sol_exists = 0,
    'ALTER TABLE servicios_publicos ADD CONSTRAINT fk_servicios_publicos_solicitudes FOREIGN KEY (id_solicitud_servicio_publico) REFERENCES solicitudes_servicios_publicos(id_solicitud_servicio_publico) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_sol FROM @sql_fk_sol;
EXECUTE stmt_fk_sol;
DEALLOCATE PREPARE stmt_fk_sol;
