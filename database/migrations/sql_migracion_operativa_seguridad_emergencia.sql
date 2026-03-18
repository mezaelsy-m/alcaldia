USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

CREATE TABLE IF NOT EXISTS tipos_seguridad_emergencia (
    id_tipo_seguridad INT(11) NOT NULL AUTO_INCREMENT,
    nombre_tipo VARCHAR(120) NOT NULL,
    requiere_ambulancia TINYINT(1) NOT NULL DEFAULT 0,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_tipo_seguridad),
    UNIQUE KEY uk_tipos_seguridad_emergencia_nombre (nombre_tipo),
    KEY idx_tipos_seguridad_emergencia_estado (estado, nombre_tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO tipos_seguridad_emergencia (nombre_tipo, requiere_ambulancia, estado) VALUES
('Guardia y seguridad', 0, 1),
('Supresion de incendio', 0, 1),
('Traslado', 1, 1),
('Atencion prehospitalaria', 1, 1),
('Robo de vehiculo', 0, 1),
('Hurto', 0, 1),
('Robo de inmueble', 0, 1),
('Riesgo de vias publicas', 0, 1),
('Maltrato domestico', 0, 1),
('Atraco a mano armada', 0, 1),
('Reubicacion de insectos', 0, 1);

CREATE TABLE IF NOT EXISTS solicitudes_seguridad_emergencia (
    id_solicitud_seguridad INT(11) NOT NULL AUTO_INCREMENT,
    nombre_solicitud VARCHAR(120) NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_solicitud_seguridad),
    UNIQUE KEY uk_solicitudes_seguridad_emergencia_nombre (nombre_solicitud),
    KEY idx_solicitudes_seguridad_emergencia_estado (estado, nombre_solicitud)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO solicitudes_seguridad_emergencia (nombre_solicitud, estado) VALUES
('Atencion al ciudadano', 1),
('Redes sociales', 1);

CREATE TABLE IF NOT EXISTS choferes_ambulancia (
    id_chofer_ambulancia INT(11) NOT NULL AUTO_INCREMENT,
    id_empleado INT(11) NOT NULL,
    numero_licencia VARCHAR(60) DEFAULT NULL,
    categoria_licencia VARCHAR(40) DEFAULT NULL,
    vencimiento_licencia DATE DEFAULT NULL,
    contacto_emergencia VARCHAR(120) DEFAULT NULL,
    telefono_contacto_emergencia VARCHAR(30) DEFAULT NULL,
    observaciones TEXT DEFAULT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_chofer_ambulancia),
    UNIQUE KEY uk_choferes_ambulancia_empleado (id_empleado),
    KEY idx_choferes_ambulancia_estado (estado, id_empleado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO choferes_ambulancia (
    id_empleado,
    numero_licencia,
    categoria_licencia,
    vencimiento_licencia,
    contacto_emergencia,
    telefono_contacto_emergencia,
    observaciones,
    estado
)
SELECT DISTINCT
    e.id_empleado,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Perfil creado automaticamente desde permisos legacy.',
    1
FROM empleados AS e
INNER JOIN usuarios AS u
    ON u.id_empleado = e.id_empleado
   AND u.estado = 1
INNER JOIN usuario_permisos AS up
    ON up.id_usuario = u.id_usuario
WHERE e.estado = 1
  AND e.id_dependencia = 4
  AND up.id_permiso = 8;

CREATE TABLE IF NOT EXISTS asignaciones_unidades_choferes (
    id_asignacion_unidad_chofer INT(11) NOT NULL AUTO_INCREMENT,
    id_unidad INT(11) NOT NULL,
    id_chofer_ambulancia INT(11) NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME DEFAULT NULL,
    observaciones TEXT DEFAULT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_asignacion_unidad_chofer),
    KEY idx_asignaciones_unidades_choferes_unidad (id_unidad, estado),
    KEY idx_asignaciones_unidades_choferes_chofer (id_chofer_ambulancia, estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS despachos_unidades (
    id_despacho_unidad INT(11) NOT NULL AUTO_INCREMENT,
    id_seguridad INT(11) NOT NULL,
    id_unidad INT(11) NOT NULL,
    id_chofer_ambulancia INT(11) NOT NULL,
    id_usuario_asigna INT(11) DEFAULT NULL,
    modo_asignacion ENUM('AUTO','MANUAL') NOT NULL DEFAULT 'AUTO',
    estado_despacho ENUM('ACTIVO','CERRADO','CANCELADO') NOT NULL DEFAULT 'ACTIVO',
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre DATETIME DEFAULT NULL,
    ubicacion_salida VARCHAR(190) DEFAULT NULL,
    ubicacion_evento VARCHAR(190) DEFAULT NULL,
    ubicacion_cierre VARCHAR(190) DEFAULT NULL,
    observaciones TEXT DEFAULT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_despacho_unidad),
    KEY idx_despachos_unidades_seguridad (id_seguridad, estado_despacho),
    KEY idx_despachos_unidades_unidad (id_unidad, estado_despacho),
    KEY idx_despachos_unidades_chofer (id_chofer_ambulancia, estado_despacho)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE seguridad
    ADD COLUMN IF NOT EXISTS id_tipo_seguridad INT(11) NULL AFTER id_usuario,
    ADD COLUMN IF NOT EXISTS id_solicitud_seguridad INT(11) NULL AFTER id_tipo_seguridad,
    ADD COLUMN IF NOT EXISTS estado_atencion ENUM('REGISTRADO','PENDIENTE_UNIDAD','DESPACHADO','FINALIZADO','ANULADO') NOT NULL DEFAULT 'REGISTRADO' AFTER descripcion,
    ADD COLUMN IF NOT EXISTS ubicacion_evento VARCHAR(190) DEFAULT NULL AFTER estado_atencion,
    ADD COLUMN IF NOT EXISTS referencia_evento VARCHAR(190) DEFAULT NULL AFTER ubicacion_evento;

ALTER TABLE seguridad
    MODIFY COLUMN fecha_seguridad DATETIME NULL;

ALTER TABLE unidades
    ADD COLUMN IF NOT EXISTS estado_operativo ENUM('DISPONIBLE','EN_SERVICIO','FUERA_SERVICIO') NOT NULL DEFAULT 'DISPONIBLE' AFTER estado,
    ADD COLUMN IF NOT EXISTS ubicacion_actual VARCHAR(190) DEFAULT NULL AFTER estado_operativo,
    ADD COLUMN IF NOT EXISTS referencia_actual VARCHAR(190) DEFAULT NULL AFTER ubicacion_actual,
    ADD COLUMN IF NOT EXISTS prioridad_despacho INT(11) NOT NULL DEFAULT 100 AFTER referencia_actual,
    ADD COLUMN IF NOT EXISTS fecha_actualizacion_operativa DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER prioridad_despacho;

ALTER TABLE reportes_traslado
    MODIFY COLUMN id_ayuda INT(11) NULL,
    ADD COLUMN IF NOT EXISTS id_despacho_unidad INT(11) NULL AFTER id_seguridad;

UPDATE unidades
SET estado_operativo = 'DISPONIBLE'
WHERE estado = 1
  AND (estado_operativo IS NULL OR estado_operativo = '');

UPDATE unidades
SET estado_operativo = 'FUERA_SERVICIO'
WHERE estado = 0;

UPDATE unidades
SET prioridad_despacho = id_unidad
WHERE prioridad_despacho IS NULL
   OR prioridad_despacho = 100;

UPDATE unidades
SET fecha_actualizacion_operativa = NOW()
WHERE fecha_actualizacion_operativa IS NULL;

UPDATE seguridad
SET ticket_interno = CONCAT(
        'SEG-',
        DATE_FORMAT(COALESCE(fecha_seguridad, NOW()), '%Y%m%d'),
        '-',
        LPAD(id_seguridad, 6, '0')
    )
WHERE ticket_interno IS NULL
   OR TRIM(ticket_interno) = '';

UPDATE seguridad
SET tipo_seguridad = CASE
    WHEN UPPER(TRIM(tipo_seguridad)) IN ('GUARDIA', 'GUARDIA Y SEGURIDAD') THEN 'Guardia y seguridad'
    WHEN UPPER(TRIM(tipo_seguridad)) IN ('SUPRECION DE INCENDIO', 'SUPRESION DE INCENDIO') THEN 'Supresion de incendio'
    WHEN UPPER(TRIM(tipo_seguridad)) = 'TRASLADO' THEN 'Traslado'
    WHEN UPPER(TRIM(tipo_seguridad)) IN ('ATENCION PROHOSPITALARIA', 'ATENCION PREHOSPITALARIA') THEN 'Atencion prehospitalaria'
    WHEN UPPER(TRIM(tipo_seguridad)) = 'ROBO DE VEHICULO' THEN 'Robo de vehiculo'
    WHEN UPPER(TRIM(tipo_seguridad)) = 'HURTO' THEN 'Hurto'
    WHEN UPPER(TRIM(tipo_seguridad)) = 'ROBO DE INMUEBLE' THEN 'Robo de inmueble'
    WHEN UPPER(TRIM(tipo_seguridad)) = 'RIESGO DE VIAS PUBLICAS' THEN 'Riesgo de vias publicas'
    WHEN UPPER(TRIM(tipo_seguridad)) = 'MALTRATO DOMESTICO' THEN 'Maltrato domestico'
    WHEN UPPER(TRIM(tipo_seguridad)) IN ('ATRACO MANO ARMADA', 'ATRACO A MANO ARMADA') THEN 'Atraco a mano armada'
    WHEN UPPER(TRIM(tipo_seguridad)) = 'REUBICACION DE INSECTOS' THEN 'Reubicacion de insectos'
    ELSE tipo_seguridad
END
WHERE tipo_seguridad IS NOT NULL
  AND TRIM(tipo_seguridad) <> '';

UPDATE seguridad
SET tipo_solicitud = CASE
    WHEN UPPER(TRIM(tipo_solicitud)) IN ('ATENCION', 'ATENCION CLIENTE', 'ATENCION AL CIUDADANO') THEN 'Atencion al ciudadano'
    WHEN UPPER(TRIM(tipo_solicitud)) IN ('REDES', 'REDES SOCIALES') THEN 'Redes sociales'
    ELSE tipo_solicitud
END
WHERE tipo_solicitud IS NOT NULL
  AND TRIM(tipo_solicitud) <> '';

UPDATE seguridad AS s
INNER JOIN tipos_seguridad_emergencia AS tse
    ON tse.nombre_tipo = s.tipo_seguridad
SET s.id_tipo_seguridad = tse.id_tipo_seguridad
WHERE s.id_tipo_seguridad IS NULL;

UPDATE seguridad AS s
INNER JOIN solicitudes_seguridad_emergencia AS sse
    ON sse.nombre_solicitud = s.tipo_solicitud
SET s.id_solicitud_seguridad = sse.id_solicitud_seguridad
WHERE s.id_solicitud_seguridad IS NULL;

UPDATE seguridad AS s
INNER JOIN tipos_seguridad_emergencia AS tse
    ON tse.id_tipo_seguridad = s.id_tipo_seguridad
SET s.tipo_seguridad = tse.nombre_tipo
WHERE s.id_tipo_seguridad IS NOT NULL;

UPDATE seguridad AS s
INNER JOIN solicitudes_seguridad_emergencia AS sse
    ON sse.id_solicitud_seguridad = s.id_solicitud_seguridad
SET s.tipo_solicitud = sse.nombre_solicitud
WHERE s.id_solicitud_seguridad IS NOT NULL;

UPDATE seguridad AS s
LEFT JOIN tipos_seguridad_emergencia AS tse
    ON tse.id_tipo_seguridad = s.id_tipo_seguridad
SET s.estado_atencion = CASE
    WHEN s.estado = 0 THEN 'ANULADO'
    WHEN COALESCE(tse.requiere_ambulancia, 0) = 1 THEN 'PENDIENTE_UNIDAD'
    ELSE 'REGISTRADO'
END
WHERE s.estado_atencion IS NULL
   OR s.estado_atencion = ''
   OR s.estado_atencion = 'REGISTRADO';

SET @idx_seg_tipo_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'seguridad'
      AND INDEX_NAME = 'idx_seguridad_id_tipo_seguridad'
);
SET @sql_idx_seg_tipo := IF(
    @idx_seg_tipo_exists = 0,
    'ALTER TABLE seguridad ADD INDEX idx_seguridad_id_tipo_seguridad (id_tipo_seguridad)',
    'SELECT 1'
);
PREPARE stmt_idx_seg_tipo FROM @sql_idx_seg_tipo;
EXECUTE stmt_idx_seg_tipo;
DEALLOCATE PREPARE stmt_idx_seg_tipo;

SET @idx_seg_sol_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'seguridad'
      AND INDEX_NAME = 'idx_seguridad_id_solicitud_seguridad'
);
SET @sql_idx_seg_sol := IF(
    @idx_seg_sol_exists = 0,
    'ALTER TABLE seguridad ADD INDEX idx_seguridad_id_solicitud_seguridad (id_solicitud_seguridad)',
    'SELECT 1'
);
PREPARE stmt_idx_seg_sol FROM @sql_idx_seg_sol;
EXECUTE stmt_idx_seg_sol;
DEALLOCATE PREPARE stmt_idx_seg_sol;

SET @idx_rep_despacho_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'reportes_traslado'
      AND INDEX_NAME = 'idx_reportes_traslado_id_despacho_unidad'
);
SET @sql_idx_rep_despacho := IF(
    @idx_rep_despacho_exists = 0,
    'ALTER TABLE reportes_traslado ADD INDEX idx_reportes_traslado_id_despacho_unidad (id_despacho_unidad)',
    'SELECT 1'
);
PREPARE stmt_idx_rep_despacho FROM @sql_idx_rep_despacho;
EXECUTE stmt_idx_rep_despacho;
DEALLOCATE PREPARE stmt_idx_rep_despacho;

