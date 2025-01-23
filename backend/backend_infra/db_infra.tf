

locals {
  db_infra_backend = {
    bucket         = "careerhub-db-infra-tfstate"
    dynamodb_table = "careerhub-db-infra-tfstate-lock"
    encrypt        = true
    region         = local.backend_region
  }
}



module "db_infra_s3_backend" {
  source              = "github.com/jae2274/terraform_modules/s3_backend"
  bucket              = local.db_infra_backend.bucket
  dynamodb_lock_table = local.db_infra_backend.dynamodb_table
}

output "db_infra_backend" {
  value = merge(local.db_infra_backend,
    {
      bucket_arn         = module.db_infra_s3_backend.bucket_arn
      dynamodb_table_arn = module.db_infra_s3_backend.dynamodb_table_arn
    }
  )
}
