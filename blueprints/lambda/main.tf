# Get accountID
data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "lambda_function" {
  filename      = "${var.path_module}/build/lambda_function_payload.zip"
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.handler

  # source_code_hash = filebase64sha256("${path.module}/lambda_function_payload.zip")
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = var.runtime

  environment {
    variables = {
      ENV = var.environment
    }
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${var.path_module}/${var.source_path}"
  output_path = "${var.path_module}/build/lambda_function_payload.zip"
}

