variable "bucket_name" { type = string }
variable "account_id" { type = string }
variable "suffix" { type = string }
variable "acl" {
  type        = string
  default     = "private"
  description = "Private or public access"
}
variable "environment" { type = string }
