data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
  # Exclude characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment           = var.environment
  project               = var.project
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  frontend_subnet_cidrs = var.frontend_subnet_cidrs
  backend_subnet_cidrs  = var.backend_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_nat_gateway    = true
  single_nat_gateway    = var.single_nat_gateway

  tags = var.tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  environment       = var.environment
  project           = var.project
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = [var.allowed_ssh_cidr]

  tags = var.tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  environment  = var.environment
  project      = var.project
  secrets_arns = ["*"] # Will be updated after secrets are created

  tags = var.tags
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment             = var.environment
  project                 = var.project
  subnet_ids              = module.vpc.database_subnet_ids
  security_group_id       = module.security_groups.rds_sg_id
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  engine_version          = var.db_engine_version
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = random_password.db_password.result
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention
  skip_final_snapshot     = var.db_skip_final_snapshot

  tags = var.tags
}

# Secrets Manager Module
module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
  project     = var.project
  db_username = var.db_username
  db_password = random_password.db_password.result
  db_host     = module.rds.db_address
  db_port     = module.rds.db_port
  db_name     = var.db_name

  tags = var.tags
}
