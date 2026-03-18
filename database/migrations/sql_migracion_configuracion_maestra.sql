USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

ALTER TABLE `comunidades`
    ADD COLUMN IF NOT EXISTS `estado` TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE `tipos_ayuda_social`
    ADD COLUMN IF NOT EXISTS `estado` TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE `solicitudes_generales`
    ADD COLUMN IF NOT EXISTS `estado` TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE `tipos_servicios_publicos`
    ADD COLUMN IF NOT EXISTS `estado` TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE `tipos_seguridad_emergencia`
    ADD COLUMN IF NOT EXISTS `estado` TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE `solicitudes_seguridad_emergencia`
    ADD COLUMN IF NOT EXISTS `estado` TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE `estados_solicitudes`
    ADD COLUMN IF NOT EXISTS `estado` TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE `dependencias`
    ADD COLUMN IF NOT EXISTS `estado` TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE `permisos`
    ADD COLUMN IF NOT EXISTS `estado` TINYINT(1) NOT NULL DEFAULT 1;

UPDATE `comunidades` SET `estado` = 1 WHERE `estado` IS NULL;
UPDATE `tipos_ayuda_social` SET `estado` = 1 WHERE `estado` IS NULL;
UPDATE `solicitudes_generales` SET `estado` = 1 WHERE `estado` IS NULL;
UPDATE `tipos_servicios_publicos` SET `estado` = 1 WHERE `estado` IS NULL;
UPDATE `tipos_seguridad_emergencia` SET `estado` = 1 WHERE `estado` IS NULL;
UPDATE `solicitudes_seguridad_emergencia` SET `estado` = 1 WHERE `estado` IS NULL;
UPDATE `estados_solicitudes` SET `estado` = 1 WHERE `estado` IS NULL;
UPDATE `dependencias` SET `estado` = 1 WHERE `estado` IS NULL;
UPDATE `permisos` SET `estado` = 1 WHERE `estado` IS NULL;

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `dependencias` ADD UNIQUE KEY `uk_dependencias_nombre` (`nombre_dependencia`)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'dependencias'
      AND column_name = 'nombre_dependencia'
      AND non_unique = 0
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `dependencias` ADD KEY `idx_dependencias_estado_nombre` (`estado`, `nombre_dependencia`)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'dependencias'
      AND index_name = 'idx_dependencias_estado_nombre'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `permisos` ADD UNIQUE KEY `uk_permisos_nombre` (`nombre_permiso`)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'permisos'
      AND column_name = 'nombre_permiso'
      AND non_unique = 0
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `permisos` ADD KEY `idx_permisos_estado_nombre` (`estado`, `nombre_permiso`)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'permisos'
      AND index_name = 'idx_permisos_estado_nombre'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `estados_solicitudes` ADD UNIQUE KEY `uk_estados_solicitudes_nombre` (`nombre_estado`)',
        'SELECT 1'
    )
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'estados_solicitudes'
      AND column_name = 'nombre_estado'
      AND non_unique = 0
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
