# FTP

## 1.  Primero creamos el archivo vagrant , haciendo un vagrant init 

## 2.  Creamos el script bootstrap.sh y le ponemos los siguientes comandos : 
    apt update -y
    apt install vsftpd -y
    cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

    lo que hace esto es actualizar la maquina y ademas instala un servidor ftp y hace una copia de la configuracion 
    y le damos permiso de ejecucion al script 

## 3 hacemos un vagrant up 

## 4 Comprovamos que el demonio de FTP esta instalado

## 5 Configuramos el servidor en el /etc/vsftpd.conf
 Servidor independiente (solo IPv4)
listen=YES
listen_ipv6=NO

 Mensaje de bienvenida
ftpd_banner=--- Welcome to the FTP server of 'javier.test' ---

 Permitir usuarios anónimos (solo lectura)
anonymous_enable=YES
anon_root=/srv/ftp
write_enable=NO

 Permitir usuarios locales (lectura/escritura)
local_enable=YES
write_enable=YES

 Tiempo máximo de inactividad
idle_session_timeout=720

 Límites de velocidad
local_max_rate=5242880
anon_max_rate=2097152

 Enjaular usuarios locales en su carpeta home
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list

## Crea el archivo de lista de usuarios no enjaulados
    Solo que remos que maria pueda salir de su carpeta 
    echo "maria" | sudo tee /etc/vsftpd.chroot_list
