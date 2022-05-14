resource "aws_s3_bucket" "fluentbit_logging_bucket" {
  bucket = "fluent-bit-log-12345"
}

resource "aws_s3_bucket_acl" "fluentbit_logging_bucket_acl" {
  bucket = aws_s3_bucket.fluentbit_logging_bucket.id
  acl    = "private"
}