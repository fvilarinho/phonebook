locals {
  servicesManifestFilename = abspath(pathexpand("./services.yml"))
}

resource "null_resource" "applyServices" {
  # Runs when the script file changed.
  triggers = {
    hash = "${filemd5(local.applyManifestScriptFilename)}|${filemd5(local.servicesManifestFilename)}"
  }

  provisioner "local-exec" {
    environment = {
      MANIFEST_FILENAME = local.servicesManifestFilename
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