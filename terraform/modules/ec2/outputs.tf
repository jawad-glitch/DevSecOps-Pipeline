# modules/ec2/outputs.tf

output "public_ip" {
  description = "The public global routing WAN IP address configuration assigned to your server engine host."
  value       = aws_instance.app_server.public_ip
}
