data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "irsa_test" {
  bucket        = "${var.project}-irsa-test-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_object" "test_file" {
  bucket  = aws_s3_bucket.irsa_test.bucket
  key     = "hello.txt"
  content = "IRSA 정상 동작 확인!"
}

# 1. 테스트 버킷만 접근 가능하도록 커스텀 정책 생성
resource "aws_iam_policy" "s3_read_policy" {
  name = "${var.project}-s3-reader-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:Get*", "s3:List*"]
      Resource = [
        aws_s3_bucket.irsa_test.arn,
        "${aws_s3_bucket.irsa_test.arn}/*"
      ]
    }]
  })
}



resource "aws_iam_role" "s3_reader" {
  name = "${var.project}-s3-reader-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:default:s3-reader-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.s3_reader.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}
