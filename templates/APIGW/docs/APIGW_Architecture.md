# API Gateway + Lambda + DynamoDB — Architecture Documentation

## Executive Summary

This template provisions a serverless REST API stack on AWS. **API Gateway** exposes two HTTP endpoints (`GET /marks/get`, `POST /marks/post`) that proxy requests to a **Lambda** function, which reads and writes student mark records to a **DynamoDB** table. All runtime logs are shipped to **CloudWatch Logs**. Every resource is defined as code via Terraform modules, with no servers or VPC configuration required.

The design is well suited for lightweight CRUD APIs, rapid prototyping, and event-driven micro-services that need minimal operational overhead.

---

## System Context

![System Context](01-system-context.svg)

### Overview

Two external actors interact with the system: an **API Client** that issues HTTP requests, and a **Developer / CI-CD Pipeline** that deploys infrastructure via `terraform apply`.

### Key Components

| Actor / Component | Role |
|---|---|
| API Client | Invokes REST endpoints over HTTPS |
| Developer / CI-CD | Manages the full lifecycle of the stack via Terraform |
| API Gateway REST API | Public HTTP entry point; routes requests to Lambda via AWS_PROXY |
| Lambda (mark-management) | Business logic; reads/writes DynamoDB; runs Python 3.12 |
| DynamoDB (marks-table) | Serverless NoSQL store; keyed on `Class` (PK) + `Name` (SK) |
| CloudWatch Logs | Centralised log collection for Lambda invocations |

### Design Decisions

- **AWS_PROXY integration** passes the raw HTTP event to Lambda. No API Gateway request/response mapping is needed; the function owns the full response contract.
- **No authentication** is configured (`authorization = "NONE"`), appropriate for local/dev use. Add a Cognito authoriser or API key for production.

---

## Component Architecture

![Component Diagram](02-component.svg)

### Overview

The stack uses three Terraform modules (`log_group`, `lambda`, `api_gateway`) and two root-level resources (the DynamoDB table and an inline IAM policy). Each module encapsulates a single AWS service and exposes well-typed outputs.

### Key Components

| Module / Resource | Terraform resources | Responsibility |
|---|---|---|
| `lambda` | `aws_lambda_function`, `aws_iam_role`, policy attachment | Package and deploy the mark-management function; create its execution identity |
| `api_gateway` | REST API, 3 resources, 2 methods, 2 integrations, deployment, stage, `aws_lambda_permission` | Expose HTTP endpoints and wire them to Lambda |
| `log_group` | `aws_cloudwatch_log_group` | Provision the log group before the first Lambda invocation |
| `aws_dynamodb_table` (root) | `aws_dynamodb_table` | PAY_PER_REQUEST table with composite key |
| `aws_iam_role_policy` (root) | Inline policy | Grant Lambda `Scan` + `PutItem` on the marks table |

### Relationships

- `lambda.invoke_arn` → `api_gateway` module (integration URI for AWS_PROXY).
- `lambda.function_name` → `api_gateway` module (`aws_lambda_permission` resource).
- `dynamodb_table.arn` → root inline IAM policy.
- `dynamodb_table.name` → Lambda environment variable `DYNAMODB_TABLE_NAME`.

### NFR Considerations

- **Maintainability**: The inline DynamoDB policy is co-located in the root module, making the permission grant visible without navigating into nested modules.
- **Security**: Lambda's execution role uses `AWSLambdaBasicExecutionRole` (CloudWatch write only) as the base, with a tightly scoped inline policy that restricts DynamoDB access to a specific table ARN.

---

## Deployment Architecture

![Deployment Diagram](03-deployment.svg)

### Overview

All services are regional and fully managed — no VPC, no EC2, no container runtime to operate. The stack deploys into a single AWS region (`us-east-1` by default).

### Key Components

| Component | Tier | Notes |
|---|---|---|
| API Gateway (REST API + stage dev) | Edge / regional | Public HTTPS endpoint; no WAF in this template |
| Lambda (Python 3.12) | Compute | Serverless; auto-scales concurrently with requests |
| DynamoDB (PAY_PER_REQUEST) | Storage | No capacity planning required; scales automatically |
| CloudWatch Log Group | Observability | 14-day retention by default; configurable |
| IAM Role + inline policy | Security | Scoped to Lambda service principal and specific table ARN |

