output "emr-run-deltalake" {
  value = {
    lambda = module.lambda
    sqs    = aws_sqs_queue.lambda_trigger
  }
}
