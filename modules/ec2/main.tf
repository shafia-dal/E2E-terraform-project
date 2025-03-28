resource "aws_instance" "e2e-project" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  security_groups        = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name = var.instance_name
  }

  

     user_data = <<-EOF
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

  EOF
}

