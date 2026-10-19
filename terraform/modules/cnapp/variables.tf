variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "monitor_workspace_name" {
  description = "Name of the Azure Monitor workspace (Managed Prometheus)"
  type        = string
}

variable "basic_cluster_name" {
  description = "Name of the basic AKS cluster"
  type        = string
}

variable "advanced_cluster_name" {
  description = "Name of the advanced AKS cluster"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
}

variable "node_vm_size" {
  description = "VM size for the default node pool"
  type        = string
}

variable "falco_rules_file" {
  description = "Absolute path to the Falco rules file"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name (3-24 lowercase letters/numbers, globally unique)"
  type        = string
}

variable "file_share_name" {
  description = "Name of the file share in the storage account"
  type        = string
}

variable "falco_talon_rules_file" {
  description = "Absolute path to the Falco Talon rules file"
  type        = string
}

variable "talon_logs_storage_account_name" {
  description = "Storage account name for Talon pod log export (3-24 lowercase letters/numbers, globally unique)"
  type        = string
}

variable "app_deployment_file" {
  description = "Absolute path to the app-01 deployment file"
  type        = string
}

variable "acr_id" {
  description = "Resource ID of the shared container registry"
  type        = string
}

variable "owner" {
  description = "Value of the owner tag on all resources"
  type        = string
}
