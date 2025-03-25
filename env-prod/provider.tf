# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.16"
#     }
#   }

#   required_version = ">= 1.2.0"
# }

# provider "aws" {
#   region  = "us-west-2"
# }

# resource "aws_instance" "myProject" {
#   ami           = "ami-830c94e3"
#   instance_type = "t3a.midium"

#   tags = {
#     Name = "ReactAppServerInstance"
#   }
# }
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
  backend "s3" {
    
    bucket = "e2e_state_bucket"
    key    = "terraform.tfstate"

    # S3 backend's region
    region  = "us-east-1"
    profile = "default"
  }
}
