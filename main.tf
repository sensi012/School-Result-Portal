# VPC Module
module "vpc" {
  source = "./module/vpc"

  project_name = var.project_name
  environment  = var.environment
  cidr_block   = "10.0.0.0/16"
}

# RDS Module
module "rds" {
  source = "./module/rds"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_username        = var.db_username
  db_password        = var.db_password
  app_sg_id          = module.ecs.app_security_group_id
}

# ECS Module
module "ecs" {
  source = "./module/ecs"

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  app_image       = var.app_image
  db_host         = module.rds.db_address
  db_name         = "school_db"
  db_username     = var.db_username
  db_password     = var.db_password
}

# ALB Module
module "alb" {
  source = "./module/alb"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  app_target_group_arn = module.ecs.target_group_arn
}