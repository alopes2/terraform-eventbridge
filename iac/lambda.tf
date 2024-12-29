locals {
  function_name = "process-data"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../apps/index.js"
  output_path = "${local.function_name}_lambda_function_payload.zip"
}


resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda.output_path
  function_name = "process-data"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${local.function_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "lambda_logs" {
  role   = aws_iam_role.iam_for_lambda.name
  policy = data.aws_iam_policy_document.lambda_policies.json
}

data "aws_iam_policy_document" "assume_role" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

  }
}

data "aws_iam_policy_document" "lambda_policies" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]

    resources = [
      aws_sqs_queue.data_queue.arn
    ]
  }
}


resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn = aws_sqs_queue.data_queue.arn
  function_name    = aws_lambda_function.lambda.function_name
}


