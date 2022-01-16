
provider "aws" {
  region = var.master-region
  alias  = "master-region"

}
provider "aws" {
  region = var.worker-region
  alias  = "worker-region"

}
//laying the network foundation - Create VPC, IG and Subnets
//creating 2 VPC  - One master and One worker
resource "aws_vpc" "tf-vpc-master" {
  provider = aws.master-region
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Master-VPC-Jenkins-tf"
  }
}

resource "aws_vpc" "tf-vpc-worker" {
  provider = aws.worker-region
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Worker-VPC-Jenkins-tf"
  }
}

//create the IGW

resource "aws_internet_gateway" "igw-master" {
  provider = aws.master-region
  vpc_id   = aws_vpc.tf-vpc-master.id

  tags = {
    Name = "igw-master-VPC-terraform"
  }
}

resource "aws_internet_gateway" "igw-worker" {
  provider = aws.worker-region
  vpc_id   = aws_vpc.tf-vpc-worker.id

  tags = {
    Name = "igw-worker-VPC-terraform"
  }
}

//get the availability zones for each regions to create the subnets

//data call to get the availability zones

data "aws_availability_zones" "master-azs" {
  provider = aws.master-region
  state = "available"
  
}

data "aws_availability_zones" "worker-azs" {
  provider = aws.worker-region
  state = "available"
  
}

//create subnet #1 in master region

resource "aws_subnet" "master-subnet-1" {
  provider = aws.master-region
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.tf-vpc-master.id


  availability_zone = element(data.aws_availability_zones.master-azs.names,0)

  tags = {
    Name = "Master-Subnet-1-tf"
  }

}

resource "aws_subnet" "master-subnet-2" {
  provider = aws.master-region
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.tf-vpc-master.id


  availability_zone = element(data.aws_availability_zones.master-azs.names,1)

  tags = {
    Name = "Master-Subnet-2-tf"
  }

}

//subnet in worker region

resource "aws_subnet" "worker-subnet-1" {
  provider = aws.worker-region
  cidr_block = "192.168.1.0/24"
  vpc_id     = aws_vpc.tf-vpc-worker.id


 # availability_zone = element(data.aws_availability_zones.master-azs.names,0)

  tags = {
    Name = "Master-Subnet-1-tf"
  }

}

//Peering connection for the vpc
resource "aws_vpc_peering_connection" "useast1-uswest2" {
  provider = aws.master-region
  peer_vpc_id = aws_vpc.tf-vpc-worker.id
  vpc_id = aws_vpc.tf-vpc-master.id
  peer_region = var.worker-region
}
//accept the vpc peering connection request.
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider = aws.worker-region
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  auto_accept = true
}

//routing table

resource "aws_route_table" "internet_route_worker" {
  provider = aws.worker-region
  vpc_id = aws_vpc.tf-vpc-worker.id
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-worker.id
  }
  route {
    cidr_block = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  tags = {
    Name = "Worker-region-internet-route"
  }
} 

resource "aws_route_table" "internet_route" {
  provider = aws.master-region
  vpc_id = aws_vpc.tf-vpc-master.id
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-master.id
  }
  route {
    cidr_block = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  tags = {
    Name = "Master-region-internet-route"
  }
} 


resource "aws_main_route_table_association" "set-master-default-rt-assoc"{
  provider = aws.master-region
  vpc_id   = aws_vpc.tf-vpc-master.id
  route_table_id = aws_route_table.internet_route.id
  }

resource "aws_main_route_table_association" "set-worker-default-rt-assoc"{
  provider = aws.worker-region
  vpc_id   = aws_vpc.tf-vpc-worker.id
  route_table_id = aws_route_table.internet_route_worker.id
  }