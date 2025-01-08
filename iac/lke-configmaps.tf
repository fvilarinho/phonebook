locals {
  applyConfigMapsScriptFilename = abspath(pathexpand("./applyConfigMaps.sh"))
}

resource "null_resource" "applyConfigMaps" {
  # Runs when the script file changed.
  triggers = {
    hash = filemd5(local.applyConfigMapsScriptFilename)
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = local_sensitive_file.kubeconfig.filename
    }

    quiet   = true
    command = local.applyConfigMapsScriptFilename
  }

  depends_on = [
    linode_lke_cluster.default,
    local_sensitive_file.kubeconfig,
    null_resource.generateCertificateAndCredentials,
    null_resource.applyNamespaces
  ]
}