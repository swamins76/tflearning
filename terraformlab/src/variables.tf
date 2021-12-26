variable "user_data" {
  description = "user data for apache script"
  default = <<-EOF
#!/bin/bash
sudo yum -y update
sudo yum install -y httpd
sudo service httpd start
echo '<!doctype html><html><head><title>CONGRATULATIONS!!..You are on your way to become a Terraform expert!</title><style>body {background-color: #1c87c9;}</style></head><body></body></html>' | sudo tee /var/www/html/index.html
echo "<BR><BR>Terraform autoscaled app multi-cloud lab<BR><BR>" >> /var/www/html/index.html
EOF
}
variable "aws_image" {
  description = "amazon linux image id for us-east"
  type = string
  default = "ami-03af6a70ccd8cb578"
}

variable "instance_type" {
  description = "aws instance types"
  default = [
    "T2.MICRO",
    "T2.LARGE",
    "T2.MEDIUM"]
    type = list
}
variable "aws_launchcfg" {
    description = "aws launch config for the ASG"
    default = "aws_autoscale_launch_config"
    type = string
  
}

variable "az" {
  default = ["us-east-1b","us-east-1c","us-east-1d"]
}