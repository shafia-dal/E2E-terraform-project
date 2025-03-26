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