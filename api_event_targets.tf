resource "aws_cloudwatch_event_connection" "api" {
  name               = "TestConnection"
  authorization_type = "API_KEY"
  auth_parameters {
    api_key {
      key   = "X-API-Key"
      value = "DummyValue"
    }

    # Define custom http parameters
    # invocation_http_parameters {
    #   body {
    #     is_value_secret = true
    #     key             = "password"
    #     value           = "password"
    #   }

    #   header {
    #     is_value_secret = false
    #     key             = "Content-Type"
    #     value           = "application/json"
    #   }

    #   query_string {
    #     is_value_secret = false
    #     key             = "auth"
    #     value           = "yes"
    #   }
    # }
  }
}

resource "aws_cloudwatch_event_api_destination" "api" {
  name                = "TestAPIDestination"
  connection_arn      = aws_cloudwatch_event_connection.api.arn
  http_method         = "GET"
  invocation_endpoint = "https://example.com"
}

resource "aws_cloudwatch_event_target" "api" {
  rule     = aws_cloudwatch_event_rule.s3_createobject.name
  arn      = aws_cloudwatch_event_api_destination.api.arn
  role_arn = aws_iam_role.iam_for_api_destination.arn
  # If you need custom static input, define here
  # input = jsonencode({})
}

resource "aws_iam_role" "iam_for_api_destination" {
  name               = "api-destination-role"
  assume_role_policy = data.aws_iam_policy_document.api_destination_assume_role.json
}

resource "aws_iam_role_policy" "policies_api_destination" {
  role   = aws_iam_role.iam_for_api_destination.name
  policy = data.aws_iam_policy_document.api_destination_policies.json
}

data "aws_iam_policy_document" "api_destination_assume_role" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

  }
}

data "aws_iam_policy_document" "api_destination_policies" {
  statement {
    effect = "Allow"

    actions = ["events:InvokeApiDestination"]

    resources = [aws_cloudwatch_event_api_destination.api.arn]
  }
}
