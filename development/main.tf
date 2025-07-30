terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket       = "iac-aws-backend"
    key          = "aws-backend/aws-development-tf.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
