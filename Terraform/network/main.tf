resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "BookAdvisor_vpc"
    Environment = "Shared"
    Project = "BookAdvisor"
  }
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet_1_cidr_block
    availability_zone = var.availability_zone_1
    map_public_ip_on_launch = true
  
    tags = {
        Name = "BookAdvisor_public_subnet_1"
        Environment = "Shared"
        Project = "BookAdvisor"
        "kubernetes.io/cluster/BookAdvisor_cluster" = "owned" #This tag is used by EKS to identify the subnets that are part of the cluster
        "kubernetes.io/role/elb" = 1 #This tag is used by EKS to identify the public subnets that are part of the cluster
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet_2_cidr_block
    availability_zone = var.availability_zone_2
    map_public_ip_on_launch = true
  
    tags = {
        Name = "BookAdvisor_public_subnet_2"
        Environment = "Shared"
        Project = "BookAdvisor"
        "kubernetes.io/cluster/BookAdvisor_cluster" = "owned" #This tag is used by EKS to identify the subnets that are part of the cluster
        "kubernetes.io/role/elb" = 1 #This tag is used by EKS to identify the public subnets that are part of the cluster
    }
}

resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnet_1_cidr_block
    availability_zone = var.availability_zone_1
    map_public_ip_on_launch = false
  
    tags = {
        Name = "BookAdvisor_private_subnet_1"
        Environment = "Shared"
        Project = "BookAdvisor"
        "kubernetes.io/cluster/BookAdvisor_cluster" = "owned" #This tag is used by EKS to identify the subnets that are part of the cluster
        "kubernetes.io/role/internal-elb" = 1 #This tag is used by EKS to identify the private subnets that are part of the cluster
    }
}
resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnet_2_cidr_block
    availability_zone = var.availability_zone_2
    map_public_ip_on_launch = false
  
    tags = {
        Name = "BookAdvisor_private_subnet_2"
        Environment = "Shared"
        Project = "BookAdvisor"
        "kubernetes.io/cluster/BookAdvisor_cluster" = "owned" #This tag is used by EKS to identify the subnets that are part of the cluster
        "kubernetes.io/role/internal-elb" = 1 #This tag is used by EKS to identify the private subnets that are part of the cluster

    }
}

#!! IGW Attaches to the VPC level (not a specific subnet)
#Internate Gateway is required for public subnets to access the internet
#It's for inbound and outbound traffic to/from the internet
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "BookAdvisor_internet_gateway"
        Environment = "Shared"
        Project = "BookAdvisor"
    }
}



#When we associate it with gateway_id and not nat_gateway_id, it means that this route table is for public subnets
resource "aws_route_table" "public_route_table_1" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    tags = {
        Name = "BookAdvisor_public_route_table_1"
        Environment = "Shared"
        Project = "BookAdvisor"
    }
}

#Associating the public route table with the public subnet this is necessary for the public subnet to route traffic to the internet
resource "aws_route_table_association" "route_table_association_1" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_route_table_1.id
}
#=> the public subnet is associated with the public route table , allowing it to route traffic to the internet via the internet gateway


#When we associate it with gateway_id and not nat_gateway_id, it means that this route table is for public subnets
resource "aws_route_table" "public_route_table_2" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    tags = {
        Name = "BookAdvisor_public_route_table_2"
        Environment = "Shared"
        Project = "BookAdvisor"
    }
}

#Associating the public route table with the public subnet this is necessary for the public subnet to route traffic to the internet
resource "aws_route_table_association" "route_table_association_2" {
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_route_table_2.id
}
#=> the public subnet is associated with the public route table , allowing it to route traffic to the internet via the internet gateway




#eip is required for the NAT Gateway to function
resource "aws_eip" "nat_eip" {
  count = var.nat_enabled ? 1 : 0
  domain = "vpc" # vpc=true created a waring in the console so we i replaced with this one
  tags = {
    Name = "BookAdvisor_nat_eip"
    Environment = "Shared"
    Project = "BookAdvisor"
  }
}

