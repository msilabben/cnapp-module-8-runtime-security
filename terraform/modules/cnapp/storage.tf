resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

resource "azurerm_storage_share" "share" {
  name               = var.file_share_name
  storage_account_id = azurerm_storage_account.sa.id
  quota              = 5 # GB
}

# Uploads the local rules-falco.yaml. A change to the local file re-uploads it
# and overwrites whatever is in the share.
resource "azurerm_storage_share_file" "falco_rules" {
  name              = "rules-falco.yaml"
  storage_share_url = azurerm_storage_share.share.url
  source            = var.falco_rules_file
  content_md5       = filemd5(var.falco_rules_file)
}

# Uploads the local rules-falco-talon.yaml. A change to the local file re-uploads it
# and overwrites whatever is in the share.
resource "azurerm_storage_share_file" "falco_talon_rules" {
  name              = "rules-falco-talon.yaml"
  storage_share_url = azurerm_storage_share.share.url
  source            = var.falco_talon_rules_file
  content_md5       = filemd5(var.falco_talon_rules_file)
}

# Uploads the local deployment-app-01.yaml. A change to the local file re-uploads it
# and overwrites whatever is in the share.
resource "azurerm_storage_share_file" "app_01_deployment" {
  name              = "deployment-app-01.yaml"
  storage_share_url = azurerm_storage_share.share.url
  source            = var.app_deployment_file
  content_md5       = filemd5(var.app_deployment_file)
}
