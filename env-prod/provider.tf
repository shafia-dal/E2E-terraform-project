provider "aws" {
  region  = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::091846656105:role/operisoft-admin"
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

