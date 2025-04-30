resource "aws_secretsmanager_secret" "sftp_secret" {
    name = "sftp-secret"
    recovery_window_in_days = 0
  
}

resource "random_password" "this" {
    length = 64
    special = true
    override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "this" {
    secret_id = aws_secretsmanager_secret.sftp_secret.id
    secret_string = <<EOF
    {
    "password" : "${random_password.this.result}",
    "role" : "${aws_role.sftp_role.arn}",
    "home_dir" : "/${local.bucket_name}"
    }
    EOF

}

