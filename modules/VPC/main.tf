resource "aws_vpc" "myProject-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.myProject-vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_subnet" "private" {
      vpc_id            = aws_vpc.main.id
      cidr_block        = var.private_subnet_cidr
      availability_zone = var.availability_zone
      tags = {
        Name = "private-subnet"
      }
    }

    #  variable "vpc_cidr_block" {
#       description = "CIDR block for the VPC"
#       type        = string
#       default     = "10.0.0.0/16"
#     }

#     variable "private_subnet_cidr" {
#       description = "CIDR block for the private subnet"
#       type        = string
#       default     = "10.0.1.0/24"
#     }