variable "s3_config" {
  description = "S3 configuration"
  type = map(object({
    bucket           = string
    acl              = optional(string, "private")
    versioning       = optional(string, "Disabled")
    object_ownership = optional(string, "BucketOwnerPreferred")
    policy           = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    environment = "prd"
    managedBy   = "Terraform"
  }
}