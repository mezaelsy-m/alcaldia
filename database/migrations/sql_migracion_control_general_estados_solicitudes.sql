USE sala03v2_4;

CREATE TABLE IF NOT EXISTS estados_solicitudes (
    id_estado_solicitud INT(11) NOT NULL AUTO_INCREMENT,
    codigo_estado VARCHAR(40) NOT NULL,
    nombre_estado VARCHAR(80) NOT NULL,
    descripcion VARCHAR(190) DEFAULT NULL,
    clase_badge VARCHAR(30) NOT NULL DEFAULT 'draft',
    es_atendida TINYINT(1) NOT NULL DEFAULT 0,
    orden_visual TINYINT UNSIGNED NOT NULL DEFAULT 0,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_estado_solicitud),
    UNIQUE KEY uk_estados_solicitudes_codigo (codigo_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO estados_solicitudes (codigo_estado, nombre_estado, descripcion, clase_badge, es_atendida, orden_visual, estado)
SELECT 'REGISTRADA', 'Registrada', 'Solicitud creada y pendiente por gestion.', 'draft', 0, 1, 1
WHERE NOT EXISTS (
    SELECT 1 FROM estados_solicitudes WHERE codigo_estado = 'REGISTRADA'
);

INSERT INTO estados_solicitudes (codigo_estado, nombre_estado, descripcion, clase_badge, es_atendida, orden_visual, estado)
SELECT 'EN_GESTION', 'En gestion', 'Solicitud en proceso de atencion o seguimiento.', 'info', 0, 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM estados_solicitudes WHERE codigo_estado = 'EN_GESTION'
);

INSERT INTO estados_solicitudes (codigo_estado, nombre_estado, descripcion, clase_badge, es_atendida, orden_visual, estado)
SELECT 'ATENDIDA', 'Atendida', 'Solicitud atendida y cerrada satisfactoriamente.', 'active', 1, 3, 1
WHERE NOT EXISTS (
    SELECT 1 FROM estados_solicitudes WHERE codigo_estado = 'ATENDIDA'
);

INSERT INTO estados_solicitudes (codigo_estado, nombre_estado, descripcion, clase_badge, es_atendida, orden_visual, estado)
SELECT 'NO_ATENDIDA', 'No atendida', 'Solicitud cerrada sin atencion satisfactoria.', 'warning', 0, 4, 1
WHERE NOT EXISTS (
    SELECT 1 FROM estados_solicitudes WHERE codigo_estado = 'NO_ATENDIDA'
);

