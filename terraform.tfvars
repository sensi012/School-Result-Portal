aws_region   = "eu-west-1"
environment  = "prod"
project_name = "school-result-portal"

# Replace with your ECR image after building and pushing
app_image = "210450948229.dkr.ecr.eu-west-1.amazonaws.com/school-result-portal:latest"

# Use strong passwords in production
db_username = "school_admin"
db_password = "SChoolPortalPassword123!"

# Optional: custom domain
# domain_name = "results.yourschool.edu.ng"