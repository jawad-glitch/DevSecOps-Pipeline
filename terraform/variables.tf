# variables.tf

variable "aws_region" {
  type        = string
  description = "The target AWS region where all infrastructure resources will be deployed."
  default     = "eu-north-1"
}

variable "project_name" {
  type        = string
  description = "Project moniker used to namespace resource naming configurations."
  default     = "devsecops-demo"
}

variable "environment" {
  type        = string
  description = "The target deployment layer lifecycle phase."
  default     = "production"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Your public IP address network block (in CIDR notation, e.g., 'X.X.X.X/32') allowed to establish SSH sessions. Retrieve yours from checkip.amazonaws.com."
}

variable "ec2_instance_type" {
  type        = string
  description = "The hardware profile scale for the compute deployment engine host."
  default     = "t3.micro"
}
