#!/bin/bash
set -euo pipefail
echo "running scripts"
##
sudo apt update -y
sudo apt install -y nfs-common
## mount efs 
sudo mkdir -p /mnt/linksdb
sudo apt-get update
sudo apt-get -y install git binutils rustc cargo pkg-config libssl-dev gettext
git clone https://github.com/aws/efs-utils
 cd efs-utils
 ./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
sudo mount -t efs "${efs_id }":/ /mnt/linksdb/
sudo cp /etc/fstab /etc/fstab.bak
echo "Adding EFS mount entry to /etc/fstab"
echo "${efs_id }":/ /mnt/linksdb efs defaults,_netdev 0 0 | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount -a 

echo "Testing the new fstab entry..."
if sudo mount -a; then
  echo "EFS mount entry added and tested successfully. It will be mounted automatically on next boot."
else
  echo "Error: Failed to mount with the new fstab entry. Please check /etc/fstab for errors."
  echo "You might need to manually correct /etc/fstab or restore the backup."
fi


#db_file.sql
sudo mkdir -p /mnt/linksdb/db_init
sudo mv /home/jayesh/E2E-terraform-project/nodejs-app/scripts/db.sql /mnt/linksdb/db_init/


##mysql 
if dpkg -s mysql-server > /dev/null 2>&1; then
echo "MySQL server is installed."
else
echo "MySQL server is NOT installed."
fi
sudo apt-get update -y
sudo apt-get install mysql-client -y
if mysql -h "${rds_endpoint}" -u "${rds_username}" -p"${rds_password}" -e "CREATE DATABASE linksdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 
then
echo "linksdb database created successfully on RDS."
else
  echo "Error: Failed to create database linksdb on RDS. Check the output above for details."
  exit 1
fi
echo "RDS preparation for linksdb complete."

database_exists=$(mysql -h "${rds_endpoint}" -u "${rds_username}" -p"${rds_password}" -e "SHOW DATABASES LIKE 'linksdb';" | grep 'linksdb')

if [ -z "$database_exists" ]; then
  echo "Database 'linksdb' does not exist. Creating it..."
  if mysql -h "${rds_endpoint}" -u "${rds_username}" -p"${rds_password}" -e "CREATE DATABASE linksdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"; then
    echo "Database 'linksdb' created successfully."
    # Now apply the SQL script to create tables
    if [ -f "/mnt/efs/db_init/db.sql" ]; then
      echo "Executing SQL script from EFS to create tables..."
      sudo mysql -h "${rds_endpoint}" -u "${rds_username}" -p"${rds_password}" linksdb < /mnt/efs/db_init/db.sql
      if [ $? -eq 0 ]; then
        echo "Database tables created successfully."
      else
        echo "Error creating database tables. Check MySQL logs."
      fi
    else
      echo "SQL script not found on EFS at /mnt/efs/db_init/db.sql"
    fi
  else
    echo "Error creating database 'linksdb'. Check MySQL logs."
  fi
else
  echo "Database 'linksdb' already exists. Skipping creation."
  # You can add logic here to perform migrations or other actions if the DB exists
fi