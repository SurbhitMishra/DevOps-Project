terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.76.0"
    }
  }
  backend "s3" {
    bucket         = var.s3_bucket_name
    key            = "terraform/state/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
