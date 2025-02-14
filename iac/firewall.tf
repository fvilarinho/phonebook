resource "linode_firewall" "default" {
   label           = "${local.definitions.label}-fw"
   tags            = local.definitions.tags
   inbound_policy  = "DROP"
   outbound_policy = "ACCEPT"

   inbound {
     action   = "ACCEPT"
     label    = "allow-akamai-ips"
     protocol = "TCP"
     ports    = "22,443"
     ipv4 = [
       "139.144.212.168/31",
       "172.232.23.164/31",
       "172.236.119.4/30",
       "172.234.160.4/30",
       "172.236.94.4/30"
     ]
     ipv6 = [
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

   inbound {
     action   = "ACCEPT"
     label    = "allow-external-ips"
     protocol = "TCP"
     ipv4     = local.definitions.allowedIps.ipv4
     ipv6     = local.definitions.allowedIps.ipv6
   }

   inbound {
     action   = "ACCEPT"
     label    = "allow-icmp"
     protocol = "ICMP"
     ipv4     = [ "0.0.0.0/0" ]
   }

   linodes = [ linode_instance.default.id]

   depends_on = [ linode_instance.default ]
   ]
 }