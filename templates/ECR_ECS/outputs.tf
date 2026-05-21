# Outputs are declared alphabetically.

output "ecr_repository_url" {
  description = "URL of the ECR repository for pushing images"
  value       = module.ecr.repository_url
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  description = "ARN of the active ECS task definition revision"
  value       = module.ecs.task_definition_arn
}

output "execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  value       = module.iam.execution_role_arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for ECS container logs"
  value       = module.log_group.name
}
