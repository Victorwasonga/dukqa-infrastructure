# Production Environment Configuration

# General
region = "eu-west-1"
# account_id will be automatically detected by Terraform

# VPC Configuration
vpc_name = "dukqa-prod"
vpc_cidr = "10.0.0.0/16"

availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

# Public Subnets (ALB, NAT Gateway)
public_subnet_cidrs = [
  "10.0.1.0/24", # eu-west-1a
  "10.0.2.0/24"  # eu-west-1b
]

# Private Subnets (EKS Nodes, RDS, etc.)
private_subnet_cidrs = [
  "10.0.10.0/24", # eu-west-1a - EKS nodes
  "10.0.20.0/24", # eu-west-1b - EKS nodes
  "10.0.30.0/24", # eu-west-1a - Database
  "10.0.40.0/24"  # eu-west-1b - Database
]

# Security - Replace with your actual admin IP ranges
admin_cidr_blocks = [
  "0.0.0.0/0" # Replace with your office/admin IP ranges
]

# EKS Configuration
cluster_name       = "duka-eks-cluster"
kubernetes_version = "1.28"
enable_fargate     = true
enable_ec2_nodes   = true

# EKS Node Group Configuration
node_group_capacity_type  = "ON_DEMAND"
node_group_instance_types = ["t3.medium", "t3.large"]
node_group_desired_size   = 3
node_group_max_size       = 10
node_group_min_size       = 1

# Optional: EC2 Key Pair for SSH access to nodes
# ec2_key_pair_name = "dukqa-prod-keypair"

# ECR Configuration
ecr_repository_name = "dukqa-platform"
ecr_scan_on_push    = true
ecr_max_image_count = 50

# Tags
tags = {
  Project     = "DukQa"
  Environment = "production"
  ManagedBy   = "terraform"
  Owner       = "platform-team"
  CostCenter  = "engineering"
}