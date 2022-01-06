variable "user_data" {
  description = "user data for apache script"
  default     = <<-EOF
#!/bin/bash
yum -y update
yum install -y httpd
service httpd start
echo '<!doctype html><html><head><title>CONGRATULATIONS!!..You are on your way to become a Terraform expert!</title><style>body {background-color: #1c87c9;}</style></head><body></body></html>' | sudo tee /var/www/html/index.html
echo "<BR><BR>Terraform autoscaled app multi-cloud lab<BR><BR>" >> /var/www/html/index.html
EOF
}
variable "aws_image" {
  description = "amazon linux image id for us-east"
  type        = string
  default     = "ami-0ed9277fb7eb570c9"
}

variable "instance_type" {
  description = "aws instance types"
  default = [
    "t2.micro",
    "t2.large",
  "t2.medium"]
  type = list(any)
}
variable "aws_launchcfg" {
  description = "aws launch config for the ASG"
  default     = "aws_autoscale_launch_config"
  type        = string

}

variable "az" {
  default = ["us-east-1b", "us-east-1c", "us-east-1d"]
}

variable "rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 21
      protocol    = "tcp"
      to_port     = 21
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      protocol    = "tcp"
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}