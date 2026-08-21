variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo (e.g. sensi012/School-Result-Portal)"
  type        = string
  default     = "sensi012/School-Result-Portal"
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider resource (set to false if already exists in AWS account)"
  type        = bool
  default     = true
}

variable "oidc_provider_arn" {
  description = "Existing GitHub OIDC Provider ARN if create_oidc_provider is set to false"
  type        = string
  default     = ""
}
