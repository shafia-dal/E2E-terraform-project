#!/bin/bash
echo "running scripts"

##update packages ##
sudo apt update -y
sudo apt install -y nfs-common
sudo apt install -y ruby wget

##install codedeploy agent

wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

##docker install

sudo apt-get update -y
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu
sudo systemctl restart docker
sudo docker run hello-world

##aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
rm awscliv2.zip
rm -rf aws
echo "AWS CLI installed successfully!"
echo "Verify by running: aws --version"


## mount efs 
sudo mkdir -p /mnt/linksdb
sudo apt-get update -y
sudo apt-get -y install git binutils rustc cargo pkg-config libssl-dev gettext
git clone https://github.com/aws/efs-utils
 cd efs-utils
 ./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
sudo mount -t efs "${efs_id}":/ /mnt/linksdb/
sudo cp /etc/fstab /etc/fstab.bak
echo "Adding EFS mount entry to /etc/fstab"
echo "${efs_id}":/ /mnt/linksdb efs defaults,_netdev 0 0 | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount -a 


# Check if the database exists
sudo apt-get update -y
sudo apt install -y mysql-client-core-8.0
rds_hostname=$(echo ${rds_endpoint} | cut -d':' -f1)
DATABASE_NAME="linksdb"
DB_SQL_LOCAL_PATH="./db.sql"

log_info "Checking if database '${DATABASE_NAME}' exists on RDS..."
database_exists=$(mysql -h $rds_hostname -u ${rds_username} -p${rds_password} -e "SHOW DATABASES LIKE '${DATABASE_NAME}';" | grep "${DATABASE_NAME}")

if [ -z "$database_exists" ]; then
  log_info "Database "$DATABASE_NAME" does not exist. Creating it..."
fi
if mysql -h $rds_hostname -u ${rds_username} -p${rds_password} -e "CREATE DATABASE $DATABASE_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"; then
  log_info "Database '${DATABASE_NAME}' created successfully."
fi
if [ -f "${DB_SQL_LOCAL_PATH}" ]; then
  log_info "Executing SQL script from '${DB_SQL_LOCAL_PATH}' to create tables..."
  sudo mysql -h $rds_hostname -u ${rds_username} -p${rds_password} $DATABASE_NAME <"${DB_SQL_LOCAL_PATH}"
  if [ $? -eq 0 ]; then
    log_info "Database tables created successfully."
  else
    log_error "Error creating database tables. Check MySQL logs."
  fi
else
  log_error "SQL script not found at '${DB_SQL_LOCAL_PATH}'"
fi
