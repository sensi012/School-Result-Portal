# VPC Module
module "vpc" {
  source = "./module/vpc"

  project_name = var.project_name
  environment  = var.environment
  cidr_block   = var.vpc_cidr
}

# RDS Module
module "rds" {
  source = "./module/rds"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  app_sg_id          = module.ecs.app_security_group_id
}

# ECS Module
module "ecs" {
  source = "./module/ecs"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  app_image          = var.app_image
  db_host            = module.rds.db_address
  db_name            = module.rds.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  db_port            = module.rds.db_port
  aws_region         = var.aws_region
  secret_key         = var.secret_key
  container_port     = var.container_port
}

# ALB Module
module "alb" {
  source = "./module/alb"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  app_target_group_arn = module.ecs.target_group_arn
}

# AWS OIDC Module for GitHub Actions CI/CD
module "oidc" {
  source = "./module/oidc"

  project_name         = var.project_name
  environment          = var.environment
  github_repo          = var.github_repo
  create_oidc_provider = var.create_oidc_provider
  oidc_provider_arn    = var.oidc_provider_arn
}