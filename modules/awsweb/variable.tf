variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default = "10.0.0.0/24"
}

variable "aws_key_name" {
  default = "jon@Computer"
}
variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default = "10.0.1.0/24"
}
variable "amis" {
  description = "AMIs by region"
  default = {
    eu-west-2 = "ami-050949f5d3aede071" /*Debian 10 AMD64*/
  }
}
variable "region"     {
  description = "AWS region to host your network"
  default     = "eu-west-2"
}
