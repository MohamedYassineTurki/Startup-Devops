# Startup-DevOps

A minimal-cost, production-minded DevOps infrastructure blueprint for startups on AWS.

This repository provides an opinionated, repeatable baseline to provision a lightweight but secure and maintainable cloud platform for early-stage teams. It focuses on cost-efficiency while preserving established best practices, enabling teams to iterate quickly and scale when needed.

---

## Vision & Goals

- **Low-cost for early-stage**: Reduce cloud spend by sharing control planes and using small instance types while maintaining production patterns.
- **Fast onboarding**: Reproducible infrastructure using Terraform and documented processes so engineers can get running in hours, not days.
- **Clear environment separation**: Dev, QA, and Prod isolation via Kubernetes namespaces and CI/CD promotion flows to balance cost and safety.
- **Secure defaults**: Secrets stored in AWS Secrets Manager, least-privilege IAM policies, private RDS, and network segmentation.
- **Operationally sensible**: ALB for ingress, managed EKS control plane, monitoring-ready, and CI/CD pipelines for safe delivery.

---

## High-Level Architecture

- **VPC**: Public and private subnets per Availability Zone (AZ).
- **EKS**: Single cluster with a managed control plane by AWS; node groups for workloads.
- **ALB**: AWS Load Balancer Controller for HTTP/HTTPS ingress.
- **RDS**: MySQL/Postgres in private subnets; credentials stored in AWS Secrets Manager.
- **Terraform**: Infrastructure as Code (IaC) with S3 backend for state and DynamoDB for locks.
- **CI/CD**: Planned GitLab CI pipelines to build images, run tests, and deploy to namespaces.
- **Container Images**: Docker-based workloads for applications.
- **Namespaces**: Environment separation for Dev, QA, and Prod.

### Architecture Diagram
*(Include a visual overview of the architecture, e.g., `architecture.png` in the repo root.)*

---

## Why This Approach?

- **Cost Efficiency**: One EKS cluster with multiple namespaces balances cost and isolation, reducing control plane expenses.
- **Reproducibility**: Terraform ensures infrastructure is auditable and automatable.
- **Managed Services**: AWS-managed EKS, RDS, and ALB reduce operational overhead, allowing small teams to focus on product development.
- **Secure Secrets Management**: AWS Secrets Manager and IAM roles (or IRSA) keep credentials out of code and minimize the blast radius.

---

## Repo Layout

```plaintext
Startup-DevOps/
├── README.md               <- This file
├── architecture.png         <- Visual overview of the architecture
├── Dockerfiles/             <- Application Dockerfiles (future use)
├── cicd/                    <- GitLab CI templates & documentation (future use)
├── terraform/               <- Terraform modules for infrastructure
│   ├── backend.tf           <- Remote state backend configuration
│   ├── network/             <- VPC and networking resources
│   ├── eks/                 <- EKS cluster and node group resources
│   ├── rds/                 <- RDS database resources
│   └── iam/                 <- IAM roles and policies
└── manifests/               <- Kubernetes manifests and ingress examples
```

## Environments & Team Boundaries

### Environments
- **Dev**: For development and debugging.
- **QA**: For testing promotion builds.
- **Prod**: For production workloads with stricter approvals.

### Team Access
- **Developers**: Access to the Dev namespace for deploying and debugging. CI runs on feature branches.
- **QA/Release Engineers**: Access to the QA namespace for testing promotion builds.
- **Production Owners/SREs**: Control over the Prod namespace with stricter deployment approvals.

---

## Security & Secrets

### Secrets
- Store database credentials and other sensitive information in **AWS Secrets Manager**.
- Applications read secrets at runtime using IAM roles or environment variables.

### Networking
- **RDS**: Deployed in private subnets for enhanced security.
- **EKS Worker Nodes**: Deployed in private subnets (no public IPs by default). Use NAT for outbound traffic when necessary.

### IAM
- Start with node IAM policies that allow necessary calls (e.g., Secrets Manager access).
- Plan migration to **IRSA** (IAM Roles for Service Accounts) for pod-level identities and least-privilege access.

### Least Privilege
- Grant only the required permissions to CI/CD service roles and node roles.
- Use Terraform to manage IAM policies and ensure they are version-controlled.