# Define Launch Template
resource "aws_launch_template" "e2e-project-lt" {
  image_id      = "ami-0e35ddab05955cf57" 
  instance_type = "t3a.midium"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [module.vpc.e2e-server-sg]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "e2e-project-instance"
    }
  }
}

# Define Auto Scaling Group
resource "aws_autoscaling_group" "e2e-project-asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 1
  vpc_zone_identifier  = module.vpc.public_subnets

  launch_template {
    id      = aws_launch_template.e2e-project-lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "e2e-asg-instance"
    propagate_at_launch = true
  }
}
