output "efs_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.this.id
}

output "mount_targets" {
  description = "EFS mount target IDs"
  value       = aws_efs_mount_target.this[*].id
}
