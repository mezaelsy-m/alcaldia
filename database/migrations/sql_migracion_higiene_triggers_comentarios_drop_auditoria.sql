USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

-- 1) Eliminar dependencias de la tabla auditoria (vistas/triggers) y eliminar la tabla.
SET @sql_drop_views := (
    SELECT GROUP_CONCAT(CONCAT('DROP VIEW IF EXISTS `', TABLE_NAME, '`') SEPARATOR '; ')
    FROM information_schema.VIEWS
    WHERE TABLE_SCHEMA = DATABASE()
      AND VIEW_DEFINITION LIKE '%auditoria%'
);
SET @sql_drop_views := IFNULL(@sql_drop_views, 'SELECT 1');
PREPARE stmt FROM @sql_drop_views;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql_drop_triggers := (
    SELECT GROUP_CONCAT(CONCAT('DROP TRIGGER IF EXISTS `', TRIGGER_NAME, '`') SEPARATOR '; ')
    FROM information_schema.TRIGGERS
    WHERE TRIGGER_SCHEMA = DATABASE()
      AND (
          EVENT_OBJECT_TABLE = 'auditoria'
          OR ACTION_STATEMENT LIKE '%auditoria%'
      )
);
SET @sql_drop_triggers := IFNULL(@sql_drop_triggers, 'SELECT 1');
PREPARE stmt FROM @sql_drop_triggers;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP TABLE IF EXISTS auditoria;

-- 2) Recrear vista de monitoreo sin dependencia de auditoria (si existe respaldos_internos).
SET @existe_respaldos := (
    SELECT COUNT(*)
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'respaldos_internos'
      AND TABLE_TYPE = 'BASE TABLE'
);

SET @sql_recrear_vista := IF(
    @existe_respaldos > 0,
    'CREATE OR REPLACE VIEW vista_monitoreo_backups AS
     SELECT r.fecha_generacion AS Fecha,
            r.tabla_nombre AS Tabla,
            r.motivo AS Evento,
            ''AUTOMATICO'' AS Tipo
     FROM respaldos_internos AS r
     ORDER BY r.fecha_generacion DESC',
    'SELECT 1'
);
PREPARE stmt FROM @sql_recrear_vista;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3) Trigger global de bloqueo de DELETE fisico para tablas con columna estado.
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_crear_trigger_softdelete_por_tabla$$
CREATE PROCEDURE sp_crear_trigger_softdelete_por_tabla(IN p_tabla VARCHAR(128))
main: BEGIN
    DECLARE v_existe_tabla INT DEFAULT 0;
    DECLARE v_existe_estado INT DEFAULT 0;
    DECLARE v_trigger VARCHAR(190);

    SELECT COUNT(*) INTO v_existe_tabla
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = p_tabla
      AND TABLE_TYPE = 'BASE TABLE';

    IF v_existe_tabla = 0 THEN
        LEAVE main;
    END IF;

    SELECT COUNT(*) INTO v_existe_estado
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = p_tabla
      AND COLUMN_NAME = 'estado';

    IF v_existe_estado = 0 THEN
        LEAVE main;
    END IF;

    SET v_trigger = CONCAT('tr_', p_tabla, '_bd_block_delete');

    SET @sql_drop_trigger = CONCAT('DROP TRIGGER IF EXISTS `', v_trigger, '`');
    PREPARE stmt FROM @sql_drop_trigger;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @sql_create_trigger = CONCAT(
        'CREATE TRIGGER `', v_trigger, '` BEFORE DELETE ON `', p_tabla, '` FOR EACH ROW ',
        'BEGIN ',
        'SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''Eliminacion fisica bloqueada en tabla ', p_tabla, '. Use estado=0 para soft delete.''; ',
        'END'
    );
    PREPARE stmt FROM @sql_create_trigger;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DROP PROCEDURE IF EXISTS sp_aplicar_triggers_softdelete_global$$
CREATE PROCEDURE sp_aplicar_triggers_softdelete_global()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_tabla VARCHAR(128);

    DECLARE cur CURSOR FOR
        SELECT DISTINCT c.TABLE_NAME
        FROM information_schema.COLUMNS AS c
        INNER JOIN information_schema.TABLES AS t
            ON t.TABLE_SCHEMA = c.TABLE_SCHEMA
           AND t.TABLE_NAME = c.TABLE_NAME
        WHERE c.TABLE_SCHEMA = DATABASE()
          AND c.COLUMN_NAME = 'estado'
          AND t.TABLE_TYPE = 'BASE TABLE'
        ORDER BY c.TABLE_NAME;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    loop_tablas: LOOP
        FETCH cur INTO v_tabla;
        IF done = 1 THEN
            LEAVE loop_tablas;
        END IF;

        CALL sp_crear_trigger_softdelete_por_tabla(v_tabla);
    END LOOP;

    CLOSE cur;
