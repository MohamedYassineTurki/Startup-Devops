

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?/"
}

resource "aws_secretsmanager_secret" "secretsmanager_secret_1" {
  name                    = "BookAdvisor_db_credentials_1"
  description             = "MySQL RDS credentials for BookAdvisor application"
  recovery_window_in_days = 7
  tags = {
    Name        = "BookAdvisor_db_credentials_1"
    Environment = "Shared"
    Project     = "BookAdvisor"
  }
}

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
  identifier              = "bookadvisor-db-instance"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = "bookadvisor"
  password                = random_password.rds_password.result
  db_name                 = "bookadvisor"
  vpc_security_group_ids  = [aws_security_group.db_security_group.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  multi_az                = false # Multi-AZ is not required for dev environment but it's recommended for production
  publicly_accessible     = false
  storage_encrypted       = true
  tags = {
    Name        = "BookAdvisor_db_instance"
    Environment = "Shared"
    Project     = "BookAdvisor"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "bookadvisor_db_subnet_group"
  subnet_ids = [data.terraform_remote_state.network.outputs.private_subnet_ids[0]]
  tags = {
    Name        = "BookAdvisor_db_subnet_group"
    Environment = "Shared"
    Project     = "BookAdvisor"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "BookAdvisor_db_sg"
  description = "Security group for BookAdvisor database"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.eks.outputs.EKS_Cluster_Security_Group_ID]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}