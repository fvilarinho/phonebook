resource "aws_vpc" "phonebook" {
  cidr_block           = var.settings.network.vpc.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.settings.general.name}-vpc"
  }
}

resource "aws_internet_gateway" "phonebook" {
  vpc_id = aws_vpc.phonebook.id

  tags = {
    Name = "${var.settings.general.name}-igw"
  }

  depends_on = [ aws_vpc.phonebook ]
}

resource "aws_route_table" "phonebook_igw" {
  vpc_id = aws_vpc.phonebook.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.phonebook.id
  }

  tags = {
    Name = "${var.settings.general.name}-rtb-igw"
  }

  depends_on = [
    aws_vpc.phonebook,
    aws_internet_gateway.phonebook
  ]
}

resource "aws_route_table_association" "phonebook_pub_subnet_a" {
  subnet_id      = aws_subnet.phonebook_pub_a.id
  route_table_id = aws_route_table.phonebook_igw.id
}

resource "aws_route_table_association" "phonebook_pub_subnet_b" {
  subnet_id      = aws_subnet.phonebook_pub_b.id
  route_table_id = aws_route_table.phonebook_igw.id
}

resource "aws_eip" "phonebook_subnet_a" {
  domain = "vpc"

  tags = {
    Name = "${var.settings.general.name}-eip-subnet-a"
  }
}

resource "aws_nat_gateway" "phonebook_pvt_subnet_a" {
  allocation_id = aws_eip.phonebook_subnet_a.id
  subnet_id     = aws_subnet.phonebook_pub_a.id

  tags = {
    Name = "${var.settings.general.name}-natgw-pvt-subnet-a"
  }

  depends_on = [
    aws_eip.phonebook_subnet_a,
    aws_subnet.phonebook_pub_a
  ]
}

resource "aws_route_table" "phonebook_pvt_subnet_a" {
  vpc_id = aws_vpc.phonebook.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.phonebook_pvt_subnet_a.id
  }

  tags = {
    Name = "${var.settings.geeral.name}-rtb-natgw-pvt-subnet-a"
  }

  depends_on = [
    aws_vpc.phonebook,
    aws_nat_gateway.phonebook_pvt_subnet_a
  ]
}

resource "aws_route_table_association" "phonebook_pvt_subnet_a" {
  subnet_id      = aws_subnet.phonebook_pvt_a.id
  route_table_id = aws_route_table.phonebook_pvt_subnet_a.id

  depends_on = [
    aws_subnet.phonebook_pvt_a,
    aws_route_table.phonebook_pvt_subnet_a
  ]
}

resource "aws_eip" "phonebook_subnet_b" {
  domain = "vpc"

  tags = {
    Name = "${var.settings.general.name}-eip-subnet-b"
  }
}

resource "aws_nat_gateway" "phonebook_pvt_subnet_b" {
  allocation_id = aws_eip.phonebook_subnet_b.id
  subnet_id     = aws_subnet.phonebook_pub_b.id

  tags = {
    Name = "${var.settings.general.name}-natgw-pvt-subnet-b"
  }

  depends_on = [
    aws_eip.phonebook_subnet_b,
    aws_subnet.phonebook_pub_b
  ]
}

resource "aws_route_table" "phonebook_pvt_subnet_b" {
  vpc_id = aws_vpc.phonebook.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.phonebook_pvt_subnet_b.id
  }

  tags = {
    Name = "${var.settings.general.name}-rtb-natgw-pvt-subnet-b"
  }

  depends_on = [
    aws_vpc.phonebook,
    aws_nat_gateway.phonebook_pvt_subnet_b
  ]
}

resource "aws_route_table_association" "phonebook_pvt_subnet_b" {
  subnet_id      = aws_subnet.phonebook_pvt_b.id
  route_table_id = aws_route_table.phonebook_pvt_subnet_b.id

  depends_on = [
    aws_subnet.phonebook_pvt_b,
    aws_route_table.phonebook_pvt_subnet_b
  ]
}
