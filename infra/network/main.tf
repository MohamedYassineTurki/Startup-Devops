resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "BookAdvisor-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
  
    tags = {
        Name = "BookAdvisor-public-subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = false
  
    tags = {
        Name = "BookAdvisor-private-subnet"
    }
}