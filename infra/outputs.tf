output "function_url" {
  description = "Function URL."
  value       = aws_lambda_function_url.this.function_url
}

output "cf_domain" {
  value       = module.cloudfront.cf_domain_name
  description = "Domain name corresponding to the distribution"
}