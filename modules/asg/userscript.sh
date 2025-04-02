#!/bin/bash
set -euo pipefail
echo "running scripts"
##
sudo apt update -y
sudo apt install -y nfs-common
## mount efs 
sudo mkdir /mnt/
sudo apt-get update
sudo apt-get -y install git binutils rustc cargo pkg-config libssl-dev gettext
git clone https://github.com/aws/efs-utils
 cd efs-utils
 ./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
sudo mount -t efs "${efs_id }":/ /mnt/nextcloud/
sudo cp /etc/fstab /etc/fstab.bak
echo "Adding EFS mount entry to /etc/fstab"
echo "${efs_id }":/ /mnt/nextcloud efs defaults,_netdev 0 0 | sudo tee -a /etc/fstab

sudo mount -a 

echo "Testing the new fstab entry..."
if sudo mount -a; then
  echo "EFS mount entry added and tested successfully. It will be mounted automatically on next boot."
else
  echo "Error: Failed to mount with the new fstab entry. Please check /etc/fstab for errors."
  echo "You might need to manually correct /etc/fstab or restore the backup."
fi


##mysql 


if dpkg -s mysql-server > /dev/null 2>&1; then
echo "MySQL server is installed."
else
echo "MySQL server is NOT installed."
fi
sudo apt-get update -y
sudo apt-get install mysql-client -y
if mysql -h "${rds_endpoint}" -u "${rds_username}" -p "${rds_password}" -e CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;; then
echo "nextcloud created successfully on RDS."
else
  echo "Error: Failed to create database nextcloud on RDS. Check the output above for details."
  exit 1
fi
echo "RDS preparation for Nextcloud complete."