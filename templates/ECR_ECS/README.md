# ECR + ECS Fargate Architecture Template

Use this template to implement a container-based architecture with a **Terraform/Floci** project.

> [!IMPORTANT]
> Ensure **Floci** is up and running and your *Floci credentials* are properly set. See [Floci setup guide](../../floci/floci.md) for more details.

## Design

This template provisions an ECR + ECS Fargate stack where:

- An **ECR repository** stores Docker container images.
- An **ECS cluster** hosts the containerised workload.
- An **ECS service** (Fargate launch type) pulls the image from ECR and keeps the desired number of tasks running.
- **CloudWatch Logs** collects container output via the `awslogs` driver.
- **IAM roles** follow least-privilege: a separate *execution role* is used by ECS to pull images and write logs, and a *task role* is available to the running container for any additional AWS API access.

> [!NOTE]
> Floci does not support VPC resources. Placeholder subnet and security group IDs (`subnet-00000000` / `sg-00000000`) are set as defaults for local testing. Replace them with real IDs when deploying to AWS.

## Structure

```text
ECR_ECS/
├── main.tf                   # Module composition and root locals
├── providers.tf              # Floci-compatible AWS provider + Terraform block
├── variables.tf              # All input variables
├── outputs.tf                # Useful outputs (ECR URL, cluster ARN, …)
├── myvars.auto.tfvars        # Default values for Floci
└── modules/
    ├── ecr/                  # ECR repository
    ├── ecs/                  # ECS cluster, task definition, and service
    ├── iam/                  # Task execution role and task role
    └── log_group/            # CloudWatch Log Group
```

## Quickstart

1. Initialize Terraform:

```powershell
terraform init
```

1. Format the configuration to keep a consistent style:

```powershell
terraform fmt -recursive
```

1. Review the execution plan:

```powershell
terraform plan
```

Optionally, you can save the plan to a file and apply it later:

```powershell
terraform plan -out=tfplan
terraform apply tfplan
```

1. Apply the changes:

```powershell
terraform apply
```

1. Push an image to the ECR repository (after apply):

```bash
# Authenticate Docker with the Floci ECR registry
aws --endpoint-url http://localhost:4566 ecr get-login-password --region eu-west-1 --profile floci \
  | docker login --username AWS --password-stdin \
    000000000000.dkr.ecr.eu-west-1.localhost.localstack.cloud:4566

# Tag and push
docker tag my-app:latest \
  000000000000.dkr.ecr.eu-west-1.localhost.localstack.cloud:4566/app-images:latest

docker push \
  000000000000.dkr.ecr.eu-west-1.localhost.localstack.cloud:4566/app-images:latest
```

1. Destroy the resources when you are done:

```powershell
terraform destroy
```

## Variables reference

| Variable | Default | Description |
| --- | --- | --- |
| `aws_region` | `eu-west-1` | AWS region |
| `environment` | `dev` | Deployment environment (`dev` / `staging` / `prod`) |
| `project` | `ecs-demo` | Project name used in tags |
| `ecr_repository_name` | `app-images` | ECR repository name |
| `ecr_image_tag_mutability` | `MUTABLE` | Tag mutability (`MUTABLE` or `IMMUTABLE`) |
| `ecr_force_delete` | `true` | Delete repo even if it holds images |
| `cluster_name` | `app-cluster` | ECS cluster name |
| `service_name` | `app-service` | ECS service name |
| `task_family` | `app-task` | Task definition family |
| `container_name` | `app` | Container name inside the task |
| `container_image` | *(ECR URL):latest* | Image to run; defaults to `<ecr_repo_url>:latest` |
| `container_port` | `80` | Port exposed by the container |
| `cpu` | `256` | Fargate CPU units |
| `memory` | `512` | Fargate memory in MiB |
| `desired_count` | `1` | Number of running task instances |
| `subnet_ids` | `["subnet-00000000"]` | Subnets for the ECS service (placeholder for Floci) |
| `security_group_ids` | `["sg-00000000"]` | Security groups for the ECS service (placeholder for Floci) |

## Outputs

| Output | Description |
| --- | --- |
| `ecr_repository_url` | Full ECR repository URL to push images to |
| `ecs_cluster_arn` | ARN of the ECS cluster |
| `ecs_cluster_name` | Name of the ECS cluster |
| `ecs_service_name` | Name of the ECS service |
| `ecs_task_definition_arn` | ARN of the current task definition revision |
| `execution_role_arn` | ARN of the ECS task execution IAM role |
| `log_group_name` | CloudWatch log group name for container logs |

## Useful AWS CLI commands

List ECR repositories:

```bash
aws --endpoint-url http://localhost:4566 ecr describe-repositories --region eu-west-1
```

List ECS clusters:

```bash
aws --endpoint-url http://localhost:4566 ecs list-clusters --region eu-west-1
```

Describe the ECS service:

```bash
aws --endpoint-url http://localhost:4566 ecs describe-services \
  --cluster app-cluster --services app-service \
  --region eu-west-1
```

List running tasks:

```bash
aws --endpoint-url http://localhost:4566 ecs list-tasks \
  --cluster app-cluster \
  --region eu-west-1 --profile floci
```
