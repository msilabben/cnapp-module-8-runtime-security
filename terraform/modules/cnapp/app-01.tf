# Creates the app-01 namespace and applies the deployment file with kubectl.
# Re-runs when the cluster is replaced or deployment-app-01.yaml changes.
# The apply is skipped while the file is still the placeholder (no Kubernetes objects).

locals {
  app_01_script = <<-EOT
    set -euo pipefail
    KCFG=$(mktemp)
    trap 'rm -f "$KCFG"' EXIT
    printf '%s' "$KUBECONFIG_RAW" > "$KCFG"

    kubectl --kubeconfig "$KCFG" create namespace "$NS" --dry-run=client -o yaml \
      | kubectl --kubeconfig "$KCFG" apply -f -

    if grep -qE '^kind:' "$DEPLOYMENT_FILE"; then
      kubectl --kubeconfig "$KCFG" -n "$NS" apply -f "$DEPLOYMENT_FILE"
    else
      echo "No Kubernetes objects in $DEPLOYMENT_FILE yet, skipping apply."
    fi
  EOT
}

resource "terraform_data" "app_01_basic" {
  triggers_replace = [
    azurerm_kubernetes_cluster.basic.id,
    filemd5(var.app_deployment_file),
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG_RAW  = azurerm_kubernetes_cluster.basic.kube_config_raw
      DEPLOYMENT_FILE = var.app_deployment_file
      NS              = "app-01"
    }
    command = local.app_01_script
  }
}

resource "terraform_data" "app_01_advanced" {
  triggers_replace = [
    azurerm_kubernetes_cluster.advanced.id,
    filemd5(var.app_deployment_file),
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG_RAW  = azurerm_kubernetes_cluster.advanced.kube_config_raw
      DEPLOYMENT_FILE = var.app_deployment_file
      NS              = "app-01"
    }
    command = local.app_01_script
  }
}
