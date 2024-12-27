resource "aws_security_group" "mongodb_security_group" {
  name        = "mongodb_security_group"
  description = "mongodb_security_group"
  vpc_id      = local.network_output.vpc_id

  ingress {
    description = "mongodb ingress"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [local.network_output.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "mongodbatlas_privatelink_endpoint_serverless" "privatelink_endpoint" {
  for_each = module.mongodb_atlas.serverless_instances

  project_id    = module.mongodb_atlas.project_id
  instance_name = each.value.name
  provider_name = "AWS"
}

data "aws_vpc_endpoint_service" "mongodb_atlas" {
  for_each = mongodbatlas_privatelink_endpoint_serverless.privatelink_endpoint

  service_name = each.value.endpoint_service_name
}

data "aws_subnets" "available_subnets" {
  for_each = data.aws_vpc_endpoint_service.mongodb_atlas
  filter {
    name   = "vpc-id"
    values = [local.network_output.vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = each.value.availability_zones
  }

  filter {
    name   = "subnet-id"
    values = [for subnet in local.network_output.public_subnets : subnet.id]
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each = mongodbatlas_privatelink_endpoint_serverless.privatelink_endpoint

  vpc_id              = local.network_output.vpc_id
  service_name        = each.value.endpoint_service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = false

  security_group_ids = [aws_security_group.mongodb_security_group.id]
  subnet_ids         = data.aws_subnets.available_subnets[each.key].ids
}

resource "mongodbatlas_privatelink_endpoint_service_serverless" "privatelink_endpoint_service" {
  for_each = module.mongodb_atlas.serverless_instances

  project_id                 = module.mongodb_atlas.project_id
  instance_name              = each.value.name
  endpoint_id                = mongodbatlas_privatelink_endpoint_serverless.privatelink_endpoint[each.key].endpoint_id
  cloud_provider_endpoint_id = aws_vpc_endpoint.vpc_endpoint[each.key].id
  provider_name              = "AWS"
  comment                    = "New serverless endpoint"
}

data "mongodbatlas_serverless_instance" "serverless_instances" {
  for_each = mongodbatlas_privatelink_endpoint_service_serverless.privatelink_endpoint_service

  project_id = module.mongodb_atlas.project_id
  name       = module.mongodb_atlas.serverless_instances[each.key].name
}
