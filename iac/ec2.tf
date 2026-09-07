locals {
  phonebook_stack_filename               = abspath(pathexpand("../docker-compose.yml"))
  phonebook_stack_banner_filename        = abspath(pathexpand("../banner.txt"))
  phonebook_stack_env_filename           = abspath(pathexpand("../.env"))
  phonebook_stack_secrets_filename       = abspath(pathexpand("../.secrets"))
  phonebook_stack_start_script_filename  = abspath(pathexpand("../start.sh"))
  phonebook_stack_stop_script_filename   = abspath(pathexpand("../stop.sh"))
  phonebook_stack_helper_script_filename = abspath(pathexpand("../functions.sh"))
  phonebook_stack_files_hash             = "${filemd5(local.phonebook_stack_filename)}-${filemd5(local.phonebook_stack_banner_filename)}-${filemd5(local.phonebook_stack_secrets_filename)}-${filemd5(local.phonebook_stack_env_filename)}-${filemd5(local.phonebook_stack_start_script_filename)}-${filemd5(local.phonebook_stack_stop_script_filename)}-${filemd5(local.phonebook_stack_helper_script_filename)}}"
}

# Compute instances.
resource "aws_instance" "phonebook_database" {
  ami                         = "ami-0246d714afcc1d494"
  instance_type               = "c9gd.large"
  subnet_id                   = aws_subnet.phonebook_pub_subnet.id
  vpc_security_group_ids      = [aws_security_group.phonebook_database_pub_traffic.id, aws_security_group.phonebook_database_pvt_traffic.id]
  key_name                    = aws_key_pair.phonebook.key_name
  associate_public_ip_address = true
  monitoring                  = true
  user_data_replace_on_change = true
  user_data                   = <<EOT
#!/usr/bin/env bash

set -euo pipefail

DEBIAN_FRONTEND=noninteractive

apt update
apt -y upgrade -y
apt -y install net-tools dnsutils vim curl wget unzip zip htop
curl -fsSL https://get.docker.com | sh -
systemctl enable docker
EOT

  tags = {
    "Name"        = "phonebook_database"
    "auto-delete" = "no"
    "auto-stop"   = "no"
  }

  depends_on = [
    aws_subnet.phonebook_pub_subnet,
    aws_key_pair.phonebook,
    aws_security_group.phonebook_database_pub_traffic,
    aws_security_group.phonebook_database_pvt_traffic
  ]
}

# Enables the Elastic IPs.
resource "aws_eip" "phonebook_database" {
  instance = aws_instance.phonebook_database.id
  domain   = "vpc"

  depends_on = [aws_instance.phonebook_database]
}

# Waits for cloud-init to complete before copying files.
resource "null_resource" "phonebook_database_setup" {
  triggers = {
    hash = aws_instance.phonebook_database.id
  }

  connection {
    host        = aws_eip.phonebook_database.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "sudo cloud-init status --wait",
      "echo 'Cloud-init finished.'",
      "curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash -",
      "sudo ln -s /home/ubuntu/.local/bin/aws /usr/local/bin/aws"
    ]
  }

  depends_on = [
    aws_instance.phonebook_database,
    aws_eip.phonebook_database,
    tls_private_key.phonebook,
    local_file.phonebook_private_key
  ]
}

# Copies the required files.
resource "null_resource" "phonebook_database_files" {
  triggers = {
    hash = "${aws_instance.phonebook_database.id}-${local.phonebook_stack_files_hash}"
  }

  connection {
    host        = aws_eip.phonebook_database.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "file" {
    source      = local.phonebook_stack_filename
    destination = "/home/ubuntu/docker-compose.yaml"
  }

  provisioner "file" {
    source      = local.phonebook_stack_banner_filename
    destination = "/home/ubuntu/banner.txt"
  }

  provisioner "file" {
    source      = local.phonebook_stack_secrets_filename
    destination = "/home/ubuntu/.secrets"
  }

  provisioner "file" {
    source      = local.phonebook_stack_env_filename
    destination = "/home/ubuntu/.env"
  }

  provisioner "file" {
    source      = local.phonebook_stack_start_script_filename
    destination = "/home/ubuntu/start.sh"
  }

  provisioner "file" {
    source      = local.phonebook_stack_stop_script_filename
    destination = "/home/ubuntu/stop.sh"
  }

  provisioner "file" {
    source      = local.phonebook_stack_helper_script_filename
    destination = "/home/ubuntu/functions.sh"
  }

  depends_on = [
    aws_instance.phonebook_database,
    aws_eip.phonebook_database,
    null_resource.phonebook_database_setup
  ]
}

# Starts the stack.
resource "null_resource" "phonebook_database_start" {
  triggers = {
    hash = "${aws_instance.phonebook_database.id}-${local.phonebook_stack_files_hash}"
  }

  connection {
    host        = aws_eip.phonebook_database.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu",
      "chmod +x *.sh",
      "sudo ./start.sh database"
    ]
  }

  depends_on = [ null_resource.phonebook_database_files ]
}
