variable "acm_certificate_arn" {
  default     = ""
  description = "The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution. The ACM certificate must be in US-EAST-1. If this is left empty, the default certificate will be used"
  type        = string
}

variable "aliases" {
  default     = []
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
}

variable "bucket_name" {
  default     = ""
  description = "The name of the orgin bucket. Defaults to distribution_name"
  type        = string
}


variable "block_s3_public_access" {
  default     = true
  description = "blocks origin bucket public acceess"
  type        = bool
}

variable "comment" {
  default     = ""
  description = "Any comments you want to include about the distribution."
  type        = string
}

variable "custom_error_response" {
  default     = []
  description = "One or more custom error response elements (multiples allowed)."
  type = list(object({
    error_caching_min_ttl = number
    error_code            = number
    response_code         = number
    response_page_path    = string
  }))
}

variable "default_root_object" {
  default     = "index.html"
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
}

variable "distribution_name" {
  description = "The name of the distribution. It must be a globally unique name since it'll be taken as the bucket name."
  type        = string
}

variable "log_bucket" {
  description = "The log bucket to log CloudFront and S3 logs to. The bucket being used should have ACL enabled."
  type        = string
}

variable "ordered_cache_behavior" {
  default     = []
  description = "An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
  type = list(object({
    allowed_methods           = list(string)
    cached_methods            = list(string)
    compress                  = string
    default_ttl               = number
    field_level_encryption_id = string
    forwarded_values = object({
      cookies = object({
        forward           = string
        whitelisted_names = list(string)
      })
      headers                 = list(string)
      query_string            = bool
      query_string_cache_keys = list(string)
    })
    lambda_function_association = list(object({
      event_type   = string
      lambda_arn   = string
      include_body = bool
    }))
    max_ttl                = number
    min_ttl                = number
    path_pattern           = string
    smooth_streaming       = string
    target_origin_id       = string
    trusted_signers        = list(string)
    viewer_protocol_policy = string
  }))
}

variable "price_class" {
  default     = "PriceClass_100"
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100."
  type        = string
}

variable "tags" {
  default     = {}
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
}

variable "web_acl_id" {
  default     = ""
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution."
  type        = string
}
