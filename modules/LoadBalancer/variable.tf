variable "alb_name" {
  type        = string  
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