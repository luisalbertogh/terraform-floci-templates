locals {
  log_group_name  = "/ecs/${var.cluster_name}"
  container_image = var.container_image != null ? var.container_image : "${module.ecr.repository_url}:latest"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  })
}

# ─── CloudWatch Log Group ─────────────────────────────────────────────────────

module "log_group" {
  source = "./modules/log_group"

  name              = local.log_group_name
  retention_in_days = var.log_retention_in_days
  tags              = local.common_tags
}

# ─── ECR Repository ───────────────────────────────────────────────────────────

module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete
  tags                 = local.common_tags
}

# ─── IAM Roles ────────────────────────────────────────────────────────────────

module "iam" {
  source = "./modules/iam"

  execution_role_name = var.execution_role_name
  task_role_name      = var.task_role_name
  tags                = local.common_tags
}

# ─── ECS Cluster, Task Definition, and Service ────────────────────────────────

module "ecs" {
  source = "./modules/ecs"

  cluster_name       = var.cluster_name
  service_name       = var.service_name
  task_family        = var.task_family
  container_name     = var.container_name
  container_image    = local.container_image
  container_port     = var.container_port
  cpu                = var.cpu
  memory             = var.memory
  desired_count      = var.desired_count
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  log_group_name     = module.log_group.name
  aws_region         = var.aws_region
  tags               = local.common_tags
}
