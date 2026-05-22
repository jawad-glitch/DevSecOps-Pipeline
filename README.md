# DevSecOps Pipeline 🔐

![Pipeline](https://img.shields.io/github/actions/workflow/status/jawad-glitch/DevSecOps-Pipeline/pipeline.yml?label=Pipeline&logo=github-actions&logoColor=white)
![Security](https://img.shields.io/badge/Security-Gitleaks%20%7C%20Semgrep%20%7C%20Trivy-critical)
![IaC](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![Cloud](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazon-aws)
![Container](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker)

A production-grade DevSecOps pipeline with integrated security gates at every stage. Built to demonstrate how security is shifted left — catching vulnerabilities in code, dependencies, and container images before they ever reach production.

---

## Architecture

```
Code Push
    │
    ▼
┌─────────────────────────────────────────┐
│           GitHub Actions CI/CD          │
│                                         │
│  1. Secret Scan     (Gitleaks)          │
│  2. SAST            (Semgrep)           │
│  3. Dependency Scan (pip-audit)         │
│  4. Unit Tests      (pytest)            │
│  5. Container Scan  (Trivy)             │
│  6. Push to ECR                         │
│  7. Deploy to EC2                       │
└─────────────────┬───────────────────────┘
                  │
    ┌─────────────▼─────────────┐
    │        AWS (eu-north-1)   │
    │                           │
    │  ECR  →  EC2 (t3.micro)  │
    │           │               │
    │      Docker Compose       │
    │      ├── Flask App        │
    │      ├── Prometheus       │
    │      └── Grafana          │
    └───────────────────────────┘
```

---

## Security Gates

Every gate is sequential — a failure at any stage stops the pipeline completely.

| Gate | Tool | What It Catches |
|------|------|----------------|
| Secret Scanning | Gitleaks | Hardcoded API keys, tokens, passwords in git history |
| SAST | Semgrep | Insecure code patterns, injection risks in your code |
| Dependency Audit | pip-audit | Known CVEs in third-party packages |
| Unit Tests | pytest | Functional correctness before building an image |
| Container Scan | Trivy | OS and package CVEs inside the Docker image |

---

## Infrastructure (Terraform)

Infrastructure is fully provisioned with Terraform using a modular structure and remote state.

```
terraform/
├── main.tf           # Root module wiring
├── variables.tf
├── backend.tf        # S3 remote state + DynamoDB locking
└── modules/
    ├── ecr/          # Container registry, immutable tags, lifecycle policy
    ├── vpc/          # VPC, public subnet, IGW, route tables
    └── ec2/          # Instance, security group, IAM role for ECR pull
```

**Key decisions:**
- Image tags are immutable — every deployment is traceable and rollback-able
- EC2 pulls images via IAM role — no AWS credentials stored on the server
- SSH restricted by CIDR — principle of least privilege
- DynamoDB state locking — prevents concurrent `terraform apply` conflicts

---

## Stack

| Layer | Technology |
|-------|-----------|
| Application | Python, Flask, Gunicorn |
| Containerisation | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Secret Scanning | Gitleaks |
| SAST | Semgrep |
| SCA | pip-audit |
| Container Security | Trivy |
| IaC | Terraform |
| Cloud | AWS (ECR, EC2, VPC, IAM, S3) |
| Monitoring | Prometheus, Grafana |

---

## Running Locally

```bash
# Clone the repo
git clone https://github.com/jawad-glitch/DevSecOps-Pipeline.git
cd DevSecOps-Pipeline

# Build and run
docker build -t devsecops-app .
docker compose up -d

# Test endpoints
curl http://localhost:5000/health
curl http://localhost:5000/info
curl http://localhost:5000/items
```

---

## Provisioning Infrastructure

```bash
cd terraform

# Create S3 backend and DynamoDB lock table first
aws s3 mb s3://devsecops-tfstate-YOUR_ACCOUNT_ID --region eu-north-1
aws dynamodb create-table \
  --table-name devsecops-tfstate-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-north-1

# Init and apply
terraform init
terraform apply -var="allowed_ssh_cidr=YOUR_IP/32"

# Tear down when done
terraform destroy -var="allowed_ssh_cidr=YOUR_IP/32"
```

---

## GitHub Actions Secrets Required

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `AWS_REGION` | Target region (e.g. eu-north-1) |
| `ECR_REGISTRY` | ECR registry URL (without repo name) |
| `EC2_HOST` | Public IP of EC2 instance |
| `EC2_SSH_KEY` | Private SSH key for EC2 access |

---

## Note on Production Hardening

This project uses direct SSH deployment for simplicity. In a production environment this would be replaced with:
- **AWS Systems Manager Session Manager** — no open SSH port required
- **ArgoCD** — GitOps-style CD for Kubernetes deployments
- **OIDC authentication** — eliminates long-lived AWS credentials in GitHub secrets
