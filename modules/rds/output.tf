output "rds_endpoint" {
  value       = aws_db_instance.rds.endpoint
  description = "RDS instance endpoint"
}
output "rds_username" {
  value = aws_db_instance.rds.username
  description = "rds username"
}
output "rds_password" {
  value = aws_db_instance.rds.password
  description = "rds pass"
}