# Creates the key pair used for the remote access.
resource "aws_key_pair" "phonebook" {
  public_key = tls_private_key.phonebook.public_key_openssh

  depends_on = [ tls_private_key.phonebook ]
}

# Saves the key pair.
resource "local_file" "phonebook_private_key" {
  content         = tls_private_key.phonebook.private_key_pem
  filename        = abspath("../etc/keypair.pem")
  file_permission = "0400"

  depends_on = [ tls_private_key.phonebook ]
}