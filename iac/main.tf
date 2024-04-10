# Required providers definition.
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.18.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
    http = {
      source  = "hashicorp/http"
    }
  }
}