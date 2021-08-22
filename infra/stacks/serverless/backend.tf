terraform {
  backend "s3" {
    region         = "eu-west-2"
    bucket         = "image-resize-terraform-state"
    key            = "eu-west-2/serverless.tfstate"
    encrypt        = "true"
    role_arn       = "arn:aws:iam::570221997972:role/CIAccessRole"
    dynamodb_table = "terraform_statelock"
  }
}
