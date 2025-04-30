variable "region" {
    type = string
    default = "ap-northeast-1"
  
}

variable "az_list" {
    type = list(string)
    default = [ "ap-northeast-1a", "ap-northeast-1c" ]
  
}

variable "storage_bucket_name" {
    type = string
    default = "sftp-bucket-"
  
}