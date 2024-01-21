output "s3_bucket_ids" {
  description = "The IDs of the created S3 buckets."
  value       = { for k, v in aws_s3_bucket.main : k => v.id }
}

output "s3_bucket_arns" {
  description = "The ARNs of the created S3 buckets."
  value       = { for k, v in aws_s3_bucket.main : k => v.arn }
}