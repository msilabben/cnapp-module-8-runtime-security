module "cnapp" {
  source = "./modules/cnapp"
  count  = var.resource_group_count

  location                        = var.location
  resource_group_name             = "cnapp-${count.index + 1}-${var.resource_group_name}"
  log_analytics_workspace_name    = "cnapp-${count.index + 1}-${var.log_analytics_workspace_name}"
  monitor_workspace_name          = "cnapp-${count.index + 1}-${var.monitor_workspace_name}"
  basic_cluster_name              = "cnapp-${count.index + 1}-${var.basic_cluster_name}"
  advanced_cluster_name           = "cnapp-${count.index + 1}-${var.advanced_cluster_name}"
  node_count                      = var.node_count
  node_vm_size                    = var.node_vm_size
  falco_rules_file                = abspath("${path.root}/rules-falco.yaml")
  falco_talon_rules_file          = abspath("${path.root}/rules-falco-talon.yaml")
  app_deployment_file             = abspath("${path.root}/deployment-app-01.yaml")
  storage_account_name            = "cnapp${count.index + 1}${var.storage_account_name}"
  file_share_name                 = var.file_share_name
  talon_logs_storage_account_name = "cnapp${count.index + 1}${var.talon_logs_storage_account_name}"
  acr_id                          = var.acr_id
  owner                           = var.owner
}
