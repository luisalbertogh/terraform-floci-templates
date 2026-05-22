# ECR + ECS Fargate — Architecture Documentation

## Executive Summary

This template provisions a container-based workload delivery stack on AWS using **Amazon ECR** for image storage and **Amazon ECS Fargate** for serverless container execution. The architecture follows a least-privilege IAM model, collects all runtime logs in **CloudWatch Logs**, and is expressed entirely as code via Terraform modules.

The design is suitable for stateless HTTP workloads, background processors, or any containerised service that does not require managing EC2 instances.

---

## System Context

![System Context](01-system-context.svg)

### Overview

The diagram shows the system boundary of the ECR + ECS stack and its two primary external actors: a **Developer / CI-CD Pipeline** that builds and pushes container images, and an **End User** that sends HTTP requests to the running container.

### Key Components

| Actor / Component | Role |
|---|---|
| Developer / CI-CD | Builds Docker images and pushes them to ECR |
| End User | Consumes the service exposed by the Fargate task |
| ECR Repository | Regional image registry; acts as the source of truth for container images |
| ECS Fargate Service | Runs the containerised workload without managing servers |
| CloudWatch Logs | Centralised log store; receives stdout/stderr from all containers |

### Design Decisions

- ECR is kept inside the AWS boundary. External actors authenticate via `ecr:GetAuthorizationToken` before pushing.
- CloudWatch Logs is the sole logging sink, keeping the architecture simple and aligned with AWS-native observability tooling.

---

## Component Architecture

![Component Diagram](02-component.svg)

### Overview

The stack is decomposed into four Terraform modules. Each module owns exactly one concern and exposes its outputs as inputs to downstream modules.

### Key Components

| Module | Resources managed | Responsibilities |
|---|---|---|
| `ecr` | `aws_ecr_repository` | Stores and versions container images |
| `iam` | Two `aws_iam_role` + policy attachment | Separates execution-time identity (pull/log) from runtime identity (app permissions) |
| `log_group` | `aws_cloudwatch_log_group` | Ensures the log group exists before the first container starts |
| `ecs` | Cluster, Task Definition, Service | Defines what to run, how many instances, and network placement |

### Relationships

- `ecr.repository_url` flows into `ecs.task_definition` as the container image source.
- `iam.execution_role_arn` and `iam.task_role_arn` are injected into the task definition.
- `log_group.name` is passed to the task definition's `logConfiguration` block.

### NFR Considerations

- **Maintainability**: Each module has a single, clearly bounded responsibility. Updating the image tag or log retention requires changing only one module's variable.
- **Security**: The execution role is limited to `AmazonECSTaskExecutionRolePolicy` (ECR pull + CloudWatch write). The task role starts empty, enforcing least-privilege for the running container.

---

## Deployment Architecture

![Deployment Diagram](03-deployment.svg)

### Overview

All resources live in a single AWS region (default `eu-west-1`). ECR and CloudWatch are regional services outside the VPC. The Fargate task runs inside a named subnet with a security group controlling inbound traffic.

### Key Components

| Component | Placement | Notes |
|---|---|---|
| ECR Repository | Regional (no VPC) | Accessed by Fargate via AWS PrivateLink or internet endpoint |
| IAM Roles | Global | Assumed by the Fargate task at startup |
| VPC / Subnet | Customer-managed | Placeholder IDs provided for local testing; replace with real IDs for AWS |
| ECS Cluster + Fargate Task | Inside VPC subnet | `assign_public_ip = true` for internet-facing workloads |
| CloudWatch Log Group | Regional (no VPC) | Named `/ecs/<cluster_name>` |

### Design Decisions

- `network_mode = "awsvpc"` gives each Fargate task its own ENI, providing task-level security group control.
- `assign_public_ip = true` is the default. For production, replace with a private subnet + NAT gateway and a load balancer in a public subnet.

### NFR Considerations

- **Scalability**: ECS service `desired_count` can be updated at any time; combined with an Application Auto Scaling policy it supports horizontal scale-out.
- **Reliability**: ECS continuously monitors task health and replaces failed tasks to maintain `desired_count`.
- **Security**: Subnet and security group IDs are explicit inputs. No inbound rules are created by this template — callers must attach appropriate ingress rules.

---

## Data Flow

![Data Flow Diagram](04-data-flow.svg)

### Overview

Five numbered flows capture the complete lifecycle of data in the system: image publish, image delivery, task scheduling, user traffic, and log shipping.

### Flow Description

| # | Flow | Transport |
|---|---|---|
| 1 | Developer pushes image | Docker registry protocol over HTTPS to ECR |
| 2 | Fargate pulls image | ECR `BatchGetImage` API, authenticated via execution role |
| 3 | ECS Service starts task | Internal ECS control plane |
| 4 | End user sends request | TCP to the container port (default 80) |
| 5 | Container emits logs | `awslogs` Docker log driver → CloudWatch Logs |

### NFR Considerations

- **Performance**: ECR layer caching reduces image pull times on subsequent deployments. Large images should use multi-stage Docker builds.
- **Security**: All AWS API calls in flows 2 and 5 are authenticated with short-lived STS credentials from the execution role.

---

## Key Workflows

![Sequence Diagram](05-sequence.svg)

### Overview

The sequence diagram shows the full task launch workflow triggered when a new image is pushed and `terraform apply` (or a service update) is run.

