locals {
  deploymentsManifestFilename = abspath(pathexpand("./deployments.yml"))
}

resource "null_resource" "applyDeployments" {
  # Runs when the script file changed.
  triggers = {
    hash = "${filemd5(local.applyManifestScriptFilename)}|${filemd5(local.deploymentsManifestFilename)}"
  }

  provisioner "local-exec" {
    environment = {
      MANIFEST_FILENAME = local.deploymentsManifestFilename
      KUBECONFIG        = local_sensitive_file.kubeconfig.filename
    }

    quiet   = true
    command = local.applyManifestScriptFilename
  }

  depends_on = [
    linode_lke_cluster.default,
    local_sensitive_file.kubeconfig,
    null_resource.applyNamespaces,
    null_resource.applySecrets,
    null_resource.applyConfigMaps,
    null_resource.applyStorages
  ]
}