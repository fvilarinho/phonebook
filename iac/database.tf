locals {
  phonebook_database_environment_filename   = ".env"
  phonebook_database_backup_script_filename = abspath(pathexpand("../bin/backup.sh"))
  phonebook_database_start_script_filename  = abspath(pathexpand("../start.sh"))
  phonebook_database_stop_script_filename   = abspath(pathexpand("../stop.sh"))
  phonebook_database_helper_script_filename = abspath(pathexpand("../functions.sh"))
}

locals {
  phonebook_database_manifest_filename             = "docker-compose.yaml"
  phonebook_database_settings_manifest_filename    = "database-settings.yaml"
  phonebook_database_credentials_manifest_filename = "database-credentials.yaml"
  phonebook_database_setup_hash                    = "${aws_instance.phonebook_database.id}-${filemd5(local.phonebook_database_backup_script_filename)}-${md5(local.phonebook_database_environment)}-${md5(local.phonebook_database_manifest)}-${filemd5(local.banner_filename)}-${filemd5(local.phonebook_database_start_script_filename)}-${filemd5(local.phonebook_database_stop_script_filename)}-${filemd5(local.phonebook_database_helper_script_filename)}}"
}

locals {
  phonebook_database_environment = <<EOT
export DB_USER=${local.secrets.database.user}
export DB_PASSWORD=${local.secrets.database.password}
export BACKUP_BUCKET="${local.build.name}-backup"
EOT

  phonebook_database_settings_manifest = <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: database-settings
  namespace: ${local.build.name}
data:
  DB_HOST: ${aws_instance.phonebook_database.private_ip}
  DB_NAME: ${local.secrets.database.name}
EOT

  phonebook_database_credentials_manifest = <<EOT
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
  namespace: ${local.build.name}
type: Opaque
stringData:
  DB_USER: ${local.secrets.database.user}
  DB_PASSWORD: ${local.secrets.database.password}
EOT

  phonebook_database_manifest = <<EOT
services:
  database:
    image: mongo:7.0
    container_name: database
    restart: unless-stopped
    environment:
      - MONGO_INITDB_ROOT_USERNAME=$${DB_USER}
      - MONGO_INITDB_ROOT_PASSWORD=$${DB_PASSWORD}
    volumes:
      - database-data:/data/db
    ports:
      - "27017:27017"
    hostname: database

volumes:
  database-data:
EOT
}

resource "null_resource" "phonebook_database_setup" {
  triggers = {
    hash = local.phonebook_database_setup_hash
  }

  connection {
    host        = aws_instance.phonebook_database.public_ip
    user        = var.infrastructure.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "file" {
    source      = local.phonebook_database_backup_script_filename
    destination = "${var.infrastructure.compute.home_dir}/${basename(local.phonebook_database_backup_script_filename)}"
  }

  provisioner "file" {
    content     = local.phonebook_database_environment
    destination = "${var.infrastructure.compute.home_dir}/${local.phonebook_database_environment_filename}"
  }

  provisioner "file" {
    content     = local.phonebook_database_manifest
    destination = "${var.infrastructure.compute.home_dir}/${local.phonebook_database_manifest_filename}"
  }

  provisioner "file" {
    source      = local.banner_filename
    destination = "${var.infrastructure.compute.home_dir}/${basename(local.banner_filename)}"
  }

  provisioner "file" {
    source      = local.phonebook_database_start_script_filename
    destination = "${var.infrastructure.compute.home_dir}/${basename(local.phonebook_database_start_script_filename)}"
  }

  provisioner "file" {
    source      = local.phonebook_database_stop_script_filename
    destination = "${var.infrastructure.compute.home_dir}/${basename(local.phonebook_database_stop_script_filename)}"
  }

  provisioner "file" {
    source      = local.phonebook_database_helper_script_filename
    destination = "${var.infrastructure.compute.home_dir}/${basename(local.phonebook_database_helper_script_filename)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for Cloud-init to complete...'",
      "sudo cloud-init status --wait",
      "echo 'Cloud-init finished!'",
      "cd ${var.infrastructure.compute.home_dir}",
      "chmod u+x *.sh",
      "chmod og-rwx *.sh",
      "chmod og-rwx *.txt",
      "chmod og-rwx *.yaml",
      "sudo ./start.sh"
    ]
  }

  depends_on = [
    aws_instance.phonebook_database,
    tls_private_key.phonebook
  ]
}
