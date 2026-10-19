# Falco is installed with the helm CLI on the machine running Terraform.
# The cluster's kubeconfig is written to a temporary file, used, and deleted.
# Helm re-runs when the cluster is replaced or rules-falco.yaml changes.
#
# Settings passed to the chart:
# - Your rules file is loaded as an extra rules file (customRules).
# - Falco sends its events as JSON over HTTP to Falco Talon.
# The rules file is skipped while it is still the placeholder (only comments).

locals {
  falco_script = <<-EOT
    set -euo pipefail
    KCFG=$(mktemp)
    trap 'rm -f "$KCFG"' EXIT
    printf '%s' "$KUBECONFIG_RAW" > "$KCFG"

    RULES_ARGS=()
    if grep -qvE '^[[:space:]]*(#|$)' "$RULES_FILE"; then
      RULES_ARGS=(--set-file "customRules.rules-custom\.yaml=$RULES_FILE")
    else
      echo "No rules in $RULES_FILE yet, installing Falco without custom rules."
    fi

    helm upgrade --install falco falco \
      --repo https://falcosecurity.github.io/charts \
      --namespace falco --create-namespace \
      --kubeconfig "$KCFG" \
      --set falco.json_output=true \
      --set falco.http_output.enabled=true \
      --set falco.http_output.url=http://falco-talon:2803 \
      $${RULES_ARGS[@]+"$${RULES_ARGS[@]}"} # safe with an empty array on older bash (macOS)
  EOT
}

resource "terraform_data" "falco_basic" {
  triggers_replace = [
    azurerm_kubernetes_cluster.basic.id,
    filemd5(var.falco_rules_file),
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG_RAW = azurerm_kubernetes_cluster.basic.kube_config_raw
      RULES_FILE     = var.falco_rules_file
    }
    command = local.falco_script
  }
}

resource "terraform_data" "falco_advanced" {
  triggers_replace = [
    azurerm_kubernetes_cluster.advanced.id,
    filemd5(var.falco_rules_file),
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG_RAW = azurerm_kubernetes_cluster.advanced.kube_config_raw
      RULES_FILE     = var.falco_rules_file
    }
    command = local.falco_script
  }
}
