variable "vpc_name" {
  description = "Name prefix for VPC resources"
  type        = string
  default     = "dukqa"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24", "10.0.40.0/24"]
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks for admin SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace with your admin IP ranges
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "DukQa"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}