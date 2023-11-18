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

#VPC
module "vpc" {
  source = "./modules/vpc" # Update this to the path of your module
}


#EC2
module "ec2" {
  source = "./modules/ec2"
  #Variáveis
  private_subnets_ids = module.vpc.private_subnet_ids
  ec2_sg_id = module.sg.ec2_sg_id
}


#SG
module "sg" {
  source = "./modules/sg" 
  #Variáveis
  vpc_id = module.vpc.vpc_id
}

