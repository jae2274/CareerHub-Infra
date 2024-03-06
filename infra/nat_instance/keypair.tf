resource "tls_private_key" "nat_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nat_keypair" {
  key_name   = "${var.instance_name}-keypair.pem"
  public_key = tls_private_key.nat_private_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  filename        = "${path.module}/keypair/${var.instance_name}-keypair.pem"
  content         = tls_private_key.nat_private_key.private_key_pem
  file_permission = "0600"
}
