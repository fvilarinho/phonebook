locals {
  applyManifestScriptFilename = abspath(pathexpand("./applyManifest.sh"))
}

resource "linode_lke_cluster" "default" {
  k8s_version = "1.31"
  label       = var.appName
  region      = var.settings.region

  pool {
    type  = var.settings.nodes.type
    count = var.settings.nodes.count
  }

  control_plane {
    high_availability = true
  }
}

resource "local_sensitive_file" "kubeconfig" {
  filename        = abspath(abspath("./.kubeconfig"))
  content_base64  = linode_lke_cluster.default.kubeconfig
  file_permission = "0600"

  depends_on = [ linode_lke_cluster.default ]
}