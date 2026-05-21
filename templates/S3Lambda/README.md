# S3-Lambda Architecture Template

Use this template to implement a simple *event-driven* architecture with a **Terraform/Floci** project.

> [!IMPORTANT]
> Ensure **Floci** is up and running and your *Floci credentials* are properly set. See [here](../../floci/floci.md) for more details.

## Design

Check the documentation [here](./docs/S3Lambda_Architecture.md) to find out about the defined architecture and technical details.

## Structure

- `Root module` split across `terraform.tf`, `providers.tf`, `data.tf`, `locals.tf`, `variables.tf`, `main.tf`, and `outputs.tf`
- Reusable modules under `modules/`: `s3`, `sqs`, `iam`, `lambda`, and `cloudwatch`
- Root-level `aws_s3_bucket_notification` resource wiring S3 object-created events to the Lambda function
- Environment-specific values in `terraform.tfvars`
- Architecture documentation and D2 diagrams under `docs/`

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
Set-Location .\modules\lambda
terraform init
terraform test
```
