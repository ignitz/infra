# Enable in final version
# module "vpc" {
#   source = "./blueprints/network/"
# }

# module "datafeeder" {
#   source = "./modules/datafeeder"

#   environment = var.environment

#   instance_name      = var.datafeeder_stack_name
#   vpc_id             = var.vpc_id
#   subnet_id          = var.subnet_id
#   key_name           = module.key_pair.key_name
#   portainer_username = var.portainer_username
#   password           = random_password.password.result
#   s3_datafeeder_path = "s3://${module.build_stacks.datafeeder.bucket}/${module.build_stacks.datafeeder.key}"
# }

# module "kafka" {
#   source = "./modules/kafka-stack"

#   environment = var.environment

#   instance_name       = var.kafka_stack_name
#   vpc_id              = var.vpc_id
#   subnet_id           = var.subnet_id
#   key_name            = module.key_pair.key_name
#   portainer_username  = var.portainer_username
#   password            = random_password.password.result
#   s3_kafka_stack_path = "s3://${module.build_stacks.kafka_stack.bucket}/${module.build_stacks.kafka_stack.key}"
# }

# Get current accoundID of the account in .account_id
data "aws_caller_identity" "current" {}

module "buckets" {
  source = "./modules/buckets/"

  account_id  = data.aws_caller_identity.current.account_id
  environment = var.environment
}

module "key_pair" {
  source = "./modules/key_pair"

  key_name = "yuriniitsuma"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

output "buckets" {
  value = module.buckets.buckets
}

module "build_stacks" {
  source = "./modules/build_stacks"

  bucket_config_name = "${module.buckets.buckets.configs}"
}

output "generated_password" {
  value       = random_password.password.result
  description = "Automatic password generated, copy to a safe place and run:\naws ec2 modify-instance-attribute --instance-id <your-instance-id> --user-data \":\""
}
