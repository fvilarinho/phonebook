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

  depends_on = [null_resource.phonebook_database_files]
}