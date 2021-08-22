resource "aws_s3_bucket" "image_resize_bucket" {
  bucket        = "shirwa-${var.environment}-images"
  acl           = "private"
  force_destroy = local.destructable

  //  server_side_encryption_configuration {
  //    rule {
  //      apply_server_side_encryption_by_default {
  //        sse_algorithm = "AES256"
  //      }
  //    }
  //  }

  tags = local.tags
}