### Design Decisions

- **PAY_PER_REQUEST** billing removes the need to estimate capacity and eliminates idle costs for low-traffic dev/test environments.
- The Terraform archive provider (`hashicorp/archive`) zips the Lambda source at plan time. The `source_code_hash` ensures the function is redeployed only when source files change.

### NFR Considerations

- **Scalability**: Lambda and DynamoDB both scale automatically. API Gateway supports up to 10,000 RPS by default (adjustable via quota increase).
- **Reliability**: All three services offer 99.9 %+ SLAs. Lambda retries on throttles; DynamoDB is multi-AZ by default.
- **Cost**: With PAY_PER_REQUEST, there is no standing cost — charges accrue only when requests are processed.

---

## Data Flow

![Data Flow Diagram](04-data-flow.svg)

### Overview

Two request flows share the same Lambda handler, differentiated by `httpMethod`. A separate log flow runs asynchronously.

### Flow Description

| # | Flow | Description |
|---|---|---|
| 1a | GET /marks/get | Client → API GW → Lambda → DynamoDB Scan → items array |
| 1b | POST /marks/post | Client → API GW → Lambda → validation → DynamoDB PutItem → 201 |
| 2 | AWS_PROXY event | API GW serialises the full HTTP request as a JSON event to Lambda |
| 3a/3b | DynamoDB calls | `Scan` for GET; `PutItem` for POST; both authenticated via Lambda execution role |
| 4 | DynamoDB response | Items list (GET) or confirmation (POST) returned to Lambda |
| 5–6 | HTTP response chain | Lambda builds the response dict → API GW forwards status/body to client |
| 7 | Log flow | Lambda runtime ships stdout/stderr to CloudWatch via the `awslogs` integration |

### NFR Considerations

- **Performance**: Lambda cold-start for Python 3.12 is typically < 300 ms. DynamoDB single-item writes and full-table scans are sub-millisecond to low-millisecond for small tables.
- **Security**: Validation of required fields (`name`, `mark`, `class`) happens inside the Lambda handler before any DynamoDB write, preventing partial records.

---

## Key Workflows

![Sequence Diagram](05-sequence.svg)

### Overview

The sequence diagram shows the complete interaction chain for both the **GET** (read all marks) and **POST** (insert a mark) workflows.

### GET workflow

1. Client sends `GET /marks/get` to API Gateway.
2. API Gateway invokes Lambda with an `AWS_PROXY` event (`httpMethod = GET`).
3. Lambda calls `DynamoDB.Scan` on the marks table.
4. DynamoDB returns all items.
5. Lambda logs the invocation and returns `{"statusCode": 200, "body": {"items": [...]}}`.
6. API Gateway forwards the HTTP 200 response to the client.

### POST workflow

1. Client sends `POST /marks/post` with a JSON body containing `name`, `mark`, and `class`.
2. API Gateway invokes Lambda with the event body attached.
3. Lambda validates the presence of all required fields; returns HTTP 400 if any are missing.
4. Lambda calls `DynamoDB.PutItem` with `Class`, `Name`, and `Mark` attributes.
5. Lambda returns HTTP 201 with a confirmation message.
6. API Gateway forwards the response to the client.

### NFR Considerations

- **Reliability**: API Gateway retries Lambda invocations on 5xx errors (up to 2 retries for synchronous calls). DynamoDB PutItem is idempotent for the same composite key.
- **Maintainability**: The single `lambda_handler` function handles both methods, keeping business logic in one place. A `405 Method Not Allowed` is returned for unsupported verbs.

---

## Non-Functional Requirements Analysis

### Scalability

| Dimension | Behaviour |
|---|---|
| Concurrent requests | Lambda scales to 1,000 concurrent executions by default (account-level quota) |
| DynamoDB throughput | PAY_PER_REQUEST adapts automatically; no hot-partition risk for mark data |
| API Gateway | 10,000 RPS default quota; burst limit 5,000 RPS |

### Performance

