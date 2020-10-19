module "raw" {
  source = "../../blueprints/s3/bucket"

  bucket_name = "kafka"
  account_id  = var.account_id
  environment = var.environment
  suffix      = "raw"
}

module "configs" {
  source = "../../blueprints/s3/bucket"

  bucket_name = "configs"
  account_id  = var.account_id
  environment = var.environment
  suffix      = ""
}

variable "account_id" { type = string }
variable "environment" {
  type    = string
  default = "ENV"
}

output "buckets" {
  value = {
    raw     = module.raw.bucket
    configs = module.configs.bucket
  }
}
