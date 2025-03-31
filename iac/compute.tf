resource "linode_instance" "default" {
  label           = var.settings.label
  tags            = var.settings.tags
  region          = var.settings.region
  type            = var.settings.type
  image           = "linode/debian12"
  backups_enabled = true
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
      "hostnamectl set-hostname ${var.settings.label}",
      "apt -y install curl wget unzip zip dnsutils net-tools htop",
      "curl https://get.docker.com | sh -",
    ]
  }

  depends_on = [ linode_sshkey.default ]
}