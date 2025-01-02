terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.76.0"
    }
  }
  backend "s3" {
    bucket         = "terraformstate-bucket-sm"
    key            = "states/terraform.tfstate"
    region         = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
}
