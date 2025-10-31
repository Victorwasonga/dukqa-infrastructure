# DukQa Infrastructure Configuration Guide

This guide explains what to configure before deploying your DukQa infrastructure.

## 🔧 Required Configuration Updates

### 1. **Security Configuration** (CRITICAL)

Update `environments/prod.tfvars` and `environments/test.tfvars`:

```hcl
# REPLACE WITH YOUR ACTUAL IP RANGES
admin_cidr_blocks = [
  "203.0.113.0/24",    # Your office network
  "198.51.100.0/24"    # Your VPN network
]

# AWS Region Configuration
region = "eu-west-1"  # Ireland region
# Note: AWS Account ID is automatically detected by Terraform
```

### 2. **Cluster Configuration**

```hcl
# Customize cluster settings
cluster_name = "your-cluster-name"  # Default: duka-eks-cluster
vpc_name     = "your-vpc-name"      # Default: dukqa

# ECR Repository
ecr_repository_name = "your-repo-name"  # Default: dukqa-platform

# Resource Prefixes (for IAM policies)
s3_bucket_prefix = "your-prefix"     # Default: dukqa
secrets_prefix   = "your-prefix"     # Default: dukqa
```

### 3. **Network Configuration**

```hcl
# VPC and Subnets (customize as needed)
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = [
  "10.0.10.0/24",  # EKS nodes AZ-a
  "10.0.20.0/24",  # EKS nodes AZ-b
  "10.0.30.0/24",  # Database AZ-a
  "10.0.40.0/24"   # Database AZ-b
]

# Availability Zones
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
```

### 4. **Compute Configuration**

```hcl
# EKS Node Groups
node_group_instance_types = ["t3.medium", "t3.large"]
node_group_desired_size   = 3
node_group_max_size       = 10
node_group_min_size       = 1

# Fargate Configuration
enable_fargate = true
fargate_namespaces = ["dukqa-apps", "monitoring", "argocd"]

# Mixed Compute
enable_ec2_nodes = true  # Set to false for Fargate-only
```

## 📋 Configuration Examples

### Production Environment (`environments/prod.tfvars`):

```hcl
# Production-specific settings
node_group_capacity_type = "ON_DEMAND"
node_group_instance_types = ["t3.large", "t3.xlarge"]
ecr_max_image_count = 50

# High availability
node_group_desired_size = 5
node_group_max_size = 20
```

### Test Environment (`environments/test.tfvars`):

```hcl
# Cost-optimized settings
node_group_capacity_type = "SPOT"
node_group_instance_types = ["t3.small", "t3.medium"]
ecr_max_image_count = 20

# Minimal resources
node_group_desired_size = 2
node_group_max_size = 5
```

## 🛡️ Security Best Practices

- **Never use 0.0.0.0/0** for admin_cidr_blocks in production
- **Use specific IP ranges** for your office/VPN networks
- **Enable MFA** for AWS account access
- **Rotate access keys** regularly
- **Use IAM roles** instead of hardcoded credentials

## 🚀 Deployment Steps

1. **Configure AWS credentials**:
   ```bash
   aws configure
   ```

2. **Update configuration files**:
   - Edit `environments/prod.tfvars`
   - Edit `environments/test.tfvars`
   - Replace all placeholder values

3. **Setup backend**:
   ```bash
   ./scripts/setup-backend.sh
   ```

4. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan -var-file=environments/test.tfvars
   terraform apply -var-file=environments/test.tfvars
   ```

5. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region eu-west-1 --name duka-eks-cluster
   ```

## 📦 What Gets Created

### Infrastructure Components:
- **VPC** with layered security groups
- **EKS Cluster** with OIDC provider
- **ECR Repository** for container images
- **IAM Roles** for pod-to-AWS service communication
- **Fargate Profiles** for serverless containers
- **EC2 Node Groups** for traditional workloads

### Security Features:
- **IRSA Roles** for S3, RDS, EBS, Secrets Manager access
- **Network Policies** ready for deployment
- **Encrypted ECR** with lifecycle policies
- **Least-privilege IAM** policies

## 🔄 After Infrastructure Deployment

1. **Deploy cluster global components** from DukQa-EKS-Project
2. **Install ArgoCD** for GitOps
3. **Configure monitoring** stack
4. **Deploy microservices**

## 🆘 Troubleshooting

### Common Issues:
- **IP range conflicts**: Ensure VPC CIDR doesn't overlap with existing networks
- **Permission errors**: Verify AWS credentials have sufficient permissions
- **Resource limits**: Check AWS service quotas for your region
- **Backend conflicts**: Ensure S3 bucket name is globally unique