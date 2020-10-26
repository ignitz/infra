resource "aws_sqs_queue" "lambda_trigger" {
  name = "${var.env}-SQS-EMR-RUN-DELTALAKE"

  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.lambda_trigger.arn
  enabled          = true
  function_name    = module.lambda.lambda.arn
  batch_size       = 1
}
