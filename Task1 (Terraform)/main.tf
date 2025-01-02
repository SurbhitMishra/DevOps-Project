# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "nat-gateway"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.public_subnet_1_cidr
  map_public_ip_on_launch = true
  availability_zone      = var.az_1
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.public_subnet_2_cidr
  map_public_ip_on_launch = true
  availability_zone      = var.az_2
  tags = {
    Name = "public-subnet-2"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.private_subnet_1_cidr
  availability_zone      = var.az_1
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.private_subnet_2_cidr
  availability_zone      = var.az_2
  tags = {
    Name = "private-subnet-2"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private-route-table"
  }
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow all traffic within VPC"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion EC2
resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = var.key_pair_name

  # using sg id since both subnet name and sg name cannot be cannot specified together.
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  root_block_device {
    volume_size           = 20  # 30GB Storage
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "bastion"
  }
}

# Jenkins EC2
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet_1.id
  key_name      = var.key_pair_name

  # using sg id since both subnet name and sg name cannot be cannot specified together.
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  root_block_device {
    volume_size           = 20  # 30GB Storage
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "jenkins"
  }
}

# App EC2
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet_2.id
  key_name      = var.key_pair_name

  # using sg id since both subnet name and sg name cannot be cannot specified together.
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  root_block_device {
    volume_size           = 20  # 30GB Storage
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "app"
  }
}
