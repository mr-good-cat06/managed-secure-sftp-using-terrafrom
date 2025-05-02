output "s3_bucket_name" {
  value = local.bucket_name
}

output "sftp_static_ip_list" {
  value = aws_eip.this[*].public_ip
}

output "sftp_password" {
  value = nonsensitive(random_password.this.result)
}