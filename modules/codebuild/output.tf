output "codebuild_project_name" {
  description = "The name of the CodeBuild project"
  value       = aws_codebuild_project.e2e_codebuild_project.name
}

output "codebuild_iam_role_arn" {
  description = "The ARN of the IAM role used by CodeBuild"
  value       = aws_iam_role.e2e_codebuild_role.arn
}

output "artifect_bucket" {
  description = "The S3 bucket where CodeBuild artifacts are stored"
  value       = aws_s3_bucket.e2e_artifect.bucket
}
output "artifect_bucket_arn" {
  description = "The S3 bucket where CodeBuild artifacts are stored"
  value       = aws_s3_bucket.e2e_artifect.arn
}