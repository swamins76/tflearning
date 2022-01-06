output "subnet_id_web1" {
  value = aws_subnet.web1.id
}

/* output "subnet_id_web2" {
  value = aws_subnet.web2.id
} */

output "awsvpcid" {

  value = aws_vpc.tfvpc.id
}

output "awsvpc" {
  value = aws_vpc.tfvpc
}