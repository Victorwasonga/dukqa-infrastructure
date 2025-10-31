# General Variables
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

# VPC Variables
variable "vpc_name" {
  description = "Name prefix for VPC resources"
  type        = string
  default     = "dukqa"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24", "10.0.40.0/24"]
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks for admin SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace with your admin IP ranges
}

# EKS Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "duka-eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

# EKS Node Group Variables
variable "node_group_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_instance_types" {
  description = "List of instance types for the EKS Node Group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS Node Group"
  type        = number
  default     = 3
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS Node Group"
  type        = number
  default     = 10
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS Node Group"
  type        = number
  default     = 1
}

variable "ec2_key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access to nodes"
  type        = string
  default     = null
}

variable "enable_fargate" {
  description = "Enable Fargate profiles"
  type        = bool
  default     = true
}

variable "enable_ec2_nodes" {
  description = "Enable EC2 managed node groups"
  type        = bool
  default     = true
}

variable "fargate_namespaces" {
  description = "List of namespaces for Fargate profiles"
  type        = list(string)
  default     = ["dukqa-apps", "monitoring", "argocd"]
}

variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket names in IAM policies"
  type        = string
  default     = "dukqa"
}

variable "secrets_prefix" {
  description = "Prefix for secrets in AWS Secrets Manager"
  type        = string
  default     = "dukqa"
}

# ECR Variables
variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "dukqa-platform"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "Maximum number of images to keep in ECR"
  type        = number
  default     = 30
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "DukQa"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}