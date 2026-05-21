output "name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}

output "arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "id" {
  description = "ID of the DynamoDB table (same as name)"
  value       = aws_dynamodb_table.this.id
}

output "stream_arn" {
  description = "ARN of the DynamoDB stream. Empty string if streams are not enabled"
  value       = aws_dynamodb_table.this.stream_arn
}

output "stream_label" {
  description = "Timestamp of the DynamoDB stream in ISO 8601 format. Empty string if streams are not enabled"
  value       = aws_dynamodb_table.this.stream_label
}
