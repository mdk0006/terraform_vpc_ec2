output "id_of_internet_gw" {
  description = "The Internet Gateway id is as follows"
  value       = aws_internet_gateway.gw.id
}
output "vpc_creation" {
  description = "The VPC name id is "
  value       = aws_vpc.main.id
}
output "ec2-public-ip" {
  description = "The public ip for your instance is"
  value       = aws_instance.TF_int.public_ip
}