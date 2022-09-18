terraform {
  required_version = "1.1.9"
  required_providers {
    aws = {
      version = "<= 5.0.0" #Forcing which version of plugin needs to be used.
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "terraformcs"
    key    = "ptajenkins.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}
