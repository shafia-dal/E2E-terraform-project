resource "aws_codepipeline" "myapp_pipeline" {
  name     = "myapp-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        Owner      = "your-github-username"
        Repo       = "myapp"
        Branch     = "main"
        OAuthToken = "your-github-token"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build_Image"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]

      configuration = {
        ProjectName = aws_codebuild_project.myapp.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy_App"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["BuildOutput"]

      configuration = {
        ApplicationName     = aws_codedeploy_app.myapp.name
        DeploymentGroupName = aws_codedeploy_deployment_group.myapp.deployment_group_name
      }
    }
  }
}
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"
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
