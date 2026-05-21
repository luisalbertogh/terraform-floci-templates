# API REST Architecture Template

Use this template to implement a simple *event-driven* architecture with a **Terraform/Floci** project.

> [!IMPORTANT]
> Ensure **Floci** is up and running and your *Floci credentials* are properly set. See [Floci setup guide](../../floci/floci.md) for more details.

## Design

This template provisions an API Gateway + Lambda + DynamoDB stack where:

- `GET /marks/get` returns all records from a DynamoDB table.
- `POST /marks/post` accepts JSON payloads and inserts records into the same table.
- DynamoDB uses `Class` (hash key, string) and `Name` (range key, string).

## Structure

- `Root module` with base files: `main.tf`, `providers.tf`, `variables.tf`, `output.tf`, and `myvars.auto.tfvars`
- Lambda source code under `lambdas/mark_management`
- Reusable modules under `modules/`: `api_gateway`, `lambda`, `log_group`, and `dynamodb`
- Current root composition uses `api_gateway`, `lambda`, and `log_group` modules
- Root-level `aws_dynamodb_table` with key schema `Class` (hash key, string) + `Name` (range key, string)
- Root-level IAM inline policy allowing Lambda to `Scan` and `PutItem` in DynamoDB

## Quickstart

1. Initialize Terraform:

```powershell
terraform init
```

2. Format the configuration to keep a consistent style:

```powershell
terraform fmt -recursive
```

3. Review the execution plan:

```powershell
terraform plan
```

Optionally, you can save the plan to a file and apply it later:

```powershell
terraform plan -out=tfplan
terraform apply tfplan
```

4. Apply the changes:

```powershell
terraform apply
```

5. Destroy the resources when you are done:

```powershell
terraform destroy
```

## Tests

To run native Terraform tests:

```powershell
terraform test
```

In this template, Terraform tests are scoped to individual modules. Run tests from a module directory, for example:

```powershell
Set-Location .\modules\api_gateway
terraform init
terraform test
```

To invoke the API Gateway, use this command:

```bash
curl http://localhost:4566/restapis/<api_gw_id>/<stage_name>/_user_request_/marks/get
```

Invoke POST with a payload:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","mark":"9.5","class":"A"}' \
  http://localhost:4566/restapis/<api_gw_id>/<stage_name>/_user_request_/marks/post
```

## Troubleshooting

Issues with API Gateway, list gateways with:

```bash
aws apigateway get-rest-apis --region eu-west-1
```

Remove API Gateway with:

```bash
aws --endpoint-url http://localhost:4566 apigateway delete-rest-api --rest-api-id <api-id> --region eu-west-1 --profile floci
```
