output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "ARN used by API Gateway to invoke the Lambda function"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "ARN of the IAM execution role attached to the Lambda function"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the IAM execution role attached to the Lambda function"
  value       = aws_iam_role.this.name
}
