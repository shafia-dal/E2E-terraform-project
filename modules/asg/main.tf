# Define Launch Template
resource "aws_launch_template" "e2e-project-lt"{
  image_id      = var.ami_id 
  instance_type = "t3a.large"
  user_data     = base64encode(data.template_file.instance_provision.rendered)
  iam_instance_profile {
    name = aws_iam_instance_profile.asg_instance_profile.arn
  }
 
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_id]
  }
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "instance_provision" {
  template = file("${path.module}/userscript.sh")

  vars = {
    efs_id         = var.efs_id
    rds_endpoint   = var.rds_endpoint
    rds_username   = var.rds_username
    rds_password   = var.rds_password
    #... any other variables used in your user_data template
  }
}

# Define Auto Scaling Group
resource "aws_autoscaling_group" "e2e-project-asg" {
  # availability_zones = ["us-east-1a"]
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = [var.subnet_id]

  launch_template {
    id      = aws_launch_template.e2e-project-lt.id
    version = aws_launch_template.e2e-project-lt.latest_version
  }
    target_group_arns = [var.target_group_arn]  # Attach ASG to ALB Target Group
  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }
}
# Create the role
resource "aws_iam_role" "ec2_role" {
  name = "my-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create the instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "my-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
