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
  http_method         = "POST"
  invocation_endpoint = "http://jsonplaceholder.org/posts"
}

resource "aws_cloudwatch_event_target" "api" {
  rule = aws_cloudwatch_event_rule.s3_createobject.name
  arn  = aws_cloudwatch_event_api_destination.api.arn
  # If you need custom static input, define here
  # input = jsonencode({})
}
