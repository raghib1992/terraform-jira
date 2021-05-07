resource "aws_route53_record" "lb" {
  name = "${local.hostname}.${var.domainname}"
  type = "A"
  zone_id = var.route53_zone_id
  alias {
    name = aws_lb.ec2-nlb.dns_name
    zone_id = aws_lb.ec2-nlb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "mumbai-cert" {
  domain_name = "${local.hostname}.${var.domainname}"
  validation_method = "DNS"
  tags = local.common_tags
}

resource "aws_route53_record" "cert_validation" {
  name = aws_acm_certificate.mumbai-cert.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.mumbai-cert.domain_validation_options[0].resource_record_type
  zone_id = var.route53_zone_id
  records = [aws_acm_certificate.mumbai-cert.domain_validation_options[0].resource_record_value]
  ttl = 60
}

resource "aws_acm_certificate_validation" "mumbai-cert" {
  certificate_arn = aws_acm_certificate.mumbai-cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
