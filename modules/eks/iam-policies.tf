# Custom IAM Policies for Service Accounts

# RDS Enhanced Access Policy
resource "aws_iam_policy" "rds_enhanced_access" {
  name        = "${var.cluster_name}-rds-enhanced-access"
  description = "Enhanced RDS access for microservices"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBSubnetGroups",
          "rds:DescribeDBParameterGroups",
          "rds:Connect",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ]
        Resource = "arn:aws:rds:*:*:cluster:${var.secrets_prefix}-*"
      }
    ]
  })

  tags = var.tags
}

# S3 Application Access Policy
resource "aws_iam_policy" "s3_app_access" {
  name        = "${var.cluster_name}-s3-app-access"
  description = "S3 access for application data"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:GetObjectAcl",
          "s3:RestoreObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_prefix}-*",
          "arn:aws:s3:::${var.s3_bucket_prefix}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Secrets Manager Application Policy
resource "aws_iam_policy" "secrets_app_access" {
  name        = "${var.cluster_name}-secrets-app-access"
  description = "Secrets Manager access for applications"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.secrets_prefix}/*"
      }
    ]
  })

  tags = var.tags
}

# EBS Volume Management Policy
resource "aws_iam_policy" "ebs_volume_access" {
  name        = "${var.cluster_name}-ebs-volume-access"
  description = "EBS volume management for applications"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumeAttribute",
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "ec2:DescribeInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}