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
      allowed_methods           = ordered_cache_behavior.value.allowed_methods
      cached_methods            = ordered_cache_behavior.value.cached_methods
      compress                  = lookup(ordered_cache_behavior.value, "compress", null)
      default_ttl               = lookup(ordered_cache_behavior.value, "default_ttl", null)
      field_level_encryption_id = lookup(ordered_cache_behavior.value, "field_level_encryption_id", null)
      max_ttl                   = lookup(ordered_cache_behavior.value, "max_ttl", null)
      min_ttl                   = lookup(ordered_cache_behavior.value, "min_ttl", null)
      path_pattern              = ordered_cache_behavior.value.path_pattern
      smooth_streaming          = lookup(ordered_cache_behavior.value, "smooth_streaming", null)
      target_origin_id          = ordered_cache_behavior.value.target_origin_id
      trusted_signers           = lookup(ordered_cache_behavior.value, "trusted_signers", null)
      viewer_protocol_policy    = ordered_cache_behavior.value.viewer_protocol_policy

      forwarded_values {  
          headers                 = lookup(ordered_cache_behavior.value.forwarded_values, "headers", null)
          query_string            = ordered_cache_behavior.value.forwarded_values.query_string
          query_string_cache_keys = lookup(ordered_cache_behavior.value.forwarded_values, "query_string_cache_keys", null)
          cookies {
              forward           = ordered_cache_behavior.value.forwarded_values.cookies.forward
              whitelisted_names = lookup(ordered_cache_behavior.value.forwarded_values.cookies, "whitelisted_names", null)
            }
          }
        
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association
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
  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn == "" ? null : "sni-only"
    minimum_protocol_version       = var.acm_certificate_arn == "" ? "TLSv1" : "TLSv1.1_2016"
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
  }
  web_acl_id = var.web_acl_id
}

