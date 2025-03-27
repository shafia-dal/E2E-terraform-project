resource "aws_instance" "e2e-project" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  security_groups        = [var.security_group_id]

  tags = {
    Name = var.instance_name
  }
    user_data = <<-EOF
              #!/bin/bash
              yum install -y amazon-efs-utils
              mkdir -p /mnt/efs
              mount -t efs ${module.efs.efs_id}:/ /mnt/efs
              echo "${module.efs.efs_id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab
              EOF
}

