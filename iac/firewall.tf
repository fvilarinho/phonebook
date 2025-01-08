# Required local variables.
locals {
  allowedIps  = flatten([ for node in data.linode_instances.cluster.instances : [ "${node.ip_address}/32", "${node.private_ip_address}/32" ]])
  allowedIpv4 = concat(var.settings.allowedIps.ipv4, local.allowedIps)
}

# Fetches all IPs (private and public) of the clusters' nodes to be allowed in the firewall.
data "linode_instances" "cluster" {
  filter {
    name   = "id"
    values = [ for node in linode_lke_cluster.default.pool[0].nodes : node.instance_id ]
  }

  depends_on = [ linode_lke_cluster.default ]
}

# Firewall definition.
resource "linode_firewall" "default" {
  label           = "${var.appName}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allow-icmp"
    protocol = "ICMP"
    ipv4     = [ "0.0.0.0/0" ]
  }

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-cluster-nodeports-udp"
    protocol = "IPENCAP"
    ipv4     = [ "192.168.128.0/17" ]
  }

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-kubelet-health-checks"
    protocol = "TCP"
    ports    = "10250, 10256"
    ipv4     = [ "192.168.128.0/17" ]
  }

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-lke-wireguard"
    protocol = "UDP"
    ports    = "51820"
    ipv4     = [ "192.168.128.0/17" ]
  }

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-cluster-dns-tcp"
    protocol = "TCP"
    ports    = "53"
    ipv4     = [ "192.168.128.0/17" ]
  }

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-cluster-dns-udp"
    protocol = "UDP"
    ports    = "53"
    ipv4     = [ "192.168.128.0/17" ]
  }

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-nodebalancers-tcp"
    protocol = "TCP"
    ports    = "30000-32767"
    ipv4     = [ "192.168.255.0/24" ]
  }

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-nodebalancers-udp"
    protocol = "UDP"
    ports    = "30000-32767"
    ipv4     = [ "192.168.255.0/24" ]
  }

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips"
    protocol = "TCP"
    ipv4     = local.allowedIpv4
    ipv6     = var.settings.allowedIps.ipv6
  }

  # Akamai compliance rule.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips"
    protocol = "UDP"
    ipv4     = local.allowedIpv4
    ipv6     = var.settings.allowedIps.ipv6
  }

  depends_on = [
    data.linode_instances.cluster,
    linode_lke_cluster.default,
    null_resource.applyDeployments,
    null_resource.applyServices,
    null_resource.applyStorages,
    null_resource.applySecrets,
    null_resource.applyConfigMaps,
    null_resource.applyNamespaces
  ]
}

resource "linode_firewall_device" "clusterNodes" {
  for_each = { for node in linode_lke_cluster.default.pool[0].nodes : node.instance_id => node }

  firewall_id = linode_firewall.default.id
  entity_id   = each.key
  entity_type = "linode"

  depends_on = [
    linode_firewall.default,
    linode_lke_cluster.default,
    null_resource.applyDeployments,
    null_resource.applyServices,
    null_resource.applyStorages,
    null_resource.applySecrets,
    null_resource.applyConfigMaps,
    null_resource.applyNamespaces
  ]
}

data "linode_nodebalancers" "default" {
  depends_on = [
    linode_lke_cluster.default,
    null_resource.applyDeployments,
    null_resource.applyServices,
    null_resource.applyStorages,
    null_resource.applySecrets,
    null_resource.applyConfigMaps,
    null_resource.applyNamespaces
  ]
}

data "linode_nodebalancer" "ingress" {
  for_each = { for nodebalancer in data.linode_nodebalancers.default.nodebalancers : nodebalancer.ipv4 => nodebalancer }

  id = each.value.id

  depends_on = [ data.linode_nodebalancers.default ]
}

resource "linode_firewall_device" "ingress" {
  firewall_id = linode_firewall.default.id
  entity_id   = data.linode_nodebalancer.ingress[linode_domain_record.default.target].id
  entity_type = "nodebalancer"

  depends_on = [
    data.linode_nodebalancer.ingress,
    linode_domain_record.default,
    linode_lke_cluster.default,
    null_resource.applyDeployments,
    null_resource.applyServices,
    null_resource.applyStorages,
    null_resource.applySecrets,
    null_resource.applyConfigMaps,
    null_resource.applyNamespaces
  ]
}