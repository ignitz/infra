# aws ec2 modify-instance-attribute --instance-id <your-instance-id> --user-data ":"

module "instance" {
  source                 = "../../blueprints/ec2/instances/"

  instance_name          = var.instance_name
  instance_type          = "t3a.large"
  environment            = var.environment
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_mymachine.id]
  subnet_id              = var.subnet_id
  user_data              = data.template_file.user_data.rendered
  iam_instance_profile   = aws_iam_instance_profile.role_profile.name
}

resource "aws_security_group" "allow_mymachine" {
  name = "${var.instance_name}-SG"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Connector REST"
  }

  ingress {
    from_port   = 9021
    to_port     = 9021
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Confluent Control Center"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    HOME                = "/home/ubuntu"
    PORTAINER_USERNAME  = var.portainer_username
    PORTAINER_PASSWORD  = var.password
    S3_KAFKA_STACK_PATH = var.s3_kafka_stack_path
    POSTGRES_PASSWORD   = var.password
  }
}
