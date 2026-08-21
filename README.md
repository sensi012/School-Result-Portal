# 🎓 School Result Portal

[![AWS](https://img.shields.io/badge/AWS-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)](https://terraform.io)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://docker.com)
[![Flask](https://img.shields.io/badge/Flask-000000?logo=flask&logoColor=white)](https://flask.palletsprojects.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)](https://postgresql.org)
[![Loom](https://img.shields.io/badge/Loom-Video_Demo-625DF5?logo=loom&logoColor=white)](https://www.loom.com/share/523d0f7c42524715a275f3401d02b19e)

> **A cloud-native, Infrastructure-as-Code solution for Nigerian schools to securely publish and manage student academic results online.**
>
> 🎥 **Video Demo & Walkthrough**: [Watch on Loom](https://www.loom.com/share/523d0f7c42524715a275f3401d02b19e)

---

## 📋 Table of Contents

- [Video Demo](#-video-demo)
- [Problem Context](#-problem-context)
- [Solution Overview](#-solution-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Local Development](#-local-development)
- [Infrastructure Deployment](#-infrastructure-deployment)
- [Environment Variables](#-environment-variables)
- [Security](#-security)
- [Scaling Strategy](#-scaling-strategy)
- [Cost Estimate](#-cost-estimate)
- [Project Structure](#-project-structure)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Monitoring & Observability](#-monitoring--observability)
- [Troubleshooting](#-troubleshooting)
- [Future Improvements](#-future-improvements)

---

## 🎥 Video Demo

Watch a walkthrough and architecture demonstration of the School Result Portal on Loom:

👉 **[Watch the Demo on Loom](https://www.loom.com/share/523d0f7c42524715a275f3401d02b19e)**

---

## 🎯 Problem Context

Nigerian secondary schools face a critical infrastructure gap:

- **Physical Result Collection**: Students and parents must travel to school during fixed hours, creating congestion and excluding remote families.
- **Paper-Based Records**: Result sheets are fragile, easily lost, and difficult to archive.
- **No Digital Access**: During strikes, holidays, or emergencies, result access is completely cut off.
- **Security Risks**: Paper results can be tampered with or falsified.

**This project solves these problems** by providing a secure, scalable, cost-effective cloud portal that allows 24/7 result checking via Matric Number and PIN authentication.

---

## 💡 Solution Overview

A containerized Flask web application deployed on **AWS ECS Fargate** (serverless containers) with a **PostgreSQL RDS** backend. The entire infrastructure is defined in **Terraform** and follows AWS Well-Architected principles:

| Feature | Implementation |
|---------|---------------|
| **Serverless Compute** | AWS ECS Fargate — no EC2 patching, pay-per-use |
| **Managed Database** | RDS PostgreSQL with automated backups & Multi-AZ |
| **HTTPS Only** | Application Load Balancer with SSL termination |
| **Auto-Scaling** | CPU-based scaling 2→4 tasks during exam season |
| **IaC** | 100% Terraform — reproducible across environments |
| **CI/CD** | GitHub Actions for automated build & syntax validation |

---

## 🏗️ Architecture

### Data Flow

```text
Student/Parent → Route 53 → CloudFront (CDN) → ALB (HTTPS)
                                          ↓
                              ECS Fargate (Flask App in Private Subnet)
                                          ↓
                              RDS PostgreSQL (Multi-AZ, Encrypted)
```

### Design Decisions

| Decision | Rationale |
|----------|-----------|
| **ECS Fargate over EC2** | Zero server management; scales to zero if needed; no OS patching at 2 AM |
| **RDS Multi-AZ** | Automatic failover; 99.95% SLA; critical for exam season uptime |
| **Private Subnets for DB** | Zero public exposure; defense-in-depth security |
| **Containerization** | Identical environments across dev/staging/prod; immutable deployments |
| **Terraform Modules** | Reusable VPC/ECS/RDS/ALB modules for multi-school deployment |

---

## 🛠️ Tech Stack

### Application Layer
- **Python 3.11** + **Flask** — Lightweight WSGI web framework
- **Gunicorn** — Production-grade HTTP server
- **Psycopg2** — PostgreSQL adapter
- **Jinja2** — Server-side HTML templating

### Infrastructure Layer
- **AWS ECS Fargate** — Serverless container orchestration
- **AWS RDS PostgreSQL 15** — Managed relational database
- **AWS ALB** — Layer 7 load balancing with health checks
- **AWS VPC** — Isolated network with public/private subnets
- **AWS ECR** — Private container registry
- **AWS CloudWatch** — Centralized logging and metrics
- **AWS S3** — ALB access log storage
- **AWS Secrets Manager** — Credential rotation (production hardening)

### DevOps Layer
- **Terraform 1.5+** — Infrastructure as Code
- **Docker** — Container build and packaging
- **GitHub Actions** — CI validation automation
- **AWS CLI** — Cloud resource management

---

## 📦 Prerequisites

### Local Machine
| Tool | Version | Purpose |
|------|---------|---------|
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | v2.x | AWS resource management |
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | ≥ 1.5.0 | Infrastructure provisioning |
| [Docker Desktop](https://www.docker.com/products/docker-desktop) | Latest | Local container builds |
| [Git](https://git-scm.com/downloads) | ≥ 2.30 | Version control |

### AWS Account Setup
1. Create an AWS account (Free Tier eligible)
2. Create an IAM user with programmatic access and these policies:
   - `AmazonEC2FullAccess`
   - `AmazonRDSFullAccess`
   - `AmazonECS_FullAccess`
   - `AmazonS3FullAccess`
   - `ElasticLoadBalancingFullAccess`
   - `CloudWatchFullAccess`
   - `IAMFullAccess`
3. Configure credentials:
   ```bash
   aws configure
   # AWS Access Key ID: [your-key]
   # AWS Secret Access Key: [your-secret]
   # Default region: eu-west-1
   # Default output: json
   ```

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/sensi012/School-Result-Portal.git
cd School-Result-Portal
```

### 2. Initialize Terraform Backend (One-Time)
```bash
bash backend.sh or ./backend.sh
```

### 3. Build & Push Docker Image

**Using the automated helper script (Recommended):**
```bash
bash docker.sh
# Or with custom parameters:
AWS_REGION=eu-west-1 IMAGE_TAG=latest bash docker.sh
```

**Or manually via AWS CLI & Docker:**
```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-1.amazonaws.com

docker build -t school-result-portal:latest -f docker/Dockerfile .

docker tag school-result-portal:latest \
  ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-1.amazonaws.com/school-result-portal:latest

docker push ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-1.amazonaws.com/school-result-portal:latest
```

### 4. Deploy Infrastructure
```bash
terraform init
terraform workspace new prod || terraform workspace select prod
terraform plan
terraform apply
```

### 5. Access the Application
```bash
# Get the load balancer DNS
terraform output load_balancer_dns

# Open in browser
open http://$(terraform output -raw load_balancer_dns)
```

**Test Credentials:**
Use credentials from [list.md](list.md). For example:
- **Matric Number**: `AIC/JSS1/001`
- **PIN**: `100001`

---

## 💻 Local Development

### Using Docker Compose (Recommended)
```bash
# Start the full stack locally
docker-compose -f docker/docker-compose.yml up --build

# Access the app
open http://localhost:5000

# View logs
docker-compose -f docker/docker-compose.yml logs -f app

# Stop
docker-compose -f docker/docker-compose.yml down
```

### Using Python Virtual Environment
```bash
cd app
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Start PostgreSQL locally (or use Docker for DB only)
export DB_HOST=localhost
export DB_NAME=school_db
export DB_USER=admin
export DB_PASSWORD=password  # 'password' is the default in app.py
export DB_PORT=5432
export SECRET_KEY=dev-secret-key

python app.py
```

---

## 🏗️ Infrastructure Deployment

### Environment Strategy
We use **Terraform workspaces** to isolate environments:

| Environment | Workspace | Purpose | Scaling |
|-------------|-----------|---------|---------|
| `dev` | `dev` | Local integration testing | 1 task, no Multi-AZ |
| `staging` | `staging` | Pre-production validation | 1 task, no Multi-AZ |
| `prod` | `prod` | Live school portal | 2 tasks, Multi-AZ |

### Deployment Commands
```bash
# Select environment
terraform workspace select prod

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy (use with caution)
terraform destroy
```

---

## 🔐 Environment Variables

### Application Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `DB_HOST` | RDS endpoint | `school-result-portal-prod.abc123.eu-west-1.rds.amazonaws.com` |
| `DB_NAME` | Database name | `school_db` |
| `DB_USER` | Database username | `school_admin` |
| `DB_PASSWORD` | Database password | `***` |
| `DB_PORT` | Database port | `5432` |
| `SECRET_KEY` | Flask session secret | `change-me-in-production` |

### Terraform Variables (`terraform.tfvars`)
```hcl
aws_region   = "eu-west-1"
environment  = "prod"
project_name = "school-result-portal"
app_image    = "210450948229.dkr.ecr.eu-west-1.amazonaws.com/school-result-portal:latest"
db_username  = "school_admin"
db_password  = "SChoolPortalPassword123!"
github_repo  = "sensi012/School-Result-Portal"
secret_key   = "your-secret-key-here"
```

> ⚠️ **Never commit `terraform.tfvars` to Git.** Use `.gitignore` and refer to `terraform.tfvars.example`.

---

## 🔒 Security

### Implemented Controls
- **Encryption at Rest**: RDS storage encrypted with AWS KMS; S3 bucket encryption
- **Encryption in Transit**: ALB enforces HTTPS (TLS 1.3); RDS uses SSL
- **Private Subnets**: Database and ECS tasks have no public IP exposure
- **Security Groups**: Least-privilege access — only ALB can reach ECS, only ECS can reach RDS
- **Non-Root Containers**: Docker image runs as unprivileged `appuser`
- **Secret Management**: Database credentials injected via ECS task definitions (not in code)
- **Deletion Protection**: Enabled on ALB and RDS in production

---

## 📈 Scaling Strategy

### Current Configuration
- **ECS Tasks**: 2 minimum → 4 maximum (CPU-based auto-scaling at 70% threshold)
- **RDS**: `db.t3.micro` with Multi-AZ failover
- **ALB**: Automatically scales to handle connection spikes

### Exam Season Scaling (Predictable Peaks)
When results are released (predictable high traffic):

```hcl
# Scheduled scaling: Scale up before result release
resource "aws_appautoscaling_scheduled_action" "scale_up" {
  name               = "scale-up-exam-season"
  service_namespace  = "ecs"
  resource_id        = "service/school-result-portal-prod/school-result-portal-prod-service"
  scalable_dimension = "ecs:service:DesiredCount"
  schedule           = "cron(0 8 15 7 ? 2026)"  # July 15, 2026 at 8 AM WAT

  scalable_target_action {
    min_capacity = 4
    max_capacity = 10
  }
}
```

### Cost-Optimized Tiers for Nigerian Schools

| Tier | Monthly Cost | Use Case | Architecture |
|------|-------------|----------|-------------|
| **Starter** | ~$15 | Small private school (< 200 students) | AWS Lightsail + RDS Single-AZ |
| **Standard** | ~$100 | Mid-size school (200–1,000 students) | **This architecture** — ECS Fargate + RDS Multi-AZ |
| **Enterprise** | ~$400 | State-wide exam board or large institution | Multi-AZ + CloudFront + ElastiCache + Aurora Serverless |

---

## 💰 Cost Estimate (Standard Tier — eu-west-1)

| Service | Specification | Monthly Cost (USD) | Monthly Cost (NGN)* |
|---------|--------------|-------------------|---------------------|
| **ECS Fargate** | 2 tasks × 0.25 vCPU × 0.5 GB | ~$15 | ~₦24,000 |
| **RDS PostgreSQL** | db.t3.micro, 20GB GP3, Multi-AZ | ~$25 | ~₦40,000 |
| **Application Load Balancer** | ALB + LCU hours | ~$20 | ~₦32,000 |
| **NAT Gateway** | 1 NAT GW + data processing | ~$35 | ~₦56,000 |
| **CloudWatch** | Logs + Container Insights | ~$5 | ~₦8,000 |
| **S3** | ALB logs + backups | ~$2 | ~₦3,200 |
| **Data Transfer** | ~100GB/month egress | ~$9 | ~₦14,400 |
| **ECR** | Image storage | ~$1 | ~₦1,600 |
| **Total** | | **~$112** | **~₦179,200** |

*\*At ₦1,600/$ — rates may vary*

> 💡 **Cost Optimization Tip**: Remove the NAT Gateway and use VPC Endpoints for ECR/CloudWatch to save ~$35/month. For very small schools, consider AWS Lightsail ($5–10/month) as a starter tier.

---

## 📁 Project Structure

```text
school-result-portal/
├── 📄 README.md                          # This file
├── 📄 .gitignore                         # Git ignore rules
│
├── 🐳 docker/                            # Container configuration
│   ├── Dockerfile                        # Multi-stage production build
│   ├── docker-compose.yml                # Local development stack
│   └── init.sql                          # Database seed data
│
├── 🐍 app/                               # Flask application
│   ├── app.py                            # Main application entry
│   ├── requirements.txt                  # Python dependencies
│   ├── templates/                        # Jinja2 HTML templates
│   │   ├── index.html                    # Login/check page
│   │   └── result.html                   # Result slip display
│   └── static/                           # CSS, JS, images (if any)
│
├── 🏗️ .                                  # Terraform Infrastructure (root)
│   ├── backend.tf                        # S3 remote state configuration
│   ├── providers.tf                      # AWS provider & version pinning
│   ├── variable.tf                       # Input variable declarations
│   ├── output.tf                         # Output values
│   ├── main.tf                           # Root module composition
│   ├── terraform.tfvars.example          # Sample variables template
│   ├── backend.sh                        # One-time S3 backend setup script
│   ├── docker.sh                         # ECR build & push script
│   │
│   └── module/                           # Reusable infrastructure modules
│       ├── vpc/                          # Network (VPC, subnets, IGW, NAT)
│       │   ├── main.tf
│       │   ├── variable.tf
│       │   └── output.tf
│       ├── ecs/                          # Container orchestration
│       │   ├── main.tf
│       │   ├── variable.tf
│       │   └── output.tf
│       ├── rds/                          # Managed database
│       │   ├── main.tf
│       │   ├── variable.tf
│       │   └── output.tf
│       ├── alb/                          # Load balancing & SSL
│       │   ├── main.tf
│       │   ├── variable.tf
│       │   └── output.tf
│       └── oidc/                         # AWS OIDC & IAM Role for GitHub Actions
│           ├── main.tf
│           ├── variable.tf
│           └── output.tf
│
└── ⚙️ .github/
    └── workflows/
        └── deploy.yml                    # GitHub Actions CI/CD pipeline (AWS OIDC)
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow with AWS OIDC
The workflow (`.github/workflows/deploy.yml`) uses passwordless **AWS OpenID Connect (OIDC)** authentication:

1. **Continuous Integration (`ci-checks`)** (Runs on Push & PR to `main`):
   - **Format Check** — Terraform `fmt -check -recursive`
   - **Init & Validate** — Terraform `init -backend=false` and `validate`
   - **Syntax Check** — Python `py_compile` to validate `app.py`
   - **Build Test** — Docker image build to ensure `docker/Dockerfile` builds cleanly

2. **Continuous Deployment (`deploy`)** (Runs on Push to `main` and `workflow_dispatch`):
   - **OIDC Authentication** — Assumes IAM Role via `aws-actions/configure-aws-credentials@v4` using short-lived tokens (no long-lived AWS keys needed)
   - **ECR Login & Push** — Authenticates to Amazon ECR, builds production image, and pushes with commit SHA and `latest` tags
   - **Terraform Plan & Apply** — Automatically initializes S3 state backend and applies infrastructure updates
   - **ECS Service Redeployment** — Triggers ECS rolling update and waits for service stability

### Required GitHub Repository Secrets & Variables

To enable automated deployments, configure the following in your GitHub repository (**Settings > Secrets and variables > Actions**):

| Type | Name | Description | Source |
|---|---|---|---|
| **Secret** | `AWS_ROLE_ARN` | IAM Role ARN for GitHub Actions | Output `github_actions_role_arn` from Terraform |
| **Secret** | `DB_USERNAME` | Master database username | e.g. `school_admin` |
| **Secret** | `DB_PASSWORD` | Master database password | Strong password |
| **Variable** | `AWS_REGION` *(optional)* | Target AWS region (default: `eu-west-1`) | `eu-west-1` |


---

## 📊 Monitoring & Observability

### CloudWatch Dashboards
- **ECS Metrics**: CPU utilization, memory usage, running task count
- **RDS Metrics**: Database connections, read/write latency, free storage
- **ALB Metrics**: Request count, 4xx/5xx errors, target response time
- **Custom Metrics**: Application health check failures

### Log Aggregation
All container logs stream to `/ecs/school-result-portal-prod` CloudWatch Log Group with 30-day retention.

### Alerting (Production)
Configure SNS + CloudWatch Alarms for:
- ECS task count < desired (service outage)
- RDS CPU > 80% for 5 minutes
- ALB 5xx error rate > 1%
- RDS free storage < 5GB

---

## 🐛 Troubleshooting

| Symptom | Cause | Solution |
|---|---|---|
| `docker login` fails | ECR auth token expired | Re-run `aws ecr get-login-password ...` or use `docker.sh` |
| `terraform plan` hangs / lock error | S3 state lock held | Run `terraform force-unlock <LOCK_ID>` |
| `Cannot connect to DB` | Security group blocking | Verify ECS security group is in RDS ingress rules |
| `Access Denied for S3 bucket` | Wrong ELB account ID | Use region-specific ELB account ID (`156460612806` for eu-west-1) |
| `InvalidParameterCombination` for RDS | Deprecated engine version | Check valid versions with `aws rds describe-db-engine-versions` |
| `503 Service Unavailable` | Health check failing | Verify `/health` endpoint returns HTTP 200 |
| `Connection timeout` | NAT Gateway missing or misrouted | Verify private subnet route table points to NAT GW |

---

## 🚀 Future Improvements

Key architectural and feature enhancements planned for production-readiness:

### 1. 🛡️ Security Hardening
- **AWS Secrets Manager / SSM Parameter Store**: Replace container environment variables with direct IAM-secured secrets injection in the ECS task definition.
- **AWS WAF**: Attach a Web Application Firewall to the ALB with rate limiting, geo-restriction, and SQL Injection/XSS managed rules to block PIN brute-forcing.
- **Custom Domain & Public ACM Certificate**: Map Route 53 with automated AWS Certificate Manager DNS validation for full HTTPS green-lock trust.

### 2. 💰 Cost Optimization
- **VPC Endpoints (PrivateLink)**: Eliminate the NAT Gateway ($35/mo savings) by using VPC endpoints for ECR, S3, and CloudWatch Logs.
- **ECS Fargate Spot**: Slash container compute costs up to 70% during standard school terms.
- **Scheduled RDS Pausing**: Automatically stop or scale down RDS instances during holiday vacations.

### 3. 🎓 Application & User Experience
- **Official PDF Result Slip Download**: Integrated `WeasyPrint`/`ReportLab` generation with official school watermark and stamp.
- **SMS & WhatsApp Alerts**: Automated PIN and result release alerts to parents via SMS API (Termii/Twilio).
- **Application-Level Rate Limiting**: `Flask-Limiter` throttling for failed PIN attempts.
- **Database Connection Pooling**: `Flask-SQLAlchemy` and `PgBouncer` integration for peak concurrency handling.

### 4. ⚙️ DevOps & CI/CD
- **Automated Test Suite**: Integrated `pytest` unit and integration tests in the GitHub Actions workflow.
- **Database Migrations**: Version-controlled schema migrations with `Alembic`/`Flask-Migrate`.
- **Multi-Environment Promotion**: Staging-to-production promotion pipelines with environment protection rules.

---
