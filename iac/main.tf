terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.20.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.3.1"
    }
  }

  backend "s3" {}
}

data "aws_region" "current" {}