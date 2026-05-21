variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for the table. Valid values: PAY_PER_REQUEST, PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be either PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "hash_key" {
  description = "Name of the hash key (partition key) attribute"
  type        = string
}

variable "range_key" {
  description = "Name of the range key (sort key) attribute. Set to null if not required"
  type        = string
  default     = null
}

variable "read_capacity" {
  description = "Number of read capacity units. Only used when billing_mode is PROVISIONED"
  type        = number
  default     = 5
  validation {
    condition     = var.read_capacity > 0
    error_message = "read_capacity must be greater than 0."
  }
}

variable "write_capacity" {
  description = "Number of write capacity units. Only used when billing_mode is PROVISIONED"
  type        = number
  default     = 5
  validation {
    condition     = var.write_capacity > 0
    error_message = "write_capacity must be greater than 0."
  }
}

variable "attributes" {
  description = "List of attribute definitions for the table. Must include all attributes used as hash/range keys in the table or any GSI/LSI. Valid types: S (String), N (Number), B (Binary)"
  type = list(object({
    name = string
    type = string
  }))
  validation {
    condition     = alltrue([for a in var.attributes : contains(["S", "N", "B"], a.type)])
    error_message = "Attribute type must be one of: S (String), N (Number), B (Binary)."
  }
}

variable "global_secondary_indexes" {
  description = "List of Global Secondary Index definitions"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number, 5)
    write_capacity     = optional(number, 5)
  }))
  default = []
  validation {
    condition     = alltrue([for gsi in var.global_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type)])
    error_message = "GSI projection_type must be one of: ALL, KEYS_ONLY, INCLUDE."
  }
}

variable "ttl_attribute" {
  description = "Name of the TTL attribute. Set to null to disable TTL"
  type        = string
  default     = null
}

variable "point_in_time_recovery_enabled" {
  description = "Whether to enable Point-in-Time Recovery (PITR). Recommended enabled for production tables"
  type        = bool
  default     = true
}

variable "sse_enabled" {
  description = "Whether to enable server-side encryption. When true with no kms_key_arn, uses the AWS managed key (aws/dynamodb)"
  type        = bool
  default     = true
}

variable "sse_kms_key_arn" {
  description = "ARN of the KMS Customer Managed Key for server-side encryption. Set to null to use the AWS managed key"
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Whether to enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Type of data written to the stream. Valid values: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES. Only used when stream_enabled is true"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "stream_view_type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

variable "deletion_protection_enabled" {
  description = "Whether to enable deletion protection on the table"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the DynamoDB table"
  type        = map(string)
  default     = {}
}
