resource "aws_instance" "instance" {
  ami           = data.aws_ami.latest-ubuntu.id
  instance_type = "t3.large"

  tags = {
    Name = var.instance_name
    Env  = "${var.environment}"
  }

  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data              = var.user_data
  iam_instance_profile   = var.iam_instance_profile

  subnet_id = var.subnet_id

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#block-devices
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
}

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


variable "instance_name" {
  type        = string
  description = "Name of the EC2 Instance on console"
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Type of the EC2 instance"
}

variable "key_name" { type = string }
variable "vpc_security_group_ids" { type = list(string) }
variable "subnet_id" { type = string }
variable "user_data" { type = string }
variable "iam_instance_profile" { type = string }
variable "volume_size" {
  type        = string
  default     = "50"
  description = "Quantos Gigabytes o disco principal da instância terá."
}
variable "volume_type" {
  type        = string
  default     = "gp2"
  description = "O tipo de armazenamento escolhido. Can be standard, gp2, io1 or io2"
}

output "instance" {
  value = aws_instance.instance
}
