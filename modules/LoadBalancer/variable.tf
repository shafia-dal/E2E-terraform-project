variable "alb_name" {
  description = "alb name"
  type        = string
  default     = "alb"
  
}

variable "internal" {
  description = "Whether the ALB is internal (true) or external (false)"
  type        = bool
  default     = false
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}


variable "security_group_ids" {
  type = list(string)
}
variable "instance_id" {
  type = string
}