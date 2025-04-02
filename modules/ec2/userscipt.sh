#!/bin/bash
set -euo pipefail
echo "running scripts"
sudo apt update -y
sudo apt install -y nfs-common
sudo mkdir /mnt/efs

sudo mount -t nfs4 -o nfsvers=4.1 ${var.efs_id}:/ /mnt/efs
mount | grep efs


if dpkg -s mysql-server > /dev/null 2>&1; then
echo "MySQL server is installed."
else
echo "MySQL server is NOT installed."
fi
sudo apt-get update -y
sudo apt-get install mysql-client -y
mysql -h "${var.rds_endpoint}" -u "${var.rds_username}" -p "${var.rds_password}" -e "SELECT 1;"

echo "jayesh" >> /var/log/syslog
echo "jayesh" >> /var/log/syslog
echo "jayesh" >> /var/log/syslog
echo "jayesh" >> /var/log/syslog
sleep 20
echo "jayesh" >> /var/log/syslog
echo "jayesh" >> /var/log/syslog
echo "jayesh" >> /var/log/syslog
echo "jayesh" >> /var/log/syslog
