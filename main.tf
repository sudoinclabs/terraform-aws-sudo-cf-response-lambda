terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.34.0"
    }
  }
}

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = var.shared_credentials_file
  profile                 = var.profile
}

module "cf_custom_lambda_sns" {
  source = "./modules/cf_custom_lambda_sns"
}