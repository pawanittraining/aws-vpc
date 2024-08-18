terraform {
  required_version = ">=1.6.0"
  required_providers {
    aws = {
      version = "= 5.62.0"
      source = "hashicorp/aws"
    }
  }
}
/*
provider "aws" {
  region = var.aws_region
  profile = "default"
}
*/