output "load_balancer_dns" {
  description = "DNS name of the application load balancer"
  value       = module.alb.alb_dns_name
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = "${var.project_name}-${var.environment}"
}