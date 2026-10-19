# ---------------------------------------------------------------
# Workspaces
# ---------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

resource "azurerm_monitor_workspace" "amw" {
  name                = var.monitor_workspace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.tags
}

# ---------------------------------------------------------------
# Container Insights (logs -> Log Analytics workspace)
# ---------------------------------------------------------------
resource "azurerm_monitor_data_collection_rule" "container_insights" {
  name                = "MSCI-${var.location}-${var.resource_group_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "ciworkspace"
    }
  }

  data_flow {
    streams      = ["Microsoft-ContainerInsights-Group-Default"]
    destinations = ["ciworkspace"]
  }

  data_sources {
    extension {
      streams        = ["Microsoft-ContainerInsights-Group-Default"]
      extension_name = "ContainerInsights"
      extension_json = jsonencode({
        dataCollectionSettings = {
          interval               = "1m"
          namespaceFilteringMode = "Off"
          enableContainerLogV2   = true
        }
      })
      name = "ContainerInsightsExtension"
    }
  }

  tags = local.tags
}

# ---------------------------------------------------------------
# Managed Prometheus (metrics -> Azure Monitor workspace)
# ---------------------------------------------------------------
resource "azurerm_monitor_data_collection_endpoint" "prometheus" {
  name                = "MSProm-${var.location}-${var.resource_group_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"

  tags = local.tags
}

resource "azurerm_monitor_data_collection_rule" "prometheus" {
  name                        = "MSProm-${var.location}-${var.resource_group_name}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.prometheus.id
  kind                        = "Linux"

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.amw.id
      name               = "MonitoringAccount1"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount1"]
  }

  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }

  tags = local.tags
}

# ---------------------------------------------------------------
# Associations: connect both clusters to both rules
# ---------------------------------------------------------------
resource "azurerm_monitor_data_collection_rule_association" "basic_ci" {
  name                    = "ContainerInsightsExtension"
  target_resource_id      = azurerm_kubernetes_cluster.basic.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.container_insights.id
}

resource "azurerm_monitor_data_collection_rule_association" "basic_prom" {
  name                    = "MSProm-${var.basic_cluster_name}"
  target_resource_id      = azurerm_kubernetes_cluster.basic.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus.id
}

resource "azurerm_monitor_data_collection_rule_association" "advanced_ci" {
  name                    = "ContainerInsightsExtension"
  target_resource_id      = azurerm_kubernetes_cluster.advanced.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.container_insights.id
}

resource "azurerm_monitor_data_collection_rule_association" "advanced_prom" {
  name                    = "MSProm-${var.advanced_cluster_name}"
  target_resource_id      = azurerm_kubernetes_cluster.advanced.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus.id
}
