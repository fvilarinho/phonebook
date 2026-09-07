terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }
  }

  # Remote state management in S3 bucket.
  backend "s3" {}
}

# AWS provider settings.
provider "aws" {}