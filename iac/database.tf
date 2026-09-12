locals {
  database_environment_filename   = ".env"
  database_backup_script_filename = abspath(pathexpand("../bin/backup.sh"))
  database_backup_cron_filename   = abspath(pathexpand("../etc/backup.cron"))
  database_start_script_filename  = abspath(pathexpand("../start.sh"))
  database_stop_script_filename   = abspath(pathexpand("../stop.sh"))
  database_helper_script_filename = abspath(pathexpand("../functions.sh"))
}

locals {
  database_manifest_filename             = "docker-compose.yaml"
  database_settings_manifest_filename    = "database-settings.yaml"
  database_credentials_manifest_filename = "database-credentials.yaml"
  database_setup_hash                    = "${aws_instance.phonebook_database.id}-${filemd5(local.database_backup_script_filename)}-${filemd5(local.database_backup_cron_filename)}-${filemd5(local.banner_filename)}-${filemd5(local.database_start_script_filename)}-${filemd5(local.database_stop_script_filename)}-${filemd5(local.database_helper_script_filename)}}=${md5(local.database_environment)}-${md5(local.database_manifest)}"
}

locals {
  database_settings_manifest = <<-EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: database-settings
  namespace: ${local.build.name}
data:
  DB_HOST: ${aws_instance.phonebook_database.private_ip}
  DB_NAME: ${local.secrets.database.name}
EOT

  database_credentials_manifest = <<-EOT
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

  database_environment = <<-EOT
export DB_USER=${local.secrets.database.user}
export DB_PASSWORD=${local.secrets.database.password}
export BACKUP_BUCKET="${local.prefix}-${local.build.name}-backup"
EOT

  database_manifest = <<-EOT
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
    hash = local.database_setup_hash
  }

  connection {
    host        = aws_instance.phonebook_database.public_ip
    user        = var.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "file" {
    source      = local.database_backup_script_filename
    destination = "${var.compute.home_dir}/${basename(local.database_backup_script_filename)}"
  }

  provisioner "file" {
    source      = local.database_backup_cron_filename
    destination = "${var.compute.home_dir}/${basename(local.database_backup_cron_filename)}"
  }

  provisioner "file" {
    content     = local.database_environment
    destination = "${var.compute.home_dir}/${local.database_environment_filename}"
  }

  provisioner "file" {
    content     = local.database_manifest
    destination = "${var.compute.home_dir}/${local.database_manifest_filename}"
  }

  provisioner "file" {
    source      = local.banner_filename
    destination = "${var.compute.home_dir}/${basename(local.banner_filename)}"
  }

  provisioner "file" {
    source      = local.database_start_script_filename
    destination = "${var.compute.home_dir}/${basename(local.database_start_script_filename)}"
  }

  provisioner "file" {
    source      = local.database_stop_script_filename
    destination = "${var.compute.home_dir}/${basename(local.database_stop_script_filename)}"
  }

  provisioner "file" {
    source      = local.database_helper_script_filename
    destination = "${var.compute.home_dir}/${basename(local.database_helper_script_filename)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for Cloud-init to complete...'",
      "sudo cloud-init status --wait",
      "echo 'Cloud-init finished!'",
      "cd ${var.compute.home_dir}",
      "chmod u+x *.sh",
      "chmod 0600 .env",
      "chmod og-rwx *.sh",
      "chmod og-rwx *.txt",
      "chmod og-rwx *.yaml",
      "sudo install -o root -g root -m 0644 backup.cron /etc/cron.d/phonebook-backup",
      "sudo systemctl enable --now cron",
      "rm -f backup.cron",
      "sudo ./start.sh"
    ]
  }

  depends_on = [
    aws_instance.phonebook_database,
    tls_private_key.phonebook
  ]
}
