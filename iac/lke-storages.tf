locals {
  storagesManifestFilename = abspath(pathexpand("./storages.yml"))
}

resource "null_resource" "applyStorages" {
  # Runs when the script file changed.
  triggers = {
    hash = "${filemd5(local.applyManifestScriptFilename)}|${filemd5(local.storagesManifestFilename)}"
  }

  provisioner "local-exec" {
    environment = {
      MANIFEST_FILENAME = local.storagesManifestFilename
      KUBECONFIG        = local_sensitive_file.kubeconfig.filename
    }

    quiet   = true
    command = local.applyManifestScriptFilename
  }

  depends_on = [
    linode_lke_cluster.default,
    local_sensitive_file.kubeconfig,
    null_resource.applyNamespaces
  ]
}