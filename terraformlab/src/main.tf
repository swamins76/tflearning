//aws compute configuraiton
data "aws_ssm_parameter" "linuxAmimaster" {
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "linuxAmiworker" {
  provider = aws.worker-region
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# create a key pair for logging into ec2 in us east
resource "aws_key_pair" "master-pub-key" {
  key_name   = "jenkinLearning"
  public_key = file("~/.ssh/id_rsa.pub")
}

# create a key pair for logging into ec2 in us east
resource "aws_key_pair" "worker-pub-key" {
  provider   = aws.worker-region
  key_name   = "jenkinLearning"
  public_key = file("~/.ssh/id_rsa.pub")
}
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
  source    = "./Modules/vpc"
  providers = { aws.worker = aws.worker-region }
}
resource "aws_instance" "tf-instance-master" {
  #provider                    = aws.master-region
  ami                         = data.aws_ssm_parameter.linuxAmimaster.value
  instance_type               = var.instance_type[0]
  subnet_id                   = module.vpc.master_subnet_id_1
  security_groups             = [aws_security_group.master_security_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.master-pub-key.key_name
  #user_data = var.user_data
  tags = {
    Name = "Jenkins_master_terraform"
  }

  depends_on = [
    module.vpc.route_table_assoc_master
  ]

}

resource "aws_instance" "tf-instance-worker" {
  provider                    = aws.worker-region
  ami                         = data.aws_ssm_parameter.linuxAmiworker.value
  instance_type               = var.instance_type[0]
  count                       = var.workers-count
  subnet_id                   = module.vpc.worker_subnet_id_1
  security_groups             = [aws_security_group.worker_security_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.worker-pub-key.key_name
  #user_data = var.user_data
  tags = {
    Name = join("-", ["jenkins_worker_terraform", count.index + 1])
  }
  depends_on = [
    module.vpc.route_table_assoc_master, aws_instance.tf-instance-master
  ]

}


//security group for alb
resource "aws_security_group" "alb_security_group" {
  #provider = aws.master-region
  name     = "alb-master-sg"
  vpc_id   = module.vpc.master_vpc_id
  tags = {
    Name = "alb-master-sg-terraform"
  }

  dynamic "ingress" {
    for_each = var.alb-rules
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
//main security group
resource "aws_security_group" "master_security_group" {
  #provider = aws.master-region
  name     = "master-sg"
  vpc_id   = module.vpc.master_vpc_id
  tags = {
    Name = "master-sg-terraform"
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
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }
  egress {
    description = "allow_all"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//worker security group
resource "aws_security_group" "worker_security_group" {
  provider = aws.worker-region
  name     = "worker-sg"
  vpc_id   = module.vpc.worker_vpc_id
  tags = {
    Name = "worker-sg-terraform"
  }

  dynamic "ingress" {
    for_each = var.worker-rules
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
/* 
resource "aws_route" "tfroute" {
  provider               = aws.east
  route_table_id         = module.vpc.awsvpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
 */
