resource "aws_cloudwatch_event_target" "target" {
  arn  = aws_sqs_queue.data_queue.arn
  rule = aws_cloudwatch_event_rule.s3_createobject.name
  input_transformer {
    input_paths = {
      bucket    = "$.detail.bucket.name"
      objectKey = "$.detail.object.key",
      action    = "$.detail.reason"
    }

    input_template = <<EOF
    {
      "bucket" : <bucket>,
      "action": <action>,
      "key": <objectKey>
    }
    EOF
  }
}

resource "aws_cloudwatch_event_target" "logs" {
  rule = aws_cloudwatch_event_rule.s3_createobject.name
  arn  = aws_cloudwatch_log_group.eventbridge.arn
  input_transformer {
    input_paths = {
      timestamp = "$.time"
      bucket    = "$.detail.bucket.name"
      objectKey = "$.detail.object.key"
    }

    input_template = <<EOF
      {
        "timestamp" : <timestamp>,
        "message": "Bucket \"<bucket>\" has a new file added <objectKey>"
      }
    EOF
  }
}

resource "aws_cloudwatch_log_group" "eventbridge" {
  name              = "/aws/events/eventbridge/logs"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_resource_policy" "logs" {
  policy_document = data.aws_iam_policy_document.eventbridge_log_policy.json
  policy_name     = "eventbridge_log_publishing-policy"
}

data "aws_iam_policy_document" "eventbridge_log_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream"
    ]

    resources = [
      "${aws_cloudwatch_log_group.eventbridge.arn}:*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.eventbridge.arn}:*:*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }

    condition {
      test     = "ArnEquals"
      values   = [aws_cloudwatch_event_rule.s3_createobject.arn]
      variable = "aws:SourceArn"
    }
  }
}
