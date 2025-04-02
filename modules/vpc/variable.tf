# modules/vpc/variables.tf

variable "vpc_name" {
  type        = string
}

variable "vpc_cidr" {
  type        = string
}

variable "azs" {
  type        = list(string)
}

variable "public_subnet_cidrs" {
  type        = list(string)
}

variable "private_subnet_cidrs" {
  type        = list(string)
}
variable "security_group" {
  type = string
}

variable "alb_sg_id" {
  type = string
  description = "alb secuirty group id "
}