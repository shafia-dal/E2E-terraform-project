variable "name" {
  description = "The name prefix for the VPC and associated resources."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones in which to create subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instances."
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair to associate with instances."
  type        = string
}
