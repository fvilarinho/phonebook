variable "settings" {
  default = {
    general = {
      name   = "<name>"
      domain = "<domain>"
    }

    compute = {
      ami      = "<ami>"
      type     = "<type>"
      user     = "<user>"
      home_dir = "<home_dir>"
    }

    network = {
      vpc = {
        cidr = "<cidr>"

        subnets = {
          public_a = {
            cidr = "<cidr>"
          }
          private_a = {
            cidr = "<cidr>"
          }
          public_b = {
            cidr = "<cidr>"
          }
          private_b = {
            cidr = "<cidr>"
          }
        }
      }
    }
  }
}