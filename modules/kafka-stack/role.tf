resource "aws_iam_role" "assume_role" {
  name               = "${var.instance_name}-${var.environment}-ROLE-ASSUME"
  assume_role_policy = file("${path.module}/roles/assume_role.json")
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.instance_name}-${var.environment}-POLICY"
  description = "S3 Full Access to Sink Connector"
  policy      = file("${path.module}/roles/policy.json")
}

resource "aws_iam_policy_attachment" "role_attachment" {
  name       = "${var.instance_name}-${var.environment}-ROLE-ATTACH"
  roles      = [aws_iam_role.assume_role.name]
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "role_profile" {
  name = "${var.instance_name}-${var.environment}-ROLE"
  role = aws_iam_role.assume_role.name
}
