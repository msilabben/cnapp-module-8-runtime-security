subscription_id      = ""
resource_group_count = 1
location             = "swedencentral"
node_vm_size         = "Standard_D4d_v5"
node_count           = 1

# Suffixes: these become cnapp-1-rg, cnapp-2-rg, etc.
resource_group_name          = "rg"
log_analytics_workspace_name = "law"
monitor_workspace_name       = "amw"
basic_cluster_name           = "aks-basic"
advanced_cluster_name        = "aks-advanced"

# Storage: becomes cnapp1<suffix>, cnapp2<suffix>, ... Must be globally unique in Azure.
storage_account_name            = "falcovalues"
talon_logs_storage_account_name = "talonlogs"

# Shared registry module8registry.azurecr.io. Get the ID with:
# az acr show -n module8registry --query id -o tsv
acr_id = ""

# Owner tag on all resources
owner = "user@owner"
