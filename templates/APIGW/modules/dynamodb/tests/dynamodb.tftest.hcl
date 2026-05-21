mock_provider "aws" {}

run "dynamodb_table_uses_expected_inputs" {
  command = plan

  variables {
    name     = "test-table"
    hash_key = "pk"
    attributes = [
      { name = "pk", type = "S" }
    ]
    tags = {
      Environment = "test"
      ManagedBy   = "terraform-test"
    }
  }

  assert {
    condition     = aws_dynamodb_table.this.name == "test-table"
    error_message = "El nombre de la tabla no coincide con el valor esperado."
  }

  assert {
    condition     = aws_dynamodb_table.this.billing_mode == "PAY_PER_REQUEST"
    error_message = "El billing mode debe ser PAY_PER_REQUEST por defecto."
  }

  assert {
    condition     = aws_dynamodb_table.this.hash_key == "pk"
    error_message = "El hash_key no coincide con el valor esperado."
  }

  assert {
    condition     = aws_dynamodb_table.this.point_in_time_recovery[0].enabled == true
    error_message = "El PITR debe estar habilitado por defecto."
  }

  assert {
    condition     = aws_dynamodb_table.this.server_side_encryption[0].enabled == true
    error_message = "El cifrado en reposo debe estar habilitado por defecto."
  }

  assert {
    condition     = aws_dynamodb_table.this.stream_enabled == false
    error_message = "Los streams deben estar deshabilitados por defecto."
  }

  assert {
    condition     = aws_dynamodb_table.this.tags["Environment"] == "test"
    error_message = "El tag Environment no coincide con el valor esperado."
  }
}

run "dynamodb_table_provisioned_mode" {
  command = plan

  variables {
    name           = "provisioned-table"
    billing_mode   = "PROVISIONED"
    read_capacity  = 10
    write_capacity = 10
    hash_key       = "pk"
    range_key      = "sk"
    attributes = [
      { name = "pk", type = "S" },
      { name = "sk", type = "N" }
    ]
  }

  assert {
    condition     = aws_dynamodb_table.this.billing_mode == "PROVISIONED"
    error_message = "El billing mode no coincide con el valor esperado."
  }

  assert {
    condition     = aws_dynamodb_table.this.read_capacity == 10
    error_message = "El read_capacity no coincide con el valor esperado."
  }

  assert {
    condition     = aws_dynamodb_table.this.write_capacity == 10
    error_message = "El write_capacity no coincide con el valor esperado."
  }

  assert {
    condition     = aws_dynamodb_table.this.range_key == "sk"
    error_message = "El range_key no coincide con el valor esperado."
  }
}