#NAT Gateway is required for private subnets to access the internet
#It allows outbound traffic from private subnets to the internet while preventing inbound traffic
resource "aws_nat_gateway" "nat_gateway" {
  count = var.nat_enabled ? 1 : 0 #how many NAT Gateways to create, based on the variable 1 or 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id = aws_subnet.public_subnet_1.id #NAT Gateway is created in the public subnet
  tags = {
    Name = "BookAdvisor_nat_gateway"
    Environment = "Shared"
    Project = "BookAdvisor"
  }
}

#When we associate it with nat_gateway_id, it means that this route table is for private subnets
#We still need to associate the private route table with the private subnet
resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "BookAdvisor_private_route_table_1"
    Environment = "Shared"
    Project = "BookAdvisor"
  }
}

#the code before was i have route block in the private route table, but even when the NAT Gateway is not enabled, it still creates the route table with it's default route
#So i added a count to the route block to create it only when the NAT Gateway is enabled
#And this route will call the private route table to route traffic to the NAT Gateway
resource "aws_route" "private_route_1" {
  count = var.nat_enabled ? 1 : 0
  route_table_id = aws_route_table.private_route_table_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway[0].id #This route allows private subnets to access the internet via the NAT Gateway
}

resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}



#When we associate it with nat_gateway_id, it means that this route table is for private subnets
#We still need to associate the private route table with the private subnet
resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "BookAdvisor_private_route_table_2"
    Environment = "Shared"
    Project = "BookAdvisor"
  }
}

#the code before was i have route block in the private route table, but even when the NAT Gateway is not enabled, it still creates the route table with it's default route
#So i added a count to the route block to create it only when the NAT Gateway is enabled
#And this route will call the private route table to route traffic to the NAT Gateway
resource "aws_route" "private_route_2" {
  count = var.nat_enabled ? 1 : 0
  route_table_id = aws_route_table.private_route_table_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway[0].id #This route allows private subnets to access the internet via the NAT Gateway
}

resource "aws_route_table_association" "private_route_table_association_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}

resource "random_password" "rds_password" {
  length  = 16
  special = true
  override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?/"
  
}

resource "aws_secretsmanager_secret" "secretsmanager_secret_1" {
  name        = "BookAdvisor_db_credentials_1"
  description = "MySQL RDS credentials for BookAdvisor application"
  recovery_window_in_days = 7 
  tags = {
    Name = "BookAdvisor_db_credentials_1"
    Environment = "Shared"
    Project = "BookAdvisor"
  } 
}


# Store the actual credentials in the secret
resource "aws_secretsmanager_secret_version" "secretsmanager_secret_version" {
  secret_id = aws_secretsmanager_secret.secretsmanager_secret_1.id
  secret_string = jsonencode({
    username             = "bookadvisor"
    password             = random_password.rds_password.result
    engine               = "mysql"
    host                 = aws_db_instance.db_instance.address
    port                 = aws_db_instance.db_instance.port
    dbname               = "bookadvisor"
    dbInstanceIdentifier = aws_db_instance.db_instance.identifier
  })
}

resource "aws_db_instance" "db_instance" {
  identifier = "bookadvisor-db-instance"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  storage_type = "gp2"
  username = "bookadvisor"
  password = random_password.rds_password.result
  db_name = "bookadvisor"
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  multi_az = false #Multi-AZ is not required for dev environment but it's recommended for production
  publicly_accessible = false
  storage_encrypted = true
  tags = {
    Name = "BookAdvisor_db_instance"
    Environment = "Shared"
    Project = "BookAdvisor"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "bookadvisor_db_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = {
    Name = "BookAdvisor_db_subnet_group"
    Environment = "Shared"
    Project = "BookAdvisor"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "BookAdvisor_db_sg"
  description = "Security group for BookAdvisor database"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [data.terraform_remote_state.eks.outputs.EKS_Cluster_Security_Group_ID] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}