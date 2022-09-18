#VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = var.cidr_block
  tags = {
    "Name" = var.vpc_name
  }
}

#Pub-Subnets
resource "aws_subnet" "Public-Subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  count                   = length(var.azs)
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.pub_cidrs, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.vpc_name}-Public-Subnet-${count.index + 1}"
  }

}

#Private-Subnets
resource "aws_subnet" "Private-Subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  count                   = length(var.azs)
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.private_cidrs, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.vpc_name}-Private-Subnet-${count.index + 1}"
  }

}

#IGW
resource "aws_internet_gateway" "My-IGW" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    "Name" = "${var.vpc_name}-IGW"
  }
}

#EIP
resource "aws_eip" "My-EIP" {
  vpc = true
  tags = {
    "Name" = "${var.vpc_name}-EIP"
  }
}

#NAT-GW
resource "aws_nat_gateway" "My-NATGw" {
  allocation_id = aws_eip.My-EIP.id
  subnet_id     = aws_subnet.Public-Subnet[0].id
  tags = {
    "Name" = "${var.vpc_name}-NATGW"
  }
}

#Public-RT
resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My-IGW.id
  }
  tags = {
    "Name" = "${var.vpc_name}-Public-RT"
  }
}

#Private-RT
resource "aws_route_table" "Private-RT" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.My-NATGw.id
  }
  tags = {
    "Name" = "${var.vpc_name}-Private-RT"
  }
}

# Public-RTA
resource "aws_route_table_association" "pub-rta" {
  count          = length(var.azs)
  route_table_id = aws_route_table.Public-RT.id
  subnet_id      = element(aws_subnet.Public-Subnet[*].id, count.index)
}

# Private-RTA
resource "aws_route_table_association" "private-rta" {
  count          = length(var.azs)
  route_table_id = aws_route_table.Private-RT.id
  subnet_id      = element(aws_subnet.Private-Subnet[*].id, count.index)
}

#SG
resource "aws_security_group" "My-SG" {
  name        = "Ngina-SG"
  description = "SG for Nginx"
  vpc_id      = aws_vpc.my-vpc.id
  ingress {
    description = "In-bound rules for nginx"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
