#!/bin/bash

#------------------------------------------------
# terraform state file
#-------------------------------------------------
echo

# 1. Create the S3 Bucket
aws s3 mb s3://school-portal-terraform-state-nigeria --region eu-west-1

# 2. Block all public access to the bucket (Crucial for security)
aws s3api put-public-access-block \
  --bucket school-portal-terraform-state-nigeria \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
  --region eu-west-1

# 3. Enable bucket versioning to allow rolling back state changes
aws s3api put-bucket-versioning \
  --bucket school-portal-terraform-state-nigeria \
  --versioning-configuration Status=Enabled \
  --region eu-west-1

# 4. Enable default Server-Side Encryption (SSE-S3)
aws s3api put-bucket-encryption \
  --bucket school-portal-terraform-state-nigeria \
  --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}' \
  --region eu-west-1