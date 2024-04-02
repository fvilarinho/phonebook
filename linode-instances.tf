locals {
  settings = jsondecode(chomp(file(pathexpand(var.settingsFilename))))
}

# Creates the manager instance of the swarm.
resource "linode_instance" "default" {
  label           = local.settings.label
  tags            = local.settings.tags
  type            = local.settings.type
  image           = local.settings.image
  region          = local.settings.region
  private_ip      = true
  authorized_keys = [ chomp(tls_private_key.default.public_key_openssh) ]

  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    # Installs the required software and initialize the swarm.
    inline = [
      "hostnamectl set-hostname ${self.label}",
      "export DEBIAN_FRONTEND=noninteractive",
      "apt update",
      "apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim",
      "curl https://get.docker.com | sh -",
      "systemctl enable docker",
      "systemctl start docker"
    ]
  }

  depends_on = [ tls_private_key.default ]
}