data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

resource "aws_s3_bucket" "eventbridge" {
  bucket = "eventbridge_terraform_test"
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
