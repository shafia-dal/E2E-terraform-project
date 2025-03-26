variable "ami_id" {
    type = string
}
variable "instance_type" {
    type = string
}
variable "security_group_id" {
    type = string
}
variable "subnet_ids" {
    type = list(string) 
}
variable "min_size" {
    type = number
}
variable "max_size" {
    type = number
}
variable "desired_capacity" {
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