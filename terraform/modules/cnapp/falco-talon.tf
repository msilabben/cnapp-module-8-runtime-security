# Falco Talon is installed the same way as Falco: helm CLI, temporary kubeconfig.
# The rules file is passed to the chart's rulesOverride value.
# Helm re-runs when the cluster is replaced or rules-falco-talon.yaml changes.

resource "terraform_data" "falco_talon_basic" {
  triggers_replace = [
    azurerm_kubernetes_cluster.basic.id,
    filemd5(var.falco_talon_rules_file),
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG_RAW = azurerm_kubernetes_cluster.basic.kube_config_raw
      RULES_FILE     = var.falco_talon_rules_file
    }
    command = <<-EOT
      set -euo pipefail
      KCFG=$(mktemp)
      trap 'rm -f "$KCFG"' EXIT
      printf '%s' "$KUBECONFIG_RAW" > "$KCFG"
      helm upgrade --install falco-talon falco-talon \
        --repo https://falcosecurity.github.io/charts \
        --namespace falco --create-namespace \
        --kubeconfig "$KCFG" \
        --set-file rulesOverride="$RULES_FILE"
    EOT
  }

  depends_on = [terraform_data.falco_basic]
}

resource "terraform_data" "falco_talon_advanced" {
  triggers_replace = [
    azurerm_kubernetes_cluster.advanced.id,
    filemd5(var.falco_talon_rules_file),
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG_RAW = azurerm_kubernetes_cluster.advanced.kube_config_raw
      RULES_FILE     = var.falco_talon_rules_file
    }
    command = <<-EOT
      set -euo pipefail
      KCFG=$(mktemp)
      trap 'rm -f "$KCFG"' EXIT
      printf '%s' "$KUBECONFIG_RAW" > "$KCFG"
      helm upgrade --install falco-talon falco-talon \
        --repo https://falcosecurity.github.io/charts \
        --namespace falco --create-namespace \
        --kubeconfig "$KCFG" \
        --set-file rulesOverride="$RULES_FILE"
    EOT
  }

  depends_on = [terraform_data.falco_advanced]
}
