

locals {
  backend = {
    bucket         = "careerhub-infra-tfstate"
    dynamodb_table = "careerhub-infra-tfstate-lock"
    encrypt        = true
    region         = local.backend_region
  }
}



module "s3_backend" {
  source              = "github.com/jae2274/terraform_modules/s3_backend"
  bucket              = local.backend.bucket
  dynamodb_lock_table = local.backend.dynamodb_table
}

output "backend" {
  value = merge(local.backend,
    {
      bucket_arn         = module.s3_backend.bucket_arn
      dynamodb_table_arn = module.s3_backend.dynamodb_table_arn
    }
  )
}
