SET @sql_use_main = 'USE `sala_situacional`';
PREPARE stmt_use_main FROM @sql_use_main;
EXECUTE stmt_use_main;
DEALLOCATE PREPARE stmt_use_main;