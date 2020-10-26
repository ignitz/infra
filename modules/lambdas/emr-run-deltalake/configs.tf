resource "aws_s3_bucket_object" "config_tracker" {
  bucket = var.bucket_config_name
  key    = "deltalake/configs/config-DATAFEEDER_tracker.${lower(var.env)}.json"
  source = "${path.module}/configs/config-DATAFEEDER_tracker.${lower(var.env)}.json"
  etag   = filemd5("${path.module}/configs/config-DATAFEEDER_tracker.${lower(var.env)}.json")
}

resource "aws_s3_bucket_object" "config_register" {
  bucket = var.bucket_config_name
  key    = "deltalake/configs/config-DATAFEEDER_register.${lower(var.env)}.json"
  source = "${path.module}/configs/config-DATAFEEDER_register.${lower(var.env)}.json"
  etag   = filemd5("${path.module}/configs/config-DATAFEEDER_register.${lower(var.env)}.json")
}

resource "aws_s3_bucket_object" "config" {
  bucket = var.bucket_config_name
  key    = "deltalake/configs/config.${lower(var.env)}.json"
  source = "${path.module}/configs/config.${lower(var.env)}.json"
  etag   = filemd5("${path.module}/configs/config.${lower(var.env)}.json")
}

resource "aws_s3_bucket_object" "deltalake-jar" {
  bucket = var.bucket_config_name
  key    = "deltalake/jars/deltalake-processing-assembly-1.0.jar"
  source = "${path.module}/build/${lower(var.env)}/deltalake-processing-assembly-1.0.jar"
  etag   = filemd5("${path.module}/build/${lower(var.env)}/deltalake-processing-assembly-1.0.jar")
}

resource "aws_s3_bucket_object" "pyspark-script-curated" {
  bucket = var.bucket_config_name
  key    = "deltalake/pyspark/staged_to_curated.py"
  source = "${path.module}/pyspark_scripts/${lower(var.env)}/staged_to_curated.py"
  etag   = filemd5("${path.module}/pyspark_scripts/${lower(var.env)}/staged_to_curated.py")
}
