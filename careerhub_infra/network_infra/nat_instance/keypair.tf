resource "tls_private_key" "nat_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nat_keypair" {
  key_name   = "${var.instance_name}-keypair.pem"
  public_key = tls_private_key.nat_private_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "nat_private_key" {
  name                    = "${var.instance_name}-private-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "nat_private_key_version" {
  secret_id     = aws_secretsmanager_secret.nat_private_key.id
  secret_string = tls_private_key.nat_private_key.private_key_pem
}
