# modules/vpc/main.tf
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true # Important for public subnets

  tags = {
    Name = "${var.vpc_name}-public-${element(var.azs, count.index)}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.vpc_name}-private-${element(var.azs, count.index)}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id
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
  subnet_id      = element(aws_subnet.public, count.index).id
  route_table_id = aws_route_table.public_rt.id
}

#  PrivateRouteTable
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id
    tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.private, count.index).id
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
  subnet_id     = element(aws_subnet.public, count.index).id # NATs reside in public subnets

  tags = {
    Name = "${var.vpc_name}-nat-gateway-${element(var.azs, count.index)}"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Add a route in the private route table to the NAT gateway
resource "aws_route" "private_nat_gateway_route" {
  count          = length(var.azs)
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id      = element(aws_nat_gateway.nat_gateway, count.index).id
}
