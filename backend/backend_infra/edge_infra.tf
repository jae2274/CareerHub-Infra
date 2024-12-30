

locals {
  edge_infra_backend = {
    bucket         = "careerhub-edge-tfstate"
    dynamodb_table = "careerhub-edge-tfstate-lock"
    encrypt        = true
    region         = local.backend_region
  }
}



module "edge_infra_s3_backend" {
  source              = "github.com/jae2274/terraform_modules/s3_backend"
  bucket              = local.edge_infra_backend.bucket
  dynamodb_lock_table = local.edge_infra_backend.dynamodb_table
}

output "edge_infra_backend" {
  value = merge(local.edge_infra_backend,
    {
      bucket_arn         = module.edge_infra_s3_backend.bucket_arn
      dynamodb_table_arn = module.edge_infra_s3_backend.dynamodb_table_arn
    }
  )
}
