locals {
  generateCertificateAndCredentialsScriptFilename = abspath(pathexpand("./generateCertificateAndCredentials.sh"))
}

resource "null_resource" "generateCertificateAndCredentials" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    quiet   = true
    command = local.generateCertificateAndCredentialsScriptFilename
  }
}