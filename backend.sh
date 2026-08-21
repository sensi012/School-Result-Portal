#!/bin/bash

#------------------------------------------------
# Terraform Remote State S3 Bucket Setup
#-------------------------------------------------

set -e

BUCKET_NAME="${1:-school-portal-terraform-state-nigeria}"
REGION="${AWS_REGION:-eu-west-1}"

echo "Creating S3 bucket '${BUCKET_NAME}' in region '${REGION}' for Terraform state..."

# 1. Create the S3 Bucket
if [ "${REGION}" == "us-east-1" ]; then
  aws s3api create-bucket --bucket "${BUCKET_NAME}" --region "${REGION}"
else
  aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}" \
    --create-bucket-configuration LocationConstraint="${REGION}"
fi

# 2. Block all public access to the bucket
aws s3api put-public-access-block \
  --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
  --region "${REGION}"

# 3. Enable bucket versioning for state rollback capability
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled \
  --region "${REGION}"

# 4. Enable default SSE-S3 encryption
aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}' \
  --region "${REGION}"

echo "S3 state bucket '${BUCKET_NAME}' configured successfully!"