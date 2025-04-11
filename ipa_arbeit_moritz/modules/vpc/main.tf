resource "aws_vpc" "default_vpc" {
  cidr_block           = var.vpc_cidr_ip_subnet
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name     = "${var.clientSlug}-vpc-tf"
    Customer = var.clientName
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "${var.clientSlug}-igw-tf"
  }
}

resource "aws_subnet" "pub_sbn" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = var.pub_ip_subnet
  availability_zone       = "eu-central-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.clientSlug}-sbn-pub-2a-tf"
  }
}

resource "aws_subnet" "pvt_sbn" {
  vpc_id            = aws_vpc.default_vpc.id
  cidr_block        = var.pvt_ip_subnet
  availability_zone = "eu-central-2a"
  tags = {
    Name = "${var.clientSlug}-sbn-pvt-2b-tf"
  }
}

resource "aws_eip" "nat_eip" {
  # vpc = true
  domain = "vpc"
}

resource "aws_route_table" "rtb_pub" {
  vpc_id = aws_vpc.default_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.clientSlug}-rtb-pub-tf"
  }
}

resource "aws_route_table" "rtb_pvt" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "${var.clientSlug}-rtb-pvt-tf"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub_sbn.id
  tags = {
    Name = "${var.clientSlug}-nat-tf"
  }
}

resource "aws_route" "pvt_rt" {
  route_table_id         = aws_route_table.rtb_pvt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "pvt_sbn_associate" {
  subnet_id      = aws_subnet.pvt_sbn.id
  route_table_id = aws_route_table.rtb_pvt.id
}

resource "aws_route_table_association" "pub_sbn_associate" {
  subnet_id      = aws_subnet.pub_sbn.id
  route_table_id = aws_route_table.rtb_pub.id
}