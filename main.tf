# Define Versão
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  
  backend "s3"{
    bucket = "pedropmc-bucket"
    key = "tf-states/terraform.tfstate"
    region = "us-east-1"
    encrypt = true

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
  public_sub1_id = module.vpc.public_subnet1_id
  public_sub2_id = module.vpc.public_subnet2_id
  target_group_arn = module.vpc.target_group_arn
  endpoint = module.db.endpoint
  alb_id = module.vpc.alb_id
  iam_profile_name = module.iam.iam_profile_name
}

module "db" {
  source = "./modules/db"
  db_sg_id = module.sg.db_sg_id
  private_sub1_id = module.vpc.private_subnet1_id
  private_sub2_id = module.vpc.private_subnet2_id
}

module "iam" {
  source = "./modules/iam"
}



