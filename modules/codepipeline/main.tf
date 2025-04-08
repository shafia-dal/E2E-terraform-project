resource "aws_codepipeline" "myapp_pipeline" {
  name     = "e2e-project-pipeline"
  role_arn = aws_iam_role.e2e_codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = var.artifect_bucket
  }

 stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "shafia-dal/nodejs-app"
        BranchName       = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "e2e_codebuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]

      configuration = {
        ProjectName = var.project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "e2e_codedeploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["BuildOutput"]

      configuration = {
        ApplicationName     = var.codedeploy_app 
        DeploymentGroupName = var.deployment_group_name
      }
    }
  }
}
resource "aws_iam_role" "e2e_codepipeline_role" {
  name = "e2e-project-codepipeline-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "e2e_codepipeline_iam_policy" {
  role = "${aws_iam_role.e2e_codepipeline_role.name}"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${var.artifect_bucket_arn}",
        "${var.artifect_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "${var.artifect_bucket_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "codeconnections:*",
          "codestar-connections:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "codebuild:*",
      "Resource": "*"
    }
  ]
}
EOF
}