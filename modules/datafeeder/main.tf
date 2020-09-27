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
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Postgres"
  }

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SqlServer"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Portainer"
  }

  ingress {
    from_port   = 3333
    to_port     = 3333
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "DataFeeder REST"
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
    S3_DATAFEEDER_PATH  = var.s3_datafeeder_path
    POSTGRES_PASSWORD   = var.password
    SQLSERVER_PASSWORD  = var.password
    TOKEN               = var.password
  }
}
