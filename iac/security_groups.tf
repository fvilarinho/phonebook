# Fetches the current public ip of the local machine.
data "http" "myip" {
  url = "https://ipinfo.io"
}

# Defines the required variables for the security groups.
locals {
  my_ip = jsondecode(chomp(data.http.myip.response_body)).ip
}

# Creates the default security groups.
resource "aws_security_group" "phonebook_database_pub_traffic" {
  name        = "phonebook_database_pub_traffic"
  description = "Allow public traffic to phonebook database."
  vpc_id      = aws_vpc.phonebook.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.phonebook,
    data.http.myip
  ]
}

resource "aws_security_group" "phonebook_database_pvt_traffic" {
  name        = "phonebook_database_pvt_traffic"
  description = "Allow private traffic to phonebook database."
  vpc_id      = aws_vpc.phonebook.id

  ingress {
    description = "MongoDB access"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.phonebook_pvt_subnet.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.phonebook]
}