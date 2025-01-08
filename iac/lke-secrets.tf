locals {
  applySecretsScriptFilename = abspath(pathexpand("./applySecrets.sh"))
}

resource "null_resource" "applySecrets" {
  # Runs when the script file changed.
  triggers = {
    hash = filemd5(local.applySecretsScriptFilename)
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = local_sensitive_file.kubeconfig.filename
    }

    quiet   = true
    command = local.applySecretsScriptFilename
  }

  depends_on = [
    linode_lke_cluster.default,
    local_sensitive_file.kubeconfig,
    null_resource.applyNamespaces
  ]
}