############ EFS ##################3
resource "aws_efs_file_system" "efs" {
  creation_token = var.efs_name
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode

  tags = {
    Name = var.efs_name
  }
}

############ security group ##################3
resource "aws_security_group" "efs_sg" {
  name        = var.efs_sg
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.efs_name}-sg"
  }
}

############ mount target ##################
resource "aws_efs_mount_target" "efs_mount" {
  # count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.public_subnet_ids
  security_groups = [aws_security_group.efs_sg.id]
}