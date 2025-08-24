terraform {
  backend "s3" {
    bucket = "bookadvisor-terraform-state-2025"
    key = "infra/eks/terraform.tfstate"
    region = "eu-west-3"
    dynamodb_table = "bookadvisor-tf-locks"
    encrypt = true
  }
}