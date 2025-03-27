variable "ami_id" {
    type = string
}
variable "instance_type" {
    type = string
}
variable "subnet_id" {
    type = string
}
variable "security_group_id" {
    type = string
}
variable "instance_name" {
    type = string
}
variable "key_name" {
  type = string
  default = "E2E-APP-KEY"
}