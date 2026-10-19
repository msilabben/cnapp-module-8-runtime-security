# ---------------------------------------------------------------
# Storage account and one container per cluster
# ---------------------------------------------------------------
resource "azurerm_storage_account" "talon_logs" {
  name                            = var.talon_logs_storage_account_name
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = local.tags
}

resource "azurerm_storage_container" "talon_logs_basic" {
  name               = var.basic_cluster_name
  storage_account_id = azurerm_storage_account.talon_logs.id
}

resource "azurerm_storage_container" "talon_logs_advanced" {
  name               = var.advanced_cluster_name
  storage_account_id = azurerm_storage_account.talon_logs.id
}

# ---------------------------------------------------------------
# RBAC: kubelet identity of each cluster -> Storage Blob Data Contributor
# ---------------------------------------------------------------
resource "azurerm_role_assignment" "talon_logs_basic" {
  scope                            = azurerm_storage_account.talon_logs.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azurerm_kubernetes_cluster.basic.kubelet_identity[0].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "talon_logs_advanced" {
  scope                            = azurerm_storage_account.talon_logs.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azurerm_kubernetes_cluster.advanced.kubelet_identity[0].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

# ---------------------------------------------------------------
# PV + PVC, and mount into the falco-talon deployment
# Runs with kubectl on the machine running Terraform.
# Re-runs when the cluster, container or Talon install changes.
# The patch is skipped if the volume is already mounted.
# ---------------------------------------------------------------
locals {
  talon_logs_script = <<-EOT
    set -euo pipefail
    KCFG=$(mktemp)
    trap 'rm -f "$KCFG"' EXIT
    printf '%s' "$KUBECONFIG_RAW" > "$KCFG"

    kubectl --kubeconfig "$KCFG" apply -f - <<EOF
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-talon-blob
      annotations:
        pv.kubernetes.io/provisioned-by: blob.csi.azure.com
    spec:
      capacity:
        storage: 10Gi
      accessModes:
        - ReadWriteMany
      persistentVolumeReclaimPolicy: Retain
      storageClassName: azureblob-fuse-premium
      mountOptions:
        - -o allow_other
        - --file-cache-timeout-in-seconds=120
      csi:
        driver: blob.csi.azure.com
        volumeHandle: $SA_RG#$SA#$CONTAINER
        volumeAttributes:
          resourceGroup: $SA_RG
          storageAccount: $SA
          containerName: $CONTAINER
          AzureStorageAuthType: MSI
          AzureStorageIdentityClientID: $KUBELET_CLIENT_ID
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: talon-blob-output
      namespace: $NS
    spec:
      accessModes:
        - ReadWriteMany
      storageClassName: azureblob-fuse-premium
      volumeName: pv-talon-blob
      resources:
        requests:
          storage: 10Gi
    EOF

    if ! kubectl --kubeconfig "$KCFG" -n "$NS" get deployment falco-talon \
         -o jsonpath='{.spec.template.spec.volumes[*].name}' | grep -qw blob-output; then
      kubectl --kubeconfig "$KCFG" -n "$NS" patch deployment falco-talon --type=json -p='[
        {"op":"add","path":"/spec/template/spec/volumes/-","value":
          {"name":"blob-output","persistentVolumeClaim":{"claimName":"talon-blob-output"}}},
        {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts/-","value":
          {"name":"blob-output","mountPath":"/var/talon-output"}}
      ]'
    fi

    kubectl --kubeconfig "$KCFG" -n "$NS" rollout status deployment/falco-talon --timeout=5m
  EOT
}

resource "terraform_data" "talon_logs_basic" {
  triggers_replace = [
    azurerm_kubernetes_cluster.basic.id,
    azurerm_storage_container.talon_logs_basic.id,
    terraform_data.falco_talon_basic.id,
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG_RAW    = azurerm_kubernetes_cluster.basic.kube_config_raw
      SA_RG             = azurerm_resource_group.rg.name
      SA                = azurerm_storage_account.talon_logs.name
      CONTAINER         = azurerm_storage_container.talon_logs_basic.name
      KUBELET_CLIENT_ID = azurerm_kubernetes_cluster.basic.kubelet_identity[0].client_id
      NS                = "falco"
    }
    command = local.talon_logs_script
  }

  depends_on = [azurerm_role_assignment.talon_logs_basic]
}

resource "terraform_data" "talon_logs_advanced" {
  triggers_replace = [
    azurerm_kubernetes_cluster.advanced.id,
    azurerm_storage_container.talon_logs_advanced.id,
    terraform_data.falco_talon_advanced.id,
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG_RAW    = azurerm_kubernetes_cluster.advanced.kube_config_raw
      SA_RG             = azurerm_resource_group.rg.name
      SA                = azurerm_storage_account.talon_logs.name
      CONTAINER         = azurerm_storage_container.talon_logs_advanced.name
      KUBELET_CLIENT_ID = azurerm_kubernetes_cluster.advanced.kubelet_identity[0].client_id
      NS                = "falco"
    }
    command = local.talon_logs_script
  }

  depends_on = [azurerm_role_assignment.talon_logs_advanced]
}
