#!! Create the s3 bucket and dynamodb table using the aws cli or console before running terraform init


terraform {
  backend "s3" {
    bucket = "bookadvisor-terraform-state-2025"
    key = "Terraform/eks/terraform.tfstate"
    region = "eu-west-3"
    dynamodb_table = "bookadvisor-tf-locks"
    encrypt = true
  }
}