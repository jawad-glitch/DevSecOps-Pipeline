# modules/ecr/variables.tf

variable "project_name" {
  type        = string
  description = "Project moniker passed down from the root workspace context to namespace resources."
}
