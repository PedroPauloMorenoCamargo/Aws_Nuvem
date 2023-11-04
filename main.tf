# Define Versão
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Define que a AWS será utilizada e a Região de Uso
provider "aws" {
  region = "us-east-1"
}
