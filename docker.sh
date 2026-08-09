#!/bin/bash

#------------------------------------------------
# Build and Push Docker Image
#-------------------------------------------------

REGION="eu-west-1"
REPO_NAME="school-result-portal"

# Dynamically fetch AWS Account ID or fallback
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "123456789012")

echo "Using AWS Account ID: ${AWS_ACCOUNT_ID} in region ${REGION}"

# Login to ECR
aws ecr create-repository --repository-name ${REPO_NAME} --region ${REGION} 2>/dev/null || true
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Build and push
docker build -t ${REPO_NAME}:latest -f docker/Dockerfile .
docker tag ${REPO_NAME}:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:latest