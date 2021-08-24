module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.service_name}-bucket"
  acl    = "private"

  versioning = {
    enabled = true
  }

  tags = {
    owner        = local.owner
    service_name = local.service_name
    managed_by   = local.managed_by
    envname      = local.envname
    versioning   = local.versioning
  }
}