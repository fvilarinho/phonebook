# Required providers definition.
terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}