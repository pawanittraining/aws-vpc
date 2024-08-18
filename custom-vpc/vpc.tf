
provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "devops-processing"
  region = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  Owner = "devops"
  common_tags = {
    Terraform = "true"
    Environment = "dev"
    Owner = "Devops"
  }
}

module "vpc" {
  source = "./vpc" 
  name = local.name
  vpc_cidr = local.vpc_cidr
  azs                 = local.azs
  private_subnet_cidrs        = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 1)]
  public_subnet_cidrs         = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnet_cidrs         = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]
  database_subnet_names = ["${local.name}-db-1a", "${local.name}-db-1b", "${local.name}-db-1c"]
  public_subnet_names = ["${local.name}-pub-1a", "${local.name}-pub-1b", "${local.name}-pub-1c"]
  private_subnet_names = ["${local.name}-priv-1a", "${local.name}-priv-1b", "${local.name}-priv-1c"]
  enable_nat_gateway  = true
 
}
