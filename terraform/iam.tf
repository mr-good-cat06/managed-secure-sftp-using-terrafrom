

####lambda function IAM role and policy

resource "aws_ami_role" "lambda_auth_role" {
    name = "lambda_auth_funtion_role"
    assume_role_policy = jsonencode({
        version = "2012-10-17"
        statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principle = {
                    Service = "lambda.amazonaws.com"
                }

            }
        ]
    })
}

resource "aws_iam_policy" "lambda_auth_policy" {
    name = "lambda_auth_policy"
    policy = temolatefile(
        "${path.root}/../../lambda_auth_role_policy.json",
        {
            region = var.region
            account_id = data.aws_caller_identity.current.account_id
            transfer_server_id = aws_transfer_server.sftp_server.id
            lambda_auth_function_name = local.auth_lambda_function_name
        }

    )
}

resource "aws_iam_role_policy_attachment" "lambda_auth_role_policy_attachment" {
    role = aws_ami_role.lambda_auth_role.name
    policy_arn = aws_iam_policy.lambda_auth_policy.arn
}


###IAM role for logging service to transfer service

resource "aws_iam_role" "logging_role" {
    name = "tranfer_sftp_logging_role"
    assume_role_policy = <<EOF
    {
        
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow"
                "Principal": {
                "Service": "transfer.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
                }
            ]
        }
    EOF
    }


resource "aws_iam_role_policy" "logging_policy" {
    name = "transfer_sftp_logging_policy"
    role = aws_iam_role.logging_role.id

    policy = jsondecode(
        {
            Version = "2012-10-17"
            Statement = [
                {
                    Sid = "AllowCloudWatchLogAccess"
                    Effect = "Allow"
                    Action = [
                        "logs:CreateLogStream",
                        "logs:DescribeLogStreams",
                        "logs:PutLogEvents",
                        "logs:CreateLogGroup"
            ]
            Resource = "arn:aws:logs:*:*:log-group:/aws/transfer/*"
        }
            ]
        }
    )
}


# s3 bucket policy for transfer service

resource "aws_iam_role_policy" "sftp_s3_policy" {
    name = "sftp_s3_policy"
    role = aws_iam_role.sftp_s3_role.id
    policy = jsondecode(
        {
        "Version" : "2012-10-17"
        "Statement" : [
            {
                "Sid" : "ListObjectsInBucket",
                "Effect" : "Allow",
                "Action" : [
                    "s3:ListBucket",
                    "s33:GetBucketLocation"
                ],
                "Resource" : [
                    "arn:aws:s3:::${local.bucket_name}"
                ]  
            },
            {
                "Sid" : "BucketAccess",
                "Effect" : "Allow",
                "Action" : [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:DeleteObject",
                    "s3:GetObjectVersion",
                    "s3:DeleteObjectVersion",
                    "s3:GetObjectAcl",
                    "s3:PutObjectAcl"

                ],
                "Resource" : [
                    "arn:aws:s3:::${local.bucket_name}/*"
                ]
            }
        ]
    })
}


resource "aws_iam_role" "sftp_s3_role" {
    name = "sftp-transfer-s3-role"
    assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
        "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF

    }
