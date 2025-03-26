variable "ami_id" {}
variable "instance_type" {}
variable "security_group_id" {}
variable "subnet_ids" { type = list(string) }
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}
variable "instance_name" {}
