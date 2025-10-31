# DUKA Infrastructure as Code (Terraform)

This repository contains production-ready Terraform infrastructure code for the DukQa platform, implementing a secure, scalable, and compliant cloud architecture on AWS.

<!-- Pipeline trigger: Testing GitHub Actions OIDC authentication -->

## 🏗️ Architecture Overview

The DukQa platform uses a modern cloud-native architecture with:
- **EKS Kubernetes cluster** for microservices orchestration
- **Layered security groups** implementing defense-in-depth
- **VPC with public/private subnets** for network isolation
- **IRSA (IAM Roles for Service Accounts)** for secure AWS service access
- **GitOps deployment** with ArgoCD for continuous delivery

## 📁 Repository Structure

```
DUKA-IAC-TERRAFORM/
├── backend.tf              # Terraform backend (S3 + DynamoDB)
├── main.tf                 # Main infrastructure orchestration
├── variables.tf            # Input variables and configuration
├── outputs.tf              # Infrastructure outputs
├── environments/           # Environment-specific configurations
│   ├── prod.tfvars        # Production environment settings
│   └── test.tfvars        # Test environment settings
├── modules/               # Reusable Terraform modules
│   ├── vpc/              # VPC, subnets, security groups
│   │   ├── main.tf       # VPC and networking resources
│   │   ├── security-groups.tf # Layered security group design
│   │   ├── variables.tf  # VPC module variables
│   │   └── outputs.tf    # VPC module outputs
│   └── eks/              # EKS cluster with OIDC integration
│       ├── main.tf       # EKS cluster and IRSA configuration
│       ├── addons.tf     # EKS managed add-ons
│       ├── helm-releases.tf # ALB Controller, Cluster Autoscaler
│       ├── iam-policies.tf  # Custom IAM policies
│       ├── variables.tf  # EKS module variables
│       ├── outputs.tf    # EKS module outputs
│       └── README.md     # EKS module documentation
└── scripts/              # Infrastructure automation scripts
    ├── setup-backend.sh # Initialize Terraform backend
    └── README.md
```

## 🔐 DukQa Layered Security Group Design

### Security Architecture
The infrastructure implements a defense-in-depth security model with layered security groups:

```
Internet → ALB-SG → Web-SG → DB-SG
    ↓         ↓        ↓       ↓
  Port 80/443  Port 80/443  Port 3306/5432
                ↓        ↓
            SSH from Bastion
```

### Security Group Rules

| Security Group | Inbound Rules | Source | Purpose |
|---------------|---------------|---------|---------|
| **ALB-SG** | 80, 443 | 0.0.0.0/0 | Public traffic to ALB |
| **SSH-SG** | 22 | Admin IPs | SSH access to Bastion Host |
| **Web-SG** | 80, 443 | ALB-SG | User traffic via ALB |
|            | 22 | SSH-SG | Admin SSH access |
|            | 1025-65535 | Self | EKS node communication |
| **DB-SG** | 3306 | Web-SG | MySQL from App servers |
|           | 5432 | Web-SG | PostgreSQL from App servers |
|           | 22 | SSH-SG | Optional SSH admin access |
| **EKS-SG** | 443 | Web-SG | HTTPS from EKS nodes |

### Traffic Flow
1. **Internet → ALB-SG (80/443)** - Public users access only the Load Balancer
2. **ALB-SG → Web-SG (80/443)** - ALB forwards requests to Web/App servers in private subnets
3. **Web-SG → DB-SG (3306/5432)** - Web/App servers connect securely to the Database
4. **Admin IP → SSH-SG (22)** - Admins log into the Bastion Host from trusted IPs
5. **SSH-SG → Web-SG (22)** - Admins jump from Bastion to Web/App servers via SSH
6. **SSH-SG → DB-SG (22)** - Admins jump from Bastion to Database server via SSH

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0 installed
- kubectl installed for EKS management

### ⚠️ IMPORTANT: Configuration Required
**Before deployment, you MUST update configuration files:**
- See [CONFIGURATION.md](CONFIGURATION.md) for detailed setup instructions
- Update `admin_cidr_blocks` with your IP ranges
- Replace `account_id` with your AWS account ID
- Customize cluster and resource names as needed

### 1. Initialize Backend
```bash
# Set up S3 bucket and DynamoDB table for Terraform state
./scripts/setup-backend.sh
```

### 2. Initialize Terraform
```bash
# Initialize Terraform with backend configuration
terraform init
```

### 3. Plan Infrastructure
```bash
# Review infrastructure changes (test environment)
terraform plan -var-file=environments/test.tfvars

# Review infrastructure changes (production environment)
terraform plan -var-file=environments/prod.tfvars
```

### 4. Deploy Infrastructure
```bash
# Deploy test environment
terraform apply -var-file=environments/test.tfvars

# Deploy production environment
terraform apply -var-file=environments/prod.tfvars
```

