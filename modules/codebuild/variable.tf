# # CodeBuild Variables
# variable "codebuild_project_name" {
#   type    = string
#   default = "nextcloud-app"
# }
# variable "codebuild_repo_url" {
#   type    = string
#   default = "https://github.com/shafia-dal/terraform.git" # REPLACE
# }
# variable "codebuild_build_spec" {
#   type    = string
#   default = "buildspec.yml"
# }
# variable "codebsuild_service_role_arn" {
#   type    = string
#   default = "" # REPLACE
# }
variable "vpc_id" {
  type = string
}
variable "private_subnet" {
  type = string
}
variable "project_name" {
  type = string
}
variable "repository_url" {
  type = string
}