END$$

-- 4) Completar comentarios faltantes de columnas para tablas base.
DROP PROCEDURE IF EXISTS sp_comentar_columnas_sin_comentario$$
CREATE PROCEDURE sp_comentar_columnas_sin_comentario()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_tabla VARCHAR(128);
    DECLARE v_columna VARCHAR(128);
    DECLARE v_columna_tipo TEXT;
    DECLARE v_es_nulo VARCHAR(3);
    DECLARE v_default_valor TEXT;
    DECLARE v_extra TEXT;
    DECLARE v_data_type VARCHAR(64);

    DECLARE v_null_sql VARCHAR(16);
    DECLARE v_default_sql TEXT;
    DECLARE v_extra_sql TEXT;
    DECLARE v_comment_sql TEXT;

    DECLARE cur CURSOR FOR
        SELECT c.TABLE_NAME,
               c.COLUMN_NAME,
               c.COLUMN_TYPE,
               c.IS_NULLABLE,
               c.COLUMN_DEFAULT,
               c.EXTRA,
               c.DATA_TYPE
        FROM information_schema.COLUMNS AS c
        INNER JOIN information_schema.TABLES AS t
            ON t.TABLE_SCHEMA = c.TABLE_SCHEMA
           AND t.TABLE_NAME = c.TABLE_NAME
        WHERE c.TABLE_SCHEMA = DATABASE()
          AND t.TABLE_TYPE = 'BASE TABLE'
          AND IFNULL(c.COLUMN_COMMENT, '') = ''
          AND IFNULL(c.GENERATION_EXPRESSION, '') = ''
        ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    loop_cols: LOOP
        FETCH cur INTO v_tabla, v_columna, v_columna_tipo, v_es_nulo, v_default_valor, v_extra, v_data_type;
        IF done = 1 THEN
            LEAVE loop_cols;
        END IF;

        SET v_null_sql = IF(v_es_nulo = 'NO', ' NOT NULL', ' NULL');
        SET v_default_sql = '';

        IF LOWER(IFNULL(v_data_type, '')) NOT IN ('tinytext', 'text', 'mediumtext', 'longtext', 'tinyblob', 'blob', 'mediumblob', 'longblob', 'json')
           AND LOWER(IFNULL(v_extra, '')) NOT LIKE '%auto_increment%'
           AND LOWER(IFNULL(v_extra, '')) NOT LIKE '%generated%'
        THEN
            IF v_default_valor IS NULL THEN
                IF v_es_nulo = 'YES' THEN
                    SET v_default_sql = ' DEFAULT NULL';
                END IF;
            ELSEIF UPPER(TRIM(v_default_valor)) IN ('CURRENT_TIMESTAMP', 'CURRENT_TIMESTAMP()') THEN
                SET v_default_sql = ' DEFAULT CURRENT_TIMESTAMP';
            ELSE
                SET v_default_sql = CONCAT(' DEFAULT ', QUOTE(v_default_valor));
            END IF;
        END IF;

        SET v_extra_sql = IF(TRIM(IFNULL(v_extra, '')) = '', '', CONCAT(' ', v_extra));
        SET v_comment_sql = CONCAT('Campo ', v_columna, ' de la tabla ', v_tabla, '.');

        SET @sql_alter_col = CONCAT(
            'ALTER TABLE `', v_tabla, '` MODIFY COLUMN `', v_columna, '` ',
            v_columna_tipo,
            v_null_sql,
            v_default_sql,
            v_extra_sql,
            ' COMMENT ', QUOTE(v_comment_sql)
        );

        PREPARE stmt FROM @sql_alter_col;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

CALL sp_aplicar_triggers_softdelete_global();
CALL sp_comentar_columnas_sin_comentario();

DROP PROCEDURE IF EXISTS sp_aplicar_triggers_softdelete_global;
DROP PROCEDURE IF EXISTS sp_crear_trigger_softdelete_por_tabla;
DROP PROCEDURE IF EXISTS sp_comentar_columnas_sin_comentario;
