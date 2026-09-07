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
    user        = var.settings.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "sudo cloud-init status --wait",
      "echo 'Cloud-init finished.'",
      "curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash -",
      "sudo ln -s ${var.settings.compute.home_dir}/.local/bin/aws /usr/local/bin/aws"
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
    user        = var.settings.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "file" {
    source      = local.phonebook_stack_filename
    destination = "${var.settings.compute.home_dir}/${basename(local.phonebook_stack_filename)}"
  }

  provisioner "file" {
    source      = local.phonebook_stack_banner_filename
    destination = "${var.settings.compute.home_dir}/${basename(local.phonebook_stack_banner_filename)}"
  }

  provisioner "file" {
    source      = local.phonebook_stack_secrets_filename
    destination = "${var.settings.compute.home_dir}/${basename(local.phonebook_stack_secrets_filename)}"
  }

  provisioner "file" {
    source      = local.phonebook_stack_env_filename
    destination = "${var.settings.compute.home_dir}/${basename(local.phonebook_stack_env_filename)}"
  }

  provisioner "file" {
    source      = local.phonebook_stack_start_script_filename
    destination = "${var.settings.compute.home_dir}/${basename(local.phonebook_stack_start_script_filename)}"
  }

  provisioner "file" {
    source      = local.phonebook_stack_stop_script_filename
    destination = "${var.settings.compute.home_dir}/${basename(local.phonebook_stack_stop_script_filename)}"
  }

  provisioner "file" {
    source      = local.phonebook_stack_helper_script_filename
    destination = "${var.settings.compute.home_dir}/${basename(local.phonebook_stack_helper_script_filename)}"
  }

  provisioner "file" {
    content     = tls_private_key.phonebook.private_key_pem
    destination = "${var.settings.compute.home_dir}/.ssh/id_rsa"
  }

  depends_on = [
    aws_instance.phonebook_database,
    aws_eip.phonebook_database,
    tls_private_key.phonebook,
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
    user        = var.settings.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "cd ${var.settings.compute.home_dir}",
      "chmod +x *.sh",
      "chown ${var.settings.compute.user}:${var.settings.compute.user} ./.ssh/id_rsa",
      "chmod 600 ./.ssh/id_rsa",
      "sudo ./start.sh database"
    ]
  }

  depends_on = [
    aws_instance.phonebook_database,
    aws_eip.phonebook_database,
    tls_private_key.phonebook,
    null_resource.phonebook_database_files
  ]
}
