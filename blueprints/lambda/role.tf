resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.function_name}_ROLE"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "basic_attach" {
  name       = "${var.function_name}_basic_attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.basic_role.arn
}

resource "aws_iam_policy" "basic_role" {
  name        = "${var.function_name}_AWSLambdaBasicExecutionRole"
  description = "Basic policy to Lambda ${var.function_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "custom_attach" {
  name       = "${var.function_name}_custom_attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.custom_policy.arn
}

resource "aws_iam_policy" "custom_policy" {
  name        = "${var.function_name}_Custom"
  description = "Extra policies to Lambda ${var.function_name}"

  policy = var.custom_policy
}
