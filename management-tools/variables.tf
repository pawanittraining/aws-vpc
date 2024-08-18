variable "vpc_cidr" {
  type = string

}

variable "public_sub" {
 type = list(string)
 default = [ "value" ]  
}

variable "jenkins_volume_id" {
  description = "The ID of the existing EBS volume to attach"
  type        = string
}

variable "vault_volume_id" {
  description = "The ID of the existing EBS volume to attach"
  type        = string
}
variable "availability_zone" {
  description = "The availability zone where the instance and volume are located"
  type        = string
  default = "us-east-1a"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}

variable "amiid" {
  type = string
}