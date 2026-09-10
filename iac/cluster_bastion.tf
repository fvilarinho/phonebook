resource "null_resource" "phonebook_cluster_bastion_setup" {
  connection {
    host        = aws_eip.phonebook_cluster_bastion.public_ip
    user        = local.compute.user
    private_key = tls_private_key.phonebook.private_key_pem
  }

  provisioner "file" {
    content     = tls_private_key.phonebook.private_key_pem
    destination = "${local.compute.home_dir}/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "cd ${local.compute.home_dir}",
      "chown ${local.compute.user}:${local.compute.user} ./.ssh/id_rsa",
      "chmod og-rwx ./.ssh/id_rsa",
      "ssh -o StrictHostKeyChecking=no ${local.compute.user}@${aws_instance.phonebook_cluster_workernode1.private_ip} \"sudo cloud-init status --wait\"",
      "scp -o StrictHostKeyChecking=no ${local.compute.user}@${aws_instance.phonebook_cluster_workernode1.private_ip}:/etc/rancher/k3s/k3s.yaml .",
      "mkdir -p ./.kube",
      "mv k3s.yaml ./.kube/config",
      "chmod -R og-rwx ./.kube",
      "sed -i 's/127.0.0.1/${aws_instance.phonebook_cluster_workernode1.private_ip}/g' ./.kube/config",
    ]
  }

  depends_on = [
    aws_vpc.phonebook,
    aws_subnet.phonebook_pvt_a,
    aws_subnet.phonebook_pvt_b,
    aws_nat_gateway.phonebook_pvt_subnet_a,
    aws_nat_gateway.phonebook_pvt_subnet_b,
    aws_eip.phonebook_subnet_a,
    aws_eip.phonebook_subnet_b,
    aws_route_table.phonebook_pvt_subnet_a,
    aws_route_table.phonebook_pvt_subnet_b,
    aws_route_table_association.phonebook_pvt_subnet_a,
    aws_route_table_association.phonebook_pvt_subnet_b,
    aws_route_table.phonebook_igw,
    aws_route_table_association.phonebook_pub_subnet_a,
    aws_route_table_association.phonebook_pub_subnet_b,
    aws_security_group.phonebook_cluster_workernodes_traffic,
    aws_eip.phonebook_cluster_bastion,
    aws_instance.phonebook_cluster_bastion,
    tls_private_key.phonebook,
    aws_instance.phonebook_cluster_workernode1,
    null_resource.phonebook_database_setup
  ]
}
