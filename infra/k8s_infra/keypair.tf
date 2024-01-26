resource "tls_private_key" "k8s_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_keypair" {
  key_name   = "${var.cluster_name}-keypair.pem"
  public_key = tls_private_key.k8s_private_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  filename        = "${path.module}/keypair/${var.cluster_name}-keypair.pem"
  content         = tls_private_key.k8s_private_key.private_key_pem
  file_permission = "0600"
}
