# Variables for Terraform configuration
# Defaults are set here; you can override via tfvars, environment variables, or variables.local.yaml (merged in locals)

variable "app_name" {
  description = "Short application name used for naming resources"
  type        = string
  default     = "paytrackr"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.app_name)) && length(var.app_name) >= 3 && length(var.app_name) <= 30
    error_message = "app_name must be 3-30 chars, lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the Azure resource group (derived from app_name if null)"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "cluster_name" {
  description = "Name of the AKS cluster (derived from app_name if null)"
  type        = string
  default     = null
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
  description = "PostgreSQL database name (derived from app_name if null)"
  type        = string
  default     = null
}

variable "docker_image" {
  description = "Docker image to deploy (format: registry/image:tag)"
  type        = string
  default     = "baltzar1994/paytrackr:latest"
}

variable "app_namespace" {
  description = "Kubernetes namespace for the application (derived from app_name if null)"
  type        = string
  default     = null
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