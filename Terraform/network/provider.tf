provider "aws" {
  region           = "eu-west-3"
  profile          = var.aws_profile
}
#this is for version pinning and it's best practice for production environments
terraform {
  required_version = "~> 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
}
