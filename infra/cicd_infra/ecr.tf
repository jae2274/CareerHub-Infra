resource "aws_ecr_repository" "ecr_repo" {
  name = "${var.cicd_name}-ecr"

  image_tag_mutability = "MUTABLE"
}
