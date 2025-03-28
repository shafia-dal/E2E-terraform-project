resource "aws_security_group" "rds_sg" {
  name        = var.rds_sg
  description = "Security group for rds"
  vpc_id      = var.vpc_id

  # Inbound HTTP
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Inbound HTTPS
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound SSH
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For production, restrict to your IP
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-group"
    Environment = "Development"
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = var.security_group_id  #ec2 security group
}


#subnet group
resource "aws_db_subnet_group" "subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [var.private_subnet_id]
  tags = {
    Name = "db-subnet-group"
  }
}

#rds db instance 

resource "aws_db_instance" "rds" {
  storage_type           = "gp3" 
  identifier             = "rds"
  instance_class        = var.instance_class
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  username               = var.username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  
}
