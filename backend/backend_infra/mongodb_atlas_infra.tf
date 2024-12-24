

locals {
  mongodb_infra_backend = {
    bucket         = "careerhub-mongodb-tfstate"
    dynamodb_table = "careerhub-mongodb-tfstate-lock"
    encrypt        = true
    region         = local.backend_region
  }
}



module "mongodb_infra_s3_backend" {
  source              = "github.com/jae2274/terraform_modules/s3_backend"
  bucket              = local.mongodb_infra_backend.bucket
  dynamodb_lock_table = local.mongodb_infra_backend.dynamodb_table
}

output "mongodb_infra_backend" {
  value = merge(local.mongodb_infra_backend,
    {
      bucket_arn         = module.mongodb_infra_s3_backend.bucket_arn
      dynamodb_table_arn = module.mongodb_infra_s3_backend.dynamodb_table_arn
    }
  )
}
