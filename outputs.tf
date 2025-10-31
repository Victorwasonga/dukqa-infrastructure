# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# Security Group Outputs
output "security_groups" {
  description = "Map of all security group IDs"
  value       = module.vpc.security_groups
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.vpc.alb_security_group_id
}

output "web_security_group_id" {
  description = "ID of the Web/Application security group"
  value       = module.vpc.web_security_group_id
}

output "database_security_group_id" {
  description = "ID of the Database security group"
  value       = module.vpc.database_security_group_id
}

# EKS Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider"
  value       = module.eks.oidc_provider_url
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "sa_role_arns" {
  description = "ARNs of the service account IAM roles"
  value       = module.eks.sa_role_arns
}

# Node Group Outputs
output "ec2_node_group_arns" {
  description = "ARNs of the EC2 Node Groups"
  value = {
    main   = var.enable_ec2_nodes ? aws_eks_node_group.main[0].arn : null
    system = var.enable_ec2_nodes && var.node_group_desired_size > 1 && length(aws_eks_node_group.system) > 0 ? aws_eks_node_group.system[0].arn : null
  }
}

output "ec2_node_group_status" {
  description = "Status of the EC2 Node Groups"
  value = {
    main   = var.enable_ec2_nodes ? aws_eks_node_group.main[0].status : null
    system = var.enable_ec2_nodes && var.node_group_desired_size > 1 && length(aws_eks_node_group.system) > 0 ? aws_eks_node_group.system[0].status : null
  }
}

# Fargate Profile Outputs
output "fargate_profile_arns" {
  description = "ARNs of the Fargate profiles"
  value       = module.eks.fargate_profile_arns
}

output "fargate_profile_role_arn" {
  description = "ARN of the Fargate profile IAM role"
  value       = module.eks.fargate_profile_role_arn
}

# ECR Outputs
output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_registry_id" {
  description = "Registry ID of the ECR repository"
  value       = module.ecr.registry_id
}

# AWS Account Information
output "aws_account_id" {
  description = "AWS Account ID (auto-detected)"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region (auto-detected)"
  value       = data.aws_region.current.name
}