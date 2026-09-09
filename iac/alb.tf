resource "aws_lb" "phonebook_cluster" {
  name                       = "${local.build.name}-cluster-lb"
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = [ aws_security_group.phonebook_cluster_lb_traffic.id, aws_security_group.phonebook_cluster_lb_secure_traffic.id ]
  subnets                    = [ aws_subnet.phonebook_pub_a.id, aws_subnet.phonebook_pub_b.id ]
  drop_invalid_header_fields = true

  depends_on = [
    aws_security_group.phonebook_cluster_lb_traffic,
    aws_subnet.phonebook_pub_a,
    aws_subnet.phonebook_pub_b
  ]
}

resource "aws_lb_target_group" "phonebook_cluster" {
  name        = "${local.build.name}-cluster-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.phonebook.id

  health_check {
    enabled = true
    matcher = "200-499"
    path    = "/"
  }

  depends_on = [aws_vpc.phonebook]
}

resource "aws_lb_target_group_attachment" "phonebook_cluster_workernode1" {
  target_group_arn = aws_lb_target_group.phonebook_cluster.arn
  target_id        = aws_instance.phonebook_cluster_workernode1.id
  port             = 80

  depends_on = [
    aws_lb_target_group.phonebook_cluster,
    aws_instance.phonebook_cluster_workernode1
  ]
}

resource "aws_lb_target_group_attachment" "phonebook_cluster_workernode2" {
  target_group_arn = aws_lb_target_group.phonebook_cluster.arn
  target_id        = aws_instance.phonebook_cluster_workernode2.id
  port             = 80

  depends_on = [
    aws_lb_target_group.phonebook_cluster,
    aws_instance.phonebook_cluster_workernode2
  ]
}

resource "aws_lb_listener" "phonebook_cluster" {
  load_balancer_arn = aws_lb.phonebook_cluster.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [ aws_lb.phonebook_cluster ]
}

resource "aws_lb_listener" "secure_phonebook_cluster" {
  load_balancer_arn = aws_lb.phonebook_cluster.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.phonebook.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.phonebook_cluster.arn
  }

  depends_on = [
    aws_lb.phonebook_cluster,
    aws_acm_certificate_validation.phonebook,
    aws_lb_target_group.phonebook_cluster
  ]
}
