variable "aws_profile" {
  description = "The AWS profile to use for authentication"
  type        = string
  default     = "default"
}


variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-3"
  
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_1_cidr_block" {
  description = "CIDR block for the private subnet 1"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_2_cidr_block" {
  description = "CIDR block for the private subnet 2"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone_1" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "eu-west-3a"
  
}

variable "availability_zone_2" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "eu-west-3b"
}

#NAT Gateway is for providing internet access to private subnets like 	Software updates, external API calls
#It is set to false for cost-saving purposes, but can be enabled if needed
variable "nat_enabled" {
  description = "Enable NAT gateway for private subnet"
  type        = bool
  default     = false
  
}

