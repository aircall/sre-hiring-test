locals {
  env          = terraform.workspace
  project_name = "aircall-"
  project_env  = "az-teks-${local.env}"
  common_tags = {
    Terraform   = "true"
    Workspace   = terraform.workspace
    Environment = local.env
    Owner       = "Aircall"
  }

  account_id = data.aws_caller_identity.current.account_id
}
