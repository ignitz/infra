resource "aws_s3_bucket_object" "kafka_stack" {
  bucket = var.bucket_config_name
  key    = "build/kafka-stack.zip"
  source = "${path.module}/build/kafka-stack.zip"
  etag   = filemd5("${path.module}/build/kafka-stack.zip")
}

resource "aws_s3_bucket_object" "datafeeder" {
  bucket = var.bucket_config_name
  key    = "build/datafeeder.zip"
  source = "${path.module}/build/datafeeder.zip"
  etag   = filemd5("${path.module}/build/datafeeder.zip")
}

output "datafeeder" {
  value = aws_s3_bucket_object.datafeeder
}

output "kafka_stack" {
  value = aws_s3_bucket_object.kafka_stack
}

variable "bucket_config_name" {}
