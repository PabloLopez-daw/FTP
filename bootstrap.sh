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