module "codedeploy" {
  source = "./modules/codedeploy"
  application_name      = var.codedeploy_application_name
  deployment_group_name = var.codedeploy_deployment_group_name
  service_role_arn      = var.codedeploy_service_role_arn
  ec2_tag_filters = {
    "Name" = var.codedeploy_ec2_tag_name
  }
  load_balancer_target_group_arn = module.elb.target_group_arn
}

