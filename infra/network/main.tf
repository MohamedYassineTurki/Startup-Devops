resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "BookAdvisor_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
  
    tags = {
        Name = "BookAdvisor_public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = false
  
    tags = {
        Name = "BookAdvisor_private_subnet"
    }
}

#!! IGW Attaches to the VPC level (not a specific subnet)
#Internate Gateway is required for public subnets to access the internet
#It's for inbound and outbound traffic to/from the internet
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "BookAdvisor_internet_gateway"
    }
}



#When we associate it with gateway_id and not nat_gateway_id, it means that this route table is for public subnets
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    tags = {
        Name = "BookAdvisor_public_route_table"
    }
}

#Associating the public route table with the public subnet this is necessary for the public subnet to route traffic to the internet
resource "aws_route_table_association" "route_table_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}
#=> the public subnet is associated with the public route table , allowing it to route traffic to the internet via the internet gateway


#eip is required for the NAT Gateway to function
resource "aws_eip" "nat_eip" {
  count = var.nat_enabled ? 1 : 0
  domain = "vpc" # vpc=true created a waring in the console so we i replaced with this one
  tags = {
    Name = "BookAdvisor_nat_eip"
  }
}

#NAT Gateway is required for private subnets to access the internet
#It allows outbound traffic from private subnets to the internet while preventing inbound traffic
resource "aws_nat_gateway" "nat_gateway" {
  count = var.nat_enabled ? 1 : 0 #how many NAT Gateways to create, based on the variable 1 or 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id = aws_subnet.public_subnet.id #NAT Gateway is created in the public subnet
  tags = {
    Name = "BookAdvisor_nat_gateway"
  }
}

#When we associate it with nat_gateway_id, it means that this route table is for private subnets
#We still need to associate the private route table with the private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.nat_enabled ? aws_nat_gateway.nat_gateway[0].id : null
    # If NAT is not enabled, the route will be null, meaning no outbound internet access
  }
  
  tags = {
    Name = "BookAdvisor_private_route_table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}