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
    for_each = [for custom_error_response in  var.custom_error_responses:{
      error_caching_min_ttl = custom_error_response.error_caching_min_ttl
      error_code            = custom_error_response.error_code
      response_code         = custom_error_response.response_code
      response_page_path    = custom_error_response.response_page_path
    }]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
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
    for_each = [for ordered_cache_behavior in var.ordered_cache_behaviors:{
      allowed_methods           = ordered_cache_behavior.allowed_methods
      cached_methods            = ordered_cache_behavior.cached_methods
      compress                  = ordered_cache_behavior.compress
      default_ttl               = ordered_cache_behavior.default_ttl
      field_level_encryption_id = ordered_cache_behavior.field_level_encryption_id
      max_ttl                   = ordered_cache_behavior.max_ttl
      min_ttl                   = ordered_cache_behavior.min_ttl
      path_pattern              = ordered_cache_behavior.path_pattern
      smooth_streaming          = ordered_cache_behavior.smooth_streaming
      target_origin_id          = ordered_cache_behavior.target_origin_id
      trusted_signers           = ordered_cache_behavior.trusted_signers
      viewer_protocol_policy    = ordered_cache_behavior.viewer_protocol_policy

    }]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      allowed_methods           = ordered_cache_behavior.value.allowed_methods
      cached_methods            = ordered_cache_behavior.value.cached_methods
      compress                  = ordered_cache_behavior.value.compress
      default_ttl               = ordered_cache_behavior.value.default_ttl
      field_level_encryption_id = ordered_cache_behavior.value.field_level_encryption_id
      max_ttl                   = ordered_cache_behavior.value.max_ttl
      min_ttl                   = ordered_cache_behavior.value.min_ttl
      path_pattern              = ordered_cache_behavior.value.path_pattern
      smooth_streaming          = ordered_cache_behavior.value.smooth_streaming
      target_origin_id          = ordered_cache_behavior.value.target_origin_id
      trusted_signers           = ordered_cache_behavior.value.trusted_signers
      viewer_protocol_policy    = ordered_cache_behavior.value.viewer_protocol_policy

      dynamic "forwarded_values" {
        for_each = lookup(ordered_cache_behavior.value, "forwarded_values", [])
        content {
          headers                 = lookup(forwarded_values.value, "headers", null)
          query_string            = forwarded_values.value.query_string
          query_string_cache_keys = lookup(forwarded_values.value, "query_string_cache_keys", null)

          dynamic "cookies" {
            for_each = lookup(forwarded_values.value, "cookies", [])
            content {
              forward           = cookies.value.forward
              whitelisted_names = lookup(cookies.value, "whitelisted_names", null)
            }
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(ordered_cache_behavior.value, "lambda_function_association", [])
        content {
          event_type   = lambda_function_association.value.event_type
          include_body = lookup(lambda_function_association.value, "include_body", null)
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
    for_each = [for viewer_certificate in local.viewer_certificates[local.cloudfront_default_certificate ? 0 : 1]:{
      acm_certificate_arn            = viewer_certificate.acm_certificate_arn
      cloudfront_default_certificate = viewer_certificate.cloudfront_default_certificate
      iam_certificate_id             = viewer_certificate.iam_certificate_id
      minimum_protocol_version       = viewer_certificate.minimum_protocol_version
      ssl_support_method             = viewer_certificate.ssl_support_method

    }]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      acm_certificate_arn            = viewer_certificate.value.acm_certificate_arn
      cloudfront_default_certificate = viewer_certificate.value.cloudfront_default_certificate
      iam_certificate_id             = viewer_certificate.value.iam_certificate_id
      minimum_protocol_version       = viewer_certificate.value.minimum_protocol_version
      ssl_support_method             = viewer_certificate.value.ssl_support_method
    }
  }
  web_acl_id = var.web_acl_id
}

