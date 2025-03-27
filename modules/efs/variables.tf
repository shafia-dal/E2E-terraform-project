variable "creation_token" {
  description = "Unique identifier for the EFS file system"
  type        = string
  default     = "my-efs"
}

variable "performance_mode" {
  description = "The performance mode of the file system"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "Throughput mode for the file system"
  type        = string
  default     = "bursting"
}

variable "encrypted" {
  description = "If true, the file system will be encrypted"
  type        = bool
  default     = true
}

variable "transition_to_ia" {
  description = "Lifecycle policy for transition to Infrequent Access (IA)"
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "tags" {
  description = "Tags to apply to the EFS file system"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "List of subnet IDs for mount targets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for EFS"
  type        = list(string)
}
