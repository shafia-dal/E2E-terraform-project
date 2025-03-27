variable "alb_name" {
  type        = string  
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}


variable "alb_sg" {
  type = string
}
variable "instance_id" {
  type = string
}