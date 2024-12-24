

locals {
  network_infra_backend = {
    bucket         = "careerhub-network-cluster-tfstate"
    dynamodb_table = "careerhub-network-cluster-tfstate-lock"
    encrypt        = true
    region         = local.backend_region
  }
}



module "network_infra_s3_backend" {
  source              = "github.com/jae2274/terraform_modules/s3_backend"
  bucket              = local.network_infra_backend.bucket
  dynamodb_lock_table = local.network_infra_backend.dynamodb_table
}

output "network_infra_backend" {
  value = merge(local.network_infra_backend,
    {
      bucket_arn         = module.network_infra_s3_backend.bucket_arn
      dynamodb_table_arn = module.network_infra_s3_backend.dynamodb_table_arn
    }
  )
}
