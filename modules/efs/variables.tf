variable "efs_name" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "subnet_id" {
  type        = list(string)
}

variable "performance_mode" {
  type        = string #general perpose
  default     = "generalPurpose"
}

variable "throughput_mode" {
  type        = string #bursting
  default     = "bursting"
}

variable "efs_sg" {
  default = "efs_sg"
}
