# Retrieves my current IP address.
data "http" "myIp" {
  url = "https://ipinfo.io"
}

# Definition of the linode firewall rules.
resource "linode_firewall" "default" {
  label           = "${local.settings.label}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"
  linodes         = [ linode_instance.default.id ]

  # Allows Prometheus & Jaeger external traffic only from Grafana and my IP.
  inbound {
    label    = "allow_grafana"
    protocol = "TCP"
    ports    = "9090,16686"
    ipv4     = concat(local.settings.allowedIps, ["${jsondecode(data.http.myIp.response_body).ip}/32"])
    action   = "ACCEPT"
  }

  # Allows HTTP/HTTPs external traffic from everywhere.
  inbound {
    label    = "allow_http_https"
    protocol = "TCP"
    ports    = "80,443"
    ipv4     = [ "0.0.0.0/0" ]
    action   = "ACCEPT"
  }

  # Allows SSH external traffic only from my IP.
  inbound {
    label    = "allow_ssh"
    protocol = "TCP"
    ports    = "22"
    ipv4     = [ "${jsondecode(data.http.myIp.response_body).ip}/32" ]
    action   = "ACCEPT"
  }

  depends_on = [
    data.http.myIp,
    linode_instance.default
  ]
}