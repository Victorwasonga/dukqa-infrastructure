# 🐳 Amazon ECR Repository - dukqa-platform

This module provisions a **single shared ECR repository** for all DukQa platform microservices.  
Each service image is tagged uniquely (e.g. `dukqa-platform:auth-service-latest`) to simplify deployment and scaling.

---

## 📘 Overview

| Component | Description |
|------------|-------------|
| **Repository Name** | `dukqa-platform` |
| **Encryption** | AES-256 |
| **Image Scanning** | Enabled on push |
| **Tag Mutability** | Mutable |
| **Usage** | All microservices share this repository, distinguished by tags |

---

## ⚙️ Terraform Deployment

### 1️⃣ Initialize Terraform
```bash
cd production-cluster/terraform
terraform init

