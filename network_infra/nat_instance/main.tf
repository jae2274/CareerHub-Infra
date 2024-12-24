data "aws_subnet" "public_subnet" {
  id = var.public_subnet_id
}

data "aws_vpc" "vpc" {
  id = data.aws_subnet.public_subnet.vpc_id
}

resource "aws_security_group" "nat_instance_sg" {
  vpc_id      = data.aws_subnet.public_subnet.vpc_id
  name        = "${var.instance_name}-sg"
  description = "Allow SSH and NAT traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat_instance" {
  ami = "ami-00c2fe3c2e5f11a2b" //Amazon Linux 2023 AMI arm64

  instance_type = "t4g.micro"
  key_name      = aws_key_pair.nat_keypair.key_name
  subnet_id     = var.public_subnet_id

  source_dest_check = false

  user_data = <<EOT
#!/bin/bash

echo "*** Install iptables and start ***"
yum install iptables-services -y
systemctl enable iptables
systemctl start iptables

echo "*** Enable IP forwarding ***"
cat <<EOF | tee /etc/sysctl.d/custom-ip-forwarding.conf
net.ipv4.ip_forward = 1
EOF

sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf

echo "*** Configure NAT ***"
/sbin/iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
/sbin/iptables -F FORWARD
service iptables save
  EOT

  vpc_security_group_ids = [aws_security_group.nat_instance_sg.id]
  tags = {
    Name = var.instance_name
  }
}



resource "aws_eip_association" "nat_public_ip" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = var.allocation_id
}

output "network_interface_id" {
  value = aws_instance.nat_instance.primary_network_interface_id
}
