variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "app_image" {
  description = "Docker image URI"
  type        = string
}

variable "db_host" {
  description = "Database host address"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port"
  type        = string
  default     = "5432"
}

variable "aws_region" {
  description = "AWS region for CloudWatch logs and ECS"
  type        = string
  default     = "eu-west-1"
}

variable "secret_key" {
  description = "Application secret key for sessions"
  type        = string
  sensitive   = true
  default     = "prod-secret-key-change-me"
}

variable "container_port" {
  description = "Port exposed by application container"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Fargate CPU units (e.g. 256, 512, 1024)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Fargate memory in MB (e.g. 512, 1024, 2048)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum tasks for auto scaling"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum tasks for auto scaling"
  type        = number
  default     = 4
}

variable "cpu_target_utilization" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70.0
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}