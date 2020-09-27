provider "aws" {
  region  = "us-east-1"
  version = "~> 2.43"
}

terraform {
  backend "s3" {
    bucket = "yuriniitsuma"
    key    = "terraform/development.tfstate"
    region = "us-east-1"
  }
}

