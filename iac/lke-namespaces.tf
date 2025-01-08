locals {
  namespacesManifestFilename = "./namespaces.yml"
}

resource "null_resource" "applyNamespaces" {
  # Runs when the script file changed.
  triggers = {
    hash = "${filemd5(local.applyManifestScriptFilename)}|${filemd5(local.namespacesManifestFilename)}"
  }

  provisioner "local-exec" {
    environment = {
      MANIFEST_FILENAME = local.namespacesManifestFilename
      KUBECONFIG        = local_sensitive_file.kubeconfig.filename
    }

    quiet   = true
    command = local.applyManifestScriptFilename
  }

  depends_on = [
    linode_lke_cluster.default,
    local_sensitive_file.kubeconfig
  ]
}