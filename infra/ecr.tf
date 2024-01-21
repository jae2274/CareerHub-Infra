resource "aws_ecr_repository" "careerhub_dataprovider" {
  name                 = "careerhub_dataprovider"
  image_tag_mutability = "MUTABLE"


  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "careerhub_dataprocessor" {
  name                 = "careerhub_dataprocessor"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
