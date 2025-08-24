
#!! Create the s3 bucket and dynamodb table using the aws cli or console before running terraform init

#This is the backend configuration for Terraform state management
#It specifies that the state will be stored in an S3 bucket, with a DynamoDB
#table for state locking to prevent concurrent modifications(two users running terraform apply at the same time)
#This is a best practice for production environments to ensure state consistency and prevent conflicts
#The s3 will have the terraform state file, and the dynamodb table will have the locks
terraform {
  backend "s3" {
    bucket = "bookadvisor-terraform-state-2025"
    key   = "rds/terraform.tfstate"
    dynamodb_table = "bookadvisor-tf-locks"
    region = "eu-west-3"
    encrypt = true
    #i tried to use profile= var.aws_profile but it didn't work because the backend run before the provider is configured
    #so i export the AWS_PROFILE environment variable before running terraform init
  }
}