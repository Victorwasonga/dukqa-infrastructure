# Additional IAM Policies for Pod-to-AWS Service Communication

# Cross-Service Communication Policy
resource "aws_iam_policy" "cross_service_access" {
  name        = "${var.cluster_name}-cross-service-access"
  description = "Cross-service access for microservices communication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:GetCallerIdentity"
        ]
        Resource = "arn:aws:iam::*:role/${var.cluster_name}-*"
      }
    ]
  })

  tags = var.tags
}

# CloudWatch Logs Policy for Application Logging
resource "aws_iam_policy" "cloudwatch_logs_access" {
  name        = "${var.cluster_name}-cloudwatch-logs-access"
  description = "CloudWatch Logs access for application logging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutRetentionPolicy"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/eks/${var.cluster_name}/*"
      }
    ]
  })

  tags = var.tags
}

# Parameter Store Access Policy
resource "aws_iam_policy" "parameter_store_access" {
  name        = "${var.cluster_name}-parameter-store-access"
  description = "Parameter Store access for configuration management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${var.secrets_prefix}/*"
      }
    ]
  })

  tags = var.tags
}

# KMS Access Policy for Encryption
resource "aws_iam_policy" "kms_access" {
  name        = "${var.cluster_name}-kms-access"
  description = "KMS access for encryption/decryption operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:ListKeys",
          "kms:ListAliases"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "s3.*.amazonaws.com",
              "rds.*.amazonaws.com",
              "secretsmanager.*.amazonaws.com"
            ]
          }
        }
      }
    ]
  })

  tags = var.tags
}