# Terraform definition.
terraform {
  # Stores the provisioning state in Akamai Cloud Computing Object Storage (Please change to use your own).
  backend "s3" {
    bucket                      = "fvilarin-devops"
    key                         = "phonebook.tfstate"
    region                      = "us-east-1"
    endpoint                    = "us-east-1.linodeobjects.com"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
  }

  # Required providers definition.
  required_providers {
    linode = {
      source = "linode/linode"
      version = "2.31.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}