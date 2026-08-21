#!/bin/bash

#------------------------------------------------
# Build and Push Docker Image
#-------------------------------------------------

set -e

REGION="${AWS_REGION:-eu-west-1}"
REPO_NAME="${REPO_NAME:-school-result-portal}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

# Dynamically fetch AWS Account ID or use fallback
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "${AWS_ACCOUNT_ID:-123456789012}")

echo "Using AWS Account ID: ${AWS_ACCOUNT_ID} in region ${REGION}"

# Ensure repository exists in ECR
aws ecr describe-repositories --repository-names "${REPO_NAME}" --region "${REGION}" 2>/dev/null || \
  aws ecr create-repository --repository-name "${REPO_NAME}" --region "${REGION}" 2>/dev/null || true

# Login to Amazon ECR
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Build, tag and push
docker build -t "${REPO_NAME}:${IMAGE_TAG}" -f docker/Dockerfile .
docker tag "${REPO_NAME}:${IMAGE_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"