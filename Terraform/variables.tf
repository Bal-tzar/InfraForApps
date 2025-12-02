variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "paytrackr-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "paytrackr-aks"
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 3
}

variable "node_vm_size" {
  description = "Size of the VMs"
  type        = string
  default     = "Standard_B2s"
}

variable "postgres_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "paytrackradmin"
}

variable "postgres_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "postgres_database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "paytrackr"
}

variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
  default     = "baltzar1994/paytracker:latest"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.33"
}