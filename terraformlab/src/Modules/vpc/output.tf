 output "master_vpc_id" {
  value = aws_vpc.tf-vpc-master.id

} 

 output "worker_vpc_id" {
  value = aws_vpc.tf-vpc-worker.id

} 

output "master_subnet_id_1" {
  value = aws_subnet.master-subnet-1.id
} 

output "master_subnet_id_2" {
  value = aws_subnet.master-subnet-2.id
} 

output "worker_subnet_id_1" {
  value = aws_subnet.worker-subnet-1.id
} 

output "route_table_assoc_master"{
  value = aws_main_route_table_association.set-master-default-rt-assoc
}


