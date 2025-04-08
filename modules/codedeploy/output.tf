output "codedeploy_app" {
  value = aws_codedeploy_app.e2e-codedeploy-app.application_id
}
output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.e2e-codedeployment-group.app_name
}