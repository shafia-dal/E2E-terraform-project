# main.tf
module "vpc" {
  source          = "../modules/vpc"
  vpc_name        = "e2e-project-vpc" 
  vpc_cidr        = "10.0.0.0/16"
  security_group  = "e2e-server-sg"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"] 
  public_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  private_subnet_cidrs = ["10.0.110.0/24", "10.0.120.0/24", "10.0.130.0/24"]
}
module "ec2" {
  source              = "../modules/ec2"
  ami_id              = "ami-084568db4383264d4"
  instance_type       = "t3a.large"
  subnet_id           = module.vpc.private_subnet_id[0]
  security_group_id   = module.vpc.security_group_id
  instance_name       = "e2e-project-server"
}

# module "asg" {
#   source              = "../modules/asg"
#   asg_name            = "e2e-project-asg" 
#   vpc_id              = module.vpc.vpc_id
#   ami_id              = "ami-084568db4383264d4"
#   instance_type       = "t3a.large"
#   security_group_id   = module.vpc.security_group_id
#   subnet_ids          = module.vpc.public_subnet_id
#   min_size            = 1
#   max_size            = 3
#   desired_capacity    = 1
#   instance_name       = "e2e-project-server"
# }