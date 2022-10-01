terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket         = "cloud-learning-bucket112"
    key            = "layer1.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "Terrafrom-remote-state"
  }

  required_version = ">= 1.1.9"
}

provider "aws" {
  region = "eu-west-1"
}

