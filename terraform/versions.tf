terraform {
  required_version = ">= 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
  backend "s3" {
    bucket  = "pixlr-terraform-state"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "haeckal-lab"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "haeckal-lab"
}