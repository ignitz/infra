output "emr-run-deltalake" {
  value = {
    lambda = module.lambda
    sqs    = aws_sqs_queue.lambda_trigger
    configs = {
      config_tracker  = aws_s3_bucket_object.config_tracker
      config_register = aws_s3_bucket_object.config_register
      deltalake_jar   = aws_s3_bucket_object.deltalake-jar
    }
  }
}
