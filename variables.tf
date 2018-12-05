variable "acm_certificate_arn" {
  description = "The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution. The ACM certificate must be in US-EAST-1."
  type        = "string"
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = "list"
}

variable "bucket_name" {
  default     = ""
  description = "The name of the orgin bucket. Defaults to distribution_name"
  type        = "string"
}

variable "comment" {
  default     = ""
  description = "Any comments you want to include about the distribution."
  type        = "string"
}

variable "custom_error_responses" {
  default     = []
  description = "One or more custom error response elements (multiples allowed)."
  type        = "list"
}

variable "default_root_object" {
  default     = "index.html"
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = "string"
}

variable "distribution_name" {
  description = "The name of the distribution."
  type        = "string"
}

variable "log_bucket" {
  description = "The log bucket to log CloudFront and S3 logs to."
  type        = "string"
}

variable "ordered_cache_behaviors" {
  default     = []
  description = "An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
  type        = "list"
}

variable "price_class" {
  default     = "PriceClass_100"
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100."
  type        = "string"
}

variable "tags" {
  default     = {}
  description = "A mapping of tags to assign to the resource."
  type        = "map"
}

variable "web_acl_id" {
  default     = ""
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution."
  type        = "string"
}
