variable "eks_vpc_cidr_block" {default = "192.168.0.0/16"}
variable "eks_public_subnet_01_cidr_block" {default = "192.168.0.0/18"}
variable "eks_public_subnet_02_cidr_block" {default = "192.168.64.0/18"}
variable "eks_private_subnet_01_cidr_block" {default = "192.168.128.0/18"}
variable "eks_private_subnet_02_cidr_block" {default = "192.168.192.0/18"}
variable "eks_availability_zone_1" {default = "us-east-1a"}
variable "eks_availability_zone_2" {default = "us-east-1b"}


resource "aws_vpc" "vpc_eks" {
  cidr_block = var.eks_vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-VPC"
  }
}

resource "aws_internet_gateway" "igw_eks" {
  vpc_id = aws_vpc.vpc_eks.id
  tags = {
    Name = "eks-IGW"
  }
}

resource "aws_route_table" "rt_public_eks" {
  vpc_id = aws_vpc.vpc_eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_eks.id
  }
  tags = {
    Name = "Public Subnets"
    Network = "Public"
  }
}

resource "aws_route_table" "rt_private_01_eks" {
  vpc_id = aws_vpc.vpc_eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_eks.id
  }
  tags = {
    Name = "Private Subnet AZ1"
    Network = "Private01"
  }
}

resource "aws_route_table" "rt_private_02_eks" {
  vpc_id = aws_vpc.vpc_eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_eks.id
  }
  tags = {
    Name = "Private Subnet AZ2"
    Network = "Private02"
  }
}

resource "aws_eip" "ngw_eip_01_eks" {
  vpc      = true
  depends_on = [aws_internet_gateway.igw_eks]
}

resource "aws_eip" "ngw_eip_02_eks" {
  vpc      = true
  depends_on = [aws_internet_gateway.igw_eks]
}

resource "aws_subnet" "public_subnet_01_eks" {
  vpc_id            = aws_vpc.vpc_eks.id
  cidr_block        = var.eks_public_subnet_01_cidr_block
  availability_zone = var.eks_availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-PublicSubnet01"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/cluster_eks" = "shared"
  }
}

resource "aws_subnet" "public_subnet_02_eks" {
  vpc_id            = aws_vpc.vpc_eks.id
  cidr_block        = var.eks_public_subnet_02_cidr_block
  availability_zone = var.eks_availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-PublicSubnet02"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/cluster_eks" = "shared"
  }
}

resource "aws_subnet" "private_subnet_01_eks" {
  vpc_id            = aws_vpc.vpc_eks.id
  cidr_block        = var.eks_private_subnet_01_cidr_block
  availability_zone = var.eks_availability_zone_1
  map_public_ip_on_launch = true # terraform bug force-requires this, even though deprecated requirement and also not required via console
  tags = {
    Name = "eks-PrivateSubnet01"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/cluster_eks" = "shared"
  }
}

resource "aws_subnet" "private_subnet_02_eks" {
  vpc_id            = aws_vpc.vpc_eks.id
  cidr_block        = var.eks_private_subnet_02_cidr_block
  availability_zone = var.eks_availability_zone_2
  map_public_ip_on_launch = true # terraform bug force-requires this, even though deprecated requirement and also not required via console
  tags = {
    Name = "eks-PrivateSubnet02"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/cluster_eks" = "shared"
  }
}

resource "aws_nat_gateway" "ngw_eks_01" {
  allocation_id = aws_eip.ngw_eip_01_eks.id
  subnet_id     = aws_subnet.public_subnet_01_eks.id

  tags = {
    Name = "eks-NatGatewayAZ1"
  }

  depends_on = [aws_internet_gateway.igw_eks]
}

resource "aws_nat_gateway" "ngw_eks_02" {
  allocation_id = aws_eip.ngw_eip_02_eks.id
  subnet_id     = aws_subnet.public_subnet_02_eks.id

  tags = {
    Name = "eks-NatGatewayAZ2"
  }

  depends_on = [aws_internet_gateway.igw_eks]
}

resource "aws_route_table_association" "rt_assoc_public01_eks" {
  subnet_id = aws_subnet.public_subnet_01_eks.id
  route_table_id = aws_route_table.rt_public_eks.id
}

resource "aws_route_table_association" "rt_assoc_public02_eks" {
  subnet_id = aws_subnet.public_subnet_02_eks.id
  route_table_id = aws_route_table.rt_public_eks.id
}

resource "aws_route_table_association" "rt_assoc_private01_eks" {
  subnet_id = aws_subnet.private_subnet_01_eks.id
  route_table_id = aws_route_table.rt_private_01_eks.id
}

resource "aws_route_table_association" "rt_assoc_private02_eks" {
  subnet_id = aws_subnet.private_subnet_02_eks.id
  route_table_id = aws_route_table.rt_private_02_eks.id
}

resource "aws_security_group" "sg_cluster_comm_nodes_eks" {
  name        = "sg_cluster_comm_nodes_eks"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.vpc_eks.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "eks"
  }
}
