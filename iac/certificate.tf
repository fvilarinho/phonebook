locals {
  generateCertificateAndCredentialsScriptFilename = abspath(pathexpand("../bin/tls/generateCertificateAndCredentials.sh"))
}

resource "null_resource" "generateCertificateAndCredentials" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      LINODE_TOKEN = var.credentials.token
    }

    quiet   = true
    command = local.generateCertificateAndCredentialsScriptFilename
  }
}