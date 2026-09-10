resource "aws_subnet" "phonebook_pub_a" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.1.0/24"
  availability_zone                           = "${data.aws_region.current.region}a"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "${local.build.name}-pub-subnet-a"
  }
}

resource "aws_subnet" "phonebook_pvt_a" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.2.0/24"
  availability_zone                           = "${data.aws_region.current.region}a"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "${local.build.name}-pvt-subnet-a"
  }
}

resource "aws_subnet" "phonebook_pub_b" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.3.0/24"
  availability_zone                           = "${data.aws_region.current.region}b"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "${local.build.name}-pub-subnet-b"
  }
}

resource "aws_subnet" "phonebook_pvt_b" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.4.0/24"
  availability_zone                           = "${data.aws_region.current.region}b"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "${local.build.name}-pvt-subnet-b"
  }
}
