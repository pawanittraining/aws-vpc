variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default = [ "value" ]
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "public_subnet_names" {
  description = "Name of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Name of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "database_subnet_names" {
  description = "Name of CIDR blocks for the private subnets."
  type        = list(string)
}
variable "azs" {
  description = "A list of availability zones for the subnets."
  type        = list(string)
}

variable "name" {
  description = "A prefix for naming the resources."
  type        = string
}

variable "enable_nat_gateway" {
  description = "A boolean to determine if a NAT Gateway should be created."
  type        = bool
  default     = true
}
