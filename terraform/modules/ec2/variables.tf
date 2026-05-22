# modules/ec2/variables.tf

variable "project_name" {
  type        = string
  description = "Project namespace moniker passed down from the root workspace."
}

variable "ec2_instance_type" {
  type        = string
  description = "The target scale size profile for the cloud compute instance host."
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Your unique public IP address block allowed to establish SSH connections."
}

variable "vpc_id" {
  type        = string
  description = "The unique target virtual private network space identifier."
}

variable "subnet_id" {
  type        = string
  description = "The specific public network gateway subnet block identifier string."
}
