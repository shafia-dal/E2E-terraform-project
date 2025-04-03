# main.tf
module "vpc" {
  source               = "../modules/vpc"
  vpc_name             = "e2e-project-vpc"
  vpc_cidr             = "10.0.0.0/16"
  security_group       = "e2e-server-sg"
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  private_subnet_cidrs = ["10.0.110.0/24", "10.0.120.0/24", "10.0.130.0/24"]
  alb_sg_id            = module.alb.alb_sg_id
}
module "asg" {
  source               = "../modules/asg"
  asg_name             = "e2e-project-asg"
  vpc_id               = module.vpc.vpc_id
  ami_id               = "ami-084568db4383264d4"
  instance_type        = "t3a.large"
  security_group_id    = module.vpc.security_group_id
  subnet_id            = module.vpc.private_subnet_id[0]
  min_size             = 1
  max_size             = 3
  instance_name        = "e2e-project-server"
  target_group_arn     = module.alb.target_group_arns
  rds_endpoint         = module.rds.rds_endpoint
  rds_password         = module.rds.rds_password
  rds_username         = module.rds.rds_username
  efs_id               = module.efs.efs_id
}

module "alb" {
  source            = "/home/ubuntu/E2E-terraform-project/modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_id
  alb_name          = "e2e-project-alb"
  alb_sg            = "alb_sg"
}
output "alb_dns" {
  value = module.alb.alb_dns_name
}

module "rds" {
  source            = "../modules/rds"
  vpc_id            = module.vpc.vpc_id
  rds_sg            = "rds_sg"
  private_subnet_id = module.vpc.private_subnet_id
  engine            = "mysql"
  engine_version    = "8.0.35"
  instance_class    = "db.t3.medium"
  username          = "rds"
  db_password       = "password123"
  allocated_storage = 20
  security_group_id = module.vpc.security_group_id

}
module "efs" {
  source    = "../modules/efs"
  efs_name  = "e2e-project-efs"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_id # Attach to private subnets
  efs_sg    = "efs_sg"
}

module "elasticache" {
  source            = "../modules/elasticache"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_id
  cluster_id        = "redis"
  engine            = "redis"
  elasticache_sg    = "elasticache_sg"
  engine_version    = "7.0"
  node_type         = "cache.t3.micro"
  num_cache_nodes   = 1
  security_group_id = module.vpc.security_group_id
}

module "codebuild" {
  source            = "../modules/codebuild"
  project_name = "e2e_codebuild_project"
  vpc_id = module.vpc.vpc_id
  private_subnet = module.vpc.private_subnet_id
  repository_url = module.ecr.repository_url
}