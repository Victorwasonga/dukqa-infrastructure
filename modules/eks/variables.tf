variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# EKS Add-on versions
variable "ebs_csi_version" {
  description = "EBS CSI driver version"
  type        = string
  default     = "v1.24.0-eksbuild.1"
}

variable "coredns_version" {
  description = "CoreDNS version"
  type        = string
  default     = "v1.10.1-eksbuild.5"
}

variable "kube_proxy_version" {
  description = "Kube-proxy version"
  type        = string
  default     = "v1.28.2-eksbuild.2"
}

variable "vpc_cni_version" {
  description = "VPC CNI version"
  type        = string
  default     = "v1.15.1-eksbuild.1"
}

variable "region" {
  description = "AWS region"
  type        = string
}

# Helm chart versions
variable "alb_controller_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "1.6.2"
}

variable "cluster_autoscaler_version" {
  description = "Cluster Autoscaler Helm chart version"
  type        = string
  default     = "9.29.0"
}

variable "enable_fargate" {
  description = "Enable Fargate profiles"
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

variable "sa_roles" {
  description = "Map of service account roles for IRSA"
  type = map(object({
    role_name   = string
    policy_arns = list(string)
    sub         = string
  }))
  default = {
    # System Components - will be dynamically named with cluster_name
    "kube-system:aws-load-balancer-controller" = {
      role_name   = "aws-lb-controller-role"
      policy_arns = ["arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"]
      sub         = "system:serviceaccount:kube-system:aws-load-balancer-controller"
    }
    "kube-system:cluster-autoscaler" = {
      role_name   = "cluster-autoscaler-role"
      policy_arns = ["arn:aws:iam::aws:policy/AutoScalingFullAccess"]
      sub         = "system:serviceaccount:kube-system:cluster-autoscaler"
    }
    "kube-system:ebs-csi-controller-sa" = {
      role_name   = "ebs-csi-driver-role"
      policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
      sub         = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
    }
    "kube-system:secrets-store-csi-driver" = {
      role_name   = "secrets-store-csi-role"
      policy_arns = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
      sub         = "system:serviceaccount:kube-system:secrets-store-csi-driver"
    }
    "kube-system:aws-node" = {
      role_name   = "vpc-cni-role"
      policy_arns = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
      sub         = "system:serviceaccount:kube-system:aws-node"
    }

    # Application Services - will be dynamically named with cluster_name
    "dukqa-apps:app-service-account" = {
      role_name = "app-full-access-role"
      policy_arns = [
        "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess",
        "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
      ]
      sub = "system:serviceaccount:dukqa-apps:app-service-account"
    }
    "dukqa-apps:s3-service-account" = {
      role_name   = "s3-full-access-role"
      policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
      sub         = "system:serviceaccount:dukqa-apps:s3-service-account"
    }
    "dukqa-apps:rds-service-account" = {
      role_name = "rds-access-role"
      policy_arns = [
        "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
      ]
      sub = "system:serviceaccount:dukqa-apps:rds-service-account"
    }
    "dukqa-apps:secrets-service-account" = {
      role_name   = "secrets-access-role"
      policy_arns = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
      sub         = "system:serviceaccount:dukqa-apps:secrets-service-account"
    }
    "dukqa-apps:ebs-service-account" = {
      role_name = "ebs-access-role"
      policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
      ]
      sub = "system:serviceaccount:dukqa-apps:ebs-service-account"
    }
    # Monitoring namespace roles
    "monitoring:monitoring-service-account" = {
      role_name = "monitoring-access-role"
      policy_arns = [
        "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      ]
      sub = "system:serviceaccount:monitoring:monitoring-service-account"
    }
    # ArgoCD namespace roles
    "argocd:argocd-service-account" = {
      role_name = "argocd-access-role"
      policy_arns = [
        "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      ]
      sub = "system:serviceaccount:argocd:argocd-service-account"
    }
  }
}