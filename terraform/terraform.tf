terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

# Load centralized variables
locals {
  config = yamldecode(file("${path.module}/../variables.yaml"))
  local_config = try(yamldecode(file("${path.module}/../variables.local.yaml")), {})
  
  # Merge local config with defaults (local overrides defaults)
  merged_config = merge(local.config, local.local_config)

  # Naming derived from a single app_name for reuse across projects
  name_prefix = var.app_name
  effective_resource_group_name     = coalesce(var.resource_group_name, "${local.name_prefix}-rg")
  effective_cluster_name            = coalesce(var.cluster_name,        "${local.name_prefix}-aks")
  effective_app_namespace           = coalesce(var.app_namespace,       local.name_prefix)
  effective_postgres_database_name  = coalesce(var.postgres_database_name, local.name_prefix)

  # Common tags merged with any YAML-provided tags (use lowercase keys to avoid Azure case-insensitive duplicates)
  tags = merge(
    try(local.merged_config.tags, {}),
    {
      project     = local.name_prefix
      environment = var.environment
    }
  )

  # Postgres private DNS zone name (kept consistent with prior convention)
  postgres_private_dns_zone = "${local.name_prefix}.postgres.database.azure.com"
}