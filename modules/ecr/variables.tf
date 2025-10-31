variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for IAM role permissions"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (optional)"
  type        = string
  default     = null
}

variable "max_image_count" {
  description = "Maximum number of images to keep"
  type        = number
  default     = 30
}

variable "lifecycle_tag_prefixes" {
  description = "Tag prefixes for lifecycle policy"
  type        = list(string)
  default     = ["v", "release", "main"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}