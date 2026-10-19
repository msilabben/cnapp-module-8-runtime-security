variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_count" {
  description = "How many identical resource groups (cnapp-1 ... cnapp-N) to create"
  type        = number
  default     = 1
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

# The names below are suffixes. Each gets the prefix "cnapp-<number>-",
# e.g. resource_group_name = "rg" becomes "cnapp-1-rg", "cnapp-2-rg", ...

variable "resource_group_name" {
  description = "Resource group name suffix"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name suffix"
  type        = string
}

variable "monitor_workspace_name" {
  description = "Azure Monitor workspace name suffix"
  type        = string
}

variable "basic_cluster_name" {
  description = "Basic AKS cluster name suffix"
  type        = string
}

variable "advanced_cluster_name" {
  description = "Advanced AKS cluster name suffix"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "storage_account_name" {
  description = "Storage account name suffix. Becomes cnapp<number><suffix> (no hyphens allowed, max 24 chars total)"
  type        = string
}

variable "file_share_name" {
  description = "File share name (same in every storage account)"
  type        = string
  default     = "falco"
}

variable "talon_logs_storage_account_name" {
  description = "Talon log storage account name suffix. Becomes cnapp<number><suffix> (no hyphens allowed, max 24 chars total)"
  type        = string
}

variable "acr_id" {
  description = "Resource ID of the shared container registry (az acr show -n <name> --query id -o tsv)"
  type        = string
}

variable "owner" {
  description = "Value of the owner tag on all resources"
  type        = string
}
