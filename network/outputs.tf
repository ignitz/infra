output "subnet_public" {
  value = aws_subnet.public[0].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
