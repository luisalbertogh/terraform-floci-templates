variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  type        = string
  default     = "/terraform-sandbox/demo-log-group"
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 14
  validation {
    condition     = var.log_retention_in_days >= 0
    error_message = "Retention period must be a non-negative integer."
  }
}

variable "tags" {
  description = "Tags applied to created resources"
  type        = map(string)
  default = {
    Project     = "terraform-sandbox"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
