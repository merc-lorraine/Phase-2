provider "aws" {
  region = "us-east-1"
}

resource "random_id" "id" {
  byte_length = 4
}

# Log Bucket
resource "aws_s3_bucket" "log_bucket"{
  bucket        = "tkh-vault-logs-${random_id.id.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "log_bucket_public_access" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# The 'Vulnerable_Vault' or Main Bucket
resource "aws_s3_bucket" "not_so_vulnerable_vault" {
  bucket = "tkh-exposed-vault-${random_id.id.hex}"
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "vault_public_access" {
  bucket = aws_s3_bucket.not_so_vulnerable_vault.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# KMS Key for Encryption
resource "aws_kms_key" "vault_key" {
  description             = "KMS key for vault bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# Server-Side Encryption using KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "vault_encryption" {
  bucket = aws_s3_bucket.not_so_vulnerable_vault.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.vault_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Versioning Configuration
resource "aws_s3_bucket_versioning" "vault_versioning" {
  bucket = aws_s3_bucket.not_so_vulnerable_vault.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 4. Access Logging Configuration
resource "aws_s3_bucket_logging" "vault_logging" {
  bucket = aws_s3_bucket.not_so_vulnerable_vault.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}


