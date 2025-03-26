output "vpc_id" {
  value = aws_vpc.e2e-project-vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "security_group_id" {
  value = aws_security_group.e2e-server-sg.id
}
