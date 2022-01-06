//aws compute configuraiton
/*
resource "aws_autoscaling_group" "tfasg" {
  provider = aws.east
  name = "tf-asg"
  max_size = 4
  min_size = 2
  launch_configuration = aws_launch_configuration.tf-launch-config.name
  vpc_zone_identifier = [aws_subnet.web1.id,aws_subnet.web2.id]
  #target_group_arns = [aws_lb_target_group.pool.arn]

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "tf-ec2VM"
  }
}

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
*/
//terraformlab\src\Modules\vpc
module "vpc" {
  source = "./Modules/vpc"
}
resource "aws_instance" "tf-instance-name" {
  provider                    = aws.east
  ami                         = var.aws_image
  instance_type               = var.instance_type[0]
  subnet_id                   = module.vpc.subnet_id_web1
  security_groups             = [aws_security_group.awsfw.id]
  associate_public_ip_address = true
  #key_name = ""
  user_data = var.user_data
  tags = {
    Name = "webserver-terraform"
  }

}
resource "aws_security_group" "awsfw" {
  provider = aws.east
  name     = "aws-fw"
  vpc_id   = module.vpc.awsvpcid
  tags = {
    Name = "sg-terraform"
  }

  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    description = "allow_all"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "igw" {
  provider = aws.east
  vpc_id   = module.vpc.awsvpcid

  tags = {
    Name = "igw-terraform"
  }
}

/* resource "aws_route_table" "table" {
  vpc_id = "${aws_vpc.main.id}"
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "MyRoute"
  }
} */

resource "aws_route" "tfroute" {
  provider               = aws.east
  route_table_id         = module.vpc.awsvpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

