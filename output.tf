output "load_balancer_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "database_endpoint" {
  description = "RDS database endpoint with port"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "database_address" {
  description = "RDS database host address"
  value       = module.rds.db_address
  sensitive   = true
}

output "database_name" {
  description = "RDS database name"
  value       = module.rds.db_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions OIDC (Configure as AWS_ROLE_ARN secret in GitHub)"
  value       = module.oidc.github_actions_role_arn
}

output "oidc_provider_arn" {
  description = "ARN of the AWS IAM OIDC Provider for GitHub Actions"
  value       = module.oidc.oidc_provider_arn
}