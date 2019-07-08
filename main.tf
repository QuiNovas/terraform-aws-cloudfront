data "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket
}

resource "aws_cloudfront_origin_access_identity" "origin" {
  comment = var.distribution_name
}

resource "aws_cloudfront_distribution" "distribution" {
  aliases = var.aliases
  comment = var.comment
  dynamic "custom_error_response" {
    for_each = var.custom_error_response
    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }
  default_cache_behavior {
    allowed_methods = [
      "HEAD",
      "GET",
    ]
    cached_methods = [
      "HEAD",
      "GET",
    ]
    default_ttl = 3600
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = aws_lambda_function.redirector.qualified_arn
    }
    max_ttl                = 86400
    min_ttl                = 0
    target_origin_id       = var.distribution_name
    viewer_protocol_policy = "redirect-to-https"
  }
  default_root_object = var.default_root_object
  depends_on          = [aws_lambda_permission.redirector]
  enabled             = true
  is_ipv6_enabled     = true
  lifecycle {
    ignore_changes = [default_cache_behavior]
  }
  logging_config {
    bucket          = data.aws_s3_bucket.log_bucket.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront/${var.distribution_name}/"
  }
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior
    content {
      allowed_methods           = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      cached_methods            = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      compress                  = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      default_ttl               = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      field_level_encryption_id = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      max_ttl                   = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      min_ttl                   = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      path_pattern              = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      smooth_streaming          = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      target_origin_id          = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      trusted_signers           = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)
      viewer_protocol_policy    = lookup(ordered_cache_behavior.value, "error_caching_min_ttl", null)

      forwarded_values {  
          headers                 = ordered_cache_behavior.value.forwarded_values.headers
          query_string            = ordered_cache_behavior.value.forwarded_values.query_string
          query_string_cache_keys = ordered_cache_behavior.value.forwarded_values.query_string_cache_keys
          cookies {
              forward           = ordered_cache_behavior.value.forwarded_values.cookies.forward
              whitelisted_names = ordered_cache_behavior.value.forwarded_values.cookies.whitelisted_names
            }
          }
        
      dynamic "lambda_function_association" {
        for_each = [for lambda_function_association in ordered_cache_behavior.value.lambda_function_association :{
          event_type   = lambda_function_association.event_type
          include_body = lambda_function_association.include_body
          lambda_arn   = lambda_function_association.lambda_arn
        }]
        content {
          event_type   = lambda_function_association.value.event_type
          include_body = lambda_function_association.value.include_body
          lambda_arn   = lambda_function_association.value.lambda_arn
        }
      }
    }
  }
  origin {
    domain_name = aws_s3_bucket.origin.bucket_domain_name
    origin_id   = var.distribution_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin.cloudfront_access_identity_path
    }
  }
  price_class = var.price_class
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = local.tags
  dynamic "viewer_certificate" {
    for_each = [local.viewer_certificates[local.cloudfront_default_certificate ? 0 : 1]]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      acm_certificate_arn            = lookup(viewer_certificate.value, "acm_certificate_arn", null)
      cloudfront_default_certificate = lookup(viewer_certificate.value, "cloudfront_default_certificate", null)
      iam_certificate_id             = lookup(viewer_certificate.value, "iam_certificate_id", null)
      minimum_protocol_version       = lookup(viewer_certificate.value, "minimum_protocol_version", null)
      ssl_support_method             = lookup(viewer_certificate.value, "ssl_support_method", null)
    }
  }
  web_acl_id = var.web_acl_id
}

