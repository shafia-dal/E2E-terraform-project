module "vpc" {
  source               = "../modules/vpc"
  cidr_block           = "10.0.0.0/16"
  name                 = "e2e-appserver-vpc"
  public_subnet_cidrs  = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  private_subnet_cidrs = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]

}