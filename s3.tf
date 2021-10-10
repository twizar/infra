resource "aws_s3_bucket" "twizar_web_bucket" {
  bucket = aws_route53_zone.twizar_route53_zone.name
}