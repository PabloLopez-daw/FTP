# FTP

## 1.  Primero creamos el archivo vagrant , haciendo un vagrant init 

## 2.  Creamos el script bootstrap.sh y le ponemos los siguientes comandos : 
    apt update -y
    apt install vsftpd -y
    cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

    lo que hace esto es actualizar la maquina y ademas instala un servidor ftp y hace una copia de la configuracion 
    y le damos permiso de ejecucion al script 

## 3. hacemos un vagrant up 

## 4. Comprovamos que el demonio de FTP esta instalado

## 5. Configuramos el servidor en el /etc/vsftpd.conf
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

## 6. Crea el archivo de lista de usuarios no enjaulados
    Solo que remos que maria pueda salir de su carpeta 
    echo "maria" | sudo tee /etc/vsftpd.chroot_list

## 7. Reiniciamos el servidor 
    sudo systemctl restart vsftpd

## 8. Creamos los usuario locales
    sudo useradd -m luis
    sudo passwd luis
    sudo useradd -m maria
    sudo passwd maria
    sudo useradd -m miguel
    sudo passwd miguel

## 9. reamos Archivos de preueba

sudo touch /home/luis/luis{1,2}.txt
sudo chown luis:luis /home/luis/luis*.txt

sudo touch /home/maria/maria{1,2}.txt
sudo chown maria:maria /home/maria/maria*.txt

## 10. Instalamos filezilla en la maquina local

iniciamos con el usuario anonimous y ponemos la ip de la maquina y el puerto 21 y nos establece conexion

## 11. Creamos un certificado ssl
sudo openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key \
-out /etc/ssl/certs/pablo.test.pem

## 12. Añadimos estos parametros en el final del archivo de vsftpd.conf y reiniciamos el servidor
ssl_enable=YES
rsa_cert_file=/etc/ssl/certs/pablo.test.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.key
allow_anon_ssl=NO
require_ssl_reuse=NO
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO

## 13. Nos volvemos a conectar con fillezilla 
Ponemos la ip : 192.168.56.105 , usuario luis, passwd luis, puerto 21

## 14. Copiamos los archivos de configuracion del servidor ftp y los copiamos en /vagrant/config 
sudo cp /etc/vsftpd.conf /vagrant/config/
sudo cp /etc/vsftpd.conf /vagrant/config/

## 15. Y por ultimo volvemos a configurar el bootstrap
    #!/bin/bash
set -e

echo "=== [1/8] Actualizando paquetes ==="
apt update -y

echo "=== [2/8] Instalando vsftpd y openssl ==="
apt install -y vsftpd openssl

echo "=== [3/8] Creando usuarios locales ==="
for user in luis maria miguel; do
    if ! id "$user" &>/dev/null; then
        useradd -m "$user"
        echo "$user:$user" | chpasswd
    fi
done

echo "=== [4/8] Creando estructura de directorios FTP ==="
for user in luis miguel; do
    mkdir -p /home/$user/ftp
    chown nobody:nogroup /home/$user
    chmod a-w /home/$user
    touch /home/$user/ftp/${user}1.txt /home/$user/ftp/${user}2.txt
    chown -R $user:$user /home/$user/ftp
done

# Usuario maria (no enjaulado)
touch /home/maria/maria1.txt /home/maria/maria2.txt
chown maria:maria /home/maria/maria*.txt

echo "=== [5/8] Creando certificados SSL ==="
mkdir -p /etc/ssl/private /etc/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/vsftpd.key \
-out /etc/ssl/certs/pablo.test.pem \
-subj "/C=ES/ST=Granada/L=Chauchina/O=PabloServidor/OU=FTP/CN=pablo.test"

chmod 600 /etc/ssl/private/vsftpd.key
chmod 644 /etc/ssl/certs/pablo.test.pem

echo "=== [6/8] Copiando archivos de configuración desde /vagrant/config ==="
mkdir -p /home/vagrant/config
cp /vagrant/config/vsftpd.conf /etc/vsftpd.conf
cp /vagrant/config/vsftpd.chroot_list /etc/vsftpd.chroot_list
cp /vagrant/config/* /home/vagrant/config/

echo "=== [7/8] Reiniciando servicio vsftpd ==="
systemctl enable vsftpd
systemctl restart vsftpd

echo "=== [8/8] Estado final del servicio ==="
systemctl status vsftpd --no-pager
echo "=== Servidor FTP y FTPS configurado correctamente ==="
echo "Puedes conectarte con los usuarios: luis, maria, miguel (contraseña igual al usuario)."
echo "Directorio de maria no está enjaulado; los demás sí."