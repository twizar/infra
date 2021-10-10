resource "aws_acm_certificate" "cert" {
  domain_name       = aws_route53_zone.twizar_route53_zone.name
  validation_method = "DNS"
  provider = aws.Virginia

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.Virginia
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
