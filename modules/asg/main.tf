# Define Launch Template
resource "aws_launch_template" "e2e-project-lt" {
  image_id      = "ami-084568db4383264d4" 
  instance_type = "t3a.large"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
    }
  }
   user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y amazon-efs-utils
  sudo mkdir /mnt/efs
  sudo mount -t efs ${var.efs_id}:/ /mnt/efs
  EOF
}

# Define Auto Scaling Group
resource "aws_autoscaling_group" "e2e-project-asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.subnet_ids

  launch_template {
    id      = aws_launch_template.e2e-project-lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }
}