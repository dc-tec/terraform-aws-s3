terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.7.0"
}

data "aws_region" "current" {}

resource "aws_s3_bucket" "main" {
  for_each = var.s3_config

  bucket = "s3-${each.value.bucket}-${data.aws_region.current.name}"

  tags = merge(
    var.tags,
    {
      "Name" = "s3-${each.value.bucket}-${data.aws_region.current.name}"
    }
  )
}

resource "aws_s3_bucket_versioning" "main" {
  for_each = var.s3_config

  bucket = aws_s3_bucket.main[each.key].id

  versioning_configuration {
    status = each.value.versioning
  }
}