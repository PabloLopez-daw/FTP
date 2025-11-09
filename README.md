# FTP

## 1.  Primero creamos el archivo vagrant , haciendo un vagrant init 

## 2.  Creamos el script bootstrap.sh y le ponemos los siguientes comandos : 
    apt update -y
    apt install vsftpd -y
    cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

    lo que hace esto es actualizar la maquina y ademas instala un servidor ftp y hace una copia de la configuracion 
    y le damos permiso de ejecucion al script 

## 3 hacemos un vagrant up 

