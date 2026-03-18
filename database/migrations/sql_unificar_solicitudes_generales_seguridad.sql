USE sala03v2_4;

START TRANSACTION;
SET SESSION sql_safe_updates = 0;

SET @tabla_solicitudes_seguridad_existe := (
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name = 'solicitudes_seguridad_emergencia'
);

SET @sql_seed_solicitudes_generales := IF(
    @tabla_solicitudes_seguridad_existe = 1,
    "INSERT INTO solicitudes_generales (codigo_solicitud, nombre_solicitud, estado)
     SELECT CONCAT('SEG-', LPAD(sse.id_solicitud_seguridad, 5, '0')),
            sse.nombre_solicitud,
            IFNULL(sse.estado, 1)
     FROM solicitudes_seguridad_emergencia sse
     WHERE NOT EXISTS (
         SELECT 1
         FROM solicitudes_generales sg
         WHERE UPPER(TRIM(sg.nombre_solicitud)) = UPPER(TRIM(sse.nombre_solicitud))
     )",
    'SELECT 1'
);
PREPARE stmt_seed_solicitudes_generales FROM @sql_seed_solicitudes_generales;
EXECUTE stmt_seed_solicitudes_generales;
DEALLOCATE PREPARE stmt_seed_solicitudes_generales;

SET @sql_mapear_solicitudes_seguridad := IF(
    @tabla_solicitudes_seguridad_existe = 1,
    "UPDATE seguridad s
     LEFT JOIN solicitudes_seguridad_emergencia sse
         ON sse.id_solicitud_seguridad = s.id_solicitud_seguridad
     LEFT JOIN solicitudes_generales sg_desde_seguridad
         ON UPPER(TRIM(sg_desde_seguridad.nombre_solicitud)) = UPPER(TRIM(COALESCE(sse.nombre_solicitud, '')))
     LEFT JOIN solicitudes_generales sg_desde_texto
         ON UPPER(TRIM(sg_desde_texto.nombre_solicitud)) = UPPER(TRIM(COALESCE(s.tipo_solicitud, '')))
     SET s.id_solicitud_seguridad = COALESCE(
             sg_desde_seguridad.id_solicitud_general,
             sg_desde_texto.id_solicitud_general,
             s.id_solicitud_seguridad
         ),
         s.tipo_solicitud = COALESCE(
             sg_desde_seguridad.nombre_solicitud,
             sg_desde_texto.nombre_solicitud,
             s.tipo_solicitud
         )",
    "UPDATE seguridad s
     LEFT JOIN solicitudes_generales sg_desde_texto
         ON UPPER(TRIM(sg_desde_texto.nombre_solicitud)) = UPPER(TRIM(COALESCE(s.tipo_solicitud, '')))
     SET s.id_solicitud_seguridad = COALESCE(sg_desde_texto.id_solicitud_general, s.id_solicitud_seguridad),
         s.tipo_solicitud = COALESCE(sg_desde_texto.nombre_solicitud, s.tipo_solicitud)"
);
PREPARE stmt_mapear_solicitudes_seguridad FROM @sql_mapear_solicitudes_seguridad;
EXECUTE stmt_mapear_solicitudes_seguridad;
DEALLOCATE PREPARE stmt_mapear_solicitudes_seguridad;

UPDATE seguridad s
LEFT JOIN solicitudes_generales sg
    ON sg.id_solicitud_general = s.id_solicitud_seguridad
SET s.id_solicitud_seguridad = NULL
WHERE s.id_solicitud_seguridad IS NOT NULL
  AND sg.id_solicitud_general IS NULL;

SET @fk_seguridad_solicitudes := (
    SELECT kcu.constraint_name
    FROM information_schema.key_column_usage kcu
    WHERE kcu.table_schema = DATABASE()
      AND kcu.table_name = 'seguridad'
      AND kcu.column_name = 'id_solicitud_seguridad'
      AND kcu.referenced_table_name IS NOT NULL
    LIMIT 1
);

SET @sql_drop_fk_solicitudes := IF(
    @fk_seguridad_solicitudes IS NOT NULL,
    CONCAT('ALTER TABLE seguridad DROP FOREIGN KEY `', @fk_seguridad_solicitudes, '`'),
    'SELECT 1'
);
PREPARE stmt_drop_fk_solicitudes FROM @sql_drop_fk_solicitudes;
EXECUTE stmt_drop_fk_solicitudes;
DEALLOCATE PREPARE stmt_drop_fk_solicitudes;

SET @fk_solicitudes_generales_existe := (
    SELECT COUNT(*)
    FROM information_schema.referential_constraints
    WHERE constraint_schema = DATABASE()
      AND table_name = 'seguridad'
      AND constraint_name = 'fk_seguridad_solicitudes_generales'
);

SET @sql_add_fk_solicitudes := IF(
    @fk_solicitudes_generales_existe = 0,
    'ALTER TABLE seguridad ADD CONSTRAINT fk_seguridad_solicitudes_generales FOREIGN KEY (id_solicitud_seguridad) REFERENCES solicitudes_generales(id_solicitud_general) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt_add_fk_solicitudes FROM @sql_add_fk_solicitudes;
EXECUTE stmt_add_fk_solicitudes;
DEALLOCATE PREPARE stmt_add_fk_solicitudes;

SET @sql_drop_tabla_solicitudes_seguridad := IF(
    @tabla_solicitudes_seguridad_existe = 1,
    'DROP TABLE solicitudes_seguridad_emergencia',
    'SELECT 1'
);
PREPARE stmt_drop_tabla_solicitudes_seguridad FROM @sql_drop_tabla_solicitudes_seguridad;
EXECUTE stmt_drop_tabla_solicitudes_seguridad;
DEALLOCATE PREPARE stmt_drop_tabla_solicitudes_seguridad;

COMMIT;
