data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "bookadvisor-terraform-state-2025"
    key   = "network/terraform.tfstate"
    dynamodb_table = "bookadvisor-tf-locks"
    region = "eu-west-3"
  }
}