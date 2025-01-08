locals {
  fetchIngressScriptFilename = abspath(pathexpand("./fetchIngress.sh"))
}

data "external" "ingress" {
  program = [
    local.fetchIngressScriptFilename,
    local_sensitive_file.kubeconfig.filename
  ]

  depends_on = [
    linode_lke_cluster.default,
    local_sensitive_file.kubeconfig,
    null_resource.applyDeployments,
    null_resource.applyServices,
    null_resource.applyStorages,
    null_resource.applySecrets,
    null_resource.applyConfigMaps,
    null_resource.applyNamespaces
  ]
}

data "linode_domain" "default" {
  domain = var.appDomain
}

resource "linode_domain_record" "default" {
  domain_id   = data.linode_domain.default.id
  name        = "${var.appName}.${var.appDomain}"
  record_type = "A"
  target      = data.external.ingress.result.ip
  ttl_sec     = 30

  depends_on = [
    data.linode_domain.default,
    data.external.ingress,
    linode_lke_cluster.default,
    null_resource.applyDeployments,
    null_resource.applyServices,
    null_resource.applyStorages,
    null_resource.applySecrets,
    null_resource.applyConfigMaps,
    null_resource.applyNamespaces
  ]
}