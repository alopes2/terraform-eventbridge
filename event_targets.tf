resource "aws_cloudwatch_event_target" "target" {
  arn  = aws_sqs_queue.data_queue.arn
  rule = aws_cloudwatch_event_rule.s3_createobject.name
}

# resource "aws_cloudwatch_event_target" "better_scheduler_to_cloudwatch" {
#   arn  = aws_cloudwatch_log_group.eventbridge.arn
#   rule = aws_cloudwatch_event_rule.better_scheduler_to_cloudwatch.name
# }

# resource "aws_cloudwatch_log_group" "eventbridge" {
#   name              = "/aws/events/eventbridge/logs"
#   retention_in_days = 1
# }

# data "aws_iam_policy_document" "eventbridge_log_policy" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogStream"
#     ]
#     resources = [
#       "${aws_cloudwatch_log_group.eventbridge.arn}:*"
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
#       "${aws_cloudwatch_log_group.eventbridge.arn}:*:*"
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
#       values   = [aws_cloudwatch_event_rule.better_scheduler_to_cloudwatch.arn]
#       variable = "aws:SourceArn"
#     }
#   }
# }
