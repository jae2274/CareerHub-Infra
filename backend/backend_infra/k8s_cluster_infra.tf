

locals {
  k8s_cluster_infra_backend = {
    bucket         = "careerhub-k8s-cluster-tfstate"
    dynamodb_table = "careerhub-k8s-cluster-tfstate-lock"
    encrypt        = true
    region         = local.backend_region
  }
}



module "k8s_cluster_infra_s3_backend" {
  source              = "github.com/jae2274/terraform_modules/s3_backend"
  bucket              = local.k8s_cluster_infra_backend.bucket
  dynamodb_lock_table = local.k8s_cluster_infra_backend.dynamodb_table
}

output "k8s_cluster_infra_backend" {
  value = merge(local.k8s_cluster_infra_backend,
    {
      bucket_arn         = module.k8s_cluster_infra_s3_backend.bucket_arn
      dynamodb_table_arn = module.k8s_cluster_infra_s3_backend.dynamodb_table_arn
    }
  )
}
