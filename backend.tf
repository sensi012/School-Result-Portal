# S3 Backend for State Management
# Run backend.sh FIRST manually to create the backend resources
terraform {
  backend "s3" {
    bucket       = "school-portal-terraform-state-nigeria"
    key          = "infrastructure/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
  }
}