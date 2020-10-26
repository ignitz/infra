resource "aws_s3_bucket_object" "config_tracker" {
  bucket = var.bucket_config_name
  key    = "deltalake/configs/config-DATAFEEDER_tracker.${var.env}.json"
  source = "${path.module}/configs/config-DATAFEEDER_tracker.${var.env}.json"
  etag   = filemd5("${path.module}/configs/config-DATAFEEDER_tracker.${var.env}.json")
}

resource "aws_s3_bucket_object" "config_register" {
  bucket = var.bucket_config_name
  key    = "deltalake/configs/config-DATAFEEDER_register.${var.env}.json"
  source = "${path.module}/configs/config-DATAFEEDER_register.${var.env}.json"
  etag   = filemd5("${path.module}/configs/config-DATAFEEDER_register.${var.env}.json")
}

resource "aws_s3_bucket_object" "config" {
  bucket = var.bucket_config_name
  key    = "deltalake/configs/config.${var.env}.json"
  source = "${path.module}/configs/config.${var.env}.json"
  etag   = filemd5("${path.module}/configs/config.${var.env}.json")
}

resource "aws_s3_bucket_object" "deltalake-jar" {
  bucket = var.bucket_config_name
  key    = "deltalake/jars/deltalake-processing-assembly-1.0.jar"
  source = "${path.module}/build/${var.env}/deltalake-processing-assembly-1.0.jar"
  etag   = filemd5("${path.module}/build/${var.env}/deltalake-processing-assembly-1.0.jar")
}
