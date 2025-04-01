resource "aws_security_group" "alb_sg" {
  name        = var.alb_sg
  description = "Security group for alb"
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
resource "aws_lb" "alb_loadbalancer" {
  name               = "e2e-project-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]
  tags = {
    Environment = "production"
  }
}


#target group
resource "aws_lb_target_group" "alb-tg" {
  name        = "alb-target-group"
  target_type = "instance"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path = "/"
    port = "80"
  }
}


#listener

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb_loadbalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb-tg.arn
    type             = "forward"
  }
}