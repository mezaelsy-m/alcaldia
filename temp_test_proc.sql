DROP PROCEDURE IF EXISTS sp_try_exec_test;
DELIMITER $$
CREATE PROCEDURE sp_try_exec_test(IN p_sql LONGTEXT)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
    SET @sql_try_exec = p_sql;
    PREPARE stmt_try_exec FROM @sql_try_exec;
    EXECUTE stmt_try_exec;
    DEALLOCATE PREPARE stmt_try_exec;
END$$
DELIMITER ;
DROP PROCEDURE IF EXISTS sp_try_exec_test;