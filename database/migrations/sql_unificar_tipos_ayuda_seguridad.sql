USE sala03v2_4;

START TRANSACTION;
SET SESSION sql_safe_updates = 0;

ALTER TABLE tipos_ayuda_social
    ADD COLUMN IF NOT EXISTS requiere_ambulancia TINYINT(1) NOT NULL DEFAULT 0 AFTER nombre_tipo_ayuda;

UPDATE tipos_ayuda_social
SET requiere_ambulancia = IFNULL(requiere_ambulancia, 0)
WHERE requiere_ambulancia IS NULL;

INSERT INTO tipos_ayuda_social (nombre_tipo_ayuda, requiere_ambulancia, estado)
SELECT tse.nombre_tipo,
       IFNULL(tse.requiere_ambulancia, 0),
       IFNULL(tse.estado, 1)
FROM tipos_seguridad_emergencia tse
WHERE NOT EXISTS (
    SELECT 1
    FROM tipos_ayuda_social tas
    WHERE UPPER(TRIM(tas.nombre_tipo_ayuda)) = UPPER(TRIM(tse.nombre_tipo))
);

UPDATE tipos_ayuda_social tas
INNER JOIN tipos_seguridad_emergencia tse
    ON UPPER(TRIM(tas.nombre_tipo_ayuda)) = UPPER(TRIM(tse.nombre_tipo))
SET tas.requiere_ambulancia = CASE
        WHEN IFNULL(tas.requiere_ambulancia, 0) = 1 OR IFNULL(tse.requiere_ambulancia, 0) = 1 THEN 1
        ELSE 0
    END,
    tas.estado = IFNULL(tas.estado, 1);

UPDATE seguridad s
LEFT JOIN tipos_seguridad_emergencia tse
    ON tse.id_tipo_seguridad = s.id_tipo_seguridad
LEFT JOIN tipos_ayuda_social tas_desde_seg
    ON UPPER(TRIM(tas_desde_seg.nombre_tipo_ayuda)) = UPPER(TRIM(COALESCE(tse.nombre_tipo, '')))
LEFT JOIN tipos_ayuda_social tas_desde_texto
    ON UPPER(TRIM(tas_desde_texto.nombre_tipo_ayuda)) = UPPER(TRIM(COALESCE(s.tipo_seguridad, '')))
SET s.id_tipo_seguridad = COALESCE(
        tas_desde_seg.id_tipo_ayuda_social,
        tas_desde_texto.id_tipo_ayuda_social,
        s.id_tipo_seguridad
    ),
    s.tipo_seguridad = COALESCE(
        tas_desde_seg.nombre_tipo_ayuda,
        tas_desde_texto.nombre_tipo_ayuda,
        s.tipo_seguridad
    );

UPDATE seguridad s
LEFT JOIN tipos_ayuda_social tas
    ON tas.id_tipo_ayuda_social = s.id_tipo_seguridad
SET s.id_tipo_seguridad = NULL
WHERE s.id_tipo_seguridad IS NOT NULL
  AND tas.id_tipo_ayuda_social IS NULL;

SET @fk_seguridad_tipos := (
    SELECT kcu.constraint_name
    FROM information_schema.key_column_usage kcu
    WHERE kcu.table_schema = DATABASE()
      AND kcu.table_name = 'seguridad'
      AND kcu.column_name = 'id_tipo_seguridad'
      AND kcu.referenced_table_name IS NOT NULL
    LIMIT 1
);

SET @sql_drop_fk := IF(
    @fk_seguridad_tipos IS NOT NULL,
    CONCAT('ALTER TABLE seguridad DROP FOREIGN KEY `', @fk_seguridad_tipos, '`'),
    'SELECT 1'
);
PREPARE stmt_drop_fk FROM @sql_drop_fk;
EXECUTE stmt_drop_fk;
DEALLOCATE PREPARE stmt_drop_fk;

SET @fk_tipos_ayuda_existe := (
    SELECT COUNT(*)
    FROM information_schema.referential_constraints
    WHERE constraint_schema = DATABASE()
      AND table_name = 'seguridad'
      AND constraint_name = 'fk_seguridad_tipos_ayuda_social'
);

SET @sql_add_fk := IF(
    @fk_tipos_ayuda_existe = 0,
    'ALTER TABLE seguridad ADD CONSTRAINT fk_seguridad_tipos_ayuda_social FOREIGN KEY (id_tipo_seguridad) REFERENCES tipos_ayuda_social(id_tipo_ayuda_social) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt_add_fk FROM @sql_add_fk;
EXECUTE stmt_add_fk;
DEALLOCATE PREPARE stmt_add_fk;

COMMIT;
