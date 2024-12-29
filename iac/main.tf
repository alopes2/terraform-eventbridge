data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

resource "aws_s3_bucket" "eventbridge" {
  bucket = "eventbridge-terraform-test"
}

resource "aws_s3_bucket_notification" "s3_eventbridge" {
  bucket      = aws_s3_bucket.eventbridge.bucket
  eventbridge = true
}

resource "aws_cloudwatch_event_rule" "s3_createobject" {
  name           = "s3_createobject"
  description    = "Rule to trigger when an object is created in the S3 bucket"
  event_bus_name = data.aws_cloudwatch_event_bus.default.name

  event_pattern = jsonencode({
    source      = ["aws.s3"],
    detail-type = ["Object Created"],
    detail = {
      bucket = {
        name = ["${aws_s3_bucket.eventbridge.bucket}"]
      }
    }
  })
}

resource "aws_cloudwatch_event_rule" "scheduler" {
  name                = "every_minute_test_schulder"
  description         = "Rule to trigger every minute"
  event_bus_name      = data.aws_cloudwatch_event_bus.default.name
  schedule_expression = "cron(* * * * ? *)" // Triggers every minute
}


# resource "aws_cloudwatch_event_target" "scheduler_log" {
#   rule      = aws_cloudwatch_event_rule.scheduler.name
#   target_id = "SendSchdulerToCloudWatch"
#   arn       = aws_cloudwatch_log_group.s3_createobject.arn
#   input = "I trigger every 1 minute"
# }

# resource "aws_cloudwatch_log_group" "s3_createobject" {
#   name              = "/aws/events/s3_createobject/logs"
#   retention_in_days = 1
# }

# data "aws_iam_policy_document" "s3_createobject_log_policy" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogStream"
#     ]

#     resources = [
#       "${aws_cloudwatch_log_group.s3_createobject.arn}:*"
#     ]

#     principals {
#       type = "Service"
#       identifiers = [
#         "events.amazonaws.com",
#         "delivery.logs.amazonaws.com"
#       ]
#     }
#   }
#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:PutLogEvents"
#     ]

#     resources = [
#       "${aws_cloudwatch_log_group.s3_createobject.arn}:*:*"
#     ]

#     principals {
#       type = "Service"
#       identifiers = [
#         "events.amazonaws.com",
#         "delivery.logs.amazonaws.com"
#       ]
#     }

#     condition {
#       test     = "ArnEquals"
#       values   = [aws_cloudwatch_event_rule.s3_createobject.arn]
#       variable = "aws:SourceArn"
#     }
#   }
# }
