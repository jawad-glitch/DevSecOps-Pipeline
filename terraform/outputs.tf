# outputs.tf

output "ecr_repository_url" {
  description = "The container image repository landing target endpoint URL"
  value       = module.ecr.repository_url
}

output "ec2_public_ip" {
  description = "The public WAN IP routing address of your pipeline host environment server"
  value       = module.ec2.public_ip
}