### Flow of Operations

1. Developer pushes a tagged image to ECR.
2. Terraform updates the ECS service (or a deployment is triggered externally).
3. ECS schedules a new Fargate task.
4. Fargate assumes the execution role via STS to obtain temporary credentials.
5. Fargate authenticates with ECR and pulls the image layers.
6. The container starts and the `awslogs` driver begins streaming stdout/stderr to CloudWatch Logs.

### NFR Considerations

- **Reliability**: If the image pull fails (e.g., wrong tag), ECS marks the task as `STOPPED` and retries according to the service's deployment configuration. No manual intervention is required.
- **Security**: Image pull credentials are never stored; they are derived on-demand via STS and expire automatically.

---

## Non-Functional Requirements Analysis

### Scalability

| Mechanism | Detail |
|---|---|
| Horizontal scaling | Increase `desired_count` or attach an `aws_appautoscaling_policy` to the ECS service |
| CPU / Memory | Adjust `cpu` and `memory` task-level variables without changing the image |
| ECR | Regional service with no throughput limits under normal usage |

### Performance

- Container startup time is dominated by image pull latency. Keep images small (< 500 MB compressed) and use ECR pull-through cache or pre-warmed tasks if cold-start latency is critical.
- Fargate task placement is managed by AWS; no bin-packing tuning is required.

### Security

| Control | Implementation |
|---|---|
| Least-privilege IAM | Execution role limited to ECR pull + CW write; task role is empty by default |
| Image scanning | `scan_on_push` is configurable per `ecr_force_delete` variable; enable for production |
| Network isolation | `awsvpc` mode gives each task its own ENI and security group |
| No long-lived credentials | Fargate uses STS-derived short-lived tokens for all AWS API calls |

### Reliability

| Mechanism | Detail |
|---|---|
| Task replacement | ECS service reconciliation loop restarts failed tasks automatically |
| Log durability | CloudWatch Logs retention configurable (`log_retention_in_days`); default 14 days |
| Image immutability | Set `ecr_image_tag_mutability = "IMMUTABLE"` in production to prevent tag overwrite |

### Maintainability

- All inputs are declared in `variables.tf` with descriptions and validations.
- Modules are self-contained; updating one module does not require changes to others.
- `terraform fmt -recursive` and `terraform plan` are the only commands needed for a safe change cycle.

---

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Public IP exposure | Medium | Move to private subnet + NAT gateway + ALB for production |
| `latest` tag overwritten silently | Medium | Set `ecr_image_tag_mutability = "IMMUTABLE"` and use versioned tags in CI/CD |
| No health check on service | Medium | Add `health_check_grace_period_seconds` and an ALB target group health check |
| Single AZ deployment | High (local/dev) | Provide subnets from multiple AZs via `subnet_ids` for production |
| Logs lost after retention period | Low | Adjust `log_retention_in_days` or export to S3 via a subscription filter |

---

## Technology Stack

| Layer | Service / Tool | Justification |
|---|---|---|
| Container registry | Amazon ECR | Native integration with ECS, IAM-authenticated, no external registry needed |
| Container orchestration | Amazon ECS Fargate | Serverless; no EC2 management; pay-per-task-second |
| IAM | AWS IAM Roles | Fine-grained, auditable access control |
| Observability | Amazon CloudWatch Logs | Zero-config with `awslogs` driver; integrated with Insights and alarms |
| IaC | Terraform ≥ 1.5 | Modular, reusable, state-managed |

---

## Cost Estimate

Approximate monthly costs for a single Fargate task (0.25 vCPU / 0.5 GB) running 24/7 in `eu-west-1`:

| Service | Configuration | Est. monthly cost |
|---|---|---|
| ECR | 1 GB storage + 10 GB data transfer | ~$0.11 |
| ECS Fargate | 0.25 vCPU × 730 h | ~$9.18 |
| ECS Fargate | 0.5 GB memory × 730 h | ~$2.02 |
| CloudWatch Logs | 5 GB ingestion + 14-day retention | ~$2.75 |
| **Total** | | **~$14 / month** |

> Costs increase linearly with `desired_count`. Use [AWS Pricing Calculator](https://calculator.aws/pricing/2/home) to model your specific CPU/memory and task count.

---

## Next Steps

1. **Production hardening**: Replace placeholder subnet/SG IDs, set `ecr_image_tag_mutability = "IMMUTABLE"`, add an Application Load Balancer.
2. **Auto-scaling**: Add an `aws_appautoscaling_target` and `aws_appautoscaling_policy` targeting the ECS service.
3. **CI/CD integration**: Integrate the `push-ecr-image.ps1` script (or equivalent) into your pipeline to automate image build, push, and service update.
4. **Health checks**: Configure ALB health checks and ECS service `health_check_grace_period_seconds`.
5. **Observability**: Add CloudWatch Container Insights and metric alarms for CPU/memory utilisation.

---

## References

- [Amazon ECR documentation](https://docs.aws.amazon.com/ecr/latest/userguide/what-is-ecr.html)
- [Amazon ECS — Fargate launch type](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)
- [ECS Task IAM roles](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html)
- [CloudWatch Logs — awslogs driver](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html)
- [AWS Well-Architected Framework — Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)
- [Terraform AWS Provider — ECS resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster)