- Median end-to-end latency for GET: ~10–50 ms (warm Lambda + DynamoDB Scan on small table).
- POST adds ~5 ms for PutItem over GET baseline.
- Cold-start latency (~200–400 ms) applies to the first request after a period of inactivity. Use provisioned concurrency for latency-sensitive production workloads.

### Security

| Control | Implementation |
|---|---|
| Least-privilege compute | Lambda role restricted to `BasicExecutionRole` + specific DynamoDB table ARN |
| No open admin access | `source_arn` on `aws_lambda_permission` limits invocation to this API's ARN only |
| Input validation | Handler validates required fields before writing to DynamoDB |
| No auth on endpoints | Acceptable for local/dev; add Cognito or API key for production |

### Reliability

| Mechanism | Detail |
|---|---|
| Automatic retries | API Gateway retries on Lambda throttle/5xx |
| DynamoDB durability | Multi-AZ storage, 99.999% durability |
| Log retention | 14 days default; set `log_retention_in_days = 0` for indefinite retention |

### Maintainability

- `terraform fmt -recursive` and `terraform test` are the only hygiene commands needed.
- Modules have isolated test suites under `modules/<name>/`.
- The `source_code_hash` on the Lambda resource ensures automatic redeploy when handler code changes.

---

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| DynamoDB full Scan on large tables | Medium | Add a GSI or switch to Query with a filter; paginate results |
| No authentication on API | High (dev) / Low (prod) | Add `aws_api_gateway_api_key` or Cognito authoriser before production |
| Lambda cold starts on infrequent traffic | Low | Enable provisioned concurrency or use Lambda SnapStart (Java only) |
| No rate limiting | Medium | Add a usage plan and throttle settings on the API Gateway stage |
| `latest` Lambda alias not used | Low | Pin task deployments to a versioned alias for zero-downtime deploys |

---

## Technology Stack

| Layer | Service / Tool | Justification |
|---|---|---|
| API | Amazon API Gateway (REST) | Managed HTTP entry point with built-in throttling, logging, and stage management |
| Compute | AWS Lambda (Python 3.12) | Zero-server, pay-per-invocation; ideal for CRUD APIs with infrequent traffic |
| Storage | Amazon DynamoDB | Serverless NoSQL; composite key model fits mark records naturally |
| Observability | Amazon CloudWatch Logs | Native Lambda integration; zero-config log capture |
| IaC | Terraform ≥ 1.5 + archive provider | Reproducible, modular, testable infrastructure |

---

## Cost Estimate

Approximate monthly costs for a low-traffic dev workload (100,000 requests/month) in `us-east-1`:

| Service | Configuration | Est. monthly cost |
|---|---|---|
| API Gateway | 100K REST API calls | ~$0.35 |
| Lambda | 100K invocations × 128 MB × 500 ms avg | ~$0.00 (free tier) |
| DynamoDB | PAY_PER_REQUEST, 100K reads + 100K writes | ~$0.13 |
| CloudWatch Logs | 1 GB ingestion + 14-day retention | ~$0.57 |
| **Total** | | **~$1.05 / month** |

> Above the free tier, Lambda costs ~$0.20 per 1M invocations + $0.0000166667 per GB-second. Use [AWS Pricing Calculator](https://calculator.aws/pricing/2/home) to model your exact workload.

---

## Next Steps

1. **Add authentication**: Attach a Cognito User Pool authoriser or an API key + usage plan to the API Gateway stage.
2. **Pagination**: Replace `DynamoDB.Scan` with a `Query` + pagination token for production-scale tables.
3. **Error observability**: Add a CloudWatch alarm on Lambda error rate and a dead-letter queue for async invocations.
4. **Rate limiting**: Configure throttle settings (`throttling_rate_limit`, `throttling_burst_limit`) on the stage.
5. **Versioning**: Publish Lambda versions and use aliases for blue/green deployments.

---

## References

- [Amazon API Gateway — REST API developer guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-rest-api.html)
- [AWS Lambda — Developer guide](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [Amazon DynamoDB — Developer guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)
- [API Gateway Lambda proxy integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html)
- [AWS Well-Architected Framework — Serverless Lens](https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/welcome.html)
- [Terraform AWS Provider — API Gateway resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api)
