# Required variables.
locals {
  sshPrivateKeyFilename = abspath(pathexpand("~/.ssh/id_rsa"))
  sshPublicKeyFilename  = abspath(pathexpand("~/.ssh/id_rsa.pub"))
}

# Creates the SSH public key.
resource "linode_sshkey" "default" {
  label   = local.definitions.label
  ssh_key = chomp(file(local.sshPublicKeyFilename))
}