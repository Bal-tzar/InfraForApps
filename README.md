# InfraForApps: Reusable Azure Stack

Deploy PayTrackR (or any app) to Azure with a reusable Terraform setup. Change a couple variables and reuse for multiple projects.

## What This Does

This setup automatically creates:
- **Azure Kubernetes Cluster (AKS)** - Runs your app
- **Azure PostgreSQL Database** - Stores your data
- **Monitoring** - Prometheus + Grafana to track everything
- **LoadBalancer** - Makes your app accessible online

## Before You Start

You need:
1. `az` command (Azure CLI) - [Install here](https://docs.microsoft.com/cli/azure/install-azure-cli)
2. `kubectl` - [Install here](https://kubernetes.io/docs/tasks/tools/)
3. `terraform` - [Install here](https://www.terraform.io/downloads)
4. A Docker image (e.g., `baltzar1994/paytrackr:latest`)

## Quick Setup (Windows PowerShell)

### Step 1: Login to Azure

```powershell
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Step 2: Clone & Configure

```powershell
git clone https://github.com/Bal-tzar/InfraForApps.git
cd InfraForApps\InfraForApps\terraform

# Create project variables
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
notepad .\terraform.tfvars
```

Set at minimum:

```hcl
app_name                = "myapp"
location                = "westeurope"
environment             = "production"
docker_image            = "dockerhubuser/myapp:latest"
postgres_admin_username = "dbadmin"
postgres_admin_password = "REPLACE_ME"
```

### Step 3: Set Database Password

```bash
export TF_VAR_postgres_admin_password="YourSecurePassword123!"
```

### Step 4: Deploy Infrastructure

```powershell
terraform init
terraform plan
terraform apply
```

### Step 5: Deploy Your App

```powershell
# Get kubectl credentials (values come from outputs)
az aks get-credentials --resource-group <app_name>-rg --name <app_name>-aks

# Deploy to Kubernetes
kubectl apply -f ..\k8s\namespace.yaml
kubectl apply -f ..\k8s\secret.yaml
kubectl apply -f ..\k8s\configmap.yaml
kubectl apply -f ..\k8s\deployment.yaml
kubectl apply -f ..\k8s\service.yaml
```

## Check if It's Working

```bash
# See your pods
kubectl get pods -n your-namespace

# Get the website URL
kubectl get svc your-app-service -n your-namespace

# Look for the EXTERNAL-IP - that's your app URL!
```

Open in browser: `http://EXTERNAL-IP`

## Reuse Across Apps

- Change `app_name` (and image/credentials) in `terraform.tfvars` and re-run `terraform apply`.
- Resource names derive automatically:
  - Resource Group: `<app_name>-rg`
  - AKS: `<app_name>-aks`
  - VNet: `<app_name>-aks-vnet`
  - Postgres: `<app_name>-aks-postgres` + private DNS `<app_name>.postgres.database.azure.com`
  - Key Vault: `<app_name>-aks-kv`
- Optional overrides: you can explicitly set `resource_group_name`, `cluster_name`, `app_namespace`, `postgres_database_name` in `terraform.tfvars` if you prefer custom names.

### Manual Changes

If your app needs more resources, edit `k8s/deployment.yaml`:

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## Monitoring

### View Prometheus (Metrics)

```powershell
kubectl port-forward -n your-namespace svc/prometheus-service 9090:9090
# Open http://localhost:9090
```

### View Grafana (Dashboards)

```powershell
kubectl port-forward -n your-namespace svc/grafana-service 3000:3000
# Open http://localhost:3000
# Login: admin / admin
```

## Troubleshooting

### Pods Not Running?

```bash
# Check pod status
kubectl describe pod -n your-namespace -l app=your-app

# Check logs
kubectl logs -n your-namespace deployment/your-app
```

### Can't Connect to Database?

```bash
# Check if secret is correct
kubectl get secret -n your-namespace your-app-secrets -o yaml

# Test connection
kubectl run -n your-namespace test-db --image=postgres:15-alpine -it -- \
  psql -h paytrackr-db.postgres.database.azure.com \
  -U your-username -d your-directory
```

### Terraform Tips

```powershell
terraform validate
terraform plan
```


## Common Tasks

### Update Your App

```bash
# Push new image to Docker Hub
docker push myregistry/my-app:v2.0.0

# Update K8s
kubectl set image deployment/your-app \
  paytrackr=myregistry/my-app:v2.0.0 \
  -n your-namespace
```

### Scale Up/Down

```bash
# More replicas
kubectl scale deployment your-app -n your-namespace --replicas=5

# Fewer replicas
kubectl scale deployment your-app -n your-namespace --replicas=1
```

### Check Costs

```bash
az vm list-usage --output table
az postgresql server show --resource-group your-rg --name your-db
```

### Delete Everything (Stop Charges)

```powershell
cd .\terraform
terraform destroy
```

## Reuse Across Apps (Simplest)

If you want to reuse the same Terraform for different projects by only changing a couple of values, use `terraform.tfvars` with the new `app_name`:

1) Copy the example and edit values

```powershell
Copy-Item .\terraform\terraform.tfvars.example .\terraform\terraform.tfvars
notepad .\terraform\terraform.tfvars
```

Suggested minimal values:

```hcl
app_name                = "myapp"
location                = "westeurope"
environment             = "production"
docker_image            = "dockerhubuser/myapp:latest"
postgres_admin_username = "dbadmin"
postgres_admin_password = "REPLACE_ME"
```

2) Apply with Terraform

```powershell
cd .\terraform
terraform init
terraform plan
terraform apply
```

Notes:
- Resource names (resource group, AKS, Key Vault, DB name) derive from `app_name` unless you override them.
- You can still override `resource_group_name`, `cluster_name`, `app_namespace`, or `postgres_database_name` in `terraform.tfvars` if needed.
- On Windows PowerShell, to set an environment variable directly use: `$env:TF_VAR_postgres_admin_password = "YourSecurePassword123!"`

## What Terraform Creates

- Azure Resource Group, VNet, and subnets (AKS + Postgres).
- AKS cluster with a system-assigned identity.
- Azure PostgreSQL Flexible Server (private, VNet-integrated) and one database named from `app_name`.
- Private DNS zone for Postgres: `<app_name>.postgres.database.azure.com` + VNet link.
- Azure Key Vault storing `postgres-connection-string`.

## File Structure

```
.
├── variables.yaml                  # Default config
├── variables.local.yaml            # Your custom config (ignored by git)
├── terraform/                      # Infrastructure code
│   ├── terraform.tf
│   ├── variables.tf
│   ├── resource.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── k8s/                            # Kubernetes files
    ├── namespace.yaml
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    ├── secret.yaml
    └── monitoring/
        ├── prometheus-deployment.yaml
        └── grafana-deployment.yaml
```

## Security Tips

1. **Never commit passwords** - Use environment variables only
2. **Keep `variables.local.yaml` local** - It's in `.gitignore` for a reason
3. **Rotate passwords regularly**:

```bash
# Generate new password
openssl rand -base64 32

# Update in Azure
az postgres server update \
  --resource-group your-rg \
  --name your-db \
  --admin-user-password "new-password"
```

4. **Use different subscriptions for different environments** (dev, staging, prod)

## Need Help?

1. Check logs: `kubectl logs -n paytrackr deployment/your-app-name`
2. Check pod details: `kubectl describe pod -n your-namespace <pod-name>`
3. Read [Kubernetes Docs](https://kubernetes.io/docs)
4. Read [Azure Docs](https://docs.microsoft.com/azure)

---

**Last Updated:** December 9, 2025