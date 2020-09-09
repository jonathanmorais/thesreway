provider "aws" {
  region   = "us-east-1"
  profile  = "personal"
  shared_credentials_file = "~/.aws/credentials"

}

terraform {
  backend "s3" {
    bucket         = "infra-states-terraform"
    key            = "states"
    region         = "us-east-1"
  }
}

module "ecs_cluster" {
    source = "../../modules/ecs-cluster"
    team   = "foo"
    capacity_providers = [xxx]
    tags = {
        team        = "squad-foo"
        Billing     = "squad-foo"
        Project     = "foo-project"
        Application = "infra"
        Environment = "prod"
    }
}

module "ecs_capacity_provider" {
  source          = "../../modules/ecs-cp"
  ecs_cluster     = "foo"
  name            = "t2-micro"
  instace_type    = "t2.micro"
  max_size        = 3
  min_size        = 1
  target_capacity = 2
  network = {
    vpc             = "vpc-xxx"
    subnets         = ["subnet-xxx", "subnet-xxx", "subnet-xxx", "subnet-xxx"]
    security_groups = ["sg-xxx"]
  }
  tags = {
    team        = "squad-foo"
    project     = "infra"
    service     = "ecs"
    Application = "ecs/squad-foo"
    Billing     = "ecs/squad-foo"
    Environment = "production"
    Name        = "ecs/squad-foo"
    Provisioner = "terraform"
  }

  asg_tags = [
    {
      key                 = "team"
      value               = "squad-foo"
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "infra"
      propagate_at_launch = true
    },
    {
      key                 = "service"
      value               = "ecs"
      propagate_at_launch = true
    },
    {
      key                 = "Application"
      value               = "ecs/squad-foo"
      propagate_at_launch = true
    },
    {
      key                 = "Billing"
      value               = "ecs/squad-foo"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "production"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "ecs/squad-foo"
      propagate_at_launch = true
    },
    {
      key                 = "Provisioner"
      value               = "terraform"
      propagate_at_launch = true
    }
  ]
}

module "ecr_proxy_nginx" {
  source = "../../modules/ecr"

  team          =  "squad-foo"
  application   =  "nginx-proxy"
  tags = {
    team        = "squad-foo"
    Billing     = "squad-foo"
    Project     = "foo-project"
    Application = "infra"
    Environment = "prod"
  }

}

module "ecs_service" {
  source  = "../../modules/ecs-service"
  cluster = "foo"
  application = {
    name        = "nginx"
    version     = "01"
    environment = "prod"
  }
  container = {
    image  = "xxx.dkr.ecr.region.amazonaws.com/${var.team}/${var.application}:latest"
    cpu    = 256
    memory = 512
    port   = 8080
  }
  scale = {
    cpu = 90
    min = 1
    max = 2
  }
  config = {
    environment = []
  }
  network = {
    vpc             = "vpc-xxx"
    subnets         = ["subnet-xxx", "subnet-xxx", "subnet-xxx", "subnet-xxx"]
    security_groups = ["sg-xxx"]
  }
  service_policy = "policy/policy.tpl.json"
  tags = {
    "team"    = "squad-foo"
    "project" = "foo-project"
    "service" = "reverse_proxy"
  }
  capacity_provider = "xxx"

  alb = {
    enable             = true
    public             = true
    certificate_domain = "web-foo.com"
    idle_timeout       = 300
    health             = "/health"
    subnets            = ["subnet-xxx", "subnet-xxx", "subnet-xxx", "subnet-xxx"]
    security_groups    = ["sg-xxx"]
  }
}

module "redis_replication_group" {
    source                        = "../../modules/redis-cluster"
    availability_zones            = ["us-east-1a"]
    name                          = "redis_replication_group"
    number_cache_clusters         = 1
    replication_group_id          = "rd-rep-group-1"
    instance_type                 = "cache.t3.micro"
    subnet_group_name             = "sub-group-redis"
    parame_group_name             = "redis-pg"
    family                        = "redis4.0"
    replication_group_description = "replication group for redis"
    cluster_size                  = var.cluster_size
    apply_immediately             = true
    automatic_failover_enabled    = false

    parameter = [
      {
        name  = "notify-keyspace-events"
        value = "lK"
      }
    ]

    tags = {
        team        = "squad-foo"
        Billing     = "squad-foo"
        Project     = "foo-project"
        Application = "infra"
        Environment = "prod"
    }
}