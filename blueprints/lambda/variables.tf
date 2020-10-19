variable "function_name" {
  description = "Function name of AWS Lambda"
  type        = string
}

variable "path_module" {
  description = "Path to where are the lambda source code."
  type        = string
}

variable "region" {
  description = "Region where is lambda are created."
  type        = string
}

variable "memory" {
  description = "Memory RAM to lambda function. (128 MB to 3,008 MB, in 64 MB increments.)"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout (in seconds) for Lambda execution. (Max 900 seconds)"
  type        = number
  default     = 3
}

variable "handler" {
  description = "Function to invoke {filename.function} on Python"
  default     = "lambda_function.lambda_handler"
  type        = string
}

variable "runtime" {
  description = "nodejs10.x | nodejs12.x | java8 | java8.al2 | java11 | python2.7 | python3.6 | python3.7 | python3.8 | dotnetcore2.1 | dotnetcore3.1 | go1.x | ruby2.5 | ruby2.7 | provided | provided.al2"
  default     = "python3.8"
  type        = string
}

variable "environment" {
  description = "Enrivonment variable"
  default     = "ENV"
  type        = string
}

variable "source_path" {
  description = "Prefix of source code to Lambda"
  default     = "src"
  type        = string
}

variable "custom_policy" {
  description = "Policies to insert permissions to Lambda execution."
  type        = string
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CreateLogGroup",
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "*"
    }
  ]
}
EOF
}
