output bucket_arn{
    value = aws_s3_bucket.tfstate.arn
}

output dynamodb_table_arn{
    value = aws_dynamodb_table.terraform_state_lock.arn
}