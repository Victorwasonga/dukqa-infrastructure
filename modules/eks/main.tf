# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.cluster_log_types

  tags = var.tags
}

# OIDC Provider for IRSA
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })
}

# IRSA Roles
resource "aws_iam_role" "sa_roles" {
  for_each = var.sa_roles
  name     = "${var.cluster_name}-${each.value.role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.cluster.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = each.value.sub
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sa_attach" {
  for_each = {
    for pair in flatten([
      for k, v in var.sa_roles : [
        for policy_arn in v.policy_arns : {
          key        = "${k}-${policy_arn}"
          role       = aws_iam_role.sa_roles[k].name
          policy_arn = policy_arn
        }
      ]
    ]) : pair.key => pair
  }

  role       = each.value.role
  policy_arn = each.value.policy_arn
}

# Attach custom policies to specific roles
resource "aws_iam_role_policy_attachment" "rds_enhanced" {
  count      = contains(keys(var.sa_roles), "default:rds-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["default:rds-service-account"].name
  policy_arn = aws_iam_policy.rds_enhanced_access.arn
}

resource "aws_iam_role_policy_attachment" "s3_app" {
  count      = contains(keys(var.sa_roles), "default:s3-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["default:s3-service-account"].name
  policy_arn = aws_iam_policy.s3_app_access.arn
}

resource "aws_iam_role_policy_attachment" "secrets_app" {
  count      = contains(keys(var.sa_roles), "default:secrets-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["default:secrets-service-account"].name
  policy_arn = aws_iam_policy.secrets_app_access.arn
}

resource "aws_iam_role_policy_attachment" "ebs_volume" {
  count      = contains(keys(var.sa_roles), "dukqa-apps:ebs-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["dukqa-apps:ebs-service-account"].name
  policy_arn = aws_iam_policy.ebs_volume_access.arn
}

# Attach enhanced policies to application service accounts
resource "aws_iam_role_policy_attachment" "app_s3_enhanced" {
  count      = contains(keys(var.sa_roles), "dukqa-apps:s3-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["dukqa-apps:s3-service-account"].name
  policy_arn = aws_iam_policy.s3_app_access.arn
}

resource "aws_iam_role_policy_attachment" "app_rds_enhanced" {
  count      = contains(keys(var.sa_roles), "dukqa-apps:rds-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["dukqa-apps:rds-service-account"].name
  policy_arn = aws_iam_policy.rds_enhanced_access.arn
}

resource "aws_iam_role_policy_attachment" "app_secrets_enhanced" {
  count      = contains(keys(var.sa_roles), "dukqa-apps:secrets-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["dukqa-apps:secrets-service-account"].name
  policy_arn = aws_iam_policy.secrets_app_access.arn
}

# Attach cross-service policies to main application role
resource "aws_iam_role_policy_attachment" "app_cross_service" {
  count      = contains(keys(var.sa_roles), "dukqa-apps:app-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["dukqa-apps:app-service-account"].name
  policy_arn = aws_iam_policy.cross_service_access.arn
}

resource "aws_iam_role_policy_attachment" "app_cloudwatch_logs" {
  count      = contains(keys(var.sa_roles), "dukqa-apps:app-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["dukqa-apps:app-service-account"].name
  policy_arn = aws_iam_policy.cloudwatch_logs_access.arn
}

resource "aws_iam_role_policy_attachment" "app_parameter_store" {
  count      = contains(keys(var.sa_roles), "dukqa-apps:app-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["dukqa-apps:app-service-account"].name
  policy_arn = aws_iam_policy.parameter_store_access.arn
}

resource "aws_iam_role_policy_attachment" "app_kms" {
  count      = contains(keys(var.sa_roles), "dukqa-apps:app-service-account") ? 1 : 0
  role       = aws_iam_role.sa_roles["dukqa-apps:app-service-account"].name
  policy_arn = aws_iam_policy.kms_access.arn
}
