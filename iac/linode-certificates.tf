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

# Create the TLS certificate key file.
resource "local_sensitive_file" "certificateKey" {
  filename   = var.certificateKeyFilename
  content    = tls_private_key.default.private_key_pem
  depends_on = [ tls_private_key.default]
}

# Create the TLS certificate file.
resource "local_sensitive_file" "certificate" {
  filename   = var.certificateFilename
  content    = tls_self_signed_cert.default.cert_pem
  depends_on = [ tls_self_signed_cert.default ]
}