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
  default = "alb_sg"
}