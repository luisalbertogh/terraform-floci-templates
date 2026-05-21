# This will be a "real" provider configuration for AWS when running in a real environment.
# provider "aws" {
#   region  = var.aws_region
#   profile = "default"
# } 

# Provider for local testing with Floci
provider "aws" {
  region     = "eu-west-1"
  profile    = "floci" # Floci profile in AWS CLI
  # access_key = "test"
  # secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true   # required for path-style S3 URLs with Floci

  endpoints {
    cloudwatch = "http://localhost:4566"
    iam        = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    logs       = "http://localhost:4566"
    s3         = "http://localhost:4566"
    sqs        = "http://localhost:4566"
    sts        = "http://localhost:4566"
  }
}

terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
