output "lambda" {
  value = {
    id          = aws_lambda_function.lambda_function.id
    arn         = aws_lambda_function.lambda_function.arn
    invoke_arn  = aws_lambda_function.lambda_function.invoke_arn
    memory_size = aws_lambda_function.lambda_function.memory_size
    timeout     = aws_lambda_function.lambda_function.timeout
  }
}
