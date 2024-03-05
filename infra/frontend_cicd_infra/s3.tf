resource "aws_s3_bucket" "frontend_s3_bucket" {
  bucket = "${var.cicd_name}-frontend"
}
locals {
  key_prefix = "deploy"
}
resource "aws_s3_bucket_website_configuration" "s3_website" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend_s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket_acl" "frontend_s3_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.frontend_s3_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.frontend_s3_bucket_public_access_block,
  ]

  bucket = aws_s3_bucket.frontend_s3_bucket.id

  access_control_policy {
    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
      }
      permission = "READ_ACP"
    }

    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
      }
      permission = "READ"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}
