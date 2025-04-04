resource "aws_codedeploy_app" "e2e-codedeploy-app" {
  name = var.codedeploy_app
}

resource "aws_codedeploy_deployment_group" "e2e-codedeployment-group" {
  app_name              = aws_codedeploy_app.e2e-codedeploy-app.name
  deployment_group_name = var.deployment_group_name
  service_role_arn      = aws_iam_role.e2e_codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "nodeapp-server"
    }
  }
}
resource "aws_iam_role" "e2e_codedeploy_role" {
  name = "e2e-codedeploy-role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codedeploy.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}
