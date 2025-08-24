# Terraform — Infrastructure (Network, VPC & Related Modules)

This folder contains the Terraform code that builds the network foundation for the **Startup-DevOps** project. It provisions the following resources:

- **VPC**: A single VPC with configurable CIDR defaults.
- **Subnets**: Public and private subnets (one per Availability Zone).
- **Internet Gateway**: For public subnets.
- **NAT Gateway(s)**: Optional, for outbound internet access from private subnets.
- **Route Tables**: Public subnets route to the Internet Gateway, private subnets route to NAT Gateway (if enabled).
- **Security Groups**: Network-level security groups for use by other modules (e.g., EKS, RDS).
- **Terraform Outputs**: Provides outputs like `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `nat_gateway_ids`, and more for downstream modules.

This README explains what the module does, how to use it, and provides a checklist for getting started.

---

## What This Module Provides (High-Level)

1. **VPC**:
   - A single VPC for the project with sensible CIDR defaults (configurable).

2. **Subnets**:
   - Public subnets (one per AZ) for NAT Gateways, Internet Gateway, and ALB.
   - Private subnets (one per AZ) for EKS worker nodes and RDS.

3. **Internet Gateway**:
   - Provides internet access for public subnets.

4. **NAT Gateway(s)**:
   - Optional (controlled via `nat_enabled` toggle):
     - `true`: Private subnets have outbound internet via NAT Gateway(s).
     - `false`: Cheaper, but private workloads cannot reach the public internet.

5. **Route Tables**:
   - Public subnets → Internet Gateway.
   - Private subnets → NAT Gateway (if enabled) or no internet route.

6. **Security Groups**:
   - Security groups for use by other modules (e.g., EKS cluster, RDS).

7. **Terraform Outputs**:
   - Outputs consumed by downstream modules (e.g., `vpc_id`, `private_subnet_ids`, `public_subnet_ids`, `nat_gateway_ids`, etc.).

---

## Design Decisions & Recommendations

- **Single VPC, Multiple Subnets per AZ**:
  - Keeps networking simple and low-cost for startups while allowing AZ resilience when you expand.

- **NAT Gateways**:
  - Use `nat_enabled = true` if private subnets need outbound internet (e.g., for downloading updates or accessing external services).
  - If cost is a concern:
    - Use one NAT Gateway in the primary AZ.
    - Consider NAT instances (less recommended).
    - Schedule NAT Gateway deletion when not needed.

- **Subnet Sizing**:
  - Choose reasonably sized CIDRs for private/public subnets. If you plan to run many pods/ENIs, size accordingly.

- **Tags**:
  - Every resource should include `Project` and `Environment` tags for cost tracking and governance.

- **Outputs for Downstream Modules**:
  - Expose private subnet IDs for EKS node groups and RDS subnet groups. Keep output names consistent.

---

## How to Get Started — Minimal Checklist

1. **Fork/Clone This Repo**:

2. **Add an Architecture Diagram**:
   - Place the diagram at the root of the repository (optional but recommended).

3. **Configure Backend**:
   - Review `backend.tf` in each folder(eks-network-rds) and set the S3 bucket and DynamoDB lock table for state using the console.

4. **Provision Network**:
   - Use `Terraform/network` to provision the VPC, subnets, NAT, and route tables.

5. **Provision EKS Control Plane**:
   - Use `Terraform/eks` and wait for the cluster to become active.

6. **Provision Node Groups**:
   - Deploy node groups in private subnets and ensure to do it only after the creation of the cluster.

7. **Install Add-Ons**:
   - Install `cert-manager` and AWS Load Balancer Controller (recommended via `kubectl` or Helm).

8. **Provision RDS**:
   - Use `terraform/rds` and store credentials in Secrets Manager.

9. **Create Namespaces**:
   - Create `dev`, `qa`, and `prod` namespaces and apply `ResourceQuotas` and `LimitRanges`.

10. **Set Up Roles and Service Accounts**:
    - Create namespaced Roles, RoleBindings, and service accounts for CI/CD access.

11. **Test a Simple App**:
    - Deploy an app with an Ingress that creates an ALB. Verify the ALB and target groups.

12. **Build CI/CD Pipelines**:
    - Set up pipelines to push images and deploy to the appropriate namespace.