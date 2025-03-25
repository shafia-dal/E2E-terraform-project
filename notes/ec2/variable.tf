variable "ec2_instance_type" {
  type    = string
  default = "t3.medium"
}
variable "ec2_min_size" {
  type    = number
  default = 2
}
variable "ec2_max_size" {
  type    = number
  default = 5
}

variable "ami_id" {
  type    = string
  default = "ami-0e35ddab05955cf57"
}
