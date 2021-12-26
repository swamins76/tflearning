//aws compute configuraiton

resource "aws_launch_configuration" "tf-launch-config" {
  provider = aws.east
    name = var.aws_launchcfg
    image_id = var.aws_image
  instance_type = var.instance_type[0]
  security_groups =[aws_security_group.awsfw.id]
  associate_public_ip_address = true
  #key_name = ""
  user_data = var.user_data
  }

 resource "aws_vpc" "tfvpc" {
   provider = aws.east
  cidr_block = "172.20.0.0/16"
}
resource "aws_subnet" "web1" {
  provider = aws.east
      cidr_block = "172.20.10.0/24"
  vpc_id = aws_vpc.tfvpc.id
  availability_zone = var.az[0]

  tags = {
    name = "web1"
  }

}

resource "aws_subnet" "web2" {
  provider = aws.east
  cidr_block = "172.20.20.0/24"
  vpc_id = aws_vpc.tfvpc.id
  availability_zone = var.az[1]

  tags = {
    name = "web1"
  }
}

resource "aws_security_group" "awsfw" {
  provider = aws.east
  name = "aws-fw"
  vpc_id = aws_vpc.tfvpc.id

   ingress {
        from_port = 80
        protocol = "tcp"
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        protocol = "tcp"
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    }


  egress {
    description = "allow_all"
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

