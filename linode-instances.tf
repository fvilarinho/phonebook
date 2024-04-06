# Local variables definition.
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
      "systemctl start docker",
      "mkdir -p /root/etc",
    ]
  }

  # Copies the stack definition file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    source      = "docker-compose.yml"
    destination = "/root/docker-compose.yml"
  }

  # Copies the certificate files.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    source      = "etc/cert.pem"
    destination = "/root/etc/cert.pem"
  }

  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    source      = "etc/cert.key"
    destination = "/root/etc/cert.key"
  }

  # Copies the frontend configuration file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    source      = "etc/frontend.conf"
    destination = "/root/etc/frontend.conf"
  }

  # Copies the metrics server configuration file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    source      = "etc/prometheus.yml"
    destination = "/root/etc/prometheus.yml"
  }

  # Copies the environment definition file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    source      = ".env"
    destination = "/root/.env"
  }

  # Copies the start script file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    source      = "start.sh"
    destination = "/root/start.sh"
  }

  # Copies the stop script file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    source      = "stop.sh"
    destination = "/root/stop.sh"
  }

  # Starts the stack.
  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(tls_private_key.default.private_key_openssh)
    }

    # Installs the required software and initialize the swarm.
    inline = [
      "chmod +x /root/*.sh",
      "./start.sh"
    ]
  }

  depends_on = [ tls_private_key.default ]
}