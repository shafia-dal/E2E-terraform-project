#instance profile and policy
resource "aws_iam_role" "e2e_instance_profile" {
  name = "e2e-instance-profile"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "e2e_instance_iam_policy" {
  role = "${aws_iam_role.e2e_instance_profile.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "rds:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ecr:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "cloudwatch:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "autoscaling:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:AWSServiceName": [
            "autoscaling.amazonaws.com",
            "ec2scheduled.amazonaws.com",
            "elasticloadbalancing.amazonaws.com",
            "spot.amazonaws.com",
            "spotfleet.amazonaws.com",
            "transitgateway.amazonaws.com"
          ]
        }
      }
    }
  ]
}
POLICY
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "e2e-instance-profile"
  role = "${aws_iam_role.e2e_instance_profile.name}"
}

# Define Launch Template
resource "aws_launch_template" "e2e-project-lt"{
  image_id      = var.ami_id 
  instance_type = "t3a.large"
  user_data     = base64encode(data.template_file.instance_provision.rendered)
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_id]
  }
   iam_instance_profile {
    # arn = aws_iam_instance_profile.ec2_instance_profile.arn
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  # depends_on = [aws_iam_instance_profile.ec2_instance_profile]
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