CREATE TABLE IF NOT EXISTS seguimientos_solicitudes (
    id_seguimiento_solicitud INT(11) NOT NULL AUTO_INCREMENT,
    modulo ENUM('AYUDA_SOCIAL', 'SEGURIDAD', 'SERVICIOS_PUBLICOS') NOT NULL,
    id_referencia INT(11) NOT NULL,
    id_estado_solicitud INT(11) NOT NULL,
    id_usuario INT(11) DEFAULT NULL,
    fecha_gestion DATETIME NOT NULL,
    observacion TEXT DEFAULT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_seguimiento_solicitud),
    KEY idx_seguimientos_modulo_referencia (modulo, id_referencia),
    KEY idx_seguimientos_estado (id_estado_solicitud),
    KEY idx_seguimientos_usuario (id_usuario),
    CONSTRAINT fk_seguimientos_estados_solicitudes FOREIGN KEY (id_estado_solicitud) REFERENCES estados_solicitudes (id_estado_solicitud) ON UPDATE CASCADE,
    CONSTRAINT fk_seguimientos_usuarios FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET @col_ayuda_estado_solicitud := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'ayuda_social'
      AND COLUMN_NAME = 'id_estado_solicitud'
);
SET @sql := IF(
    @col_ayuda_estado_solicitud = 0,
    'ALTER TABLE ayuda_social ADD COLUMN id_estado_solicitud INT(11) NULL AFTER id_solicitud_ayuda_social',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_servicios_estado_solicitud := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'servicios_publicos'
      AND COLUMN_NAME = 'id_estado_solicitud'
);
SET @sql := IF(
    @col_servicios_estado_solicitud = 0,
    'ALTER TABLE servicios_publicos ADD COLUMN id_estado_solicitud INT(11) NULL AFTER id_solicitud_servicio_publico',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_seguridad_estado_solicitud := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'seguridad'
      AND COLUMN_NAME = 'id_estado_solicitud'
);
SET @sql := IF(
    @col_seguridad_estado_solicitud = 0,
    'ALTER TABLE seguridad ADD COLUMN id_estado_solicitud INT(11) NULL AFTER id_solicitud_seguridad',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @id_estado_registrada := (
    SELECT id_estado_solicitud
    FROM estados_solicitudes
    WHERE codigo_estado = 'REGISTRADA'
    LIMIT 1
);
SET @id_estado_en_gestion := (
    SELECT id_estado_solicitud
    FROM estados_solicitudes
    WHERE codigo_estado = 'EN_GESTION'
    LIMIT 1
);
SET @id_estado_atendida := (
    SELECT id_estado_solicitud
    FROM estados_solicitudes
    WHERE codigo_estado = 'ATENDIDA'
    LIMIT 1
);
SET @id_estado_no_atendida := (
    SELECT id_estado_solicitud
    FROM estados_solicitudes
    WHERE codigo_estado = 'NO_ATENDIDA'
    LIMIT 1
);

UPDATE ayuda_social
SET id_estado_solicitud = CASE
    WHEN COALESCE(id_estado_solicitud, 0) > 0 THEN id_estado_solicitud
    WHEN estado = 1 THEN @id_estado_atendida
    ELSE @id_estado_registrada
END;

UPDATE ayuda_social
SET estado = 1
WHERE id_estado_solicitud IS NOT NULL;

UPDATE servicios_publicos
SET id_estado_solicitud = CASE
    WHEN COALESCE(id_estado_solicitud, 0) > 0 THEN id_estado_solicitud
    WHEN estado = 1 THEN @id_estado_atendida
    ELSE @id_estado_registrada
END;

UPDATE servicios_publicos
SET estado = 1
WHERE id_estado_solicitud IS NOT NULL;

UPDATE seguridad
SET id_estado_solicitud = CASE
    WHEN COALESCE(id_estado_solicitud, 0) > 0 THEN id_estado_solicitud
    WHEN estado_atencion = 'FINALIZADO' THEN @id_estado_atendida
    WHEN estado_atencion = 'DESPACHADO' THEN @id_estado_en_gestion
    WHEN estado_atencion = 'PENDIENTE_UNIDAD' THEN @id_estado_en_gestion
    WHEN estado_atencion = 'ANULADO' THEN @id_estado_no_atendida
    ELSE @id_estado_registrada
END;

SET @fk_ayuda_estado_solicitud := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'ayuda_social'
      AND CONSTRAINT_NAME = 'fk_ayuda_social_estado_solicitud'
);
SET @sql := IF(
    @fk_ayuda_estado_solicitud = 0,
    'ALTER TABLE ayuda_social ADD INDEX idx_ayuda_social_estado_solicitud (id_estado_solicitud), ADD CONSTRAINT fk_ayuda_social_estado_solicitud FOREIGN KEY (id_estado_solicitud) REFERENCES estados_solicitudes (id_estado_solicitud) ON UPDATE CASCADE',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_servicios_estado_solicitud := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'servicios_publicos'
      AND CONSTRAINT_NAME = 'fk_servicios_publicos_estado_solicitud'
);
SET @sql := IF(
    @fk_servicios_estado_solicitud = 0,
    'ALTER TABLE servicios_publicos ADD INDEX idx_servicios_publicos_estado_solicitud (id_estado_solicitud), ADD CONSTRAINT fk_servicios_publicos_estado_solicitud FOREIGN KEY (id_estado_solicitud) REFERENCES estados_solicitudes (id_estado_solicitud) ON UPDATE CASCADE',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_seguridad_estado_solicitud := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'seguridad'
      AND CONSTRAINT_NAME = 'fk_seguridad_estado_solicitud'
);
SET @sql := IF(
    @fk_seguridad_estado_solicitud = 0,
    'ALTER TABLE seguridad ADD INDEX idx_seguridad_estado_solicitud (id_estado_solicitud), ADD CONSTRAINT fk_seguridad_estado_solicitud FOREIGN KEY (id_estado_solicitud) REFERENCES estados_solicitudes (id_estado_solicitud) ON UPDATE CASCADE',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

INSERT INTO seguimientos_solicitudes (modulo, id_referencia, id_estado_solicitud, id_usuario, fecha_gestion, observacion, estado)
SELECT 'AYUDA_SOCIAL',
       a.id_ayuda,
       a.id_estado_solicitud,
       a.id_usuario,
       STR_TO_DATE(CONCAT(DATE_FORMAT(COALESCE(a.fecha_ayuda, CURDATE()), '%Y-%m-%d'), ' 08:00:00'), '%Y-%m-%d %H:%i:%s'),
       'Registro migrado al control general de estados de solicitudes.',
       1
FROM ayuda_social AS a
LEFT JOIN seguimientos_solicitudes AS ss
    ON ss.modulo = 'AYUDA_SOCIAL'
   AND ss.id_referencia = a.id_ayuda
   AND ss.estado = 1
WHERE a.id_estado_solicitud IS NOT NULL
  AND ss.id_seguimiento_solicitud IS NULL;

INSERT INTO seguimientos_solicitudes (modulo, id_referencia, id_estado_solicitud, id_usuario, fecha_gestion, observacion, estado)
SELECT 'SERVICIOS_PUBLICOS',
       sp.id_servicio,
       sp.id_estado_solicitud,
       sp.id_usuario,
       STR_TO_DATE(CONCAT(DATE_FORMAT(COALESCE(sp.fecha_servicio, CURDATE()), '%Y-%m-%d'), ' 08:00:00'), '%Y-%m-%d %H:%i:%s'),
       'Registro migrado al control general de estados de solicitudes.',
       1
FROM servicios_publicos AS sp
LEFT JOIN seguimientos_solicitudes AS ss
    ON ss.modulo = 'SERVICIOS_PUBLICOS'
   AND ss.id_referencia = sp.id_servicio
   AND ss.estado = 1
WHERE sp.id_estado_solicitud IS NOT NULL
  AND ss.id_seguimiento_solicitud IS NULL;

INSERT INTO seguimientos_solicitudes (modulo, id_referencia, id_estado_solicitud, id_usuario, fecha_gestion, observacion, estado)
SELECT 'SEGURIDAD',
       s.id_seguridad,
       s.id_estado_solicitud,
       s.id_usuario,
       COALESCE(s.fecha_seguridad, NOW()),
       'Registro migrado al control general de estados de solicitudes.',
       1
FROM seguridad AS s
LEFT JOIN seguimientos_solicitudes AS ss
    ON ss.modulo = 'SEGURIDAD'
   AND ss.id_referencia = s.id_seguridad
   AND ss.estado = 1
WHERE s.id_estado_solicitud IS NOT NULL
  AND ss.id_seguimiento_solicitud IS NULL;
