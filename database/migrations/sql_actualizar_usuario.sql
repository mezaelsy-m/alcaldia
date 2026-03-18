-- SQL para actualizar usuario maestro a prueba con todos los permisos
-- Base de datos: sala03v2_4

-- Paso 1: Actualizar el usuario maestro
UPDATE usuarios 
SET 
    usuario = 'prueba',
    password = SHA2('prueba', 256),
    rol = 'ADMIN'
WHERE usuario = 'maestro';

-- Paso 2: Verificar la actualización
SELECT * FROM usuarios WHERE usuario = 'prueba';

-- Paso 3: Si necesitas crear un nuevo usuario admin (opcional)
INSERT INTO usuarios (id_empleado, usuario, password, rol, estado) 
VALUES (1, 'prueba', SHA2('prueba', 256), 'ADMIN', '1');

-- Paso 4: Verificar todos los usuarios
SELECT id_usuario, usuario, rol, estado FROM usuarios ORDER BY id_usuario;
