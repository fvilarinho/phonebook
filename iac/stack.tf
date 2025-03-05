resource "null_resource" "stackFiles" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "remote-exec" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    inline = [
      "mkdir -p /root/phonebook/etc/tls/certs",
      "mkdir -p /root/phonebook/etc/tls/private"
    ]
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../etc/.htpasswd"
    destination = "/root/phonebook/etc/.htpasswd"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../etc/logback.xml"
    destination = "/root/phonebook/etc/logback.xml"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../etc/nginx.conf"
    destination = "/root/phonebook/etc/nginx.conf"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../etc/tls/certs/fullchain.pem"
    destination = "/root/phonebook/etc/tls/certs/fullchain.pem"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../etc/tls/private/privkey.pem"
    destination = "/root/phonebook/etc/tls/private/privkey.pem"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../docker-compose.yml"
    destination = "/root/phonebook/docker-compose.yml"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../functions.sh"
    destination = "/root/phonebook/functions.sh"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../start.sh"
    destination = "/root/phonebook/start.sh"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../stop.sh"
    destination = "/root/phonebook/stop.sh"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../banner.txt"
    destination = "/root/phonebook/banner.txt"
  }

  provisioner "file" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    source = "../.env"
    destination = "/root/phonebook/.env"
  }

  provisioner "remote-exec" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    inline = [
      "chmod +x /root/phonebook/*.sh"
    ]
  }

  depends_on = [
    linode_sshkey.default,
    linode_instance.default,
    null_resource.generateCertificateAndCredentials
  ]
}

resource "null_resource" "startStack" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "remote-exec" {
    connection {
      host        = linode_instance.default.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
    }

    inline = [
      "cd /root/phonebook; ./start.sh"
    ]
  }

  depends_on = [ null_resource.stackFiles ]
}