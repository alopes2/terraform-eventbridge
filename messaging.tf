# resource "aws_sns_topic" "data" {
#   name = "data-topic"
# }

resource "aws_sqs_queue" "data_queue" {
  name = "data-queue"
}

# resource "aws_sns_topic_subscription" "data_sqs_target" {
#   topic_arn = aws_sns_topic.data.arn
#   protocol  = "sqs"
#   endpoint  = aws_sqs_queue.data_queue.arn
# }

resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.data_queue.url
  policy    = data.aws_iam_policy_document.sqs-queue-policy.json
}

data "aws_iam_policy_document" "sqs-queue-policy" {
  # policy_id = "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:data-queue/SQSDefaultPolicy"
  statement {
    sid    = "data-stuff-topic"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = [
      "SQS:SendMessage",
    ]

    resources = [
      aws_sqs_queue.data_queue.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudwatch_event_rule.s3_createobject.arn,
      ]
    }
  }
}
