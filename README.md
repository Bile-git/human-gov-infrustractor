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
| Security group | SSH (22) restricted to one administrator IPv4 address; HTTP (80) remains public |
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
- An administrator public IPv4 address for SSH access

Do not put AWS access keys, secret keys, private keys, or passwords in Terraform files or commit them to this repository.

## Initialize and review

Run these commands from the Terraform directory:

```bash
cd terraform
terraform fmt -recursive
terraform init
terraform validate
```

The configuration requires an administrator IPv4 address in single-host CIDR notation (`/32`). You can supply it at plan/apply time without saving it in a committed file:

```bash
ADMIN_IP=$(curl -4 -s https://checkip.amazonaws.com | tr -d '\n')
terraform plan -var="admin_ssh_cidr=${ADMIN_IP}/32"
```

Review the plan carefully before making any changes to an AWS account. If the plan is correct, apply using the same variable:

```bash
terraform apply -var="admin_ssh_cidr=${ADMIN_IP}/32"
```

To remove resources created by this configuration when they are no longer needed:

```bash
terraform destroy -var="admin_ssh_cidr=${ADMIN_IP}/32"
```

The configured S3 backend must already exist and be accessible before `terraform init` can complete. Backend configuration is in `backend.tf`; adapt it to an S3 bucket and locking approach that you own and have permission to use.

## Security considerations

- SSH ingress is restricted to the administrator IPv4 address supplied through `admin_ssh_cidr`. Do not change this to `0.0.0.0/0`.
- HTTP on port 80 is still public. Only keep it public if the application is intended to be reachable from the internet.
- Review the AMI ID, key pair name, region, backend bucket, lock configuration, and IAM permissions for your own environment.
- Prefer AWS Systems Manager Session Manager over public SSH where practical.

## State and secret hygiene

Terraform state and backup files may contain infrastructure metadata and values that should not be public. This repository ignores local state, backup, plan, variable, and plugin-cache files. Keep state in a secured remote backend with encryption, access controls, and locking. Never commit `.tfstate`, `.tfstate.backup`, `.tfvars`, plan files, or credentials.

A previously committed state backup has been removed from the current branch and is now covered by `.gitignore`. Removing a file in a new commit does not remove it from earlier Git history. If a state file ever contained real secrets, rotate those secrets and consider rewriting Git history before continuing to publish the repository.

## Validation status

This README describes the resources and settings visible in the Terraform source. The repository changes have not been run through `terraform validate` or `terraform plan` in your AWS account. Confirm the current plan and deployment results in your own environment before describing the infrastructure as deployed.

---

Maintained by [Bile-git](https://github.com/Bile-git).
