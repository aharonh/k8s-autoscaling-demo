
# bucket for the terraform and kops state. was created manually, then imported
# so that we can manage it from here
data "aws_s3_bucket" "demo_state" {
  bucket = var.demo_state_bucket
}

# generally, it is recommended to have versioning enabled for the state bucket
# but as this is a demo cluster, we will disable it
resource "aws_s3_bucket_versioning" "demo_state" {
  bucket = data.aws_s3_bucket.demo_state.bucket

  versioning_configuration {
    status = "Disabled"
  }

}

# kops recommends to apply server side encryption by default for the kops state bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "demo_state" {
  bucket = data.aws_s3_bucket.demo_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# it is generally recommended to block public access to the state bucket
resource "aws_s3_bucket_public_access_block" "demo_state" {
  bucket                  = var.demo_state_bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# cluster OIDC discovery store
resource "aws_s3_bucket" "demo_oidc" {
  bucket = var.demo_oidc_bucket
}

# it is generally recommended to have versioning enabled for the OIDC discovery store
# but as this is a demo cluster, we will disable it
resource "aws_s3_bucket_versioning" "demo_oidc" {
  bucket = aws_s3_bucket.demo_oidc.bucket

  versioning_configuration {
    status = "Disabled"
  }
}

# the oidc bucket has to have public access enabled according to kops documentation
# see https://kops.sigs.k8s.io/getting_started/aws/
# "The ACL must be public so that the AWS STS service can access them."
resource "aws_s3_bucket_public_access_block" "demo_oidc" {
  bucket                  = var.demo_oidc_bucket
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_acl" "demo_oidc" {
  bucket = aws_s3_bucket.demo_oidc.bucket
  acl = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.demo_oidc]
}
resource "aws_s3_bucket_ownership_controls" "demo_oidc" {
  bucket = aws_s3_bucket.demo_oidc.id
  rule {
    object_ownership = "ObjectWriter"
  }
}