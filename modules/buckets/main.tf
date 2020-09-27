module "raw" {
  source = "../../blueprints/s3/bucket"

  bucket_name  = "kafka"
  account_id   = var.account_id
  environment  = var.environment
  suffix       = "raw"
}

variable "account_id" { type = string }
variable "environment" { type = string }

output "buckets" {
  value = {
    raw = module.raw.bucket
  }
}
