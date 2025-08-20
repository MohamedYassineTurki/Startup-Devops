output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_id" {
  description = "The IDs of the public subnets"
  value       = [aws_subnet.public_subnet.id] #transformed it to a list using a [] because in cluster configuration, it expects a list of subnet IDs
  
}

output "private_subnet_id" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.private_subnet.id] #transfomed it to a list using a [] because in cluster configuration, it expects a list of subnet IDs
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.internet_gateway.id 
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public_route_table.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = var.nat_enabled ? aws_nat_gateway.nat_gateway[0].id : null
  
}