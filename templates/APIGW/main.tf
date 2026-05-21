terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
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

# Lambda function that manages marks in DynamoDB
module "mark_management_lambda" {
  source = "./modules/lambda"

  function_name = var.lambda_function_name
  source_dir    = var.lambda_source_dir
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  environment_variables = merge(
    var.lambda_environment_variables,
    {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.marks.name
    }
  )
  tags = var.tags
}

# DynamoDB table used by Lambda for GET/POST marks operations
resource "aws_dynamodb_table" "marks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Class"
  range_key    = "Name"

  attribute {
    name = "Class"
    type = "S"
  }
  attribute {
    name = "Name"
    type = "S"
  }

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  name = "${var.lambda_function_name}-dynamodb-access"
  role = module.mark_management_lambda.role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Scan",
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.marks.arn
      }
    ]
  })
}

# API Gateway REST API with a GET /{path_part} → Lambda integration
module "mark_management_api" {
  source = "./modules/api_gateway"

  api_name             = var.api_name
  base_path_part       = var.api_base_path_part
  get_path_part        = var.api_get_path_part
  post_path_part       = var.api_post_path_part
  stage_name           = var.api_stage_name
  lambda_invoke_arn    = module.mark_management_lambda.invoke_arn
  lambda_function_name = module.mark_management_lambda.function_name
  tags                 = var.tags
}