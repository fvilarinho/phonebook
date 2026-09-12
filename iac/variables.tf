variable "compute" {
  default = {
    ami_id        = "ami-025d99823a4caad37"
    instance_type = "c8i-flex.large"
    user          = "ubuntu"
    home_dir      = "/home/ubuntu"
  }
}

variable "network" {
  default = {
    vpc = {
      cidr = "10.0.0.0/16"

      public_subnet_a = {
        cidr = "10.0.1.0/24"
      }

      private_subnet_a = {
        cidr = "10.0.2.0/24"
      }

      public_subnet_b = {
        cidr = "10.0.3.0/24"
      }

      private_subnet_b = {
        cidr = "10.0.4.0/24"
      }
    }
  }
}

variable "waf" {
  default = {
    restrictions = {
      rate_limit   = 1000
      body_size    = 16384
      allowed_ips  = []
      allowed_geos = ["BR", "US"]
    }
  }
}