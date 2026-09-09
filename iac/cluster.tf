locals {
  phonebook_cluster_namespace_manifest_filename = "namespace.yaml"
  phonebook_cluster_setup_hash                  = "${md5(local.phonebook_cluster_namespace_manifest_filename)}-${md5(local.phonebook_database_settings_manifest)}-${md5(local.phonebook_database_credentials_manifest)}-${md5(local.phonebook_cluster_backend_settings_manifest)}-${md5(local.phonebook_cluster_backend_manifest)}-${md5(local.phonebook_cluster_frontend_settings_manifest)}-${md5(local.phonebook_cluster_frontend_manifest)}-${md5(local.phonebook_cluster_namespace_manifest)}-${filemd5(local.banner_filename)}"
}

locals {
  phonebook_cluster_namespace_manifest = <<EOT
apiVersion: v1
kind: Namespace
metadata:
  name: ${local.build.name}
EOT
}

resource "random_password" "phonebook_cluster" {
  length  = 16
  special = false
}

resource "null_resource" "phonebook_cluster_setup" {
  triggers = {
    hash = local.phonebook_cluster_setup_hash
  }

  connection {
    host        = aws_eip.phonebook_cluster_bastion.public_ip
    user        = var.infrastructure.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "file" {
    source      = local.banner_filename
    destination = "${var.infrastructure.compute.home_dir}/${basename(local.banner_filename)}"
  }

  provisioner "file" {
    content     = local.phonebook_cluster_namespace_manifest
    destination = "${var.infrastructure.compute.home_dir}/${local.phonebook_cluster_namespace_manifest_filename}"
  }

  provisioner "file" {
    content     = local.phonebook_database_settings_manifest
    destination = "${var.infrastructure.compute.home_dir}/${local.phonebook_database_settings_manifest_filename}"
  }

  provisioner "file" {
    content     = local.phonebook_database_credentials_manifest
    destination = "${var.infrastructure.compute.home_dir}/${local.phonebook_database_credentials_manifest_filename}"
  }

  provisioner "file" {
    content     = local.phonebook_cluster_backend_settings_manifest
    destination = "${var.infrastructure.compute.home_dir}/${local.phonebook_cluster_backend_settings_manifest_filename}"
  }

  provisioner "file" {
    content     = local.phonebook_cluster_backend_manifest
    destination = "${var.infrastructure.compute.home_dir}/${local.phonebook_cluster_backend_manifest_filename}"
  }

  provisioner "file" {
    content     = local.phonebook_cluster_frontend_settings_manifest
    destination = "${var.infrastructure.compute.home_dir}/${local.phonebook_cluster_frontend_settings_manifest_filename}"
  }

  provisioner "file" {
    content     = local.phonebook_cluster_frontend_manifest
    destination = "${var.infrastructure.compute.home_dir}/${local.phonebook_cluster_frontend_manifest_filename}"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ${var.infrastructure.compute.home_dir}",
      "cat ${basename(local.banner_filename)}",
      "kubectl apply -f ${local.phonebook_cluster_namespace_manifest_filename}",
      "kubectl apply -f ${local.phonebook_database_settings_manifest_filename}",
      "kubectl apply -f ${local.phonebook_database_credentials_manifest_filename}",
      "kubectl apply -f ${local.phonebook_cluster_backend_settings_manifest_filename}",
      "kubectl apply -f ${local.phonebook_cluster_backend_manifest_filename}",
      "kubectl apply -f ${local.phonebook_cluster_frontend_settings_manifest_filename}",
      "kubectl apply -f ${local.phonebook_cluster_frontend_manifest_filename}",
    ]
  }

  depends_on = [
    aws_eip.phonebook_cluster_bastion,
    tls_private_key.phonebook,
    null_resource.phonebook_cluster_bastion_setup,
    null_resource.phonebook_database_setup
  ]
}
