variable "credentials" {
  default = {
    token = "<token>"
  }
}

variable "settings" {
  default = {
    label      = "phonebook"
    tags       = [ "demo", "phonebook" ]
    region     = "<region>"
    type       = "<type>"
    allowedIps = {
      ipv4 = [ "0.0.0.0/0" ]
      ipv6 = [ "::1/128" ]
    }
  }
}