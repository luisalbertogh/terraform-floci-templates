# AWS provider configuration for Terraform
# provider "aws" {
#   region  = var.aws_region
#   profile = "default"
# }

# Provider for local testing with Floci
provider "aws" {
  region  = "eu-west-1"
  profile = "floci" # Floci profile in AWS CLI

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cloudwatch = "http://localhost:4566"
    ecr        = "http://localhost:4566"
    ecs        = "http://localhost:4566"
    iam        = "http://localhost:4566"
    logs       = "http://localhost:4566"
    sts        = "http://localhost:4566"
  }
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}
