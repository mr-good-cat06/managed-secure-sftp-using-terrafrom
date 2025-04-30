resource "random_string" "bckt_name" {
    length = 16
    special = false
    upper = false
}

locals {
    bucket_name = "${var.storage_bucket_name}${random_string.bckt_name.result}"

}

resource "aws_s3_bucket" "this" {
    bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "this" {
    bucket = aws_s3_bucket.this.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    bucket = aws_s3.bucket.this.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

