resource "aws_efs_file_system" "this" {
  creation_token   = var.creation_token
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  encrypted        = var.encrypted
  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }
  tags = var.tags
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = var.security_group_ids
}
