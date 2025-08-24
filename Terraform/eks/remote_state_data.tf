#This file is used to retrieve the remote state of network resources
#It allows other Terraform configurations to access the outputs of the network module like VPC ID, subnets, etc.
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "bookadvisor-terraform-state-2025"
    key   = "network/terraform.tfstate"
    dynamodb_table = "bookadvisor-tf-locks"
    region = "eu-west-3"
  }
}