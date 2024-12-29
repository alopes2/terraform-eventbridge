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

# resource "aws_cloudwatch_event_rule" "scheduler" {
#   name                = "every_minute_test_schulder"
#   description         = "Rule to trigger every minute"
#   event_bus_name      = data.aws_cloudwatch_event_bus.default.name
#   schedule_expression = "cron(* * * * ? *)" // Triggers every minute, could also be rate(1 minute)
# }

# resource "aws_cloudwatch_event_rule" "better_scheduler_to_cloudwatch" {
#   name           = "better_scheduler_to_cloudwatch"
#   description    = "Rule to better_scheduler_to_cloudwatch"
#   event_bus_name = data.aws_cloudwatch_event_bus.default.name

#   event_pattern = jsonencode({
#     source      = ["Custom Scheduler"],
#     detail-type = ["My Scheduler"],
#   })
# }


# resource "aws_scheduler_schedule" "better_scheduler" {
#   name = "better_scheduler"
#   flexible_time_window {
#     mode = "OFF"
#   }
#   target {
#     arn      = data.aws_cloudwatch_event_bus.default.arn
#     role_arn = aws_iam_role.better_scheduler.arn
#     eventbridge_parameters {
#       detail_type = "My Scheduler"
#       source      = "Custom Scheduler"
#     }

#     // Event Payload (if required)
#     input = jsonencode({
#       Message = "Super Schedule"
#     })
#   }

#   schedule_expression = "cron(* * * * ? *)" // Triggers every minute, could also be rate(1 minute)
# }

# resource "aws_iam_role" "better_scheduler" {
#   name               = "scheduler_role"
#   assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_policy.json
# }

# data "aws_iam_policy_document" "better_scheduler_assume_policy" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["scheduler.amazonaws.com"]
#     }
#   }
# }

# data "aws_iam_policy_document" "better_scheduler_policies" {
#   statement {
#     effect  = "Allow"
#     actions = ["events:PutEvents"]

#     resources = [
#       data.aws_cloudwatch_event_bus.default.arn
#     ]
#   }
# }

# resource "aws_iam_role_policy" "better_scheduler_role_policy" {
#   role   = aws_iam_role.better_scheduler.name
#   policy = data.aws_iam_policy_document.better_scheduler_policies.json
# }
