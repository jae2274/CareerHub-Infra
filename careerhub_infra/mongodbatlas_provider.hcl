
generate "mongodbatlas_provider" {
    path = "mongodbatlas_provider.tf"
    if_exists = "overwrite_terragrunt"
    #if_exists = "skip"
    contents = <<EOF
provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}
EOF
}