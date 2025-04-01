variable "rds_sg" {
  type = string
  default = "rds_sg"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_id" {
  type = list(string)
}



variable "security_group_id" { #ec2 security group
  type = string
}

variable "instance_class" {
  type = string
}



variable "allocated_storage" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "username" {
  type = string
}

variable "db_password" {
  type = string
}

