USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

CREATE TABLE IF NOT EXISTS comunidades (
    id_comunidad INT(11) NOT NULL AUTO_INCREMENT,
    nombre_comunidad VARCHAR(120) NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hora_registro_12h CHAR(11) NOT NULL DEFAULT '',
    PRIMARY KEY (id_comunidad),
    UNIQUE KEY uk_comunidad_nombre (nombre_comunidad),
    KEY idx_comunidades_estado_nombre (estado, nombre_comunidad)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO comunidades (nombre_comunidad, estado) VALUES
('Casco Comercial de Tocuyito', 1),
('Urbanizacion Valles de San Francisco', 1),
('Conjunto Residencial Los Trescientos', 1),
('Urbanizacion Jose Rafael Pocaterra', 1),
('Centro Penitenciario Tocuyito', 1),
('Santa Eduviges', 1),
('Bella Vista', 1),
('Los Mangos', 1),
('La Herrerena', 1),
('Urbanizacion La Esperanza', 1),
('Triangulo El Oasis', 1),
('Hacienda Juana Paula', 1),
('Encrucijada de Carabobo', 1),
('Urbanizacion Santa Paula', 1),
('Hacienda La Trinidad', 1),
('Hacienda El Rosario', 1),
('El Rosario', 1),
('El Rosal', 1),
('Los Rosales', 1),
('Colinas del Rosario', 1),
('Barrio La Trinidad', 1),
('Zanjon Dulce', 1),
('Escuela de Cadafe', 1),
('12 de Octubre', 1),
('9 de Diciembre', 1),
('La Honda', 1),
('Altos de La Honda', 1),
('Banco Obrero Las Palmas', 1),
('Simon Bolivar', 1),
('Urbanizacion El Libertador', 1),
('Jardines del Cementerio El Oasis', 1),
('Parque Agrinco', 1),
('San Pablo Valley', 1),
('El Encanto', 1),
('Barrio El Oasis', 1),
('Urbanizacion Villa Jardin', 1),
('Avicola La Guasima', 1),
('La Guasima I y II', 1),
('Comunidad Bicentenario', 1),
('Comunidad Nueva Villa', 1),
('Comunidad Alexis Cravo', 1),
('Barrio Manuelita Saenz', 1),
('Comunidad Los Chaguaramos', 1),
('Vertedero La Guasima', 1),
('Fundacion CAP', 1),
('Barrio Bueno', 1),
('Los Chorritos', 1),
('Urbanizacion El Molino', 1),
('Comunidad Juncalito', 1),
('Urbanizacion Altos de Uslar', 1),
('Urbanizacion Negra Matea', 1),
('Comunidad Brisas de Guataparo', 1),
('Comunidad La Vega', 1),
('Comunidad El Vigia', 1),
('Comunidad El Charal', 1),
('Comunidad 23 de Enero', 1),
('Mayorista', 1),
('Colina de Carrizales', 1),
('Barrerita', 1),
('Safari Country Club', 1),
('Barrio Nueva Valencia', 1),
('Barrio Jardines de San Luis', 1),
('Urbanizacion San Luis', 1),
('Terrenos Propios del Municipio Libertador', 1),
('Urbanizacion Los Cardones', 1),
('Campamento Bautista', 1),
('Parcelamiento Los Aguacatales', 1),
('Hato Barrera', 1),
('Santa Isabel', 1),
('Hacienda San Rafael', 1),
('Comunidad La Yaguara', 1),
('Terrenos Inmediatos al Dique de Guataparo', 1),
('Hacienda Country Club', 1),
('Colinas de Carabobo', 1),
('Hector Pereda', 1),
('La Alegria', 1),
('Negro Primero', 1),
('Las Americas Jose Luis Martinez', 1),
('Barrera Norte', 1),
('Barrera Centro', 1),
('Hato Residencial La Gran Sabana', 1),
('Parcelamiento Sabana del Medio', 1),
('Campo de Carabobo', 1),
('Barrio El Cementerio', 1),
('Barrio del Rincon', 1),
('Barrio Sucre', 1),
('Barrio Union', 1),
('Brisas del Campo', 1),
('La Pica', 1),
('Las Manzanas', 1),
('Pueblo Nuevo', 1),
('Nuevo Carabobo', 1),
('El Rincon', 1),
('Los Chorros', 1),
('La Cuesta', 1),
('Manzana de Oro', 1),
('Los Cocos', 1),
('Las Manzanitas', 1),
('Ruiz Pineda', 1),
('Barrio Josefina', 1),
('7 de Octubre', 1),
('San Antonio', 1),
('El Chaguaramal', 1),
('Barrio El Carmen', 1),
('Eulalia Buroz', 1),
('Barrio La Adobera', 1),
('La Florida', 1),
('Barrio Palotal', 1),
('Urbanizacion Los Jabilos', 1),
('Urbanizacion Los Chaguaramos', 1),
('Urbanizacion Tucan', 1),
('Conjunto Residencial Las Palmas', 1),
('Conjunto Residencial Cachiri', 1),
('Urbanizacion La Honda', 1),
('Urbanizacion El Rosario', 1),
('Urbanizacion Alto de Jalisco', 1),
('Urbanizacion Libertador', 1),
('Urbanizacion Jose Hernandez', 1),
('Urbanizacion El Rincon', 1),
('Urbanizacion Cantarrana', 1),
('Urbanizacion Los Cedros', 1),
('Urbanizacion Manzana de Oro', 1),
('Urbanizacion La Adobera', 1),
('Urbanizacion Palotal', 1),
('Casco de Tocuyito', 1),
('Cantarrana Tocuyito', 1),
('Tocuyito', 1),
('No Especificada', 1);

ALTER TABLE beneficiarios
    ADD COLUMN IF NOT EXISTS id_comunidad INT(11) NULL AFTER telefono,
    ADD COLUMN IF NOT EXISTS hora_registro_12h CHAR(11) NULL AFTER fecha_registro;

UPDATE beneficiarios AS b
INNER JOIN comunidades AS c
    ON UPPER(TRIM(c.nombre_comunidad)) = UPPER(TRIM(b.comunidad))
SET b.id_comunidad = c.id_comunidad
WHERE b.id_comunidad IS NULL
  AND b.comunidad IS NOT NULL
  AND TRIM(b.comunidad) <> '';

UPDATE beneficiarios AS b
INNER JOIN comunidades AS c
    ON c.nombre_comunidad = 'No Especificada'
SET b.id_comunidad = c.id_comunidad
WHERE b.id_comunidad IS NULL;

UPDATE beneficiarios AS b
INNER JOIN comunidades AS c
    ON c.id_comunidad = b.id_comunidad
SET b.comunidad = c.nombre_comunidad
WHERE 1 = 1;

SET @id_no_especificada := (
    SELECT id_comunidad
    FROM comunidades
    WHERE nombre_comunidad = 'No Especificada'
    LIMIT 1
);

UPDATE comunidades
SET estado = 0
WHERE LOWER(TRIM(nombre_comunidad)) = 'valencia';

UPDATE beneficiarios AS b
INNER JOIN comunidades AS c
    ON c.id_comunidad = b.id_comunidad
SET b.id_comunidad = @id_no_especificada,
    b.comunidad = 'No Especificada'
WHERE c.estado = 0;

ALTER TABLE beneficiarios
    MODIFY COLUMN id_comunidad INT(11) NOT NULL;

UPDATE comunidades
SET hora_registro_12h = DATE_FORMAT(fecha_registro, '%r')
WHERE hora_registro_12h IS NULL
   OR hora_registro_12h = '';

UPDATE beneficiarios
SET hora_registro_12h = DATE_FORMAT(fecha_registro, '%r')
WHERE hora_registro_12h IS NULL
   OR hora_registro_12h = '';

SET @idx_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'beneficiarios'
      AND INDEX_NAME = 'idx_beneficiarios_id_comunidad'
);
SET @sql_idx := IF(
    @idx_exists = 0,
    'ALTER TABLE beneficiarios ADD INDEX idx_beneficiarios_id_comunidad (id_comunidad)',
    'SELECT 1'
);
PREPARE stmt_idx FROM @sql_idx;
EXECUTE stmt_idx;
DEALLOCATE PREPARE stmt_idx;

