variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_dir" {
  description = "Path to the directory containing the Lambda source code (relative to the root module)"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in the format file.method"
  type        = string
  default     = "handler.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime identifier"
  type        = string
  default     = "python3.12"
  validation {
    condition     = can(regex("^(python3\\.(9|10|11|12|13)|nodejs(18|20|22)\\.x|java(11|17|21)|dotnet[0-9]+)$", var.runtime))
    error_message = "Runtime must be a valid AWS Lambda runtime identifier (e.g. python3.12, nodejs20.x)."
  }
}

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 128
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "memory_size must be between 128 MB and 10240 MB."
  }
}

variable "timeout" {
  description = "Maximum execution time in seconds for the Lambda function"
  type        = number
  default     = 30
  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "timeout must be between 1 and 900 seconds."
  }
}

variable "environment_variables" {
  description = "Map of environment variables to pass to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
