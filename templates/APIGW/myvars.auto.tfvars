log_group_name        = "/terraform-sandbox/demo-log-group"
log_retention_in_days = 14
bucket_name           = "my-unique-s3-bucket"

# Lambda
lambda_function_name = "mark-management"
lambda_source_dir    = "./lambdas/mark_management"
lambda_handler       = "handler.lambda_handler"
lambda_runtime       = "python3.12"

# API Gateway
api_name           = "mark-management-api"
api_base_path_part = "marks"
api_get_path_part  = "get"

api_post_path_part = "post"
api_stage_name     = "dev"

dynamodb_table_name = "marks-table"

tags = {
  Project     = "terraform-sandbox"
  Environment = "dev"
  ManagedBy   = "terraform"
}
