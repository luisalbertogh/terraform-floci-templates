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

> [!IMPORTANT] [This](https://floci.io/floci/getting-started/quick-start/#step-5-optional-push-and-pull-a-container-image-to-emulated-ecr) is the standard way to upload Docker images in Floci ECR repositories.
> In case of issues with the "localhost" resolution, use the alternative below. The AWS provider here is prepared for this option. See [here](https://floci.io/floci/services/ecr/#troubleshooting)

Build the image locally:

```bash
docker build . -t myimage:latest
```

Login and push to the ECR:

```bash
# Authenticate Docker with the Floci ECR registry
aws ecr get-login-password --endpoint-url http://localhost:4566 | docker login --username AWS --password-stdin localhost:5100

# Tag and push. "app-images" is the repository name. "myimage" is the local image name
docker tag myimage:latest localhost:5100/000000000000/eu-west-1/app-images:latest

docker push localhost:5100/000000000000/eu-west-1/app-images:latest

# Optional: use the helper script to resolve repository URI automatically,
# then login, tag, push, and verify in one step
powershell -ExecutionPolicy Bypass -File .\scripts\push-ecr-image.ps1
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
