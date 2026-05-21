terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# This module creates a CloudWatch Log Group in AWS.
module "log_group" {
  source = "./modules/log_group"

  name              = var.log_group_name
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}
