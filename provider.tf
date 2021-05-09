variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable AWS_SSH_KEY {}
terraform {
  required_providers {
    aws = {
    source  = "hashicorp/aws"
    version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "jonrobtfstate"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
provider "aws" {
  region = "eu-west-2"
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
}
