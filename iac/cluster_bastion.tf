resource "null_resource" "phonebook_cluster_bastion_setup" {
  connection {
    host        = aws_eip.phonebook_cluster_bastion.public_ip
    user        = var.infrastructure.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "file" {
    content     = tls_private_key.phonebook.private_key_pem
    destination = "${var.infrastructure.compute.home_dir}/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for Cloud-init to complete...'",
      "sudo cloud-init status --wait",
      "echo 'Cloud-init finished!'",
      "cd ${var.infrastructure.compute.home_dir}",
      "chown ${var.infrastructure.compute.user}:${var.infrastructure.compute.user} ./.ssh/id_rsa",
      "chmod og-rwx ./.ssh/id_rsa",
      "scp -o StrictHostKeyChecking=no ${var.infrastructure.compute.user}@${aws_instance.phonebook_cluster_workernode1.private_ip}:/etc/rancher/k3s/k3s.yaml .",
      "mkdir -p ./.kube",
      "mv k3s.yaml ./.kube/config",
      "chmod -R og-rwx ./.kube",
      "sed -i 's/127.0.0.1/${aws_instance.phonebook_cluster_workernode1.private_ip}/g' ./.kube/config",
    ]
  }

  depends_on = [
    aws_instance.phonebook_cluster_bastion,
    tls_private_key.phonebook,
    aws_instance.phonebook_cluster_workernode1,
  ]
}
