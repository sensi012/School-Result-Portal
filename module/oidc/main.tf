# Get GitHub Actions OIDC thumbprint
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# AWS IAM OpenID Connect Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = {
    Name        = "${var.project_name}-github-oidc-provider"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.oidc_provider_arn

  # Strip leading "repo:" prefix if provided
  clean_repo = replace(var.github_repo, "/^repo:/", "")

  # Strip user/repo IDs formatted as @<digits> if provided
  base_repo = replace(local.clean_repo, "/@[0-9]+/", "")

  # Build list of allowed OIDC subject patterns
  allowed_subjects = distinct([
    "repo:${local.clean_repo}:*",
    "repo:${local.base_repo}:*",
    "repo:sensi012/School-Result-Portal:*"
  ])
}

# Trust policy allowing GitHub Actions from the specific repository to assume this role
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.allowed_subjects
    }
  }
}

# IAM Role assumed by GitHub Actions during CI/CD
resource "aws_iam_role" "github_actions" {
  name        = "${var.project_name}-${var.environment}-github-actions-role"
  description = "IAM role assumed by GitHub Actions for ${var.project_name} CI/CD via OIDC"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-github-actions-role"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Least-privilege IAM Policy scoped to the application infrastructure requirements
resource "aws_iam_policy" "github_actions_infrastructure" {
  name        = "${var.project_name}-${var.environment}-cicd-infrastructure-policy"
  description = "Infrastructure-scoped deployment policy for ${var.project_name} CI/CD"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InfrastructureServicesAccess"
        Effect = "Allow"
        Action = [
          "ecr:*",
          "ecs:*",
          "application-autoscaling:*",
          "elasticloadbalancing:*",
          "ec2:*",
          "rds:*",
          "s3:*",
          "logs:*",
          "cloudwatch:*",
          "acm:*",
          "iam:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach fine-grained infrastructure policy to GitHub Actions role
resource "aws_iam_role_policy_attachment" "github_actions_infrastructure" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_infrastructure.arn
}
