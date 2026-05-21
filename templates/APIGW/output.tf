output "log_group_name" {
  description = "Name of the created CloudWatch Log Group"
  value       = module.log_group.name
}

output "log_group_arn" {
  description = "ARN of the created CloudWatch Log Group"
  value       = module.log_group.arn
}

output "lambda_function_name" {
  description = "Name of the mark management Lambda function"
  value       = module.mark_management_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the mark management Lambda function"
  value       = module.mark_management_lambda.function_arn
}

output "api_invoke_url" {
  description = "Full URL to invoke the marks GET endpoint"
  value       = module.mark_management_api.invoke_url
}

output "api_get_invoke_url" {
  description = "Full URL to invoke the marks GET endpoint"
  value       = module.mark_management_api.get_invoke_url
}

output "api_post_invoke_url" {
  description = "Full URL to invoke the marks POST endpoint"
  value       = module.mark_management_api.post_invoke_url
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used by Lambda"
  value       = aws_dynamodb_table.marks.name
}
