#!/bin/bash
# Deployment Readiness Check for DukQa Infrastructure

set -euo pipefail

echo "🔍 DukQa Infrastructure Deployment Readiness Check"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

READY=true

check_item() {
    local item="$1"
    local status="$2"
    if [ "$status" = "true" ]; then
        echo -e "✅ ${GREEN}$item${NC}"
    else
        echo -e "❌ ${RED}$item${NC}"
        READY=false
    fi
}

warn_item() {
    local item="$1"
    echo -e "⚠️  ${YELLOW}$item${NC}"
}

echo ""
echo "📋 Infrastructure Components Check:"
echo "-----------------------------------"

# Check Terraform files
check_item "VPC Module (modules/vpc/)" "$([ -f modules/vpc/main.tf ] && echo true || echo false)"
check_item "EKS Module (modules/eks/)" "$([ -f modules/eks/main.tf ] && echo true || echo false)"
check_item "Security Groups Configuration" "$([ -f modules/vpc/security-groups.tf ] && echo true || echo false)"
check_item "OIDC Provider Configuration" "$(grep -q 'aws_iam_openid_connect_provider' modules/eks/main.tf && echo true || echo false)"
check_item "Fargate Profiles" "$([ -f modules/eks/fargate-profiles.tf ] && echo true || echo false)"
check_item "IAM Policies for Pods" "$([ -f modules/eks/pod-communication-policies.tf ] && echo true || echo false)"
check_item "ECR Module" "$([ -f modules/ecr/main.tf ] && echo true || echo false)"

echo ""
echo "🔐 Security & Access Check:"
echo "---------------------------"

check_item "Layered Security Groups" "$(grep -q 'ALB.*Web.*Database' modules/vpc/security-groups.tf && echo true || echo false)"
check_item "IRSA Service Account Roles" "$(grep -q 'dukqa-apps:app-service-account' modules/eks/variables.tf && echo true || echo false)"
check_item "S3 Access Policies" "$(grep -q 's3-service-account' modules/eks/variables.tf && echo true || echo false)"
check_item "RDS Access Policies" "$(grep -q 'rds-service-account' modules/eks/variables.tf && echo true || echo false)"
check_item "Secrets Manager Access" "$(grep -q 'secrets-service-account' modules/eks/variables.tf && echo true || echo false)"
check_item "EBS Volume Access" "$(grep -q 'ebs-service-account' modules/eks/variables.tf && echo true || echo false)"

echo ""
echo "⚙️  Configuration Check:"
echo "------------------------"

check_item "Backend Configuration (S3)" "$(grep -q 'dukqa-terraform-state-ireland' backend.tf && echo true || echo false)"
check_item "Environment Files (prod.tfvars)" "$([ -f environments/prod.tfvars ] && echo true || echo false)"
check_item "Environment Files (test.tfvars)" "$([ -f environments/test.tfvars ] && echo true || echo false)"
check_item "Variables Configuration" "$([ -f variables.tf ] && echo true || echo false)"
check_item "Outputs Configuration" "$([ -f outputs.tf ] && echo true || echo false)"

echo ""
echo "🚀 Deployment Scripts Check:"
echo "-----------------------------"

check_item "Backend Setup Script" "$([ -x scripts/setup-backend.sh ] && echo true || echo false)"
check_item "OIDC Test Script" "$([ -x scripts/test-oidc.sh ] && echo true || echo false)"

echo ""
echo "📦 Required Prerequisites:"
echo "-------------------------"

# Check if AWS CLI is available
if command -v aws >/dev/null 2>&1; then
    check_item "AWS CLI installed" "true"
else
    check_item "AWS CLI installed" "false"
fi

# Check if Terraform is available
if command -v terraform >/dev/null 2>&1; then
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || echo "unknown")
    check_item "Terraform installed (v$TERRAFORM_VERSION)" "true"
else
    check_item "Terraform installed" "false"
fi

# Check if kubectl is available
if command -v kubectl >/dev/null 2>&1; then
    check_item "kubectl installed" "true"
else
    check_item "kubectl installed" "false"
fi

echo ""
echo "⚠️  Manual Configuration Required:"
echo "----------------------------------"

warn_item "Update admin_cidr_blocks in environments/*.tfvars with your IP ranges"
warn_item "Ensure AWS credentials are configured (aws configure)"
warn_item "ECR repository will be created automatically by Terraform"
warn_item "Verify S3 bucket name availability: dukqa-terraform-state-ireland"

echo ""
echo "🎯 Deployment Commands:"
echo "----------------------"
echo "1. Setup backend:     ./scripts/setup-backend.sh"
echo "2. Initialize:        terraform init"
echo "3. Plan (test):       terraform plan -var-file=environments/test.tfvars"
echo "4. Apply (test):      terraform apply -var-file=environments/test.tfvars"
echo "5. Configure kubectl: aws eks update-kubeconfig --region eu-west-1 --name duka-eks-cluster"
echo "6. Test OIDC:         ./scripts/test-oidc.sh"

echo ""
if [ "$READY" = "true" ]; then
    echo -e "🎉 ${GREEN}Infrastructure is READY for deployment!${NC}"
    echo -e "   ${GREEN}All core components are properly configured.${NC}"
else
    echo -e "🚨 ${RED}Infrastructure is NOT ready for deployment.${NC}"
    echo -e "   ${RED}Please fix the issues marked with ❌ above.${NC}"
fi

echo ""
echo "📋 Next Steps After Deployment:"
echo "-------------------------------"
echo "• Deploy cluster global components from DukQa-EKS-Project"
echo "• Install ArgoCD for GitOps"
echo "• Configure monitoring stack"
echo "• Deploy microservices"

exit $([ "$READY" = "true" ] && echo 0 || echo 1)