output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider"
  value       = aws_iam_openid_connect_provider.cluster.url
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "sa_role_arns" {
  description = "ARNs of the service account IAM roles"
  value       = { for k, v in aws_iam_role.sa_roles : k => v.arn }
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "fargate_profile_arns" {
  description = "ARNs of the Fargate profiles"
  value = {
    kube_system  = aws_eks_fargate_profile.kube_system.arn
    default      = aws_eks_fargate_profile.default.arn
    applications = aws_eks_fargate_profile.applications.arn
  }
}

output "fargate_profile_role_arn" {
  description = "ARN of the Fargate profile IAM role"
  value       = aws_iam_role.fargate_profile.arn
}