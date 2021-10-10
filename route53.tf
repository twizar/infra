resource "aws_route53_zone" "twizar_route53_zone" {
  name = "twizar.net"
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.twizar_route53_zone.zone_id
}

resource "aws_route53_record" "domain" {
  name = aws_route53_zone.twizar_route53_zone.name
  zone_id = aws_route53_zone.twizar_route53_zone.id
  type = "A"
  alias {
    name = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
