variable "name" {
    type = string
}

variable "node_type" {
    type = string
}

variable "num_cache_nodes" {
    type = number
}

variable "port" {
    type = number
}

variable "availability_zone" {
    type = string
    description = "(optional) describe your variable"
}

variable "vpc_id" {
    type = string
    description = "(optional) describe your variable"
}

variable "security_groups" {
    type = list(string)
    description = "(optional) describe your variable"
}

variable "private_subnet_ids" {
    type = list(string)
    description = "(optional) describe your variable"
}
