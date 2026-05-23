# terraform-floci-templates

Terraform sample projects for AWS on Floci, implementing baselines for common AWS architectures.

> Also available in: [Español](./README.es.md)

## Templates

- [Basic](./templates/Basic/) - Simple template with a CloudWatch log group. Use this template to start off a new project with the simplest structure.
- [S3Lambda](./templates/S3Lambda/) - Event-driven architecture with S3 buckets and Lambda functions.
- [APIGW](./templates/APIGW/) - API REST architecture with API Gateway, Lambda functions and DynamoDB tables.
- [ECS](./templates/ECS/) - Containers architecture on ECS with ECR.

## How to use the templates

1. **Set AWS CLI credentials for Floci.** Configure the `floci` profile and endpoint settings as described in [floci/floci.md](./floci/floci.md).

2. **Spin up Floci.** Use the Docker Compose file and helper scripts in the [floci/](./floci/) folder to start the local AWS emulator.

3. **Use a template** from the [templates/](./templates/) folder:
   - Navigate into the template directory (e.g. `cd templates/APIGW`).
   - Read the `README.md` in that folder for template-specific details and variables.
   - Run the standard Terraform workflow: `terraform init`, `terraform validate`, `terraform plan`, `terraform apply`.

4. **Retrieve created resources** Use the AWS CLI to get information about the deployed resources. It is also possible to get details of the deployed Terraform resources by running the command `terraform output --json`.

