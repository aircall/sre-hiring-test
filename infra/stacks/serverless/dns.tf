resource "aws_api_gateway_domain_name" "api_domain_name" {
  domain_name              = "api.${var.dns_zone}"
  regional_certificate_arn = aws_acm_certificate.api_cert.arn

  endpoint_configuration {
    types = [var.api_endpoint_type]
  }

  security_policy = "TLS_1_2"

  tags = local.tags
}

resource "aws_api_gateway_base_path_mapping" "api_domain_mapping" {
  api_id      = aws_api_gateway_rest_api.image.id
  stage_name  = aws_api_gateway_deployment.image_deployment.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain_name.domain_name
}

resource "aws_route53_record" "api_domain_name_record" {
  name    = aws_api_gateway_domain_name.api_domain_name.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.hosted_zone.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api_domain_name.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_domain_name.regional_zone_id
  }
}