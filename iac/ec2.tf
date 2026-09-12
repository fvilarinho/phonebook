locals {
  compute = {
    bootstrap_script = <<-EOT
  #!/usr/bin/env bash

  set -euo pipefail

  export DEBIAN_FRONTEND=noninteractive

  # Force IPv4.
  install -d -m 0755 /etc/apt/apt.conf.d
  cat > /etc/apt/apt.conf.d/99force-ipv4 <<'EOF'
  Acquire::ForceIPv4 "true";
  EOF

  # Retry transient package mirror and network failures.
  cat > /etc/apt/apt.conf.d/80-network-retries <<'EOF'
  Acquire::Retries "5";
  Acquire::http::Timeout "30";
  Acquire::https::Timeout "30";
  EOF

  # Refresh package indexes.
  apt-get update

  # Install minimum packages.
  apt-get -y install net-tools dnsutils vim curl wget unzip zip htop cron
EOT
  }
}

resource "aws_instance" "phonebook_cluster_bastion" {
  ami                         = var.compute.ami_id
  instance_type               = var.compute.instance_type
  subnet_id                   = aws_subnet.phonebook_pub_b.id
  vpc_security_group_ids      = [aws_security_group.phonebook_cluster_bastion_pub_traffic.id]
  key_name                    = aws_key_pair.phonebook.key_name
  associate_public_ip_address = true
  monitoring                  = true
  user_data_replace_on_change = true
  user_data                   = <<EOT
${local.compute.bootstrap_script}

# Install kubectl.
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
mv kubectl /usr/local/bin
chmod +x /usr/local/bin/kubectl
EOT

  tags = {
    "Name" = "${local.prefix}-${local.build.name}-cluster-bastion"
  }

  depends_on = [
    aws_subnet.phonebook_pub_b,
    aws_route_table.phonebook_igw,
    aws_route_table_association.phonebook_pub_subnet_b,
    aws_security_group.phonebook_cluster_bastion_pub_traffic,
    aws_key_pair.phonebook
  ]
}

resource "aws_eip" "phonebook_cluster_bastion" {
  instance = aws_instance.phonebook_cluster_bastion.id
  domain   = "vpc"

  depends_on = [aws_instance.phonebook_cluster_bastion]
}

resource "aws_instance" "phonebook_cluster_workernode1" {
  ami                         = var.compute.ami_id
  instance_type               = var.compute.instance_type
  subnet_id                   = aws_subnet.phonebook_pvt_a.id
  vpc_security_group_ids      = [aws_security_group.phonebook_cluster_workernodes_traffic.id]
  key_name                    = aws_key_pair.phonebook.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.phonebook_cluster_workernode.name
  monitoring                  = true
  user_data_replace_on_change = true
  user_data                   = <<EOT
${local.compute.bootstrap_script}

# Install Kubernates distribution (K3S) as manager node.
curl -sfL https://get.k3s.io | K3S_TOKEN="${random_password.phonebook_cluster.result}" sh -

# Prepare the kubeconfig file used by kubectl.
chmod og+r /etc/rancher/k3s/k3s.yaml
mkdir -p ${var.compute.home_dir}/.kube
ln -s /etc/rancher/k3s/k3s.yaml ${var.compute.home_dir}/.kube/config
EOT

  tags = {
    "Name" = "${local.prefix}-${local.build.name}-cluster-workernode1"
  }

  depends_on = [
    aws_vpc.phonebook,
    aws_subnet.phonebook_pvt_a,
    aws_nat_gateway.phonebook_pvt_subnet_a,
    aws_eip.phonebook_subnet_a,
    aws_route_table.phonebook_pvt_subnet_a,
    aws_route_table_association.phonebook_pvt_subnet_a,
    aws_route_table.phonebook_igw,
    aws_route_table_association.phonebook_pub_subnet_a,
    aws_security_group.phonebook_cluster_workernodes_traffic,
    aws_key_pair.phonebook,
    random_password.phonebook_cluster
  ]
}

resource "aws_instance" "phonebook_cluster_workernode2" {
  ami                         = var.compute.ami_id
  instance_type               = "c8i-flex.large"
  subnet_id                   = aws_subnet.phonebook_pvt_b.id
  vpc_security_group_ids      = [aws_security_group.phonebook_cluster_workernodes_traffic.id]
  key_name                    = aws_key_pair.phonebook.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.phonebook_cluster_workernode.name
  monitoring                  = true
  user_data_replace_on_change = true
  user_data                   = <<EOT
${local.compute.bootstrap_script}

# Install Kubernetes distribution (K3S) as worker node.
curl -sfL https://get.k3s.io | K3S_TOKEN="${random_password.phonebook_cluster.result}" K3S_URL="https://${aws_instance.phonebook_cluster_workernode1.private_ip}:6443" sh -
EOT

  tags = {
    "Name" = "${local.prefix}-${local.build.name}-cluster-workernode2"
  }

  depends_on = [
    aws_vpc.phonebook,
    aws_subnet.phonebook_pvt_b,
    aws_nat_gateway.phonebook_pvt_subnet_b,
    aws_eip.phonebook_subnet_b,
    aws_route_table.phonebook_pvt_subnet_b,
    aws_route_table_association.phonebook_pvt_subnet_b,
    aws_route_table.phonebook_igw,
    aws_route_table_association.phonebook_pub_subnet_b,
    aws_security_group.phonebook_cluster_workernodes_traffic,
    aws_key_pair.phonebook,
    random_password.phonebook_cluster,
    aws_instance.phonebook_cluster_workernode1
  ]
}

resource "aws_instance" "phonebook_database" {
  ami                         = var.compute.ami_id
  instance_type               = var.compute.instance_type
  subnet_id                   = aws_subnet.phonebook_pub_a.id
  vpc_security_group_ids      = [aws_security_group.phonebook_database_pub_traffic.id, aws_security_group.phonebook_database_pvt_traffic.id]
  key_name                    = aws_key_pair.phonebook.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.phonebook_database.name
  monitoring                  = true
  user_data_replace_on_change = true
  user_data                   = <<EOT
${local.compute.bootstrap_script}

# Install Docker.
curl -fsSL https://get.docker.com | sh -
systemctl enable docker

# Install AWS CLI.
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash -s -- --system
EOT

  tags = {
    "Name" = "${local.prefix}-${local.build.name}-database"
  }

  depends_on = [
    aws_subnet.phonebook_pub_a,
    aws_route_table.phonebook_igw,
    aws_route_table_association.phonebook_pub_subnet_a,
    aws_security_group.phonebook_database_pub_traffic,
    aws_security_group.phonebook_database_pvt_traffic,
    aws_key_pair.phonebook
  ]
}

resource "aws_eip" "phonebook_database" {
  instance = aws_instance.phonebook_database.id
  domain   = "vpc"

  depends_on = [aws_instance.phonebook_database]
}
