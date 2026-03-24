<?php 
//Verificar si las constantes ya están definidas para evitar warnings
if (!defined("DB_HOST")) {
    //Ip de la pc servidor de base de datos
    define("DB_HOST","localhost");
}

if (!defined("DB_NAME")) {
    //Nombre de la base de datos
    define("DB_NAME", "sala_situacional");
    //define("DB_NAME", "id21721168_gestionsala");
}

if (!defined("DB_USERNAME")) {
    //Usuario de la base de datos
    define("DB_USERNAME", "root");
    //define("DB_USERNAME", "id21721168_alcaldia");
}

if (!defined("DB_PASSWORD")) {
    //Contraseña del usuario de la base de datos
    define("DB_PASSWORD", "123456789");
    //define("DB_PASSWORD", "Alcaldia@123456");
}

if (!defined("DB_ENCODE")) {
    //definimos la codificación de los caracteres
    define("DB_ENCODE","utf8");
}

if (!defined("PRO_NOMBRE")) {
    //Definimos una constante como nombre del proyecto
    define("PRO_NOMBRE","");
}
?>