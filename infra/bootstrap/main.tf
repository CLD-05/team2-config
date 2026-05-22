provider "aws" {
  region = "ap-northeast-2"
}

# 1. 상태 저장용 S3 버킷
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-unique-terraform-state-bucket-${data.aws_caller_identity.current.account_id}"
}

data "aws_caller_identity" "current" {}

# 2. 동시 수정 방지용 DynamoDB
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# 버전 관리: 상태 파일 실수 삭제/덮어쓰기 시 이전 버전으로 복구 가능
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

output "s3_bucket_name" { value = aws_s3_bucket.terraform_state.bucket }
