resource "aws_instance" "phonebook_cluster_workernode1" {
  ami                         = var.settings.compute.ami
  instance_type               = var.settings.compute.type
  subnet_id                   = aws_subnet.phonebook_pvt_a.id
  vpc_security_group_ids      = [aws_security_group.phonebook_cluster_workernodes_traffic.id]
  key_name                    = aws_key_pair.phonebook.key_name
  associate_public_ip_address = false
  monitoring                  = true
  user_data_replace_on_change = true
  user_data                   = <<EOT
#!/usr/bin/env bash

set -euo pipefail

DEBIAN_FRONTEND=noninteractive

# Update the system.
apt update
apt -y upgrade

# Install minimum packages.
apt -y install net-tools dnsutils vim curl wget unzip zip htop

# Install Kubernates distribution (K3S) as manager node.
export K3S_TOKEN="${random_password.phonebook_cluster.result}"
curl -sfL https://get.k3s.io | sh -

# Prepare the kubeconfig file used by kubectl.
chmod og+r /etc/rancher/k3s/k3s.yaml
ln -s /etc/rancher/k3s/k3s.yaml ${var.settings.compute.home_dir}/.kube/config
EOT

  tags = {
    "Name"        = "${var.settings.general.name}-cluster-workernode1"
    "auto-delete" = "no"
    "auto-stop"   = "no"
  }

  depends_on = [
    random_password.phonebook_cluster,
    aws_key_pair.phonebook,
    aws_security_group.phonebook_cluster_workernodes_traffic,
    aws_internet_gateway.phonebook,
    aws_route_table.phonebook_igw,
    aws_route_table_association.phonebook_pub_subnet_a,
    aws_subnet.phonebook_pvt_a,
    aws_eip.phonebook_subnet_a,
    aws_nat_gateway.phonebook_pvt_subnet_a,
    aws_route_table.phonebook_pvt_subnet_a,
    aws_route_table_association.phonebook_pvt_subnet_a
  ]
}

resource "aws_instance" "phonebook_cluster_workernode2" {
  ami                         = var.settings.compute.ami
  instance_type               = var.settings.compute.type
  subnet_id                   = aws_subnet.phonebook_pvt_b.id
  vpc_security_group_ids      = [aws_security_group.phonebook_cluster_workernodes_traffic.id]
  key_name                    = aws_key_pair.phonebook.key_name
  associate_public_ip_address = false
  monitoring                  = true
  user_data_replace_on_change = true
  user_data                   = <<EOT
#!/usr/bin/env bash

set -euo pipefail

DEBIAN_FRONTEND=noninteractive

# Update the system.
apt update
apt -y upgrade

# Install minimum packages.
apt -y install net-tools dnsutils vim curl wget unzip zip htop

# Install Kubernetes distribution (K3S) as worker node.
export K3S_TOKEN="${random_password.phonebook_cluster.result}"
export K3S_URL="https://${aws_instance.phonebook_cluster_workernode1.private_ip}:6443"
curl -sfL https://get.k3s.io | sh -
EOT

  tags = {
    "Name"        = "${var.settings.general.name}-cluster-workernode2"
    "auto-delete" = "no"
    "auto-stop"   = "no"
  }

  depends_on = [
    random_password.phonebook_cluster,
    aws_key_pair.phonebook,
    aws_security_group.phonebook_cluster_workernodes_traffic,
    aws_subnet.phonebook_pvt_b,
    aws_internet_gateway.phonebook,
    aws_route_table.phonebook_igw,
    aws_route_table_association.phonebook_pub_subnet_b,
    aws_eip.phonebook_subnet_b,
    aws_nat_gateway.phonebook_pvt_subnet_b,
    aws_route_table.phonebook_pvt_subnet_b,
    aws_route_table_association.phonebook_pvt_subnet_b
  ]
}

resource "aws_instance" "phonebook_database" {
  ami                         = var.settings.compute.ami
  instance_type               = var.settings.compute.type
  subnet_id                   = aws_subnet.phonebook_pub_a.id
  vpc_security_group_ids      = [aws_security_group.phonebook_database_pub_traffic.id, aws_security_group.phonebook_database_pvt_traffic.id]
  key_name                    = aws_key_pair.phonebook.key_name
  associate_public_ip_address = true
  monitoring                  = true
  user_data_replace_on_change = true
  user_data                   = <<EOT
#!/usr/bin/env bash

set -euo pipefail

DEBIAN_FRONTEND=noninteractive

# Update the system.
apt update
apt -y upgrade -y

# Install minimum packages.
apt -y install net-tools dnsutils vim curl wget unzip zip htop

# Install docker.
curl -fsSL https://get.docker.com | sh -
systemctl enable docker

# Install kubectl.
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
mv kubectl /usr/local/bin
chmod +x /usr/local/bin/kubectl

# Install AWS CLI.
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash -s -- --system
EOT

  tags = {
    "Name"        = "${var.settings.general.name}-database"
    "auto-delete" = "no"
    "auto-stop"   = "no"
  }

  depends_on = [
    aws_key_pair.phonebook,
    aws_security_group.phonebook_database_pub_traffic,
    aws_security_group.phonebook_database_pvt_traffic,
    aws_subnet.phonebook_pub_a,
    aws_internet_gateway.phonebook,
    aws_route_table.phonebook_igw,
    aws_route_table_association.phonebook_pub_subnet_a,
    aws_instance.phonebook_cluster_workernode1,
    aws_instance.phonebook_cluster_workernode2
  ]
}

resource "aws_eip" "phonebook_database" {
  instance = aws_instance.phonebook_database.id
  domain   = "vpc"

  depends_on = [aws_instance.phonebook_database]
}
