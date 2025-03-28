resource "aws_security_group" "elasticache_sg" {
  name        = var.elasticache_sg
  description = "Security group for elasticache"
  vpc_id      = var.vpc_id

  # Inbound HTTP
  ingress {
    description = "HTTP from anywhere"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [ var.security_group_id ]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-group"
    Environment = "Development"
  }
}
#####################################################

resource "aws_elasticache_subnet_group" "e2e-project-esg" {
  name       = "${var.cluster_id}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_cluster" "e2e-project-elasticache-cluster" {
  cluster_id           = var.cluster_id
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.e2e-project-esg.name
  security_group_ids   = aws_security_group.elasticache_sg.id

  tags = {
    Name = var.cluster_id
  }
}
