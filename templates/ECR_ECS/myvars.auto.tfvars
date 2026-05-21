aws_region  = "eu-west-1"
environment = "dev"
project     = "ecs-demo"

# ── CloudWatch ───────────────────────────────────────────────────────────────
log_retention_in_days = 14

# ── ECR ──────────────────────────────────────────────────────────────────────
ecr_repository_name      = "app-images"
ecr_image_tag_mutability = "MUTABLE"
ecr_force_delete         = true

# ── IAM ──────────────────────────────────────────────────────────────────────
execution_role_name = "ecs-task-execution-role"
task_role_name      = "ecs-task-role"

# ── ECS ──────────────────────────────────────────────────────────────────────
cluster_name   = "app-cluster"
service_name   = "app-service"
task_family    = "app-task"
container_name = "app"
container_port = 80
cpu            = "256"
memory         = "512"
desired_count  = 1

# container_image defaults to <ecr_repository_url>:latest when not set.
# After the first apply, set this to pin a specific image tag:
# container_image = "000000000000.dkr.ecr.eu-west-1.localhost.localstack.cloud:4566/app-images:1.0.0"

# ── Networking ───────────────────────────────────────────────────────────────
# Floci does not manage VPC resources. These are placeholder IDs for local testing.
# Replace with real subnet and security group IDs when deploying to AWS.
subnet_ids         = ["subnet-00000000"]
security_group_ids = ["sg-00000000"]

tags = {
  Project     = "ecs-demo"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
