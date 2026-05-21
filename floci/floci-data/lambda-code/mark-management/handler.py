import json
import os
from decimal import Decimal

import boto3


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body),
    }


def _normalize_dynamodb_types(value):
    if isinstance(value, list):
        return [_normalize_dynamodb_types(item) for item in value]
    if isinstance(value, dict):
        return {key: _normalize_dynamodb_types(item) for key, item in value.items()}
    if isinstance(value, Decimal):
        return int(value) if value % 1 == 0 else float(value)
    return value


def lambda_handler(event, context):
    table_name = os.environ.get("DYNAMODB_TABLE_NAME")
    if not table_name:
        return _response(500, {"message": "Missing DYNAMODB_TABLE_NAME environment variable."})

    method = (event.get("httpMethod") or "").upper()
    table = boto3.resource("dynamodb", endpoint_url=os.environ.get("DYNAMODB_ENDPOINT_URL", "http://floci:4566")).Table(table_name)

    if method == "GET":
        result = table.scan()
        items = _normalize_dynamodb_types(result.get("Items", []))
        return _response(200, {"items": items})

    if method == "POST":
        raw_body = event.get("body") or "{}"
        try:
            payload = json.loads(raw_body) if isinstance(raw_body, str) else raw_body
        except json.JSONDecodeError:
            return _response(400, {"message": "Request body must be valid JSON."})

        required_fields = ["name", "mark", "class"]
        missing_fields = [field for field in required_fields if field not in payload or payload[field] in (None, "")]
        if missing_fields:
            return _response(400, {"message": f"Missing required fields: {', '.join(missing_fields)}"})

        item = {
            "Class": str(payload["class"]),
            "Name": str(payload["name"]),
            "Mark": str(payload["mark"]),
        }
        table.put_item(Item=item)

        return _response(201, {"message": "Record inserted successfully.", "item": item})

    return _response(405, {"message": "Method not allowed. Use GET or POST."})
