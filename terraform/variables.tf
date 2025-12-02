# Variables for Terraform configuration
# Defaults are set from variables.yaml, can be overridden via variables.local.yaml or environment variables

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "paytrackr-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "paytrackr-aks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.33"
}

variable "node_count" {
  description = "Initial number of nodes in AKS cluster"
  type        = number
  default     = 3
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "postgres_admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "otto"
  sensitive   = true
}

variable "postgres_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true


}

variable "postgres_database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "paytrackr"
}

variable "docker_image" {
  description = "Docker image to deploy (format: registry/image:tag)"
  type        = string
  default     = "baltzar1994/paytrackr:latest"
}

variable "app_namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "paytrackr"
}

variable "app_replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 2
}

variable "postgres_sku" {
  description = "Azure PostgreSQL SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_gb" {
  description = "PostgreSQL storage in GB"
  type        = number
  default     = 32
}

variable "environment" {
  description = "Environment name (production, staging, development)"
  type        = string
  default     = "production"
}