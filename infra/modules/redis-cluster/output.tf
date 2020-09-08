output "cache_nodes" {
    value = "${aws_elasticache_cluster.bar.cache_nodes.0.address}"
}