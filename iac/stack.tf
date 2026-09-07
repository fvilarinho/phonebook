locals {
  phonebook_stack_banner_filename        = abspath(pathexpand("../banner.txt"))
  phonebook_stack_start_script_filename  = abspath(pathexpand("../start.sh"))
  phonebook_stack_stop_script_filename   = abspath(pathexpand("../stop.sh"))
  phonebook_stack_helper_script_filename = abspath(pathexpand("../functions.sh"))
  phonebook_stack_files_hash             = "${md5(local.phonebook_stack)}-${filemd5(local.phonebook_stack_banner_filename)}-${md5(local.phonebook_stack_env)}-${filemd5(local.phonebook_stack_start_script_filename)}-${filemd5(local.phonebook_stack_stop_script_filename)}-${filemd5(local.phonebook_stack_helper_script_filename)}}"
}

locals {
  phonebook_stack_env = <<EOT
export DB_USER="demo"
export DB_PASS="${random_password.phonebook_database.result}"
EOT

  phonebook_stack = <<EOT
services:
  database:
    image: mongo:7.0
    container_name: database
    restart: unless-stopped
    environment:
      - MONGO_INITDB_ROOT_USERNAME=$${DB_USER}
      - MONGO_INITDB_ROOT_PASSWORD=$${DB_PASS}
    volumes:
      - database-data:/data/db
    hostname: database

volumes:
  database-data:
EOT
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
      "echo 'Waiting for Cloud-init to complete...'",
      "sudo cloud-init status --wait",
      "echo 'Cloud-init finished.'",
      "curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash -",
      "sudo rm -f /usr/local/bin/aws",
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
    content     = local.phonebook_stack
    destination = "${var.settings.compute.home_dir}/docker-compose.yml"
  }

  provisioner "file" {
    source      = local.phonebook_stack_banner_filename
    destination = "${var.settings.compute.home_dir}/${basename(local.phonebook_stack_banner_filename)}"
  }

  provisioner "file" {
    content     = local.phonebook_stack_env
    destination = "${var.settings.compute.home_dir}/.env"
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
      "chmod u+x *.sh",
      "chown ${var.settings.compute.user}:${var.settings.compute.user} ./.ssh/id_rsa",
      "chmod og-rwx *.txt",
      "chmod og-rwx *.yml",
      "chmod og-rwx *.sh",
      "chmod og-rwx ./.ssh/id_rsa",
      "chmod og-rwx ./.env",
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

resource "null_resource" "phonebook_cluster_files" {
  connection {
    host        = aws_eip.phonebook_database.public_ip
    user        = var.settings.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no ${var.settings.compute.user}@${aws_instance.phonebook_cluster_workernode1.private_ip}:/etc/rancher/k3s/k3s.yaml .",
      "mkdir -p ./.kube",
      "mv k3s.yaml ./.kube/config",
      "chmod -R og-rwx ./.kube",
      "sed -i 's/127.0.0.1/${aws_instance.phonebook_cluster_workernode1.private_ip}/g' ./.kube/config"
    ]
  }

  depends_on = [
    aws_eip.phonebook_database,
    tls_private_key.phonebook,
    aws_instance.phonebook_cluster_workernode1,
    null_resource.phonebook_database_setup,
    null_resource.phonebook_database_files,
    null_resource.phonebook_database_start
  ]
}
