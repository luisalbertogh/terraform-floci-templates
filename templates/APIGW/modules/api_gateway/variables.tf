variable "api_name" {
  description = "Name of the API Gateway REST API"
  type        = string
}

variable "description" {
  description = "Description of the API Gateway REST API"
  type        = string
  default     = ""
}

variable "base_path_part" {
  description = "Base URL path segment for API resources (e.g. 'marks' creates /{stage}/marks/...)"
  type        = string
  default     = "marks"
}

variable "get_path_part" {
  description = "URL path segment for the GET endpoint under base_path_part"
  type        = string
  default     = "get"
}

variable "post_path_part" {
  description = "URL path segment for the POST endpoint under base_path_part"
  type        = string
  default     = "post"
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function to integrate with (use module.lambda.invoke_arn)"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to grant API Gateway permission to invoke"
  type        = string
}

variable "stage_name" {
  description = "Name of the API Gateway deployment stage"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
