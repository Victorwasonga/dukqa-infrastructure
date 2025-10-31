# Helm provider configuration
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# AWS Load Balancer Controller (disabled to avoid conflicts with addons)
# Will be installed via ArgoCD after cluster deployment
# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = var.alb_controller_version
# }

# Cluster Autoscaler (disabled to avoid conflicts)
# Will be installed via ArgoCD after cluster deployment
# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"
#   version    = var.cluster_autoscaler_version
# }