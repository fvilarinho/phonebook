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
  label           = "${var.appName}-cn-fw"
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
    label    = "allow-akamai-ips"
    protocol = "TCP"
    ports    = "22,443"
    ipv4     = [
      "172.236.119.4/30",
      "172.234.160.4/30",
      "172.236.94.4/30",
      "139.144.212.168/31",
      "172.232.23.164/31"
    ]
    ipv6     = [
      "2600:3c06::f03c:94ff:febe:162f/128",
      "2600:3c06::f03c:94ff:febe:16ff/128",
      "2600:3c06::f03c:94ff:febe:16c5/128",
      "2600:3c07::f03c:94ff:febe:16e6/128",
      "2600:3c07::f03c:94ff:febe:168c/128",
      "2600:3c07::f03c:94ff:febe:16de/128",
      "2600:3c08::f03c:94ff:febe:16e9/128",
      "2600:3c08::f03c:94ff:febe:1655/128",
      "2600:3c08::f03c:94ff:febe:16fd/128"
    ]
  }

  depends_on = [
    linode_lke_cluster.default,
    local_sensitive_file.kubeconfig,
    null_resource.applyDeployments,
    null_resource.applyServices,
    null_resource.applyStorages,
    null_resource.applySecrets,
    null_resource.applyConfigMaps,
    null_resource.applyNamespaces
  ]
}