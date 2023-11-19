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
  source = "./modules/vpc"
  alb_sg_id = module.sg.alb_sg_id
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./modules/ec2"
  ec2_sg_id = module.sg.ec2_sg_id
  private_sub1_id = module.vpc.private_subnet1_id
  private_sub2_id = module.vpc.private_subnet2_id
  target_group_arn = module.vpc.target_group_arn
}

module "db" {
  source = "./modules/db"
  ec2_sg_id = module.sg.ec2_sg_id
  private_sub1_id = module.vpc.private_subnet1_id
  private_sub2_id = module.vpc.private_subnet2_id
  db_sg_id = module.sg.db_sg_id
}

