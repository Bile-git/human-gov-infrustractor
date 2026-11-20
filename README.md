# Human Government Infrastructure (Terraform)

This repository contains Terraform configuration for provisioning a small AWS infrastructure environment. The current configuration uses a reusable child module and a list of state names to create a separate set of resources for each configured entry.

## Architecture

The root Terraform configuration in `terraform/`:

1. Configures the AWS provider for `us-east-2`.
2. Reads the `states` input variable.
3. Instantiates the `aws_humangov_infrastructure` module once for each value.
4. Collects each module's EC2 public DNS name, DynamoDB table name, and S3 bucket name as outputs.

### Resources defined by the module

| Resource | Purpose |
|---|---|
| EC2 instance | Small `t3.micro` instance using the configured AMI and key pair |
| Security group | Inbound SSH (22) and HTTP (80) rules |
| DynamoDB table | On-demand table with a string hash key named `id` |
| S3 bucket | Bucket name includes a generated random suffix |

The default input currently contains `minnesota`. The module is reusable for additional values supplied through the `states` variable.

## Repository layout

```text
human-gov-infrustractor/
├── README.md
└── terraform/
    ├── backend.tf
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        └── aws_humangov_infrastructure/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

## Prerequisites

- Terraform CLI
- AWS CLI
- An AWS account and permissions for the resources in the module
- AWS credentials configured through a supported provider method (for example, an IAM role or local AWS CLI profile)
- An existing S3 bucket and DynamoDB lock table if you intend to use the configured remote backend

Do not put AWS access keys, secret keys, private keys, or passwords in Terraform files or commit them to this repository.

## Initialize and review

Run these commands from the Terraform directory:

```bash
cd terraform
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

Review the plan carefully before making any changes to an AWS account. Apply only when you understand the resources and costs:

```bash
terraform apply
```

To remove resources created by this configuration when they are no longer needed:

```bash
terraform destroy
```

The configured S3 backend must already exist and be accessible before `terraform init` can complete. Backend configuration is in `backend.tf`; adapt it to an S3 bucket and locking approach that you own and have permission to use.

## Important security review

**Do not use the current security group unchanged for a production deployment.** The module currently allows inbound SSH (TCP 22) and HTTP (TCP 80) from `0.0.0.0/0`. Publicly exposing SSH is risky. Restrict SSH to a trusted administrator IP/CIDR or use a managed access method such as AWS Systems Manager Session Manager. Keep database and other administrative services private.

Before deploying, also review the AMI ID, key pair name, region, backend bucket, lock configuration, and IAM permissions for your own environment.

## State and secret hygiene

Terraform state and backup files may contain infrastructure metadata and values that should not be public. This repository ignores local state, backup, plan, variable, and plugin-cache files. Keep state in a secured remote backend with encryption, access controls, and locking. Never commit `.tfstate`, `.tfstate.backup`, `.tfvars`, plan files, or credentials.

## Current implementation notes

This README describes the resources and settings visible in the Terraform source. It does not claim that the configuration has been validated or successfully applied in every AWS account. Confirm the current plan and deployment results in your own environment before describing the infrastructure as deployed.

---

Maintained by [Bile-git](https://github.com/Bile-git).
