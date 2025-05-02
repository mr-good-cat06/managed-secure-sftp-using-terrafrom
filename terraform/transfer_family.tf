resource "aws_transfer_server" "sftp_server" {
    endpoint_type = "VPC"
    logging_role = resource.aws_iam_role.logging_role.arn
    identity_provider_type = "AWS_LAMBDA"
    function = aws_lambda_function.sftp-lambda-auth.arn
    domain = "S3"
    sftp_authentication_methods = "PASSWORD"
    protocols = ["SFTP"]
    structured_log_destinations = ["${aws_cloudwatch_log_group.sftp.arn}:*"]
    endpoint_details {
        vpc_id = aws_vpc.this.id
        subnet_ids = aws_subnet.public[*].id
        security_group_ids = [aws_security_group.sftp_sg.id]
        address_allocation_ids = aws_eip.this[*].id
    }
    tags = {
        Name = "sftp-server"
    }
}

resource "aws_cloudwatch_log_group" "sftp" {
    name_prefix = "sftp"
}

