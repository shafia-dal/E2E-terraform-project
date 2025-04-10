######## S3 ##############
# resource "aws_s3_bucket" "e2e_artifect" {
#   bucket = var.artifect_bucket
#   # policy = file("bucket-policy.json")
#   policy = <<EOF
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "AllowCodeBuildToAccessS3",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "arn:aws:iam::091846656105:role/e2e_codebuild_role"
#             },
#             "Action": [
#                 "s3:GetObject",
#                 "s3:PutObject",
#                 "s3:ListBucket",
#                 "s3:GetObjectVersion"
#             ],
#             "Resource": [
#                 "arn:aws:s3:::e2e-artifect-bucket",
#                 "arn:aws:s3:::e2e-artifect-bucket/*"
#             ]
#         }
#     ]
# }
# EOF
# }
data "aws_s3_bucket" "e2e_artifect" {
  bucket = var.artifect_bucket
}

############# codebuild iam role ##########
resource "aws_iam_role" "e2e_codebuild_role" {
  name = "e2e_codebuild_role"

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
  role = "${aws_iam_role.e2e_codebuild_role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:us-east-1:091846656105:log-group:/aws/codebuild/e2e_codebuild_project",
        "arn:aws:logs:us-east-1:091846656105:log-group:/aws/codebuild/e2e_codebuild_project:*"
        ],
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::codepipeline-us-east-1-*"
      ],
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "codebuild:StartBuild",
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
      ],
      "Resource": [
          "arn:aws:codebuild:us-east-1:091846656105:report-group/e2e_codebuild_project-*"
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
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
      ],
      "Resource": "*"
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
  service_role  = "${aws_iam_role.e2e_codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${data.aws_s3_bucket.e2e_artifect.bucket}"
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

  # vpc_config {
  #   vpc_id = var.vpc_id

  #   subnets = [var.private_subnet] 
  #   security_group_ids = [aws_security_group.cicd_sg.id]
   
  # }
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
# resource "aws_security_group" "cicd_sg" {
#   name        = "cicd_security_group"
#   description = "Security group for CodeBuild in CICD"
#   vpc_id      = var.vpc_id

#   # No inbound rules needed
#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = 0
#     cidr_blocks = []
#   }

#   # Allow all outbound traffic (needed for S3, ECR, RDS, etc.)
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "CICD Security Group"
#   }
# }