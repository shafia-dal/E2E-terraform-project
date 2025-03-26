# main.tf
module "vpc" {
  source          = "/home/jayesh/E2E-terraform-project/modules/vpc"
  vpc_name        = "my-custom-vpc" # Override the default vpc_name
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"] #Or use different AZs
  public_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  private_subnet_cidrs = ["10.0.110.0/24", "10.0.120.0/24", "10.0.130.0/24"]
}

module "alb" {
  source             = "/home/jayesh/E2E-terraform-project/modules/LoadBalancer"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  alb_name           = "my-app-alb"
  instance_id        = module.ec2.instance_id
 security_group_ids = [aws_security_group.alb_sg.id]
}

output "alb_dns" {
    value = module.alb.alb_dns_name
}