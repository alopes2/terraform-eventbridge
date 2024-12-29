resource "aws_sns_topic" "data" {
  name = "data-topic"
}

resource "aws_sqs_queue" "data_queue" {
  name = "data-queue"
}

resource "aws_sns_topic_subscription" "data_sqs_target" {
  topic_arn = aws_sns_topic.data.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.data_queue.arn
}


# resource "aws_sqs_queue_policy" "queue_policy" {
#   queue_url = aws_sqs_queue.data_queue.url
#   policy    = data.aws_iam_policy_document.sqs-queue-policy.json
# }

# data "aws_iam_policy_document" "sqs-queue-policy" {
#   policy_id = "arn:aws:sqs:YOUR_REGION:YOUR_ACCOUNT_ID:data-queue/SQSDefaultPolicy"

#   statement {
#     sid    = "movie_updates-sns-topic"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["sns.amazonaws.com"]
#     }

#     actions = [
#       "SQS:SendMessage",
#     ]

#     resources = [
#       "arn:aws:sqs:YOUR_REGION:YOUR_ACCOUNT_ID:data-queue",
#     ]

#     condition {
#       test     = "ArnEquals"
#       variable = "aws:SourceArn"

#       values = [
#         aws_sns_topic.movie_updates.arn,
#       ]
#     }
#   }
# }
