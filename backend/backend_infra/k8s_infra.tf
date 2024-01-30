

locals {
  k8s_backend = {
    bucket         = "careerhub-k8s-tfstate"
    dynamodb_table = "careerhub-k8s-tfstate-lock"
    encrypt        = true
    region         = local.backend_region
  }
}



module "k8s_s3_backend" {
  source              = "github.com/jae2274/terraform_modules/s3_backend"
  bucket              = local.k8s_backend.bucket
  dynamodb_lock_table = local.k8s_backend.dynamodb_table
}

output "k8s_backend" {
  value = merge(local.k8s_backend,
    {
      bucket_arn         = module.k8s_s3_backend.bucket_arn
      dynamodb_table_arn = module.k8s_s3_backend.dynamodb_table_arn
    }
  )
}
