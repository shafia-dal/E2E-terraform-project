module "vpc" {
  source           = "../modules/vpc"
  vpc_cidr         = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones = var.availability_zones
  instance_type      = var.instance_type
  ami                = var.ami
  key_name           = var.key_name
}