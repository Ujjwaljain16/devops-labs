output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.demo.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.demo.arn
}

output "bucket_region" {
  description = "AWS region the bucket was created in"
  value       = aws_s3_bucket.demo.region
}
