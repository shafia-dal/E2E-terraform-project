######## S3 ##############
resource "aws_s3_bucket" "e2e_artifect" {
  bucket = "e2e-artifect-bucket"
}
############# codebuild iam role ##########
resource "aws_iam_role" "e2e_codebuild_iam" {
  name = "e2e_codebuild_iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "e2e_codebuild_iam_policy" {
  role = "${aws_iam_role.e2e_codebuild_iam.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:123456789012:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:${var.private_subnet}":"",
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.e2e_artifect.arn}",
        "${aws_s3_bucket.e2e_artifect.arn}/*"
      ]
    }
  ]
}
POLICY
}

######## build project ###############
resource "aws_codebuild_project" "e2e_codebuild_project" {
  name          = var.project_name
  description   = "test_codebuild_project"
  # build_timeout = "5"
  service_role  = "${aws_iam_role.e2e_codebuild_iam.arn}"

  artifacts {
    type = "CODEBUILD"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.e2e_artifect.bucket}"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true # Required for Docker commands
  #   environment_variable {
  #     name  = "SOME_KEY2"
  #     value = "SOME_VALUE2"
  #     type  = "PARAMETER_STORE"
  #   }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/shafia-dal/nodejs-app.git"
    # git_clone_depth = 1
    buildspec = "buildspec.yml"
  }

  vpc_config {
    vpc_id = var.vpc_id

    subnets = [var.private_subnet] 
    security_group_ids = [aws_security_group.cicd_sg.id]
   
  }
}
# resource "aws_codebuild_project" "e2e-codebuild-project" {
#   name         = "e2e-codebuild"
#   service_role = aws_iam_role.e2e_codebuild_iam.arn

#   artifacts {
#     type = "S3"
#     location = aws_s3_bucket.e2e_artifect.bucket
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:5.0"
#     type                        = "LINUX_CONTAINER"
#     privileged_mode             = true 
#   }

#   source {
#     type      = "GITHUB"
#     location  = "https://github.com/shafia-dal/nodejs-app.git"
#     buildspec = "buildspec.yml"
#   }
# }

####### security Group ################
resource "aws_security_group" "cicd_sg" {
  name        = "cicd_security_group"
  description = "Security group for CodeBuild in CICD"
  vpc_id      = var.vpc_id

  # No inbound rules needed
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = 0
    cidr_blocks = []
  }

  # Allow all outbound traffic (needed for S3, ECR, RDS, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CICD Security Group"
  }
}