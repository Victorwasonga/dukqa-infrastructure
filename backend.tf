terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "dukqa-terraform-state-ireland"
    key     = "production/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "DukQa"
      ManagedBy   = "terraform"
      Environment = "production"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}