# ---------------------------------------------------------------
# Basic cluster
# ---------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "basic" {
  name                = var.basic_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.basic_cluster_name

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    tags       = local.tags
  }

  identity {
    type = "SystemAssigned"
  }

  # --enable-blob-driver
  storage_profile {
    blob_driver_enabled = true
  }

  # Container Insights -> Log Analytics workspace
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.law.id
    msi_auth_for_monitoring_enabled = true
  }

  # Managed Prometheus -> Azure Monitor workspace
  monitor_metrics {}

  tags = local.tags
}

# ---------------------------------------------------------------
# Advanced cluster
# ---------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "advanced" {
  name                = var.advanced_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.advanced_cluster_name

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    tags       = local.tags
  }

  identity {
    type = "SystemAssigned"
  }

  # --enable-blob-driver
  storage_profile {
    blob_driver_enabled = true
  }

  network_profile {
    network_plugin      = "azure"   # --network-plugin azure
    network_plugin_mode = "overlay" # --network-plugin-mode overlay
    network_data_plane  = "cilium"  # --network-dataplane cilium
    network_policy      = "cilium"  # set automatically by the CLI with cilium; explicit here to avoid drift

    # --enable-acns
    advanced_networking {
      observability_enabled = true
      security_enabled      = true
    }
  }

  # Container Insights -> Log Analytics workspace
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.law.id
    msi_auth_for_monitoring_enabled = true
  }

  # Managed Prometheus -> Azure Monitor workspace
  monitor_metrics {}

  tags = local.tags
}

# --enable-azure-monitor-app-monitoring (preview, not in azurerm, so set via azapi)
resource "azapi_update_resource" "advanced_app_monitoring" {
  type        = "Microsoft.ContainerService/managedClusters@2026-08-02-preview"
  resource_id = azurerm_kubernetes_cluster.advanced.id

  body = {
    properties = {
      azureMonitorProfile = {
        appMonitoring = {
          autoInstrumentation = {
            enabled = true
          }
        }
      }
    }
  }
}
