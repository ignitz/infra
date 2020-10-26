variable "key_name" {
  description = "Key pair for using SSH on EMR."
}

variable "ec2_subnet_id" {
  description = "Subnet ID for EMR cluster."
}

variable "env" {
  description = "Environment"
  default     = "DEV"
}
