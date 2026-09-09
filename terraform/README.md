# Terraform — Azure Container Apps Platform

This directory contains the Terraform code for the Azure Container Apps platform described in
`requirements/container-apps.md` and `architecture/`.

## Layout

```
terraform/
├── provider.tf            # Provider configuration (azurerm 4.x)
├── variables.tf           # Root-level input variables
├── outputs.tf             # Root-level outputs
├── main.tf                # Root composition (calls all modules)
├── terraform.tfvars.example
└── modules/
    ├── network/           # VNet, Container Apps subnet, Private Endpoint subnet
    ├── platform/          # ACA Environment, ACR, Key Vault
    ├── identity/          # Managed Identity, RBAC
    ├── monitoring/        # Log Analytics, Application Insights
    └── workload/          # Next.js and .NET API Container Apps
```

## Components Deployed

- **VNet**: Single application VNet (10.0.0.0/16), no hub
- **Subnets**: Container Apps (10.0.0.0/22), Private Endpoints (10.0.4.0/26)
- **Container Apps Environment** with VNet integration (internal, workload-profile, Consumption)
- **Azure Container Registry** (Standard SKU, private access only, no admin user, AcrPull via MI)
- **Azure Key Vault** (private, RBAC, soft delete enabled, purge protection)
- **Managed Identity** (user-assigned) with RBAC: AcrPull, Key Vault Secrets User, Key Vault Keys User, Log Analytics Reader
- **API Management** (Developer SKU, internal VNet type, Private Endpoint, system-assigned MI)
- **Log Analytics** workspace (30 day retention)
- **Application Insights** with workspace-based metrics
- **Next.js Container App** (internal ingress, target_port=3000, scale-to-zero, concurrency scaling)
- **.NET API Container App** (internal ingress, target_port=8080, scale-to-zero, concurrency scaling)

## What is NOT Deployed

- Azure Front Door, WAF
- PostgreSQL, Redis (network is designed to be extensible for these)

## Usage

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
terraform init
terraform validate
terraform plan
```

## Security Posture

- Managed Identity only — no embedded credentials
- Key Vault public access disabled
- ACR admin user disabled
- RBAC for Key Vault (no access policies)
- HTTPS-only ingress for all Container Apps
- No secrets stored in Terraform code
