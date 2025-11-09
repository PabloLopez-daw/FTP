#!/bin/bash
apt update -y
apt install vsftpd -y
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak