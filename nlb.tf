resource "aws_lb" "ec2-nlb" {
 internal           = false
 load_balancer_type = "network"
 name                = "saas-${var.name_prefix}-ec2-nlb"
 subnet_mapping {
  subnet_id = aws_subnet.public_0.id
  allocation_id = aws_eip.nlb-eip[0].id
 }

 subnet_mapping {
  subnet_id = aws_subnet.public_1.id
  allocation_id = aws_eip.nlb-eip[1].id
 }

 enable_deletion_protection = true
 enable_cross_zone_load_balancing = true

 tags = local.common_tags

 depends_on = [aws_internet_gateway.gw]

}

resource "aws_lb_target_group" "ec2-nlb-target-group" {
    name                = "${var.name_prefix}-ec2-nlb-target-group"
    vpc_id              = aws_vpc.mumbai-vpc.id
    port                = "443"
    protocol            = "TCP"
    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold   = "5"
        interval            = "10"
        port                = "8080"
        protocol            = "TCP"
    }
    
    deregistration_delay = 300

    tags = merge(
             local.common_tags,
             {
               Name = "${var.name_prefix}-ec2-nlb-target-group"
             }
    )
}

resource "aws_lb_listener" "nlb-listener-443" {
    load_balancer_arn = aws_lb.ec2-nlb.arn
    port              = "443"
    protocol          = "TLS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = aws_acm_certificate_validation.mumbai-cert.certificate_arn
    default_action {
       target_group_arn = aws_lb_target_group.ec2-nlb-target-group.arn
       type             = "forward"
   }
}

resource "aws_lb_target_group" "scconverter-target-group" {
    name                = "${var.name_prefix}-ec2-nlb-tg-scconverter"
    vpc_id              = aws_vpc.mumbai-vpc.id
    port                = "4443"
    protocol            = "TCP"
    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "5"
        interval            = "10"
        port                = "traffic-port"
        protocol            = "TCP"
    }

    deregistration_delay = 300

    tags = merge(
             local.common_tags,
             {
               Name = "${var.name_prefix}-ec2-nlb-tg-scconverter"
             }
    )
}

resource "aws_lb_listener" "nlb-listener-scconverter" {
    load_balancer_arn = aws_lb.ec2-nlb.arn
    port              = "4443"
    protocol          = "TLS"
    certificate_arn = aws_acm_certificate_validation.mumbai-cert.certificate_arn
    default_action {
       target_group_arn = aws_lb_target_group.scconverter-target-group.arn
       type             = "forward"
   }
}
