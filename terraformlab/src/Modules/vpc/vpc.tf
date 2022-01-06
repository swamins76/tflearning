provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "tfvpc" {
  cidr_block = "172.20.0.0/16"
  tags = {
    Name = "VPC-terraform"
  }
}
resource "aws_subnet" "web1" {
  cidr_block = "172.20.10.0/24"
  vpc_id     = aws_vpc.tfvpc.id


  availability_zone = var.az[0]

  tags = {
    Name = "web1-Terraform"
  }

}

/* resource "aws_subnet" "web2" {
  cidr_block        = "172.20.20.0/24"
  vpc_id            = aws_vpc.tfvpc.id
  availability_zone = var.az[1]

  tags = {
    name = "web1"
  }
} */