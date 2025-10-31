#!/bin/bash

# Destroy and Reapply Infrastructure Script
# This script safely destroys and recreates the entire DukQa infrastructure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="${1:-test}"

echo "🔥 Starting infrastructure destroy and reapply for environment: $ENVIRONMENT"
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
echo "🔥 DESTROYING existing infrastructure..."
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
echo "✅ Infrastructure destroyed successfully"
echo ""
echo "🚀 REAPPLYING infrastructure..."

# Initialize (in case of backend changes)
echo "🔧 Initializing Terraform..."
terraform init

# Plan the deployment
echo ""
echo "📋 Planning deployment..."
terraform plan -var-file="$TFVARS_FILE" -out=tfplan

# Apply the plan
echo ""
echo "🚀 Applying infrastructure..."
terraform apply tfplan

# Clean up plan file
rm -f tfplan

echo ""
echo "✅ Infrastructure successfully destroyed and reapplied!"
echo ""
echo "📊 Final state summary:"
terraform show -json | jq -r '.values.root_module.resources[] | select(.type != null) | "\(.type): \(.values.id // .values.name // "unnamed")"' | sort | uniq -c

echo ""
echo "🎉 Deployment complete for environment: $ENVIRONMENT"
echo "🔗 Next steps:"
echo "   1. Verify EKS cluster: aws eks describe-cluster --name duka-eks-cluster --region eu-west-1"
echo "   2. Update kubeconfig: aws eks update-kubeconfig --name duka-eks-cluster --region eu-west-1"
echo "   3. Deploy cluster components: kubectl apply -f ../DukQa-EKS-Project/cluster-global-components/"