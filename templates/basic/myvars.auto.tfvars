aws_region            = "eu-central-1"
log_group_name        = "/terraform-sandbox/demo-log-group"
log_retention_in_days = 14

tags = {
  Project     = "terraform-sandbox"
  Environment = "dev"
  ManagedBy   = "terraform"
}
