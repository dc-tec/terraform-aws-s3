# Terraform AWS S3 Bucket Module

This module manages S3 buckets on AWS. It creates S3 buckets, sets their policies, and configures versioning.

## Requirements

- Terraform version 1.7.0 or newer
- AWS provider version 5.0 or newer

## Providers

- AWS

## Resources

- `aws_s3_bucket.main`: This resource creates an S3 bucket. The bucket name is a combination of a prefix "s3-", the bucket name from the `s3_config` variable, and the current AWS region name.
- `aws_s3_bucket_policy.main`: This resource sets the policy for each S3 bucket created by `aws_s3_bucket.main`. The policy is taken from the `s3_config` variable.
- `aws_s3_bucket_versioning.main`: This resource configures versioning for each S3 bucket created by `aws_s3_bucket.main`. The versioning status is taken from the `s3_config` variable.

## Inputs

- `s3_config`: A map where each item represents an S3 bucket. Each item should have the following keys:
  - `bucket`: The name of the bucket.
  - `policy`: The policy to apply to the bucket.
  - `versioning`: The versioning status for the bucket.
- `tags`: A map of tags to apply to all resources.

## Outputs

- `s3_bucket_ids`: The id's from the created S3 buckets
- `s3_bucket_arns`: The arn's of the created S3 buckets.

## Example Usage
The module can be used in the following way. Please note that `policy` is a required argument. For flexibility please include a [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.7.0"
}

provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

data "aws_iam_user" "main" {
  user_name = local.iam_user_name
}

data "aws_iam_policy_document" "main" {
  for_each = local.s3_config_yaml

  statement {
    sid    = "ListObjectsInBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_iam_user.main.arn}"]
    }

    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::s3-${each.value.bucket}-${data.aws_region.current.name}"]
  }

  statement {
    sid    = "ReadWriteObjectsInBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_iam_user.main.arn}"]
    }

    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::s3-${each.value.bucket}-${data.aws_region.current.name}/*"]
  }
}

locals {
  iam_user_name  = "iam_username"

  s3_config = {
    for key, value in var.s3_config :
    key => {
      bucket           = value.bucket
      acl              = value.acl
      versioning       = value.versioning
      object_ownership = value.object_ownership
      policy           = data.aws_iam_policy_document.main[key].json
    }
  }
}

module "s3" {
  source = "src"

  ## S3 configuration
  s3_config = local.s3_config
}

```

the following example TFVars can be used with this module.

```hcl
s3_config = {
  s3_bucket = {
    bucket = "s3-bucket"
    acl = "private"
    versioning = "Enabled"
    object_ownership = "BucketOwnerPreferred"
  }
}
```

## Notes

- The bucket name will be unique across AWS, as it includes the region name.
- The bucket policy and versioning status can be customized for each bucket.