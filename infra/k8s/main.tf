terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-2"
}

variable "nodes" {
  type = map(object({
    name = string
    type = string
    size = number
  }))
  default = {
    "k8smaster" = {
      name = "k8smaster"
      type = "t3.large"
      size = "20"
    },
    "k8sworker1" = {
      name = "k8sworker1"
      type = "t3.xlarge"
      size = "40"
    },
    "k8sworker2" = {
      name = "k8sworker2"
      type = "t3.xlarge"
      size = "40"
    },
    "k8sworker3" = {
      name = "k8sworker3"
      type = "t3.xlarge"
      size = "40"
    }
  }
}

resource "aws_instance" "instances" {
  for_each = var.nodes

  availability_zone = "ap-northeast-2c"
  ami               = "ami-0c9c942bd7bf113a2" # ubuntu 22.04 LTS
  instance_type     = each.value.type
  key_name          = key-name
  user_data         = file("./user-data/node-install.sh")
  vpc_security_group_ids = [
    "${security-group-id1}",
    "${security-group-id2}"
  ]

  root_block_device {
    volume_type = "gp3"
    volume_size = 10 # GiB
  }

  tags = {
    Name     = each.value.name
    provider = "terraform"
  }
}

resource "aws_ebs_volume" "volumes" {
  for_each = var.nodes

  availability_zone = "ap-northeast-2c"
  size              = each.value.size
  type              = "gp3"

  tags = {
    Name     = "${each.value.name}-vol"
    provider = "terraform"
  }
}

resource "aws_volume_attachment" "attachments" {
  for_each = var.nodes

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.volumes[each.value.name].id
  instance_id = aws_instance.instances[each.value.name].id
}

resource "aws_eip" "master_ip" {
  instance = aws_instance.instances["k8smaster"].id
  vpc      = true

  tags = {
    Name     = "k8smaster_ip"
    provider = "terraform"
  }
}
