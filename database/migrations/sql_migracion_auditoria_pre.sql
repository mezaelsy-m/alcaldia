USE sala03v2_4;

SET SESSION sql_safe_updates = 0;

-- 1) Normalizar campo de estado
ALTER TABLE beneficiarios CHANGE COLUMN activo estado TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE ayuda_social MODIFY estado TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE beneficiarios MODIFY estado TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE seguridad MODIFY estado TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE servicios_publicos MODIFY estado TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE usuarios MODIFY estado TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE auditoria ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1 AFTER fecha;
ALTER TABLE bitacora ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1 AFTER moment;
ALTER TABLE dependencias ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1 AFTER nombre_dependencia;
ALTER TABLE empleados ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1 AFTER direccion;
ALTER TABLE permisos ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1 AFTER descripcion;
ALTER TABLE reportes_traslado ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1 AFTER km_llegada;
ALTER TABLE unidades ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1 AFTER placa;
ALTER TABLE usuario_permisos ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1 AFTER id_permiso;

UPDATE auditoria SET estado = 1 WHERE estado IS NULL;
UPDATE ayuda_social SET estado = 1 WHERE estado IS NULL;
UPDATE beneficiarios SET estado = 1 WHERE estado IS NULL;
UPDATE bitacora SET estado = 1 WHERE estado IS NULL;
UPDATE dependencias SET estado = 1 WHERE estado IS NULL;
UPDATE empleados SET estado = 1 WHERE estado IS NULL;
UPDATE permisos SET estado = 1 WHERE estado IS NULL;
UPDATE reportes_traslado SET estado = 1 WHERE estado IS NULL;
UPDATE seguridad SET estado = 1 WHERE estado IS NULL;
UPDATE servicios_publicos SET estado = 1 WHERE estado IS NULL;
UPDATE unidades SET estado = 1 WHERE estado IS NULL;
UPDATE usuario_permisos SET estado = 1 WHERE estado IS NULL;
UPDATE usuarios SET estado = 1 WHERE estado IS NULL;

-- 2) Convertir bitacora en tabla de auditoria extensible
ALTER TABLE bitacora
  ADD COLUMN tabla_afectada VARCHAR(64) NULL AFTER id_usuario,
  ADD COLUMN accion VARCHAR(20) NOT NULL DEFAULT 'LEGACY' AFTER tabla_afectada,
  ADD COLUMN id_registro VARCHAR(64) NULL AFTER accion,
  ADD COLUMN datos_antes LONGTEXT NULL AFTER detalle,
  ADD COLUMN datos_despues LONGTEXT NULL AFTER datos_antes,
  ADD COLUMN usuario_bd VARCHAR(100) NULL AFTER datos_despues,
  ADD COLUMN fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER moment;

ALTER TABLE bitacora
  ADD INDEX idx_bitacora_tabla_accion_fecha (tabla_afectada, accion, fecha_evento),
  ADD INDEX idx_bitacora_tabla_registro (tabla_afectada, id_registro);

UPDATE bitacora
SET
  tabla_afectada = COALESCE(tabla_afectada, 'SISTEMA'),
  accion = COALESCE(NULLIF(accion, ''), 'LEGACY'),
  id_registro = COALESCE(id_registro, CAST(id_bitacora AS CHAR)),
  usuario_bd = COALESCE(usuario_bd, CURRENT_USER()),
  fecha_evento = COALESCE(fecha_evento, moment)
WHERE
  tabla_afectada IS NULL
  OR accion IS NULL
  OR accion = ''
  OR id_registro IS NULL
  OR usuario_bd IS NULL
  OR fecha_evento IS NULL;

-- 3) Completar relaciones faltantes
ALTER TABLE seguridad
  ADD INDEX idx_seg_id_usuario (id_usuario),
  ADD CONSTRAINT fk_seg_user FOREIGN KEY (id_usuario)
    REFERENCES usuarios(id_usuario)
    ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE servicios_publicos
  ADD INDEX idx_ser_id_usuario (id_usuario),
  ADD CONSTRAINT fk_ser_user FOREIGN KEY (id_usuario)
    REFERENCES usuarios(id_usuario)
    ON UPDATE CASCADE ON DELETE SET NULL;
