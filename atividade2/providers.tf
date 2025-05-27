# providers.tf

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-unico-123"  # ajuste conforme seu bucket
    key            = "terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}

