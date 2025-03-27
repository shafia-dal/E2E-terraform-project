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
}

# Define Auto Scaling Group
resource "aws_autoscaling_group" "e2e-project-asg" {
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