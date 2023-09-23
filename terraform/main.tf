terraform {
  backend "s3" {
    # IMPORTANT NOTE: you need to adjust here to your own S3 state bucket
    bucket  = "demo-harley-systems-state"
    key     = "terraform/terraform.tfstate"
    region  = "us-east-1"
    # IMPORTANT NOTE: you need to adjust here to your own AWS PROFILE
    profile = "harley-systems-mfa"
  }
}

# Define provider
provider "aws" {
  region = var.demo_region  # Update with your desired AWS region
}
