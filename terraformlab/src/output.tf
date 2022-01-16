output "master_jenkins_instance_ip" {
  value = aws_instance.tf-instance-master.public_ip

}

output "worker_jenkins_instance_ip" {
  value = {
    for instance in aws_instance.tf-instance-worker :
    instance.id => instance.public_ip
  }
}