output "jenkins_public_ip" {
  description = "SSH and browser access to Jenkins"
  value       = aws_instance.jenkins.public_ip
}

output "app_public_ip" {
  description = "SSH and app access"
  value       = aws_instance.app.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
