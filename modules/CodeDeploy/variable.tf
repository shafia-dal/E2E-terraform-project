# CodeDeploy Variables
variable "codedeploy_application_name" {
  type = string
  default = "nextcloud-app-deploy"
}
variable "codedeploy_deployment_group_name" {
  type = string
  default = "nextcloud-app-deployment-group"
}
variable "codedeploy_service_role_arn" {
  type = string
  default = "" # REPLACE
}
variable "codedeploy_ec2_tag_name" {
  type = string
  default = "nextcloud"
}