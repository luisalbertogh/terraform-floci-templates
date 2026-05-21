# Input variables are declared alphabetically.

variable "aws_region" {
  description = "AWS region where all resources will be deployed"
  type        = string
  default     = "eu-west-1"
}

# ── Project metadata ─────────────────────────────────────────────────────────

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "project" {
  description = "Project name used in resource naming and tagging"
  type        = string
  default     = "ecs-demo"
}

variable "tags" {
  description = "Tags applied to all created resources"
  type        = map(string)
  default = {
    Project     = "ecs-demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# ── CloudWatch ───────────────────────────────────────────────────────────────

variable "log_retention_in_days" {
  description = "Number of days to retain ECS container logs in CloudWatch"
  type        = number
  default     = 14

  validation {
    condition     = var.log_retention_in_days >= 0
    error_message = "Retention period must be a non-negative integer."
  }
}

# ── ECR ──────────────────────────────────────────────────────────────────────

variable "ecr_repository_name" {
  description = "Name of the ECR repository where container images are stored"
  type        = string
  default     = "app-images"
}

variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting for the ECR repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "ecr_force_delete" {
  description = "If true, delete the ECR repository even if it contains images"
  type        = bool
  default     = true
}

# ── IAM ──────────────────────────────────────────────────────────────────────

variable "execution_role_name" {
  description = "Name of the ECS task execution IAM role (used to pull images and write logs)"
  type        = string
  default     = "ecs-task-execution-role"
}

variable "task_role_name" {
  description = "Name of the ECS task IAM role granted to the running container"
  type        = string
  default     = "ecs-task-role"
}

# ── ECS ──────────────────────────────────────────────────────────────────────

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "app-cluster"
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "app-service"
}

variable "task_family" {
  description = "Task definition family name"
  type        = string
  default     = "app-task"
}

variable "container_name" {
  description = "Name of the container inside the ECS task"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image to run in the ECS task. Defaults to <ecr_repository_url>:latest when null"
  type        = string
  default     = null
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

# ── Networking ───────────────────────────────────────────────────────────────
# Floci does not support VPC resources. Placeholder IDs are set as defaults for
# local testing. Replace with real subnet and security group IDs for AWS deployments.

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service network configuration"
  type        = list(string)
  default     = ["subnet-00000000"]
}

variable "security_group_ids" {
  description = "List of security group IDs for the ECS service network configuration"
  type        = list(string)
  default     = ["sg-00000000"]
}
