terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Retrieve availability zones for the current region
data "aws_availability_zones" "azs" {
  state = "available"
}

# Retreive current account ID
data "aws_caller_identity" "current" {}