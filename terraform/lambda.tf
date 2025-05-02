
#local name

locals {
    auth_lambda_function_name = "sftp_lambda_auth_${local.bucket_name}"
}


#lambda function code declaration

data "archive_file" "lambda_auth_function" {
    type        = "zip"
    source_dir = "${path.module}/../functions/auth_lambda"
    output_path = "${path.module}/../functions/auth_lambda.zip"
}

#lambda function resource
resource "aws_lambda_function" "sftp-lambda-auth" {
    filename = data.archive_file.lambda_auth_function.output_path
    function_name = local.auth_lambda_function_name
    role = aws_iam_role.lambda_auth_role.arn
    handler = "auth_lambda.handler"
    runtime = "python3.12"
    architectures = ["arm64"]
    layers = ["arn:aws:lambda:ap-northeast-1:017000801446:layer:AWSLambdaPowertoolsPythonV3-python38-arm64:4"]
    source_code_hash = data.archive_file.lambda_auth_function.output_base64sha256
  
    environment {
        variables = {
            SecretManagerRegion = var.region
        }
    }
}

#lambda permission for transfer service

resource "aws_lambda_permission" "transfer_sftp_lambda_invoke" {
    statement_id = "permit-invoke-transfer-sftp-lambda"
    action = "lambda:InvokeFunction"
    function_name = local.auth_lambda_function_name
    principal = "transfer.amazonaws.com"
    source_arn = aws_transfer_server.sftp_server.arn  
}
