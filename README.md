# terraform-sandbox

Proyecto de pruebas para aprender Terraform.

## Formacion

- Guia de practica: [EJERCICIOS_TERRAFORM_BASICO.md](EJERCICIOS_TERRAFORM_BASICO.md)

## Estructura

- `Root module` con archivos base: `main.tf`, `providers.tf`, `variables.tf`, `output.tf`
- Módulo reutilizable en `modules/log_group` para crear un CloudWatch Log Group
- Backend local para guardar estado en `terraform.tfstate`

## Quickstart

1. Inicializa Terraform:

```powershell
terraform init
```

2. Formatea la configuración para mantener un estilo consistente:

```powershell
terraform fmt -recursive
```

3. Revisa el plan de ejecución:

```powershell
terraform plan
```

	Opcionalmente, puedes guardar el plan en un archivo para aplicarlo después:

```powershell
terraform plan -out=tfplan
terraform apply tfplan
```

4. Aplica los cambios:

```powershell
terraform apply
```

5. Print out resources present in the Terraform state (created resources):

```powershell
terraform output -json
```

6. Destruye los recursos cuando termines:

```powershell
terraform destroy
```

## Tests

Para ejecutar tests nativos de Terraform:

```powershell
terraform test
```

En este repositorio, el test unitario actual esta en el modulo `modules/log_group`, por lo que puedes lanzarlo asi:

```powershell
Set-Location .\modules\log_group
terraform init
terraform test
```

## Notas

- Asegúrate de tener credenciales AWS válidas en tu entorno antes de ejecutar `plan` o `apply`.
- Puedes cambiar región, nombre del log group y tags desde `terraform.tfvars`.

## Configurar profile en CMD

Si trabajas con CMD en Windows, puedes usar el script `set-aws-profile-env.cmd` para setear variables de entorno de AWS:

> [!IMPORTANT]
> Revisa antes el script y reemplaza en `AWS_PROFILE=testing` donde corresponda

```bat
set-aws-profile-env.cmd
```

Con parámetros opcionales:

```bat
set-aws-profile-env.cmd testing us-east-1
```

Esto configura `AWS_PROFILE`, `AWS_REGION`, `AWS_DEFAULT_REGION` y `AWS_SDK_LOAD_CONFIG` para la sesión actual de CMD.
