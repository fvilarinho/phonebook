variable linodeToken {}

variable appName {}

variable appDomain {}

variable settings {
  default = {
    region  = "<region>"
    nodes   = {
      type  = "<type>"
      count = 2
    }
    allowedIps = {
      ipv4 = [ "0.0.0.0/0" ]
      ipv6 = [ "::/0" ]
    }
  }
}