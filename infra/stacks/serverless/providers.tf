provider "aws" {
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.account_id[var.account_name]}:role/CIAccessRole"
  }
}