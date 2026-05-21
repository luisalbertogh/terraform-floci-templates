variable "execution_role_name" {
  description = "Name of the ECS task execution IAM role"
  type        = string
  default     = "ecs-task-execution-role"
}

variable "task_role_name" {
  description = "Name of the ECS task IAM role granted to the running container"
  type        = string
  default     = "ecs-task-role"
}

variable "tags" {
  description = "Tags to apply to IAM roles"
  type        = map(string)
  default     = {}
}
