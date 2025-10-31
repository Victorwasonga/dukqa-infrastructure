# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  admin_cidr_blocks    = var.admin_cidr_blocks

  tags = var.tags
}

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# EKS Node Group IAM Role
resource "aws_iam_role" "eks_node_group" {
  name = "${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  account_id      = data.aws_caller_identity.current.account_id
  cluster_name    = var.cluster_name
  scan_on_push    = var.ecr_scan_on_push
  max_image_count = var.ecr_max_image_count

  tags = var.tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_role_arn   = aws_iam_role.eks_cluster.arn
  kubernetes_version = var.kubernetes_version
  subnet_ids         = module.vpc.private_subnet_ids
  region             = var.region

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.admin_cidr_blocks

  enable_fargate     = var.enable_fargate
  fargate_namespaces = var.fargate_namespaces
  s3_bucket_prefix   = var.s3_bucket_prefix
  secrets_prefix     = var.secrets_prefix

  tags = var.tags
}

# EKS Node Group (EC2)
resource "aws_eks_node_group" "main" {
  count = var.enable_ec2_nodes ? 1 : 0

  cluster_name    = module.eks.cluster_id
  node_group_name = "${var.cluster_name}-ec2-nodes"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = module.vpc.private_subnet_ids

  capacity_type  = var.node_group_capacity_type
  instance_types = var.node_group_instance_types

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Optional SSH access (only if key pair is provided)
  dynamic "remote_access" {
    for_each = var.ec2_key_pair_name != null ? [1] : []
    content {
      ec2_ssh_key               = var.ec2_key_pair_name
      source_security_group_ids = [module.vpc.ssh_security_group_id]
    }
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

# Additional EC2 Node Group for system workloads (disabled for test env)
resource "aws_eks_node_group" "system" {
  count = var.enable_ec2_nodes && var.node_group_desired_size > 1 ? 1 : 0

  cluster_name    = module.eks.cluster_id
  node_group_name = "${var.cluster_name}-system-nodes"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = module.vpc.private_subnet_ids

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Taints for system workloads
  taint {
    key    = "node-type"
    value  = "system"
    effect = "NO_SCHEDULE"
  }

  labels = {
    "node-type" = "system"
    "workload"  = "infrastructure"
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-system-nodes"
    Type = "system"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}