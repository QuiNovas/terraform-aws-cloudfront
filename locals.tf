locals {
  bucket_name                    = var.bucket_name == "" ? var.distribution_name : var.bucket_name
  cloudfront_default_certificate = length(var.acm_certificate_arn) == 0
  tags = merge(
    var.tags,
    {
      "Name" = var.distribution_name
    },
  )
  viewer_certificate_acm = {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
  viewer_certificate_default = {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
  viewer_certificates = [
    local.viewer_certificate_default,
    local.viewer_certificate_acm,
  ]
}

