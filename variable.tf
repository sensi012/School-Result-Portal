variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "school-result-portal"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "school_db"
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

variable "app_image" {
  description = "Docker image URI for the application"
  type        = string
}

variable "secret_key" {
  description = "Application session secret key"
  type        = string
  sensitive   = true
  default     = "prod-secret-key-change-me"
}

variable "container_port" {
  description = "Port exposed by the application container"
  type        = number
  default     = 8080
}

variable "domain_name" {
  description = "Custom domain name (optional)"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo for OIDC trust"
  type        = string
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider (set to false if already exists in AWS account)"
  type        = bool
  default     = true
}

variable "oidc_provider_arn" {
  description = "Existing GitHub OIDC Provider ARN if create_oidc_provider is false"
  type        = string
  default     = ""
}
