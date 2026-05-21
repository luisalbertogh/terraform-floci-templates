# Basic Template

Use this template to trigger a **Terraform/Floci** project.

> [!IMPORTANT]
> Ensure **Floci** is up and running and your *Floci credentials* are properly set. See [here](../../floci/floci.md) for more details.

## Structure

- `Root module` with base files: `main.tf`, `providers.tf`, `variables.tf`, `output.tf`
- Reusable module in `modules/log_group` to create a CloudWatch Log Group
- Local backend to store state in `terraform.tfstate`

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

In this repository, the current unit test is in the `modules/log_group` module, so you can run it like this:

```powershell
Set-Location .\modules\log_group
terraform init
terraform test
```