### 5. Configure kubectl
```bash
# Configure kubectl to access the EKS cluster
aws eks update-kubeconfig --region eu-west-1 --name dukqa-production
```

## 🏗️ Infrastructure Components

### Core Infrastructure
- **VPC** - Isolated network with public/private subnets across multiple AZs
- **EKS Cluster** - Managed Kubernetes cluster for microservices
- **Security Groups** - Layered network security with least privilege access
- **NAT Gateway** - Secure internet access for private subnets
- **OIDC Provider** - Service account authentication for AWS services

### Security & Access
- **IRSA Roles** - IAM roles for service accounts (no hardcoded credentials)
- **Network Policies** - Kubernetes-level network segmentation
- **Secrets Manager Integration** - Secure credential management
- **Private Endpoints** - VPC endpoints for AWS services

### Automation & Operations
- **AWS Load Balancer Controller** - Automatic ALB/NLB provisioning
- **Cluster Autoscaler** - Automatic node scaling based on demand
- **EBS CSI Driver** - Dynamic volume provisioning
- **Secrets Store CSI** - Secure secret injection into pods

## 🔧 Configuration

### Environment Variables
Update the following in your `.tfvars` files:

```hcl
# Network Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24", "10.0.40.0/24"]

# Security Configuration
admin_cidr_blocks = ["YOUR_OFFICE_IP/32"] # Replace with your admin IP ranges

# EKS Configuration
cluster_name = "dukqa-production"
kubernetes_version = "1.28"
node_group_instance_types = ["t3.medium", "t3.large"]
```

### Security Considerations
- **Replace default admin CIDR blocks** with your actual office/admin IP ranges
- **Use EC2 Key Pairs** for SSH access to nodes (optional but recommended)
- **Enable AWS CloudTrail** for audit logging
- **Configure AWS Config** for compliance monitoring

## 📊 Outputs

After deployment, Terraform provides the following outputs:

```bash
# VPC Information
vpc_id = "vpc-xxxxxxxxx"
public_subnet_ids = ["subnet-xxxxxxxxx", "subnet-yyyyyyyyy"]
private_subnet_ids = ["subnet-zzzzzzzzz", "subnet-aaaaaaaaa"]

# Security Groups
security_groups = {
  alb = "sg-xxxxxxxxx"
  web = "sg-yyyyyyyyy"
  database = "sg-zzzzzzzzz"
  eks = "sg-aaaaaaaaa"
}

# EKS Cluster
cluster_endpoint = "https://XXXXXXXXX.gr7.eu-west-1.eks.amazonaws.com"
oidc_provider_arn = "arn:aws:iam::746387399274:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/XXXXXXXXX"
```

## 🔄 State Management

Terraform state is securely managed using:
- **S3 Backend** - Encrypted state storage with versioning in Ireland region
- **S3 Versioning** - Prevents state corruption and enables rollback
- **State Encryption** - All state data encrypted at rest and in transit

### Backend Configuration
```hcl
backend "s3" {
  bucket  = "dukqa-terraform-state-ireland"
  key     = "production/terraform.tfstate"
  region  = "eu-west-1"
  encrypt = true
}
```

## 🛡️ Security Best Practices

### Network Security
- **Private subnets** for all application workloads
- **Security groups** with least privilege access
- **Network ACLs** for additional layer of security
- **VPC Flow Logs** for network monitoring

### Access Control
- **IRSA** instead of hardcoded AWS credentials
- **RBAC** for Kubernetes access control
- **IAM policies** with minimal required permissions
- **MFA enforcement** for administrative access

### Data Protection
- **Encryption at rest** for all storage services
- **Encryption in transit** for all communications
- **Secrets Manager** for credential storage
- **Regular key rotation** for enhanced security

## 🚨 Important Notes

### Production Readiness
- **Update admin CIDR blocks** before production deployment
- **Configure monitoring and alerting** for all components
- **Set up backup strategies** for critical data
- **Implement disaster recovery procedures**

### Cost Optimization
- **Use Spot instances** for non-critical workloads (test environment)
- **Configure cluster autoscaler** for dynamic scaling
- **Monitor resource usage** and right-size instances
- **Set up cost alerts** and budgets

### Compliance
- **Enable AWS CloudTrail** for audit logging
- **Configure AWS Config** for compliance monitoring
- **Implement resource tagging** for cost allocation
- **Regular security assessments** and penetration testing

## 🔗 Integration Points

This infrastructure integrates with:
- **DukQa-EKS-Project** - Kubernetes manifests and GitOps workflows
- **ArgoCD** - Continuous deployment and GitOps
- **Monitoring Stack** - Prometheus, Grafana, and alerting
- **CI/CD Pipelines** - GitHub Actions for automated deployments

## 📞 Support

For infrastructure issues or questions:
- **Platform Team** - infrastructure@dukqa.com
- **Documentation** - Internal wiki and runbooks
- **Monitoring** - Grafana dashboards and alerts
- **Incident Response** - On-call rotation and escalation procedures