# Fargate Profile IAM Role
resource "aws_iam_role" "fargate_profile" {
  name = "${var.cluster_name}-fargate-profile-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile.name
}

# Fargate Profile for kube-system namespace
resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.cluster_name}-kube-system"
  pod_execution_role_arn = aws_iam_role.fargate_profile.arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "kube-system"
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-kube-system-fargate"
  })
}

# Fargate Profile for default namespace
resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.cluster_name}-default"
  pod_execution_role_arn = aws_iam_role.fargate_profile.arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "default"
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-default-fargate"
  })
}

# Fargate Profile for application workloads
resource "aws_eks_fargate_profile" "applications" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.cluster_name}-applications"
  pod_execution_role_arn = aws_iam_role.fargate_profile.arn
  subnet_ids             = var.subnet_ids

  dynamic "selector" {
    for_each = var.fargate_namespaces
    content {
      namespace = selector.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-applications-fargate"
  })
}