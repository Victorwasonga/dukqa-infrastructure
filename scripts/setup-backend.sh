#!/bin/bash
# Setup Terraform Backend - S3 Bucket and DynamoDB Table

set -euo pipefail

# Configuration
BUCKET_NAME="dukqa-terraform-state-ireland"
REGION="eu-west-1"

echo "🚀 Setting up Terraform backend infrastructure..."

# Create S3 bucket for Terraform state
echo "📦 Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  --no-cli-pager || echo "Bucket may already exist"

# Enable versioning on the bucket
echo "🔄 Enabling versioning on S3 bucket"
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled \
  --no-cli-pager

# Enable server-side encryption
echo "🔒 Enabling server-side encryption on S3 bucket"
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }' \
  --no-cli-pager

# Block public access
echo "🛡️  Blocking public access to S3 bucket"
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --no-cli-pager

echo "✅ Terraform backend setup complete!"
echo ""
echo "📋 Backend Configuration:"
echo "  S3 Bucket: $BUCKET_NAME"
echo "  Region: $REGION (Ireland)"
echo ""
echo "🚀 You can now run 'terraform init' to initialize your Terraform configuration"