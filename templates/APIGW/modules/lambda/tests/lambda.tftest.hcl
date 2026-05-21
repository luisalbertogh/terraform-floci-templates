mock_provider "aws" {}
mock_provider "archive" {}

run "lambda_uses_expected_inputs" {
  command = plan

  variables {
    function_name = "test-lambda"
    source_dir    = "./lambdas/mark_management"
    tags = {
      Environment = "test"
      ManagedBy   = "terraform-test"
    }
  }

  assert {
    condition     = aws_lambda_function.this.function_name == "test-lambda"
    error_message = "El nombre de la función no coincide con el valor esperado."
  }

  assert {
    condition     = aws_lambda_function.this.runtime == "python3.12"
    error_message = "El runtime debe ser python3.12 por defecto."
  }

  assert {
    condition     = aws_lambda_function.this.memory_size == 128
    error_message = "El memory_size debe ser 128 MB por defecto."
  }

  assert {
    condition     = aws_lambda_function.this.timeout == 30
    error_message = "El timeout debe ser 30 segundos por defecto."
  }

  assert {
    condition     = aws_lambda_function.this.handler == "handler.lambda_handler"
    error_message = "El handler no coincide con el valor esperado."
  }

  assert {
    condition     = aws_iam_role.this.name == "test-lambda-role"
    error_message = "El nombre del rol IAM no coincide con el valor esperado."
  }

  assert {
    condition     = aws_lambda_function.this.tags["Environment"] == "test"
    error_message = "El tag Environment no coincide con el valor esperado."
  }
}
