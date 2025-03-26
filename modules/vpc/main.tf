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

#  PrivateRouteTable
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

#  NAT Gateway (Required for instances in the private subnets to access the internet) -  Important
resource "aws_eip" "nat_gateway_eip" {
  count = length(var.azs) # One EIP for each NAT gateway
  tags = {
    Name = "${var.vpc_name}-nat-gateway-eip-${element(var.azs, count.index)}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.azs) # One NAT gateway for each AZ
  allocation_id = element(aws_eip.nat_gateway_eip, count.index).id
  subnet_id     = element(aws_subnet.public_subnet, count.index).id # NATs reside in public subnets

  tags = {
    Name = "${var.vpc_name}-nat-gateway-${element(var.azs, count.index)}"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Add a route in the private route table to the NAT gateway
resource "aws_route" "private_nat_gateway_route" {
  count          = length(var.azs)
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = ""
  nat_gateway_id      = element(aws_nat_gateway.nat_gateway, count.index).id
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