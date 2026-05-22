# main.tf

# 1. Fire up the ECR Repository Module
module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

# 2. Build the Networking Infrastructure Module
module "vpc" {
  source       = "./modules/vpc"
  aws_region   = var.aws_region
  project_name = var.project_name
}

# 3. Provision the Compute Host Module (Depends on networking outputs)
module "ec2" {
  source            = "./modules/ec2"
  project_name      = var.project_name
  ec2_instance_type = var.ec2_instance_type
  allowed_ssh_cidr  = var.allowed_ssh_cidr
  
  # Pass outputs from the VPC module into the EC2 module inputs
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.subnet_id
}
