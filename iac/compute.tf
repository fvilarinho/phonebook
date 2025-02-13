locals {
  definitions = jsondecode(file(abspath(pathexpand("../etc/definitions.json"))))
}

resource "linode_instance" "default" {
  label           = local.definitions.label
  tags            = local.definitions.tags
  region          = local.definitions.region
  type            = local.definitions.type
  image           = "linode/debian12"
  private_ip      = true
  authorized_keys = [ linode_sshkey.default.ssh_key ]

  # Installs the required software.
  provisioner "remote-exec" {
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    inline = [
      "apt update",
      "apt -y upgrade",
      "hostnamectl set-hostname ${local.definitions.label}",
      "apt -y install curl wget unzip zip dnsutils net-tools htop",
      "curl https://get.docker.com | sh -",
    ]
  }

  depends_on = [ linode_sshkey.default ]
}