module "ec2" {
  source             = "./modules/ec2"
  ami_id             = var.ec2_ami_id
  instance_type      = var.ec2_instance_type
  min_size           = var.ec2_min_size
  max_size           = var.ec2_max_size
  private_subnet_ids = [module.vpc.private_subnet_id]
  vpc_id             = module.vpc.vpc_id
  rds_endpoint       = module.rds.db_endpoint
  rds_password       = var.rds_db_password
  tags = {
    Name = "nextcloud"
  }
}