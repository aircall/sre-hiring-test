locals {
  # Define default tags used on all resources

  tags = {
    tagversion         = "1"
    project            = "image-resizer"
    costcentre         = "aircall"
    environment        = var.environment
    customer           = "aircall"
    datatype           = "tbc"
    securityclassifier = "tbc"
    tool               = "Terraform"
    stack              = var.stack
  }

  destructable = var.environment != "prod" ? true : false
}