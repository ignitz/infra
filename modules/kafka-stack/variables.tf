variable "environment" { type = string }
variable "instance_name" { type = string }
variable "vpc_id" { type = string }
variable "key_name" { type = string }
variable "subnet_id" { type = string }
variable "portainer_username" {
  type    = string
  default = "admin"
}
variable "password" { type = string }
variable "s3_kafka_stack_path" { type = string }
