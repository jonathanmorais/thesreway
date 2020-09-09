module "simple_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace  = "eg"
  stage      = "prod"
  name       = "default"
  attributes = ["public"]
  delimiter  = "-"
  tags       = var.tags
}

resource "aws_elasticache_replication_group" "default" {
  count                         = var.enabled ? 1 : 0
  auth_token                    = var.transit_encryption_enabled ? var.auth_token : null
  replication_group_id          = var.replication_group_id
  replication_group_description = var.replication_group_description
  node_type                     = var.instance_type
  number_cache_clusters         = var.number_cache_clusters
  port                          = var.port
  parameter_group_name          = aws_elasticache_parameter_group.default.name
  availability_zones            = var.availability_zones
  automatic_failover_enabled    = var.automatic_failover_enabled
  subnet_group_name             = var.subnet_group_name
  security_group_ids            = var.use_existing_security_groups ? var.existing_security_groups : [join("", aws_security_group.default.*.id)]
  maintenance_window            = var.maintenance_window
  notification_topic_arn        = var.notification_topic_arn
  engine_version                = var.engine_version
  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  transit_encryption_enabled    = var.transit_encryption_enabled
  kms_key_id                    = var.at_rest_encryption_enabled ? var.kms_key_id : null
  snapshot_window               = var.snapshot_window
  snapshot_retention_limit      = var.snapshot_retention_limit
  apply_immediately             = var.apply_immediately

  tags = var.tags

  dynamic "cluster_mode" {
    for_each = var.cluster_mode_enabled ? ["true"] : []
    content {
      replicas_per_node_group = var.cluster_mode_replicas_per_node_group
      num_node_groups         = var.cluster_mode_num_node_groups
    }
  }

}

resource "aws_elasticache_parameter_group" "default" {
  name   = module.simple_label.name
  family = var.family

  parameter {
    name  = "activerehashing"
    value = "yes"
  }

  parameter {
    name  = "min-slaves-to-write"
    value = "2"
  }
}