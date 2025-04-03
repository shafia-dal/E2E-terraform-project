#instance profile

#instance variables
variable "ami_id" {
    type = string
}
variable "instance_type" {
    type = string
}
variable "security_group_id" {
    type = string
}
variable "subnet_id" {
    type = string
}
variable "min_size" {
    type = number
}
variable "max_size" {
    type = number
}
variable "instance_name" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "asg_name" {
  type = string
}
variable "key_name" {
  type = string
  default = "E2E-APP-KEY"
}
variable "target_group_arn" {
  type = string
}


##rds variables 
variable "efs_id" {
  type = string
}
variable "rds_endpoint" {
  type = string
  description = "The RDS endpoint"
}

variable "rds_username" {
  type        = string
  description = "RDS username"
}

variable "rds_password" {
  type        = string
  description = "RDS password"
  sensitive   = true
}