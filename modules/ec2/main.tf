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
  sudo apt update -y
  sudo apt install -y amazon-efs-utils
  sudo mkdir /mnt/efs
  sudo mount -t efs ${var.efs_id}:/ /mnt/efs


     sudo apt-get update -y
    sudo apt-get install mysql-client -y

    mysql -h "${var.rds_endpoint}" -u "${var.rds_username}" -p "${var.rds_password}" -e "SELECT 1;"

  EOF

 

}

