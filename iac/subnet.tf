resource "aws_subnet" "phonebook_pub_a" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = var.settings.network.vpc.subnets.public_a.cidr
  availability_zone                           = "${data.aws_region.current.region}a"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name                     = "${var.settings.general.name}-pub-subnet-a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "phonebook_pvt_a" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = var.settings.network.vpc.subnets.private_a.cidr
  availability_zone                           = "${data.aws_region.current.region}a"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name                              = "${var.settings.general.name}-pvt-subnet-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "phonebook_pub_b" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = var.settings.network.vpc.subnets.public_b.cidr
  availability_zone                           = "${data.aws_region.current.region}b"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name                     = "${var.settings.general.name}-pub-subnet-b"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "phonebook_pvt_b" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = var.settings.network.vpc.subnets.private_b.cidr
  availability_zone                           = "${data.aws_region.current.region}b"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name                              = "${var.settings.general.name}-pvt-subnet-b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
