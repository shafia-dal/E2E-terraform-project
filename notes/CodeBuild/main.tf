module "codebuild" {
  source           = "./modules/codebuild"
  project_name     = var.codebuild_project_name
  repo_url         = var.codebuild_repo_url
  build_spec       = var.codebuild_build_spec
  service_role_arn = var.codebuild_service_role_arn
}