SET @fk_seg_tipo_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'seguridad'
      AND CONSTRAINT_NAME = 'fk_seguridad_tipos_emergencia'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_seg_tipo := IF(
    @fk_seg_tipo_exists = 0,
    'ALTER TABLE seguridad ADD CONSTRAINT fk_seguridad_tipos_emergencia FOREIGN KEY (id_tipo_seguridad) REFERENCES tipos_seguridad_emergencia(id_tipo_seguridad) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_seg_tipo FROM @sql_fk_seg_tipo;
EXECUTE stmt_fk_seg_tipo;
DEALLOCATE PREPARE stmt_fk_seg_tipo;

SET @fk_seg_sol_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'seguridad'
      AND CONSTRAINT_NAME = 'fk_seguridad_solicitudes_emergencia'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_seg_sol := IF(
    @fk_seg_sol_exists = 0,
    'ALTER TABLE seguridad ADD CONSTRAINT fk_seguridad_solicitudes_emergencia FOREIGN KEY (id_solicitud_seguridad) REFERENCES solicitudes_seguridad_emergencia(id_solicitud_seguridad) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_seg_sol FROM @sql_fk_seg_sol;
EXECUTE stmt_fk_seg_sol;
DEALLOCATE PREPARE stmt_fk_seg_sol;

SET @fk_chofer_empleado_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'choferes_ambulancia'
      AND CONSTRAINT_NAME = 'fk_choferes_ambulancia_empleados'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_chofer_empleado := IF(
    @fk_chofer_empleado_exists = 0,
    'ALTER TABLE choferes_ambulancia ADD CONSTRAINT fk_choferes_ambulancia_empleados FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_chofer_empleado FROM @sql_fk_chofer_empleado;
EXECUTE stmt_fk_chofer_empleado;
DEALLOCATE PREPARE stmt_fk_chofer_empleado;

SET @fk_asig_unidad_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'asignaciones_unidades_choferes'
      AND CONSTRAINT_NAME = 'fk_asignaciones_unidades'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_asig_unidad := IF(
    @fk_asig_unidad_exists = 0,
    'ALTER TABLE asignaciones_unidades_choferes ADD CONSTRAINT fk_asignaciones_unidades FOREIGN KEY (id_unidad) REFERENCES unidades(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_asig_unidad FROM @sql_fk_asig_unidad;
EXECUTE stmt_fk_asig_unidad;
DEALLOCATE PREPARE stmt_fk_asig_unidad;

SET @fk_asig_chofer_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'asignaciones_unidades_choferes'
      AND CONSTRAINT_NAME = 'fk_asignaciones_choferes'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_asig_chofer := IF(
    @fk_asig_chofer_exists = 0,
    'ALTER TABLE asignaciones_unidades_choferes ADD CONSTRAINT fk_asignaciones_choferes FOREIGN KEY (id_chofer_ambulancia) REFERENCES choferes_ambulancia(id_chofer_ambulancia) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_asig_chofer FROM @sql_fk_asig_chofer;
EXECUTE stmt_fk_asig_chofer;
DEALLOCATE PREPARE stmt_fk_asig_chofer;

SET @fk_despacho_seguridad_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'despachos_unidades'
      AND CONSTRAINT_NAME = 'fk_despachos_seguridad'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_despacho_seguridad := IF(
    @fk_despacho_seguridad_exists = 0,
    'ALTER TABLE despachos_unidades ADD CONSTRAINT fk_despachos_seguridad FOREIGN KEY (id_seguridad) REFERENCES seguridad(id_seguridad) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_despacho_seguridad FROM @sql_fk_despacho_seguridad;
EXECUTE stmt_fk_despacho_seguridad;
DEALLOCATE PREPARE stmt_fk_despacho_seguridad;

SET @fk_despacho_unidad_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'despachos_unidades'
      AND CONSTRAINT_NAME = 'fk_despachos_unidades'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_despacho_unidad := IF(
    @fk_despacho_unidad_exists = 0,
    'ALTER TABLE despachos_unidades ADD CONSTRAINT fk_despachos_unidades FOREIGN KEY (id_unidad) REFERENCES unidades(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_despacho_unidad FROM @sql_fk_despacho_unidad;
EXECUTE stmt_fk_despacho_unidad;
DEALLOCATE PREPARE stmt_fk_despacho_unidad;

SET @fk_despacho_chofer_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'despachos_unidades'
      AND CONSTRAINT_NAME = 'fk_despachos_choferes'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_despacho_chofer := IF(
    @fk_despacho_chofer_exists = 0,
    'ALTER TABLE despachos_unidades ADD CONSTRAINT fk_despachos_choferes FOREIGN KEY (id_chofer_ambulancia) REFERENCES choferes_ambulancia(id_chofer_ambulancia) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_fk_despacho_chofer FROM @sql_fk_despacho_chofer;
EXECUTE stmt_fk_despacho_chofer;
DEALLOCATE PREPARE stmt_fk_despacho_chofer;

SET @fk_despacho_usuario_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'despachos_unidades'
      AND CONSTRAINT_NAME = 'fk_despachos_usuarios'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_despacho_usuario := IF(
    @fk_despacho_usuario_exists = 0,
    'ALTER TABLE despachos_unidades ADD CONSTRAINT fk_despachos_usuarios FOREIGN KEY (id_usuario_asigna) REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt_fk_despacho_usuario FROM @sql_fk_despacho_usuario;
EXECUTE stmt_fk_despacho_usuario;
DEALLOCATE PREPARE stmt_fk_despacho_usuario;

SET @fk_reporte_despacho_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'reportes_traslado'
      AND CONSTRAINT_NAME = 'fk_reportes_traslado_despacho'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_fk_reporte_despacho := IF(
    @fk_reporte_despacho_exists = 0,
    'ALTER TABLE reportes_traslado ADD CONSTRAINT fk_reportes_traslado_despacho FOREIGN KEY (id_despacho_unidad) REFERENCES despachos_unidades(id_despacho_unidad) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt_fk_reporte_despacho FROM @sql_fk_reporte_despacho;
EXECUTE stmt_fk_reporte_despacho;
DEALLOCATE PREPARE stmt_fk_reporte_despacho;

DELIMITER $$

DROP TRIGGER IF EXISTS tr_tipos_seguridad_emergencia_ai_audit$$
CREATE TRIGGER tr_tipos_seguridad_emergencia_ai_audit
AFTER INSERT ON tipos_seguridad_emergencia
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'tipos_seguridad_emergencia',
        'INSERT',
        NEW.id_tipo_seguridad,
        NULL,
        JSON_OBJECT('id_tipo_seguridad', NEW.id_tipo_seguridad, 'nombre_tipo', NEW.nombre_tipo, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_tipos_seguridad_emergencia_au_audit$$
CREATE TRIGGER tr_tipos_seguridad_emergencia_au_audit
AFTER UPDATE ON tipos_seguridad_emergencia
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'tipos_seguridad_emergencia',
        'UPDATE',
        NEW.id_tipo_seguridad,
        JSON_OBJECT('id_tipo_seguridad', OLD.id_tipo_seguridad, 'nombre_tipo', OLD.nombre_tipo, 'requiere_ambulancia', OLD.requiere_ambulancia, 'estado', OLD.estado),
        JSON_OBJECT('id_tipo_seguridad', NEW.id_tipo_seguridad, 'nombre_tipo', NEW.nombre_tipo, 'requiere_ambulancia', NEW.requiere_ambulancia, 'estado', NEW.estado),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_tipos_seguridad_emergencia_bd_block_delete$$
CREATE TRIGGER tr_tipos_seguridad_emergencia_bd_block_delete
BEFORE DELETE ON tipos_seguridad_emergencia
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla tipos_seguridad_emergencia. Use estado=0.';
END$$

DROP TRIGGER IF EXISTS tr_solicitudes_seguridad_emergencia_ai_audit$$
CREATE TRIGGER tr_solicitudes_seguridad_emergencia_ai_audit
AFTER INSERT ON solicitudes_seguridad_emergencia
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'solicitudes_seguridad_emergencia',
        'INSERT',
        NEW.id_solicitud_seguridad,
        NULL,
        JSON_OBJECT('id_solicitud_seguridad', NEW.id_solicitud_seguridad, 'nombre_solicitud', NEW.nombre_solicitud, 'estado', NEW.estado),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_solicitudes_seguridad_emergencia_au_audit$$
CREATE TRIGGER tr_solicitudes_seguridad_emergencia_au_audit
AFTER UPDATE ON solicitudes_seguridad_emergencia
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'solicitudes_seguridad_emergencia',
        'UPDATE',
        NEW.id_solicitud_seguridad,
        JSON_OBJECT('id_solicitud_seguridad', OLD.id_solicitud_seguridad, 'nombre_solicitud', OLD.nombre_solicitud, 'estado', OLD.estado),
        JSON_OBJECT('id_solicitud_seguridad', NEW.id_solicitud_seguridad, 'nombre_solicitud', NEW.nombre_solicitud, 'estado', NEW.estado),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_solicitudes_seguridad_emergencia_bd_block_delete$$
CREATE TRIGGER tr_solicitudes_seguridad_emergencia_bd_block_delete
BEFORE DELETE ON solicitudes_seguridad_emergencia
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla solicitudes_seguridad_emergencia. Use estado=0.';
END$$

DROP TRIGGER IF EXISTS tr_choferes_ambulancia_ai_audit$$
CREATE TRIGGER tr_choferes_ambulancia_ai_audit
AFTER INSERT ON choferes_ambulancia
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'choferes_ambulancia',
        'INSERT',
        NEW.id_chofer_ambulancia,
        NULL,
        JSON_OBJECT('id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_empleado', NEW.id_empleado, 'numero_licencia', NEW.numero_licencia, 'categoria_licencia', NEW.categoria_licencia, 'estado', NEW.estado),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_choferes_ambulancia_au_audit$$
CREATE TRIGGER tr_choferes_ambulancia_au_audit
AFTER UPDATE ON choferes_ambulancia
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'choferes_ambulancia',
        'UPDATE',
        NEW.id_chofer_ambulancia,
        JSON_OBJECT('id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'id_empleado', OLD.id_empleado, 'numero_licencia', OLD.numero_licencia, 'categoria_licencia', OLD.categoria_licencia, 'estado', OLD.estado),
        JSON_OBJECT('id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'id_empleado', NEW.id_empleado, 'numero_licencia', NEW.numero_licencia, 'categoria_licencia', NEW.categoria_licencia, 'estado', NEW.estado),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_choferes_ambulancia_bd_block_delete$$
CREATE TRIGGER tr_choferes_ambulancia_bd_block_delete
BEFORE DELETE ON choferes_ambulancia
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla choferes_ambulancia. Use estado=0.';
END$$

DROP TRIGGER IF EXISTS tr_asignaciones_unidades_choferes_ai_audit$$
CREATE TRIGGER tr_asignaciones_unidades_choferes_ai_audit
AFTER INSERT ON asignaciones_unidades_choferes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'asignaciones_unidades_choferes',
        'INSERT',
        NEW.id_asignacion_unidad_chofer,
        NULL,
        JSON_OBJECT('id_asignacion_unidad_chofer', NEW.id_asignacion_unidad_chofer, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'fecha_inicio', NEW.fecha_inicio, 'fecha_fin', NEW.fecha_fin, 'estado', NEW.estado),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_asignaciones_unidades_choferes_au_audit$$
CREATE TRIGGER tr_asignaciones_unidades_choferes_au_audit
AFTER UPDATE ON asignaciones_unidades_choferes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'asignaciones_unidades_choferes',
        'UPDATE',
        NEW.id_asignacion_unidad_chofer,
        JSON_OBJECT('id_asignacion_unidad_chofer', OLD.id_asignacion_unidad_chofer, 'id_unidad', OLD.id_unidad, 'id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'fecha_inicio', OLD.fecha_inicio, 'fecha_fin', OLD.fecha_fin, 'estado', OLD.estado),
        JSON_OBJECT('id_asignacion_unidad_chofer', NEW.id_asignacion_unidad_chofer, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'fecha_inicio', NEW.fecha_inicio, 'fecha_fin', NEW.fecha_fin, 'estado', NEW.estado),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_asignaciones_unidades_choferes_bd_block_delete$$
CREATE TRIGGER tr_asignaciones_unidades_choferes_bd_block_delete
BEFORE DELETE ON asignaciones_unidades_choferes
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla asignaciones_unidades_choferes. Use estado=0.';
END$$

DROP TRIGGER IF EXISTS tr_despachos_unidades_ai_audit$$
CREATE TRIGGER tr_despachos_unidades_ai_audit
AFTER INSERT ON despachos_unidades
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'despachos_unidades',
        'INSERT',
        NEW.id_despacho_unidad,
        NULL,
        JSON_OBJECT('id_despacho_unidad', NEW.id_despacho_unidad, 'id_seguridad', NEW.id_seguridad, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'estado_despacho', NEW.estado_despacho, 'modo_asignacion', NEW.modo_asignacion),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_despachos_unidades_au_audit$$
CREATE TRIGGER tr_despachos_unidades_au_audit
AFTER UPDATE ON despachos_unidades
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, antes, despues, usuario_bd, fecha, estado)
    VALUES (
        'despachos_unidades',
        'UPDATE',
        NEW.id_despacho_unidad,
        JSON_OBJECT('id_despacho_unidad', OLD.id_despacho_unidad, 'id_seguridad', OLD.id_seguridad, 'id_unidad', OLD.id_unidad, 'id_chofer_ambulancia', OLD.id_chofer_ambulancia, 'estado_despacho', OLD.estado_despacho, 'modo_asignacion', OLD.modo_asignacion),
        JSON_OBJECT('id_despacho_unidad', NEW.id_despacho_unidad, 'id_seguridad', NEW.id_seguridad, 'id_unidad', NEW.id_unidad, 'id_chofer_ambulancia', NEW.id_chofer_ambulancia, 'estado_despacho', NEW.estado_despacho, 'modo_asignacion', NEW.modo_asignacion),
        CURRENT_USER(),
        NOW(),
        1
    );
END$$

DROP TRIGGER IF EXISTS tr_despachos_unidades_bd_block_delete$$
CREATE TRIGGER tr_despachos_unidades_bd_block_delete
BEFORE DELETE ON despachos_unidades
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eliminacion fisica bloqueada en tabla despachos_unidades. Use estado_despacho para cierre o cancelacion.';
END$$

DELIMITER ;
