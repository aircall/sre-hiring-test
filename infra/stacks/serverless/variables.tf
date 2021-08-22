variable "api_endpoint_type" {
  type        = string
  description = "A list of endpoint types. This resource currently only supports managing a single value. Valid values: EDGE, REGIONAL or PRIVATE. If unspecified, defaults to EDGE."
  default     = "REGIONAL"
}

variable "binary_media_types" {
  type        = list(any)
  default     = ["multipart/form-data", "application/octet-stream"]
  description = "he list of binary media types supported by the RestApi. By default, the RestApi supports only UTF-8-encoded text payloads."
}

variable "dns_zone" {
  type        = string
  description = "Route53 Zone"
  default     = "shirwalab.net"
}