SET @fk_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'beneficiarios'
      AND CONSTRAINT_NAME = 'fk_beneficiarios_comunidades'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk := IF(
    @fk_exists = 0,
    'ALTER TABLE beneficiarios ADD CONSTRAINT fk_beneficiarios_comunidades FOREIGN KEY (id_comunidad) REFERENCES comunidades(id_comunidad) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk FROM @sql_fk;
EXECUTE stmt_fk;
DEALLOCATE PREPARE stmt_fk;

DROP TRIGGER IF EXISTS tr_comunidades_ai_audit;
DROP TRIGGER IF EXISTS tr_comunidades_au_audit;
DROP TRIGGER IF EXISTS tr_comunidades_bd_block_delete;
DROP TRIGGER IF EXISTS tr_comunidades_bi_hora12;
DROP TRIGGER IF EXISTS tr_comunidades_bu_hora12;
DROP TRIGGER IF EXISTS tr_beneficiarios_bi_hora12;
DROP TRIGGER IF EXISTS tr_beneficiarios_bu_hora12;

DELIMITER //
CREATE TRIGGER tr_comunidades_bi_hora12
BEFORE INSERT ON comunidades
FOR EACH ROW
BEGIN
    IF NEW.fecha_registro IS NULL THEN
        SET NEW.fecha_registro = NOW();
    END IF;
    SET NEW.hora_registro_12h = DATE_FORMAT(NEW.fecha_registro, '%r');
END//

CREATE TRIGGER tr_comunidades_bu_hora12
BEFORE UPDATE ON comunidades
FOR EACH ROW
BEGIN
    IF NEW.fecha_registro IS NULL THEN
        SET NEW.fecha_registro = NOW();
    END IF;
    SET NEW.hora_registro_12h = DATE_FORMAT(NEW.fecha_registro, '%r');
END//

CREATE TRIGGER tr_beneficiarios_bi_hora12
BEFORE INSERT ON beneficiarios
FOR EACH ROW
BEGIN
    IF NEW.fecha_registro IS NULL THEN
        SET NEW.fecha_registro = NOW();
    END IF;
    SET NEW.hora_registro_12h = DATE_FORMAT(NEW.fecha_registro, '%r');
END//

CREATE TRIGGER tr_beneficiarios_bu_hora12
BEFORE UPDATE ON beneficiarios
FOR EACH ROW
BEGIN
    IF NEW.fecha_registro IS NULL THEN
        SET NEW.fecha_registro = NOW();
    END IF;
    SET NEW.hora_registro_12h = DATE_FORMAT(NEW.fecha_registro, '%r');
END//

CREATE TRIGGER tr_comunidades_ai_audit
AFTER INSERT ON comunidades
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (
        id_usuario,
        tabla_afectada,
        accion,
        id_registro,
        resumen,
        detalle,
        datos_antes,
        datos_despues,
        usuario_bd,
        ipaddr,
        moment,
        fecha_evento
    ) VALUES (
        NULL,
        'comunidades',
        'INSERT',
        CAST(NEW.id_comunidad AS CHAR),
        'AUDIT INSERT comunidades',
        CONCAT('Insercion en comunidades [ID=', CAST(NEW.id_comunidad AS CHAR), ']'),
        NULL,
        JSON_OBJECT(
            'id_comunidad', NEW.id_comunidad,
            'nombre_comunidad', NEW.nombre_comunidad,
            'estado', NEW.estado,
            'fecha_registro', NEW.fecha_registro
        ),
        CURRENT_USER(),
        SUBSTRING_INDEX(USER(), '@', -1),
        NOW(),
        NOW()
    );
END//

CREATE TRIGGER tr_comunidades_au_audit
AFTER UPDATE ON comunidades
FOR EACH ROW
BEGIN
    DECLARE v_accion VARCHAR(20);
    IF OLD.estado = 1 AND NEW.estado = 0 THEN
        SET v_accion = 'SOFTDELETE';
    ELSEIF OLD.estado = 0 AND NEW.estado = 1 THEN
        SET v_accion = 'RESTORE';
    ELSE
        SET v_accion = 'UPDATE';
    END IF;

    INSERT INTO bitacora (
        id_usuario,
        tabla_afectada,
        accion,
        id_registro,
        resumen,
        detalle,
        datos_antes,
        datos_despues,
        usuario_bd,
        ipaddr,
        moment,
        fecha_evento
    ) VALUES (
        NULL,
        'comunidades',
        v_accion,
        CAST(NEW.id_comunidad AS CHAR),
        CONCAT('AUDIT ', v_accion, ' comunidades'),
        CONCAT(v_accion, ' en comunidades [ID=', CAST(NEW.id_comunidad AS CHAR), ']'),
        JSON_OBJECT(
            'id_comunidad', OLD.id_comunidad,
            'nombre_comunidad', OLD.nombre_comunidad,
            'estado', OLD.estado,
            'fecha_registro', OLD.fecha_registro
        ),
        JSON_OBJECT(
            'id_comunidad', NEW.id_comunidad,
            'nombre_comunidad', NEW.nombre_comunidad,
            'estado', NEW.estado,
            'fecha_registro', NEW.fecha_registro
        ),
        CURRENT_USER(),
        SUBSTRING_INDEX(USER(), '@', -1),
        NOW(),
        NOW()
    );
END//

CREATE TRIGGER tr_comunidades_bd_block_delete
BEFORE DELETE ON comunidades
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla comunidades. Use estado=0 para softdelete.';
END//
DELIMITER ;
