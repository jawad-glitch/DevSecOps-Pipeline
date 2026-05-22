# modules/vpc/outputs.tf

output "vpc_id" {
  description = "The unique identifier key tracking the main virtual network space."
  value       = aws_vpc.main_vpc.id
}

output "subnet_id" {
  description = "The public infrastructure gateway subnet block identifier string."
  value       = aws_subnet.public_subnet.id
}
