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

# Definition of the initial password for the compute instance.
resource "random_password" "default" {
  length = 15
}