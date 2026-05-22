# modules/vpc/variables.tf

variable "project_name" {
  type        = string
  description = "Project moniker passed down from the root workspace context to namespace naming tags."
}

variable "aws_region" {
  type        = string
  description = "The target AWS region used to isolate availability zone placement."
}
