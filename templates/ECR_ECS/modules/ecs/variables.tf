variable "aws_region" {
  description = "AWS region used in the container log configuration"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "task_family" {
  description = "Task definition family name"
  type        = string
}

variable "container_name" {
  description = "Name of the container inside the ECS task"
  type        = string
}

variable "container_image" {
  description = "Docker image to run in the ECS task (e.g. <account>.dkr.ecr.<region>.amazonaws.com/<repo>:tag)"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "CPU units for the Fargate task (256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for the Fargate task in MiB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of ECS task instances to run"
  type        = number
  default     = 1
}

variable "execution_role_arn" {
  description = "ARN of the IAM role used by ECS to pull images and write logs"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM role granted to the running container"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service network configuration"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ECS service network configuration"
  type        = list(string)
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group for container logs"
  type        = string
}

variable "tags" {
  description = "Tags to apply to ECS resources"
  type        = map(string)
  default     = {}
}
