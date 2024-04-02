# Creates a TLS private key.
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creates a TLS self-signed certificate using the TLS private key.
resource "tls_self_signed_cert" "default" {
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  private_key_pem       = tls_private_key.default.private_key_pem
  validity_period_hours = 86400
  depends_on            = [ tls_private_key.default ]
}

# Saves the TLS private key file.
resource "local_sensitive_file" "privateKey" {
  filename        = var.privateKeyFilename
  file_permission = "600"
  content         = tls_private_key.default.private_key_openssh
  depends_on      = [ tls_private_key.default ]
}

resource "linode_sshkey" "default" {
  label      = local.settings.label
  ssh_key    = chomp(tls_private_key.default.public_key_openssh)
  depends_on = [ tls_private_key.default]
}