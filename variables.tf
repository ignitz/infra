variable "config_bucket" { type = string }
variable "region" { type = string }

variable "datafeeder_stack_name" { type = string }
variable "kafka_stack_name" { type = string }
variable "environment" { type = string }

variable "vpc_id" { type = string }
variable "subnet_id" { type = string }

variable "portainer_username" { type = string }