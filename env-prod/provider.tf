provider "aws" {
  region = "us-east-1"

}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "e2e-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}