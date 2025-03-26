# main.tf
module "vpc" {
  source          = "/home/ubuntu/E2E-terraform-project/modules/vpc"
  vpc_name        = "my-custom-vpc" # Override the default vpc_name
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"] #Or use different AZs
  public_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  private_subnet_cidrs = ["10.0.110.0/24", "10.0.120.0/24", "10.0.130.0/24"]
}