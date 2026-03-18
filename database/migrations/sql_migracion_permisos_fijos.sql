USE sala03v2_4;

START TRANSACTION;
SET SESSION sql_safe_updates = 0;

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 1, 'Escritorio', 'Permite acceder y gestionar el modulo de Beneficiarios.', 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 1
       OR UPPER(TRIM(nombre_permiso)) = 'ESCRITORIO'
);

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 2, 'Concepto', 'Permite acceder al Panel General y administrar catalogos base en Configuracion.', 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 2
       OR UPPER(TRIM(nombre_permiso)) = 'CONCEPTO'
);

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 3, 'Ayuda', 'Permite registrar y gestionar solicitudes del modulo de Ayuda Social.', 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 3
       OR UPPER(TRIM(nombre_permiso)) = 'AYUDA'
);

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 4, 'Emergencia', 'Permite gestionar Seguridad y Emergencia, incluyendo despacho y operativa de ambulancias.', 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 4
       OR UPPER(TRIM(nombre_permiso)) = 'EMERGENCIA'
);

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 5, 'Publicos', 'Permite gestionar solicitudes del modulo de Servicios Publicos.', 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 5
       OR UPPER(TRIM(nombre_permiso)) = 'PUBLICOS'
);

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 6, 'Usuarios', 'Permite administrar usuarios del sistema y su matriz de permisos.', 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 6
       OR UPPER(TRIM(nombre_permiso)) = 'USUARIOS'
);

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 7, 'Tribunal', 'Permite consultar el modulo de Bitacora y su historial de eventos.', 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 7
       OR UPPER(TRIM(nombre_permiso)) = 'TRIBUNAL'
);

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 8, 'Chofer', 'Permite gestionar funciones operativas relacionadas con choferes y traslados.', 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 8
       OR UPPER(TRIM(nombre_permiso)) = 'CHOFER'
);

INSERT INTO permisos (id_permiso, nombre_permiso, descripcion, estado)
SELECT 99, 'Acceso total del sistema', 'Permiso exclusivo para acceso completo a todos los modulos; solo puede transferirse a otro usuario administrador.', 1
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM permisos
    WHERE id_permiso = 99
       OR UPPER(TRIM(nombre_permiso)) IN ('ACCESO TOTAL DEL SISTEMA', 'ACCESO TOTAL SISTEMA')
);

UPDATE permisos
SET nombre_permiso = 'Escritorio',
    descripcion = 'Permite acceder y gestionar el modulo de Beneficiarios.',
    estado = 1
WHERE id_permiso = 1 OR UPPER(TRIM(nombre_permiso)) = 'ESCRITORIO';

UPDATE permisos
SET nombre_permiso = 'Concepto',
    descripcion = 'Permite acceder al Panel General y administrar catalogos base en Configuracion.',
    estado = 1
WHERE id_permiso = 2 OR UPPER(TRIM(nombre_permiso)) = 'CONCEPTO';

UPDATE permisos
SET nombre_permiso = 'Ayuda',
    descripcion = 'Permite registrar y gestionar solicitudes del modulo de Ayuda Social.',
    estado = 1
WHERE id_permiso = 3 OR UPPER(TRIM(nombre_permiso)) = 'AYUDA';

UPDATE permisos
SET nombre_permiso = 'Emergencia',
    descripcion = 'Permite gestionar Seguridad y Emergencia, incluyendo despacho y operativa de ambulancias.',
    estado = 1
WHERE id_permiso = 4 OR UPPER(TRIM(nombre_permiso)) = 'EMERGENCIA';

UPDATE permisos
SET nombre_permiso = 'Publicos',
    descripcion = 'Permite gestionar solicitudes del modulo de Servicios Publicos.',
    estado = 1
WHERE id_permiso = 5 OR UPPER(TRIM(nombre_permiso)) = 'PUBLICOS';

UPDATE permisos
SET nombre_permiso = 'Usuarios',
    descripcion = 'Permite administrar usuarios del sistema y su matriz de permisos.',
    estado = 1
WHERE id_permiso = 6 OR UPPER(TRIM(nombre_permiso)) = 'USUARIOS';

UPDATE permisos
SET nombre_permiso = 'Tribunal',
    descripcion = 'Permite consultar el modulo de Bitacora y su historial de eventos.',
    estado = 1
WHERE id_permiso = 7 OR UPPER(TRIM(nombre_permiso)) = 'TRIBUNAL';

UPDATE permisos
SET nombre_permiso = 'Chofer',
    descripcion = 'Permite gestionar funciones operativas relacionadas con choferes y traslados.',
    estado = 1
WHERE id_permiso = 8 OR UPPER(TRIM(nombre_permiso)) = 'CHOFER';

UPDATE permisos
SET nombre_permiso = 'Acceso total del sistema',
    descripcion = 'Permiso exclusivo para acceso completo a todos los modulos; solo puede transferirse a otro usuario administrador.',
    estado = 1
WHERE id_permiso = 99
   OR UPPER(TRIM(nombre_permiso)) IN ('ACCESO TOTAL DEL SISTEMA', 'ACCESO TOTAL SISTEMA');

COMMIT;
