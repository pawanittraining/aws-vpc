
provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "devops-processing"
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Terraform = "true"
    Environment = "dev"
    Owner = "Devops"
  }
}
/*
#### EIP- enable if needs eip for nat gateway
resource "aws_eip" "nat" {
  count = 3

  domain = "vpc" 
  tags = local.tags
}
*/
################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr

  azs                 = local.azs

  private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 1)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]
  elasticache_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 12)]
  
  private_subnet_names = ["${local.name}-priv-1a", "${local.name}-priv-1b", "${local.name}-priv-1c"]
  database_subnet_names    = ["${local.name}-db-1a", "${local.name}-db-1b", "${local.name}-db-1c"]
  public_subnet_names = ["${local.name}-public-1a", "${local.name}-public-1b", "${local.name}-public-1c"]
  elasticache_subnet_names = ["${local.name}-elastic-1a", "${local.name}-elastic-1b", "${local.name}-elastic-1c"]
  create_database_subnet_group  = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway = false
  single_nat_gateway = false  # This ensures only one NAT Gateway is created
  one_nat_gateway_per_az = false  # Disable NAT Gateway per AZ
  #external_nat_ip_ids = "${aws_eip.nat.*.id}"
  #reuse_nat_ips = true 
  tags = local.tags
}
