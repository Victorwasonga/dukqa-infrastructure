# EKS Module with OIDC Integration

This module provisions an Amazon EKS cluster with integrated OIDC provider for IAM Roles for Service Accounts (IRSA).

## Features

- **EKS Cluster** - Fully managed Kubernetes cluster
- **OIDC Provider** - Automatic setup for service account authentication
- **IRSA Roles** - Pre-configured IAM roles for common AWS services
- **Security** - Private endpoint access and proper IAM policies

## Usage

```hcl
module "eks" {
  source = "./modules/eks"
  
  cluster_name     = "dukqa-platform"
  cluster_role_arn = aws_iam_role.eks_cluster.arn
  subnet_ids       = module.vpc.private_subnet_ids
  
  sa_roles = {
    "kube-system:aws-load-balancer-controller" = {
      role_name   = "aws-lb-controller-role"
      policy_arns = ["arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"]
      sub         = "system:serviceaccount:kube-system:aws-load-balancer-controller"
    }
  }
  
  tags = {
    Environment = "production"
    Project     = "dukqa"
  }
}
```

## Pre-configured Service Account Roles

### System Components
- **AWS Load Balancer Controller** - Manages ALB/NLB
- **Cluster Autoscaler** - Auto-scales worker nodes
- **EBS CSI Driver** - Manages EBS volumes
- **Secrets Store CSI Driver** - Integrates with AWS Secrets Manager

### Application Services
- **RDS Access** - Database connectivity
- **S3 Access** - Object storage operations
- **Secrets Manager** - Secure credential access

## OIDC Provider

The module automatically creates an OIDC provider that enables:
- Service accounts to assume IAM roles
- Fine-grained permissions per service
- No need for long-lived AWS credentials in pods

## Outputs

- `cluster_id` - EKS cluster identifier
- `cluster_endpoint` - Kubernetes API endpoint
- `oidc_provider_arn` - OIDC provider ARN for additional roles
- `sa_role_arns` - Map of service account role ARNs

## Security

- Private API endpoint access by default
- Least privilege IAM policies
- Encrypted control plane logs
- VPC-native networking