# terraform-floci-templates

Proyectos de ejemplo con Terraform para AWS sobre Floci, implementando bases de referencia para arquitecturas AWS comunes.

## Plantillas

- [Basic](./templates/Basic/) - Plantilla sencilla con un grupo de logs de CloudWatch. Úsala para iniciar un nuevo proyecto con la estructura más simple.
- [S3Lambda](./templates/S3Lambda/) - Arquitectura orientada a eventos con buckets S3 y funciones Lambda.
- [APIGW](./templates/APIGW/) - Arquitectura API REST con API Gateway, funciones Lambda y tablas DynamoDB.
- [ECS](./templates/ECS/) - Arquitectura de contenedores en ECS con ECR.

## Cómo usar las plantillas

1. **Configura las credenciales de AWS CLI para Floci.** Define el perfil `floci` y los ajustes de endpoint tal como se describe en [floci/floci.md](./floci/floci.md).

2. **Levanta Floci.** Usa el archivo Docker Compose y los scripts auxiliares de la carpeta [floci/](./floci/) para iniciar el emulador local de AWS.

3. **Usa una plantilla** de la carpeta [templates/](./templates/):
   - Accede al directorio de la plantilla (p. ej. `cd templates/APIGW`).
   - Lee el archivo `README.md` de esa carpeta para conocer los detalles y variables específicos.
   - Ejecuta el flujo estándar de Terraform: `terraform init`, `terraform validate`, `terraform plan`, `terraform apply`.
