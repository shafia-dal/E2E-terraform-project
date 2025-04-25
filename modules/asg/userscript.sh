#!/bin/bash
echo "running scripts"

# Define the output file
output_file="script_output.log"

# Redirect all standard output and standard error to the output file
exec > >(tee -a "$output_file") 2>&1

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
sudo mount -t efs ${efs_id}:/ /mnt/linksdb/
sudo cp /etc/fstab /etc/fstab.bak
echo "Adding EFS mount entry to /etc/fstab"
echo ${efs_id}:/ /mnt/linksdb efs defaults,_netdev 0 0 | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount -a

echo "Testing the new fstab entry..."
if sudo mount -a
then
  echo "EFS mount entry added and tested successfully. It will be mounted automatically on next boot."
else
  echo "Error: Failed to mount with the new fstab entry. Please check /etc/fstab for errors."
  echo "You might need to manually correct /etc/fstab or restore the backup."
fi


#db_file.sql
sudo mkdir -p /mnt/linksdb/db_init
sudo mv /home/ubuntu/nodejs-app/scripts/db.sql /mnt/linksdb/db_init/


#tables file sql
aws s3 cp s3://e2e-artifect-bucket/db.sql /tmp/downloaded_db.sql
sudo mkdir -p /tmp/
S3_BUCKET_NAME="e2e-artifect-bucket" # Replace with your S3 bucket name
SCRIPT_KEY="db.sql"   # Replace with the path to your script in the bucket
LOCAL_SCRIPT_PATH="/tmp/db.sql"
aws s3 cp s3://$S3_BUCKET_NAME/$SCRIPT_KEY $LOCAL_SCRIPT_PATH


#db_file.sql
sudo apt-get update -y
sudo apt install -y mysql-client-core-8.0
rds_hostname=$(echo ${rds_endpoint} | cut -d':' -f1)
# Check if the database exists


DATABASE_NAME=linksdb

db_path=/tmp/downloaded_db.sql
echo "Checking if database $DATABASE_NAME exists on RDS..."
database_exists=$(mysql -h $rds_hostname -u ${rds_username} -p${rds_password} -e "SHOW DATABASES LIKE $DATABASE_NAME;" | grep $DATABASE_NAME)

if [ -z $database_exists ]; then
  echo "Database "$DATABASE_NAME" does not exist. Creating it..."
fi
if mysql -h $rds_hostname -u ${rds_username} -p${rds_password} -e "CREATE DATABASE $DATABASE_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"; then
  echo "Database '$DATABASE_NAME' created successfully."
fi

  echo "Executing SQL script from $db_path to create tables..."
  sudo mysql -h $rds_hostname -u ${rds_username} -p${rds_password} $DATABASE_NAME < $db_path
  if [ $? -eq 0 ]; then
    echo "Database tables created successfully."
  else
    echo "Error creating database tables. Check MySQL logs."
  fi
else
  echo "SQL script not found at $db_path. Please check the path."
fi

