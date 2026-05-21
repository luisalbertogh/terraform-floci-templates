output "log_group_name" {
  description = "Name of the created CloudWatch Log Group"
  value       = module.log_group.name
}

output "log_group_arn" {
  description = "ARN of the created CloudWatch Log Group"
  value       = module.log_group.arn
}
