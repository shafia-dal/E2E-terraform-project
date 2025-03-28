# main.tf
module "vpc" {
  source          = "../modules/vpc"
  vpc_name        = "e2e-project-vpc" 
  vpc_cidr        = "10.0.0.0/16"
  security_group  = "e2e-server-sg"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"] 
  public_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  private_subnet_cidrs = ["10.0.110.0/24", "10.0.120.0/24", "10.0.130.0/24"]
  alb_sg_id = module.alb.alb_sg_id
}
module "ec2" {
  source              = "../modules/ec2"
  ami_id              = "ami-084568db4383264d4"
  instance_type       = "t3a.large"
  subnet_id           = module.vpc.private_subnet_id[0]
  security_group_id   = module.vpc.security_group_id
  instance_name       = "e2e-project-server"
}

module "asg" {
  source              = "../modules/asg"
  asg_name            = "e2e-project-asg" 
  vpc_id              = module.vpc.vpc_id
  ami_id              = "ami-084568db4383264d4"
  instance_type       = "t3a.large"
  security_group_id   = module.vpc.security_group_id
  subnet_ids          = module.vpc.public_subnet_id
  min_size            = 1
  max_size            = 3
  instance_name       = "e2e-project-server"
}

module "alb" {
  source             = "../modules/alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_id
  alb_name           = "e2e-project-alb"
  instance_id        = module.ec2.instance_id
  alb_sg             = "alb_sg"
}
output "alb_dns" {
    value = module.alb.alb_dns_name
}

module "rds" {
  source              = "../modules/rds"
  vpc_id              = module.vpc.vpc_id
  rds_sg              = "rds_sg"
  private_subnet_id   = module.vpc.private_subnet_id[0]
  engine              = "mysql"
  engine_version      = "8.0.35"
  instance_class      = "db.t3.medium"
  username            = "rds"
  db_password         = "password123"
  allocated_storage   = 20
  security_group_id = module.vpc.security_group_id

}