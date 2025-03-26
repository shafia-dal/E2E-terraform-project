# main.tf
module "vpc" {
  source          = "../modules/vpc"
  vpc_name        = "e2e-project-vpc" 
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"] 
  public_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  private_subnet_cidrs = ["10.0.110.0/24", "10.0.120.0/24", "10.0.130.0/24"]
}
module "ec2" {
  source              = "../modules/ec2"
  ami_id              = "ami-0e35ddab05955cf57"
  instance_type       = "t3a.large"
  subnet_id           = module.vpc.private_subnet.id
  security_group_id   = module.vpc.e2e-server-sg.id
  instance_name       = "e2e-project-server"
}

module "asg" {
  source              = "../modules/asg"
  ami_id              = "ami-0e35ddab05955cf57"
  instance_type       = "t3a.large"
  security_group_id   = module.vpc.e2e-server-sgid
  subnet_ids          = module.vpc.public_subnet.id
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  instance_name       = "e2e-project-server"
}