resource "aws_codedeploy_app" "myapp" {
  name = "myapp-deployment"
}

resource "aws_codedeploy_deployment_group" "myapp" {
  app_name              = aws_codedeploy_app.myapp.name
  deployment_group_name = "myapp-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "myapp-server"
    }
  }
}
resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role"
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
