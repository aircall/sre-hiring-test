variable "region" {
  type = string
}

variable "account_name" {
  type        = string
  description = "The name of the AWS account. There must be a matching entry for 'assumed_iam_roles' variable"
}

variable "account_id" {
  type        = map(string)
  description = "The AWS accounts"

  default = {
    dev  = "570221997972"
    test = "xxxxxxxxxxxx"
    prod = "xxxxxxxxxxxx"
  }
}

variable "environment" {
  type        = string
  description = "The environment in which this is deployed"
}

variable "stack" {
  type        = string
  description = "The stack that is being deployed"
}