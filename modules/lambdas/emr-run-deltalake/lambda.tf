# https://github.com/claranet/terraform-aws-lambda/blob/master/lambda.tf

module "lambda" {
  source = "../../../blueprints/lambda"

  function_name = "EMR-RUN-DELTALAKE"
  path_module   = "${path.module}"
  region        = "us-east-1"
  source_path   = "src"
  env           = var.env

  custom_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "iam:PassRole",
      "Effect": "Allow",
      "Resource": [
          "*"
      ]
    },
    {
      "Sid": "EMRRunJobFlow",
      "Effect": "Allow",
      "Action": "elasticmapreduce:*",
      "Resource": "*"
    },
    {
        "Sid": "ReceiveSQSMessages",
        "Effect": "Allow",
        "Action": [
            "sqs:*"
        ],
        "Resource": "*"
    }
  ]
}
EOF

  environment = {
    variables = {
      ENV                  = var.env
      KEY_NAME             = var.key_name
      MASTER_INSTANCE_TYPE = "m5.xlarge"
      CORE_INSTANCE_TYPE   = "m5.xlarge"
      EC2_MASTER_NAME      = "DATAFEEDER-EMR-Master"
      EC2_CORE_NAME        = "DATAFEEDER-EMR-Core"
      INSTANCE_COUNT       = 2
      EBS_SIZE_GB          = 32
      EC2_SUBNET_ID        = var.ec2_subnet_id
    }
  }
}
