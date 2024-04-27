# Local variables definition.
locals {
  settings = jsondecode(chomp(file(pathexpand(var.settingsFilename))))
}

# Creates the linode instance and deploy the stack container the application and the observability agents (OpenTelemetry & Prometheus).
resource "linode_instance" "default" {
  label           = local.settings.label
  tags            = local.settings.tags
  type            = local.settings.type
  image           = local.settings.image
  region          = local.settings.region
  private_ip      = true
  authorized_keys = [chomp(chomp(file(pathexpand(var.sshPublicKeyFilename))))]

  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = self.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
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
}

resource "null_resource" "defaultFiles" {
  triggers = {
    always_run = timestamp()
  }

  # Copies the stack definition file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = "docker-compose.yml"
    destination = "/root/docker-compose.yml"
  }

  # Copies the certificate files.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = var.certificateKeyFilename
    destination = "/root/etc/cert.key"
  }

  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = var.certificateFilename
    destination = "/root/etc/cert.pem"
  }

  # Copies the frontend configuration file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = "../etc/frontend.conf"
    destination = "/root/etc/frontend.conf"
  }

  # Copies the metrics server configuration file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = "../etc/prometheus.yml"
    destination = "/root/etc/prometheus.yml"
  }

  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = "../etc/prometheus2json.json"
    destination = "/root/etc/prometheus2json.json"
  }

  # Copies the environment definition file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = "../.env"
    destination = "/root/.env"
  }

  # Copies the functions script file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = "../functions.sh"
    destination = "/root/functions.sh"
  }

  # Copies the start script file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = "../start.sh"
    destination = "/root/start.sh"
  }

  # Copies the stop script file.
  provisioner "file" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    source      = "../stop.sh"
    destination = "/root/stop.sh"
  }

  # Starts the stack.
  provisioner "remote-exec" {
    # Remote connection attributes.
    connection {
      host        = linode_instance.default.ip_address
      user        = "root"
      private_key = chomp(chomp(file(pathexpand(var.sshPrivateKeyFilename))))
    }

    # Installs the required software and initialize the swarm.
    inline = [
      "chmod +x /root/*.sh",
      "./start.sh"
    ]
  }

  depends_on = [
    linode_instance.default,
    local_sensitive_file.certificateKey,
    local_sensitive_file.certificate
  ]
}