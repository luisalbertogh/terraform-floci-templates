mock_provider "aws" {}

run "log_group_uses_expected_inputs" {
  command = plan

  variables {
    name              = "/unit/test/log-group"
    retention_in_days = 7
    tags = {
      Environment = "test"
      ManagedBy   = "terraform-test"
    }
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.name == "/unit/test/log-group"
    error_message = "El nombre del log group no coincide con el valor esperado."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.retention_in_days == 7
    error_message = "La retencion del log group no coincide con el valor esperado."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.tags["Environment"] == "test"
    error_message = "El tag Environment no coincide con el valor esperado."
  }
}
