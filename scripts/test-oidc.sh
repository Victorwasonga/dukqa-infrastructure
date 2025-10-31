#!/bin/bash
# Test OIDC Configuration for duka-eks-cluster

set -euo pipefail

CLUSTER_NAME="duka-eks-cluster"
REGION="eu-west-1"

echo "🔍 Testing OIDC configuration for ${CLUSTER_NAME}..."

# Check if cluster exists
echo "📋 Checking EKS cluster status..."
CLUSTER_STATUS=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query 'cluster.status' --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$CLUSTER_STATUS" != "ACTIVE" ]; then
    echo "❌ Cluster $CLUSTER_NAME is not active or doesn't exist. Status: $CLUSTER_STATUS"
    exit 1
fi

echo "✅ Cluster $CLUSTER_NAME is active"

# Get OIDC issuer URL
echo "🔗 Getting OIDC issuer URL..."
OIDC_ISSUER=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query 'cluster.identity.oidc.issuer' --output text)
echo "OIDC Issuer: $OIDC_ISSUER"

# Check if OIDC provider exists
echo "🔍 Checking OIDC provider..."
OIDC_PROVIDER_ARN=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?contains(Arn, '$(echo $OIDC_ISSUER | cut -d'/' -f3-)')].Arn" --output text)

if [ -z "$OIDC_PROVIDER_ARN" ]; then
    echo "❌ OIDC provider not found for cluster $CLUSTER_NAME"
    exit 1
fi

echo "✅ OIDC provider found: $OIDC_PROVIDER_ARN"

# Check service account roles
echo "🔐 Checking IRSA roles..."
ROLES=(
    "duka-eks-aws-lb-controller-role"
    "duka-eks-cluster-autoscaler-role"
    "duka-eks-ebs-csi-driver-role"
    "duka-eks-secrets-store-csi-role"
    "duka-eks-vpc-cni-role"
)

for role in "${ROLES[@]}"; do
    if aws iam get-role --role-name "$role" >/dev/null 2>&1; then
        echo "✅ Role exists: $role"
    else
        echo "⚠️  Role not found: $role (will be created during deployment)"
    fi
done

# Test kubectl access
echo "🔧 Testing kubectl access..."
if command -v kubectl >/dev/null 2>&1; then
    if aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME" >/dev/null 2>&1; then
        echo "✅ kubectl configured for $CLUSTER_NAME"
        
        # Test cluster access
        if kubectl get nodes >/dev/null 2>&1; then
            echo "✅ Cluster access successful"
            kubectl get nodes
        else
            echo "⚠️  Cluster access failed (nodes may not be ready yet)"
        fi
    else
        echo "⚠️  Failed to configure kubectl"
    fi
else
    echo "⚠️  kubectl not installed"
fi

echo ""
echo "🎉 OIDC configuration test completed!"
echo "📋 Summary:"
echo "  - Cluster: $CLUSTER_NAME"
echo "  - Region: $REGION"
echo "  - OIDC Issuer: $OIDC_ISSUER"
echo "  - OIDC Provider: $OIDC_PROVIDER_ARN"