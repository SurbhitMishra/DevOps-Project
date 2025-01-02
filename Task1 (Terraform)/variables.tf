variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket name to store Terraform state"
  default     = "terraformstate_bucket_SM22"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  default     = "10.0.4.0/24"
}

variable "az_1" {
  description = "Availability Zone 1"
  default     = "ap-south-1a"
}

variable "az_2" {
  description = "Availability Zone 2"
  default     = "ap-south-1b"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-053b12d3152c0cc71"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.medium"
}

variable "key_pair_name" {
  description = "Key pair name"
  default     = "c1"
}
