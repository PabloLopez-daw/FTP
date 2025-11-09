# 🌐 Servidor FTP/FTPS con Vagrant y vsftpd

Este proyecto muestra cómo crear y configurar un **servidor FTP seguro (FTPS)** dentro de una máquina virtual utilizando **Vagrant** y **vsftpd**.  
Incluye un script automatizado `bootstrap.sh` que instala, configura y deja listo el servidor con usuarios, permisos y certificados SSL.

---

## 🧰 Requisitos previos

Antes de comenzar, asegúrate de tener instalado en tu sistema:

- 🧩 **Vagrant**
- 🖥️ **VirtualBox**
- 💻 **Linux / macOS / Windows** (con terminal compatible)

---

## 🚀 Pasos de instalación y configuración

### 1️⃣ Crear y preparar el entorno de Vagrant

Inicializa el proyecto con:

```bash
vagrant init
```
```bash
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  config.vm.hostname = "ftp-server"
  config.vm.network "private_network", ip: "192.168.56.105"
  config.vm.network "forwarded_port", guest: 21, host: 2121
  config.vm.synced_folder ".", "/vagrant"  
  config.vm.provision "shell", path: "bootstrap.sh"
end
```
---

### 2️⃣ Crear el script `bootstrap.sh`

Crea un archivo llamado `bootstrap.sh` y añade el siguiente contenido:

```bash
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
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/pablo.test.pem -subj "/C=ES/ST=Granada/L=Chauchina/O=PabloServidor/OU=FTP/CN=pablo.test"

chmod 600 /etc/ssl/private/vsftpd.key
chmod 644 /etc/ssl/certs/pablo.test.pem

echo "=== [6/8] Copiando archivos de configuración ==="
mkdir -p /home/vagrant/config
cp /vagrant/config/vsftpd.conf /etc/vsftpd.conf
cp /vagrant/config/vsftpd.chroot_list /etc/vsftpd.chroot_list
cp /vagrant/config/* /home/vagrant/config/

echo "=== [7/8] Reiniciando servicio vsftpd ==="
systemctl enable vsftpd
systemctl restart vsftpd

echo "=== [8/8] Estado final del servicio ==="
systemctl status vsftpd --no-pager
echo "✅ Servidor FTP y FTPS configurado correctamente"
echo "👤 Usuarios disponibles: luis, maria, miguel (contraseña = nombre del usuario)"
```

Dale permisos de ejecución:

```bash
chmod +x bootstrap.sh
```

---

### 3️⃣ Levantar la máquina virtual

Ejecuta:

```bash
vagrant up
```

Esto creará y configurará automáticamente el servidor FTP dentro de la máquina virtual.

---

### 4️⃣ Configuración del servidor `/etc/vsftpd.conf`

Ejemplo de configuración funcional:

```conf
# Servidor independiente (solo IPv4)
listen=YES
listen_ipv6=NO

# Mensaje de bienvenida
ftpd_banner=--- Welcome to the FTP server of 'javier.test' ---

# Permitir usuarios anónimos (solo lectura)
anonymous_enable=YES
anon_root=/srv/ftp
write_enable=NO

# Permitir usuarios locales (lectura/escritura)
local_enable=YES
write_enable=YES

# Tiempo máximo de inactividad
idle_session_timeout=720

# Límites de velocidad
local_max_rate=5242880
anon_max_rate=2097152

# Enjaular usuarios locales en su carpeta home
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list
```

⚙️ Añade al final del archivo para habilitar **FTPS (SSL/TLS):**

```conf
ssl_enable=YES
rsa_cert_file=/etc/ssl/certs/pablo.test.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.key
allow_anon_ssl=NO
require_ssl_reuse=NO
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
```

---

### 5️⃣ Lista de usuarios no enjaulados

Solo **maria** puede salir de su carpeta personal:

```bash
echo "maria" | sudo tee /etc/vsftpd.chroot_list
```

---

### 6️⃣ Crear usuarios y archivos de prueba manualmente (opcional)

```bash
sudo useradd -m luis && sudo passwd luis
sudo useradd -m maria && sudo passwd maria
sudo useradd -m miguel && sudo passwd miguel

sudo touch /home/luis/luis{1,2}.txt
sudo chown luis:luis /home/luis/luis*.txt
sudo touch /home/maria/maria{1,2}.txt
sudo chown maria:maria /home/maria/maria*.txt
```

---

### 7️⃣ Conexión desde FileZilla 🧩

1. Abre **FileZilla**  
2. Conéctate con los siguientes datos:

| Parámetro | Valor |
|------------|--------|
| **Servidor (IP)** | `192.168.56.105` |
| **Usuario** | `luis` |
| **Contraseña** | `luis` |
| **Puerto** | `21` |

También puedes probar el acceso **anónimo** (`anonymous`).

---

### 8️⃣ Copia de seguridad de configuración

Guarda los archivos de configuración en la carpeta compartida de Vagrant:

```bash
sudo cp /etc/vsftpd.conf /vagrant/config/
sudo cp /etc/vsftpd.chroot_list /vagrant/config/
```

---

## 🧪 Verificación final

Comprueba el estado del servicio:

```bash
sudo systemctl status vsftpd
```

Debe aparecer:

```
Active: active (running)
```

---

## 🧾 Resumen de usuarios

| Usuario | Acceso FTP | Enjaulado | Contraseña |
|----------|-------------|------------|-------------|
| luis     | ✅ Sí       | ✅ Sí       | luis        |
| maria    | ✅ Sí       | ❌ No       | maria       |
| miguel   | ✅ Sí       | ✅ Sí       | miguel      |

---

## 🧠 Autor

Proyecto realizado por **Pablo**  
📍 *Granada, España*  
💡 Práctica de **configuración de servidor FTP seguro (FTPS)** usando **Vagrant + vsftpd**

---

## 🛡️ Licencia

Este proyecto es de uso **educativo y libre**.  
Puedes modificarlo y reutilizarlo con fines formativos.

---
