# ERP Infrastructure

Infrastructure for the ERP System (Step 2 of the DevOps Commander project).
Terraform **provisions** the servers; Ansible **configures** them.

This is the real, monitored workload that the DevOps Commander AI agents watch.
The AI runtime itself lives in a separate repository and stays entirely on Azure —
this repo only stands up the application and its database on two clouds.

## What gets created

Each cloud gets **two servers** in each environment (`dev`, `prod`):

| Server | Role | Ports |
| ------ | ---- | ----- |
| app | Java backend (8080) + React via nginx | 80, 443, 8080, 22 |
| db  | Dedicated MySQL host | 3306 (internal only), 22 |

- **Azure** (`infra/azure`): Linux VMs in a VNet with separate `app` and `db` subnets and per-tier NSGs. MySQL `3306` is reachable only from inside the VNet (`10.0.0.0/16`).
- **AWS** (`infra/aws`): EC2 instances in the default VPC with per-tier security groups. MySQL `3306` is reachable only from the VPC CIDR. *(The AWS account for this project has EC2-only permissions, so existing default networking is reused.)*

Monitoring split (wired in a later step): **Datadog → prod**, **Grafana → dev**.

## Authentication

Both clouds use **password-based** SSH (no key pairs).

- The password is **never** stored in this repo.
- Terraform reads it from the `admin_password` variable, which the CI pipeline
  injects from the GitHub secret **`TF_VAR_ADMIN_PASSWORD`**.
- Ansible connects with the same password, passed at run time via `--extra-vars`.

> Add `TF_VAR_ADMIN_PASSWORD` in the GitHub repository/organization secrets before running the pipelines.

## Layout

```
infra/
  azure/                  # app VM + db VM (provider, network, app, db, outputs)
    environments/{dev,prod}.tfvars
  aws/                    # app EC2 + db EC2
    environments/{dev,prod}.tfvars
.github/workflows/        # azure-dev, azure-prod, aws-dev, aws-prod
```

Server **configuration / app deployment** (Ansible) lives in the application
repo `ERP_System`, not here. This repo only provisions the servers.

## Deploy (Terraform via GitHub Actions)

The workflows call the shared reusable pipeline
`PixelTech-Solutions/Terraform/.github/workflows/terraform.yml@main`:

1. Push changes under `infra/azure/**` or `infra/aws/**` (or run the workflow manually).
2. The pipeline runs **fmt → validate → plan** automatically.
3. **Apply** and **Destroy** are gated behind GitHub Environments with required reviewers.

State is stored in the shared Azure backend; the state key is
`erp-system/<azure|aws>/<dev|prod>/terraform.tfstate`.

## Configure / deploy the app

Once the servers exist, copy the Terraform **outputs**
(`app_public_ip`, `db_public_ip`, `db_private_ip`) and run the
**"Deploy ERP (Ansible)"** workflow in the `ERP_System` repo, which builds
the backend JAR and configures both servers (MySQL on the db host; Java +
nginx + the app on the app host).
