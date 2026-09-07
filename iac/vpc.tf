# Creates the VPC.
resource "aws_vpc" "phonebook" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Creates the Internet gateway for the VPC.
resource "aws_internet_gateway" "phonebook" {
  vpc_id = aws_vpc.phonebook.id

  depends_on = [aws_vpc.phonebook]
}

# Creates the Internet routing table for the VPC.
resource "aws_route_table" "phonebook" {
  vpc_id = aws_vpc.phonebook.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.phonebook.id
  }

  depends_on = [
    aws_vpc.phonebook,
    aws_internet_gateway.phonebook
  ]
}

# Attaches the Internet routing table to the subnets.
resource "aws_route_table_association" "phonebook_pvt_subnet" {
  subnet_id      = aws_subnet.phonebook_pvt_subnet.id
  route_table_id = aws_route_table.phonebook.id

  depends_on = [
    aws_subnet.phonebook_pvt_subnet,
    aws_route_table.phonebook
  ]
}

resource "aws_route_table_association" "phonebook_pub_subnet" {
  subnet_id      = aws_subnet.phonebook_pub_subnet.id
  route_table_id = aws_route_table.phonebook.id

  depends_on = [
    aws_subnet.phonebook_pub_subnet,
    aws_route_table.phonebook
  ]
}
