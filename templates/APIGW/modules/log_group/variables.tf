variable "name" {
  description = "Name of the CloudWatch Log Group"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to the Log Group"
  type        = map(string)
  default     = {}
}
