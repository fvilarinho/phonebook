resource "aws_subnet" "phonebook_pub_a" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.1.0/24"
  availability_zone                           = "us-east-1a"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name                     = "phonebook-pub-subnet-a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "phonebook_pvt_a" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.2.0/24"
  availability_zone                           = "us-east-1a"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name                              = "phonebook-pvt-subnet-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "phonebook_pub_b" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.3.0/24"
  availability_zone                           = "us-east-1b"
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name                     = "phonebook-pub-subnet-b"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "phonebook_pvt_b" {
  vpc_id                                      = aws_vpc.phonebook.id
  cidr_block                                  = "10.0.4.0/24"
  availability_zone                           = "us-east-1b"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name                              = "phonebook-pvt-subnet-b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
