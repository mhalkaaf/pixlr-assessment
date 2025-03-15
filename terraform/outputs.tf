# Return the IP Public
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.ec2-pixlr-server.public_ip
}