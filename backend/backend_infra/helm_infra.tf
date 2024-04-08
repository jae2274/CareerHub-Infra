

locals {
  helm_infra_backend = {
    bucket         = "careerhub-k8s-tfstate"
    dynamodb_table = "careerhub-k8s-tfstate-lock"
    encrypt        = true
    region         = local.backend_region
  }
}



module "helm_infra_s3_backend" {
  source              = "github.com/jae2274/terraform_modules/s3_backend"
  bucket              = local.helm_infra_backend.bucket
  dynamodb_lock_table = local.helm_infra_backend.dynamodb_table
}

output "helm_infra_backend" {
  value = merge(local.helm_infra_backend,
    {
      bucket_arn         = module.helm_infra_s3_backend.bucket_arn
      dynamodb_table_arn = module.helm_infra_s3_backend.dynamodb_table_arn
    }
  )
}
