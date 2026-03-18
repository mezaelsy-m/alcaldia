USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

CREATE TABLE IF NOT EXISTS `solicitudes_generales` (
    `id_solicitud_general` INT(11) NOT NULL AUTO_INCREMENT,
    `codigo_solicitud` VARCHAR(20) NOT NULL,
    `nombre_solicitud` VARCHAR(120) NOT NULL,
    `estado` TINYINT(1) NOT NULL DEFAULT 1,
    `fecha_registro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_solicitud_general`),
    UNIQUE KEY `uk_solicitudes_generales_codigo` (`codigo_solicitud`),
    UNIQUE KEY `uk_solicitudes_generales_nombre` (`nombre_solicitud`),
    KEY `idx_solicitudes_generales_estado_codigo_nombre` (`estado`, `codigo_solicitud`, `nombre_solicitud`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO `solicitudes_generales` (`codigo_solicitud`, `nombre_solicitud`, `estado`) VALUES
('SOL-1X10', '1X10', 1),
('SOL-ATC', 'Atencion al ciudadano', 1),
('SOL-RDS', 'Redes sociales', 1);

SET @sql = (
    SELECT IF(
        COUNT(*) > 0,
        "INSERT INTO `solicitudes_generales` (`codigo_solicitud`, `nombre_solicitud`, `estado`)
         SELECT
             CASE UPPER(TRIM(`nombre_solicitud_ayuda`))
                 WHEN '1X10' THEN 'SOL-1X10'
                 WHEN 'ATENCION AL CIUDADANO' THEN 'SOL-ATC'
                 WHEN 'REDES SOCIALES' THEN 'SOL-RDS'
                 ELSE CONCAT('SOL-', LPAD(`id_solicitud_ayuda_social`, 4, '0'))
             END,
             CASE UPPER(TRIM(`nombre_solicitud_ayuda`))
                 WHEN 'REDES SOCIALES' THEN 'Redes sociales'
                 WHEN 'ATENCION AL CIUDADANO' THEN 'Atencion al ciudadano'
                 ELSE TRIM(`nombre_solicitud_ayuda`)
             END,
             `estado`
         FROM `solicitudes_ayuda_social`
         ON DUPLICATE KEY UPDATE
             `codigo_solicitud` = VALUES(`codigo_solicitud`),
             `nombre_solicitud` = VALUES(`nombre_solicitud`),
             `estado` = VALUES(`estado`)",
        "SELECT 1"
    )
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name = 'solicitudes_ayuda_social'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        COUNT(*) > 0,
        "INSERT INTO `solicitudes_generales` (`codigo_solicitud`, `nombre_solicitud`, `estado`)
         SELECT
             CASE UPPER(TRIM(`nombre_solicitud_servicio`))
                 WHEN '1X10' THEN 'SOL-1X10'
                 WHEN 'ATENCION AL CIUDADANO' THEN 'SOL-ATC'
                 WHEN 'REDES SOCIALES' THEN 'SOL-RDS'
                 ELSE COALESCE(NULLIF(TRIM(`codigo_solicitud_servicio_publico`), ''), CONCAT('SOL-', LPAD(`id_solicitud_servicio_publico`, 4, '0')))
             END,
             CASE UPPER(TRIM(`nombre_solicitud_servicio`))
                 WHEN 'REDES SOCIALES' THEN 'Redes sociales'
                 WHEN 'ATENCION AL CIUDADANO' THEN 'Atencion al ciudadano'
                 ELSE TRIM(`nombre_solicitud_servicio`)
             END,
             `estado`
         FROM `solicitudes_servicios_publicos`
         ON DUPLICATE KEY UPDATE
             `codigo_solicitud` = VALUES(`codigo_solicitud`),
             `nombre_solicitud` = VALUES(`nombre_solicitud`),
             `estado` = VALUES(`estado`)",
        "SELECT 1"
    )
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name = 'solicitudes_servicios_publicos'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE `ayuda_social` AS `a`
INNER JOIN `solicitudes_generales` AS `sg`
    ON UPPER(TRIM(`sg`.`nombre_solicitud`)) = CASE UPPER(TRIM(COALESCE(`a`.`solicitud_ayuda`, '')))
        WHEN 'REDES SOCIALES' THEN 'REDES SOCIALES'
        WHEN 'ATENCION AL CIUDADANO' THEN 'ATENCION AL CIUDADANO'
        ELSE UPPER(TRIM(COALESCE(`a`.`solicitud_ayuda`, '')))
    END
SET `a`.`id_solicitud_ayuda_social` = `sg`.`id_solicitud_general`,
    `a`.`solicitud_ayuda` = `sg`.`nombre_solicitud`
WHERE `a`.`solicitud_ayuda` IS NOT NULL
  AND TRIM(`a`.`solicitud_ayuda`) <> '';

UPDATE `servicios_publicos` AS `sp`
INNER JOIN `solicitudes_generales` AS `sg`
    ON UPPER(TRIM(`sg`.`nombre_solicitud`)) = CASE UPPER(TRIM(COALESCE(`sp`.`solicitud_servicio`, '')))
        WHEN 'REDES SOCIALES' THEN 'REDES SOCIALES'
        WHEN 'ATENCION AL CIUDADANO' THEN 'ATENCION AL CIUDADANO'
        ELSE UPPER(TRIM(COALESCE(`sp`.`solicitud_servicio`, '')))
    END
SET `sp`.`id_solicitud_servicio_publico` = `sg`.`id_solicitud_general`,
    `sp`.`solicitud_servicio` = `sg`.`nombre_solicitud`
WHERE `sp`.`solicitud_servicio` IS NOT NULL
  AND TRIM(`sp`.`solicitud_servicio`) <> '';

SET @fk_ayuda = (
    SELECT `constraint_name`
    FROM information_schema.key_column_usage
    WHERE table_schema = DATABASE()
      AND table_name = 'ayuda_social'
      AND column_name = 'id_solicitud_ayuda_social'
      AND referenced_table_name IS NOT NULL
    LIMIT 1
);
SET @sql = IF(@fk_ayuda IS NULL, 'SELECT 1', CONCAT('ALTER TABLE `ayuda_social` DROP FOREIGN KEY `', @fk_ayuda, '`'));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_servicios = (
    SELECT `constraint_name`
    FROM information_schema.key_column_usage
    WHERE table_schema = DATABASE()
      AND table_name = 'servicios_publicos'
      AND column_name = 'id_solicitud_servicio_publico'
      AND referenced_table_name IS NOT NULL
    LIMIT 1
);
SET @sql = IF(@fk_servicios IS NULL, 'SELECT 1', CONCAT('ALTER TABLE `servicios_publicos` DROP FOREIGN KEY `', @fk_servicios, '`'));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `ayuda_social` ADD CONSTRAINT `fk_ayuda_social_solicitudes_generales` FOREIGN KEY (`id_solicitud_ayuda_social`) REFERENCES `solicitudes_generales`(`id_solicitud_general`) ON UPDATE CASCADE ON DELETE RESTRICT',
        'SELECT 1'
    )
    FROM information_schema.key_column_usage
    WHERE table_schema = DATABASE()
      AND table_name = 'ayuda_social'
      AND column_name = 'id_solicitud_ayuda_social'
      AND referenced_table_name = 'solicitudes_generales'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `servicios_publicos` ADD CONSTRAINT `fk_servicios_publicos_solicitudes_generales` FOREIGN KEY (`id_solicitud_servicio_publico`) REFERENCES `solicitudes_generales`(`id_solicitud_general`) ON UPDATE CASCADE ON DELETE RESTRICT',
        'SELECT 1'
    )
    FROM information_schema.key_column_usage
    WHERE table_schema = DATABASE()
      AND table_name = 'servicios_publicos'
      AND column_name = 'id_solicitud_servicio_publico'
      AND referenced_table_name = 'solicitudes_generales'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP TABLE IF EXISTS `solicitudes_ayuda_social`;
DROP TABLE IF EXISTS `solicitudes_servicios_publicos`;
