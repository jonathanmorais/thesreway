resource "aws_elasticache_cluster" "example" {
  cluster_id                 = var.name
  engine                     = "redis"
  node_type                  = var.node_type
  num_cache_nodes            = var.num_cache_nodes
  engine_version             = "3.2.10"
  port                       = var.port
  availability_zone          = var.num_cache_nodes > 1 ? var.availability_zone : ""
  vpc_id                     = var.vpc_id
  allowed_security_groups    = [var.security_groups]
  subnets                    = [var.private_subnet_ids]
  apply_immediately          = true
  automatic_failover_enabled = true
}
