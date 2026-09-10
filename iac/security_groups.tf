data "http" "myip" {
  url = "https://ipinfo.io"
}

data "aws_ec2_managed_prefix_list" "cloudfront_ips" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

locals {
  my_ip = jsondecode(chomp(data.http.myip.response_body)).ip
}

resource "aws_security_group" "phonebook_cluster_bastion_pub_traffic" {
  name        = "${local.prefix}-${local.build.name}-cluster-bastion-pub-traffic"
  description = "Allow public traffic to phonebook cluster bastion."
  vpc_id      = aws_vpc.phonebook.id

  ingress {
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

resource "aws_security_group" "phonebook_cluster_lb_traffic" {
  name        = "${local.prefix}-${local.build.name}-cluster-lb-traffic"
  description = "Allow public HTTP traffic to the K3s application ALB."
  vpc_id      = aws_vpc.phonebook.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront_ips.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.phonebook,
    data.aws_ec2_managed_prefix_list.cloudfront_ips
  ]
}

resource "aws_security_group" "phonebook_cluster_lb_secure_traffic" {
  name        = "${local.prefix}-${local.build.name}-cluster-lb-secure-traffic"
  description = "Allow public HTTPS traffic to the K3s application ALB."
  vpc_id      = aws_vpc.phonebook.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront_ips.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.phonebook,
    data.aws_ec2_managed_prefix_list.cloudfront_ips
  ]
}

resource "aws_security_group" "phonebook_database_pub_traffic" {
  name        = "${local.prefix}-${local.build.name}-database-pub-traffic"
  description = "Allow public traffic to phonebook database."
  vpc_id      = aws_vpc.phonebook.id

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

  depends_on = [
    aws_vpc.phonebook,
    data.http.myip
  ]
}

resource "aws_security_group" "phonebook_database_pvt_traffic" {
  name        = "${local.prefix}-${local.build.name}-database-pvt-traffic"
  description = "Allow private traffic to phonebook database."
  vpc_id      = aws_vpc.phonebook.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.phonebook_cluster_workernode1.private_ip}/32", "${aws_instance.phonebook_cluster_workernode2.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.phonebook,
    aws_instance.phonebook_cluster_workernode1,
    aws_instance.phonebook_cluster_workernode2
  ]
}

# Allows only the database EC2 to initiate SSH connections to private workers.
resource "aws_security_group" "phonebook_cluster_workernodes_traffic" {
  name        = "${local.prefix}-${local.build.name}-cluster-workernodes-traffic"
  description = "Allow traffic to workernodes"
  vpc_id      = aws_vpc.phonebook.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.phonebook_cluster_bastion.public_ip}/32", "${aws_instance.phonebook_cluster_bastion.private_ip}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.phonebook_pvt_a.cidr_block}", "${aws_subnet.phonebook_pvt_b.cidr_block}", "${aws_subnet.phonebook_pub_a.cidr_block}", "${aws_subnet.phonebook_pub_b.cidr_block}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.phonebook_pvt_a.cidr_block}", "${aws_subnet.phonebook_pvt_b.cidr_block}", "${aws_subnet.phonebook_pub_a.cidr_block}", "${aws_subnet.phonebook_pub_b.cidr_block}"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.phonebook_pvt_a.cidr_block}", "${aws_subnet.phonebook_pvt_b.cidr_block}", "${aws_instance.phonebook_cluster_bastion.public_ip}/32", "${aws_instance.phonebook_cluster_bastion.private_ip}/32"]
  }

  ingress {
    from_port   = 9345
    to_port     = 9345
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.phonebook_pvt_a.cidr_block}", "${aws_subnet.phonebook_pvt_b.cidr_block}"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.phonebook_pvt_a.cidr_block}", "${aws_subnet.phonebook_pvt_b.cidr_block}"]
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["${aws_subnet.phonebook_pvt_a.cidr_block}", "${aws_subnet.phonebook_pvt_b.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.phonebook,
    aws_subnet.phonebook_pvt_a,
    aws_subnet.phonebook_pvt_b,
    aws_subnet.phonebook_pub_a,
    aws_subnet.phonebook_pub_b,
    aws_instance.phonebook_cluster_bastion
  ]
}
