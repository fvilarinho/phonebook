resource "aws_subnet" "phonebook_pub_a" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = var.network.vpc.public_subnet_a.cidr
  availability_zone                           = "${data.aws_region.current.region}a"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "${local.prefix}-${local.build.name}-pub-subnet-a"
  }
}

resource "aws_subnet" "phonebook_pvt_a" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = var.network.vpc.private_subnet_a.cidr
  availability_zone                           = "${data.aws_region.current.region}a"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "${local.prefix}-${local.build.name}-pvt-subnet-a"
  }
}

resource "aws_subnet" "phonebook_pub_b" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = var.network.vpc.public_subnet_b.cidr
  availability_zone                           = "${data.aws_region.current.region}b"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "${local.prefix}-${local.build.name}-pub-subnet-b"
  }
}

resource "aws_subnet" "phonebook_pvt_b" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = var.network.vpc.private_subnet_b.cidr
  availability_zone                           = "${data.aws_region.current.region}b"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "${local.prefix}-${local.build.name}-pvt-subnet-b"
  }
}
