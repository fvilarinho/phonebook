# Creates the VPC subnets.
resource "aws_subnet" "phonebook_pvt_subnet" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.1.0/24"
  enable_resource_name_dns_a_record_on_launch = true
  availability_zone                           = "us-east-1a"

  depends_on = [aws_vpc.phonebook]
}

resource "aws_subnet" "phonebook_pub_subnet" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.2.0/24"
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch                     = true
  availability_zone                           = "us-east-1a"

  depends_on = [aws_vpc.phonebook]
}
