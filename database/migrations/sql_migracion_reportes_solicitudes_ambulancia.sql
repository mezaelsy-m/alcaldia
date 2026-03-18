-- =============================================================
-- Migracion: Reportes de solicitudes de ambulancia (registro/cierre)
-- Fecha: 2026-03-17
-- =============================================================

CREATE TABLE IF NOT EXISTS reportes_solicitudes_ambulancia (
    id_reporte_solicitud INT(11) NOT NULL AUTO_INCREMENT,
    id_seguridad INT(11) NOT NULL,
    id_despacho_unidad INT(11) NULL,
    tipo_reporte ENUM('REGISTRO','CIERRE') NOT NULL DEFAULT 'REGISTRO',
    nombre_archivo VARCHAR(180) NOT NULL,
    ruta_archivo VARCHAR(255) NOT NULL,
    estado_envio ENUM('NO_APLICA','PENDIENTE','ENVIADO','ERROR') NOT NULL DEFAULT 'NO_APLICA',
    correo_destino VARCHAR(150) NULL,
    fecha_envio DATETIME NULL,
    detalle_envio TEXT NULL,
    id_usuario_genera INT(11) NULL,
    fecha_generacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_reporte_solicitud),
    KEY idx_rsa_seguridad (id_seguridad, estado, tipo_reporte),
    KEY idx_rsa_despacho (id_despacho_unidad),
    KEY idx_rsa_usuario (id_usuario_genera),
    KEY idx_rsa_envio (estado_envio, fecha_envio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE reportes_solicitudes_ambulancia
    ADD COLUMN IF NOT EXISTS id_seguridad INT(11) NOT NULL AFTER id_reporte_solicitud,
    ADD COLUMN IF NOT EXISTS id_despacho_unidad INT(11) NULL AFTER id_seguridad,
    ADD COLUMN IF NOT EXISTS tipo_reporte ENUM('REGISTRO','CIERRE') NOT NULL DEFAULT 'REGISTRO' AFTER id_despacho_unidad,
    ADD COLUMN IF NOT EXISTS nombre_archivo VARCHAR(180) NOT NULL AFTER tipo_reporte,
    ADD COLUMN IF NOT EXISTS ruta_archivo VARCHAR(255) NOT NULL AFTER nombre_archivo,
    ADD COLUMN IF NOT EXISTS estado_envio ENUM('NO_APLICA','PENDIENTE','ENVIADO','ERROR') NOT NULL DEFAULT 'NO_APLICA' AFTER ruta_archivo,
    ADD COLUMN IF NOT EXISTS correo_destino VARCHAR(150) NULL AFTER estado_envio,
    ADD COLUMN IF NOT EXISTS fecha_envio DATETIME NULL AFTER correo_destino,
    ADD COLUMN IF NOT EXISTS detalle_envio TEXT NULL AFTER fecha_envio,
    ADD COLUMN IF NOT EXISTS id_usuario_genera INT(11) NULL AFTER detalle_envio,
    ADD COLUMN IF NOT EXISTS fecha_generacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER id_usuario_genera,
    ADD COLUMN IF NOT EXISTS estado TINYINT(1) NOT NULL DEFAULT 1 AFTER fecha_generacion;

SET @idx_rsa_seguridad := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'reportes_solicitudes_ambulancia'
      AND INDEX_NAME = 'idx_rsa_seguridad'
);
SET @sql_idx_rsa_seguridad := IF(
    @idx_rsa_seguridad = 0,
    'ALTER TABLE reportes_solicitudes_ambulancia ADD INDEX idx_rsa_seguridad (id_seguridad, estado, tipo_reporte)',
    'SELECT 1'
);
PREPARE stmt_idx_rsa_seguridad FROM @sql_idx_rsa_seguridad;
EXECUTE stmt_idx_rsa_seguridad;
DEALLOCATE PREPARE stmt_idx_rsa_seguridad;

SET @idx_rsa_despacho := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'reportes_solicitudes_ambulancia'
      AND INDEX_NAME = 'idx_rsa_despacho'
);
SET @sql_idx_rsa_despacho := IF(
    @idx_rsa_despacho = 0,
    'ALTER TABLE reportes_solicitudes_ambulancia ADD INDEX idx_rsa_despacho (id_despacho_unidad)',
    'SELECT 1'
);
PREPARE stmt_idx_rsa_despacho FROM @sql_idx_rsa_despacho;
EXECUTE stmt_idx_rsa_despacho;
DEALLOCATE PREPARE stmt_idx_rsa_despacho;

SET @idx_rsa_usuario := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'reportes_solicitudes_ambulancia'
      AND INDEX_NAME = 'idx_rsa_usuario'
);
SET @sql_idx_rsa_usuario := IF(
    @idx_rsa_usuario = 0,
    'ALTER TABLE reportes_solicitudes_ambulancia ADD INDEX idx_rsa_usuario (id_usuario_genera)',
    'SELECT 1'
);
PREPARE stmt_idx_rsa_usuario FROM @sql_idx_rsa_usuario;
EXECUTE stmt_idx_rsa_usuario;
DEALLOCATE PREPARE stmt_idx_rsa_usuario;

SET @fk_rsa_seguridad := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'reportes_solicitudes_ambulancia'
      AND CONSTRAINT_NAME = 'fk_rsa_seguridad'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_rsa_seguridad := IF(
    @fk_rsa_seguridad = 0,
    'ALTER TABLE reportes_solicitudes_ambulancia ADD CONSTRAINT fk_rsa_seguridad FOREIGN KEY (id_seguridad) REFERENCES seguridad(id_seguridad) ON UPDATE CASCADE ON DELETE CASCADE',
    'SELECT 1'
);
PREPARE stmt_fk_rsa_seguridad FROM @sql_fk_rsa_seguridad;
EXECUTE stmt_fk_rsa_seguridad;
DEALLOCATE PREPARE stmt_fk_rsa_seguridad;

SET @fk_rsa_despacho := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'reportes_solicitudes_ambulancia'
      AND CONSTRAINT_NAME = 'fk_rsa_despacho'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_rsa_despacho := IF(
    @fk_rsa_despacho = 0,
    'ALTER TABLE reportes_solicitudes_ambulancia ADD CONSTRAINT fk_rsa_despacho FOREIGN KEY (id_despacho_unidad) REFERENCES despachos_unidades(id_despacho_unidad) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt_fk_rsa_despacho FROM @sql_fk_rsa_despacho;
EXECUTE stmt_fk_rsa_despacho;
DEALLOCATE PREPARE stmt_fk_rsa_despacho;

SET @fk_rsa_usuario := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'reportes_solicitudes_ambulancia'
      AND CONSTRAINT_NAME = 'fk_rsa_usuario'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_rsa_usuario := IF(
    @fk_rsa_usuario = 0,
    'ALTER TABLE reportes_solicitudes_ambulancia ADD CONSTRAINT fk_rsa_usuario FOREIGN KEY (id_usuario_genera) REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt_fk_rsa_usuario FROM @sql_fk_rsa_usuario;
EXECUTE stmt_fk_rsa_usuario;
DEALLOCATE PREPARE stmt_fk_rsa_usuario;

