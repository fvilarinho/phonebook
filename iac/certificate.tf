# Creates a TLS private key.
resource "tls_private_key" "phonebook" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
