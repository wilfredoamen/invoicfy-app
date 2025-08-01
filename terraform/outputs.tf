output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.invoify.public_ip
}

output "ssh_connection_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.invoify.public_ip}"
}