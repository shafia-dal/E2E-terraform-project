# modules/vpc/main.tf

resource "aws_vpc" "e2e-project-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.e2e-project-vpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true # Important for public subnets

  tags = {
    Name = "${var.vpc_name}-public-${element(var.azs, count.index)}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.e2e-project-vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.vpc_name}-private-${element(var.azs, count.index)}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.e2e-project-vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.e2e-project-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.public_subnet, count.index).id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.e2e-project-vpc.id
  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.private_subnet, count.index).id
  route_table_id = aws_route_table.private_rt.id
}

# NAT Gateway (Single NAT Gateway)
resource "aws_eip" "nat_gateway_eip" {
  tags = {
    Name = "${var.vpc_name}-nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id # Place NAT in the first public subnet

  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Add a route in the private route table to the NAT gateway
resource "aws_route" "private_nat_gateway_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
###########################################################################3
resource "aws_security_group" "e2e-server-sg" {
  name        = var.security_group
  description = "Security group for ec2 instance"
  vpc_id      = aws_vpc.e2e-project-vpc.id

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

#mysql
  ingress {
    description = "RDS MYSQL traffic "
    from_port   = 3306
    to_port     = 3306
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
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 8080
  protocol          = "tcp"
  
  security_group_id = aws_security_group.e2e-server-sg.id
  source_security_group_id = var.alb_sg_id  
}