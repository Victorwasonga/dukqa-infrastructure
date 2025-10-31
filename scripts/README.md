# 🧭 EKS OIDC Configuration — dukqa-platform

This folder contains operational scripts for preparing the `dukqa-platform` EKS cluster for IRSA (IAM Roles for Service Accounts).

---

## 📍 Overview

Before you can assign AWS IAM roles to Kubernetes service accounts, you **must enable the EKS OIDC provider**.  
This allows your pods to securely assume AWS IAM roles using short-lived credentials.

The script below automates that step.

---

## ⚙️ Script: `enable-oidc.sh`

**Purpose:**  
Enable or verify the OpenID Connect (OIDC) provider for the EKS cluster `dukqa-platform`.

**Location:**  

