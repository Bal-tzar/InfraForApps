# PayTrackR Infrastructure as Code

Deploy PayTrackR (or any app) to Azure with Kubernetes in minutes.

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

## Quick Setup (5 Steps)

### Step 1: Login to Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Step 2: Clone & Configure

```bash
git clone https://github.com/Bal-tzar/InfraForApps.git
cd InfraForApps

# Copy example config
cp variables.local.yaml.example variables.local.yaml

# Edit with your app details
nano variables.local.yaml
```

Change these in `variables.local.yaml`:

```yaml
app:
  name: "your-app"              # Your app name
  docker_image: "your-image"      # Your Docker image
  docker_tag: "latest"           # Docker image tag

azure:
  resource_group: "your-rg" # Unique name
  region: "westeurope"           # Your region

kubernetes:
  namespace: "your-namespace"         # K8s namespace
```

### Step 3: Set Database Password

```bash
export TF_VAR_postgres_admin_password="YourSecurePassword123!"
```

### Step 4: Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

Type `yes` when asked.

### Step 5: Deploy Your App

```bash
# Get kubectl credentials
az aks get-credentials \
  --resource-group your-rg \
  --name your-app-aks

# Deploy to Kubernetes
kubectl apply -f ../k8s/namespace.yaml
kubectl apply -f ../k8s/secret.yaml
kubectl apply -f ../k8s/configmap.yaml
kubectl apply -f ../k8s/deployment.yaml
kubectl apply -f ../k8s/service.yaml
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

## Using for a Different App

### Use Variables File

```bash
cp variables.local.yaml.example variables.local.yaml
```

Edit `variables.local.yaml` with your app info:

```yaml
app:
  name: "my-app"
  docker_registry: "myregistry"
  docker_image: "my-app"
  docker_tag: "v1.0.0"
  port: 5000                    # Change if needed

kubernetes:
  namespace: "my-app"
  app_replicas: 3
```

Then re-deploy:

```bash
cd terraform
terraform apply
```

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

```bash
kubectl port-forward -n your-namespace svc/prometheus-service 9090:9090
# Open http://localhost:9090
```

### View Grafana (Dashboards)

```bash
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

### Terraform Errors?

```bash
# Validate
terraform validate

# Try again with debug info
TF_LOG=DEBUG terraform apply
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

```bash
cd terraform
terraform destroy
```

Type `yes` to confirm.

## File Structure

```
.
├── variables.yaml                  # Default config
├── variables.local.yaml            # Your custom config (ignored by git)
├── terraform/                      # Infrastructure code
│   ├── terraform.tf
│   ├── variables.tf
│   └── resource.tf
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

## What Gets Created

| Resource | Cost | Notes |
|----------|------|-------|
| AKS Cluster | ~$70/month | 3 nodes, autoscaling |
| PostgreSQL | ~$40/month | 32GB storage |
| Storage | ~$5/month | Logs, monitoring |
| **Total** | **~$115/month** | Can be reduced |

## License



---

**Last Updated:** December 2, 2025