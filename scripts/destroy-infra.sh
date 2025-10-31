#!/bin/bash

# Destroy Infrastructure Script
# This script safely destroys the DukQa infrastructure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="${1:-test}"

echo "🔥 Starting infrastructure destruction for environment: $ENVIRONMENT"
echo "📁 Working directory: $PROJECT_ROOT"

# Check if tfvars file exists
TFVARS_FILE="$PROJECT_ROOT/environments/$ENVIRONMENT.tfvars"
if [[ ! -f "$TFVARS_FILE" ]]; then
    echo "❌ Error: Environment file $TFVARS_FILE not found"
    exit 1
fi

cd "$PROJECT_ROOT"

echo ""
echo "🔍 Current Terraform state:"
terraform show -json > /dev/null 2>&1 && echo "✅ State exists" || echo "ℹ️  No existing state"

echo ""
echo "🔥 DESTROYING infrastructure..."
echo "⚠️  This will destroy ALL resources in the $ENVIRONMENT environment"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [[ $confirm != "yes" ]]; then
    echo "❌ Aborted by user"
    exit 1
fi

# Destroy infrastructure
echo ""
echo "🔥 Running terraform destroy..."
terraform destroy -var-file="$TFVARS_FILE" -auto-approve

echo ""
echo "✅ Infrastructure destroyed successfully!"
echo "💰 All AWS resources have been terminated to avoid charges"