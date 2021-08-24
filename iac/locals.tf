locals {
  owner        = var.owner
  service_name = var.service_name
  managed_by   = var.managed_by
  envname      = var.envname
  versioning   = var.versioning

  filename_module   = var.filename_module
  filename_codebase = var.filename_codebase

  stage_name = var.envname
}