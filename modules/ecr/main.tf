resource "aws_ecr_repository" "myapp" {
  name = "myapp-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = false
  }
}
