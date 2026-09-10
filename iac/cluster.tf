locals {
  cluster_namespace_manifest_filename = "namespace.yaml"
  cluster_setup_hash                  = "${md5(local.cluster_namespace_manifest_filename)}-${md5(local.database_settings_manifest)}-${md5(local.database_credentials_manifest)}-${md5(local.cluster_backend_settings_manifest)}-${md5(local.cluster_backend_manifest)}-${md5(local.cluster_frontend_settings_manifest)}-${md5(local.cluster_frontend_manifest)}-${md5(local.cluster_namespace_manifest)}-${filemd5(local.banner_filename)}"
}

locals {
  cluster_namespace_manifest = <<-EOT
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
    hash = local.cluster_setup_hash
  }

  connection {
    host        = aws_eip.phonebook_cluster_bastion.public_ip
    user        = local.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "file" {
    source      = local.banner_filename
    destination = "${local.compute.home_dir}/${basename(local.banner_filename)}"
  }

  provisioner "file" {
    content     = local.cluster_namespace_manifest
    destination = "${local.compute.home_dir}/${local.cluster_namespace_manifest_filename}"
  }

  provisioner "file" {
    content     = local.database_settings_manifest
    destination = "${local.compute.home_dir}/${local.database_settings_manifest_filename}"
  }

  provisioner "file" {
    content     = local.database_credentials_manifest
    destination = "${local.compute.home_dir}/${local.database_credentials_manifest_filename}"
  }

  provisioner "file" {
    content     = local.cluster_backend_settings_manifest
    destination = "${local.compute.home_dir}/${local.cluster_backend_settings_manifest_filename}"
  }

  provisioner "file" {
    content     = local.cluster_backend_manifest
    destination = "${local.compute.home_dir}/${local.cluster_backend_manifest_filename}"
  }

  provisioner "file" {
    content     = local.cluster_frontend_settings_manifest
    destination = "${local.compute.home_dir}/${local.cluster_frontend_settings_manifest_filename}"
  }

  provisioner "file" {
    content     = local.cluster_frontend_manifest
    destination = "${local.compute.home_dir}/${local.cluster_frontend_manifest_filename}"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ${local.compute.home_dir}",
      "cat ${basename(local.banner_filename)}",
      "kubectl apply -f ${local.cluster_namespace_manifest_filename}",
      "kubectl apply -f ${local.database_settings_manifest_filename}",
      "kubectl apply -f ${local.database_credentials_manifest_filename}",
      "kubectl apply -f ${local.cluster_backend_settings_manifest_filename}",
      "kubectl apply -f ${local.cluster_backend_manifest_filename}",
      "kubectl apply -f ${local.cluster_frontend_settings_manifest_filename}",
      "kubectl apply -f ${local.cluster_frontend_manifest_filename}",
    ]
  }

  depends_on = [
    aws_eip.phonebook_cluster_bastion,
    tls_private_key.phonebook,
    null_resource.phonebook_cluster_bastion_setup,
    null_resource.phonebook_database_setup
  ]
}
