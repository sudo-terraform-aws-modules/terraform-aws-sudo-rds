# Complete usage: MySQL with a module-managed security group, custom parameter
# and option groups, Enhanced Monitoring, Performance Insights, CloudWatch log
# exports, and one read replica.

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "rds" {
  source = "../../"

  identifier     = "example-complete"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t4g.medium"

  allocated_storage     = 50
  max_allocated_storage = 200
  storage_type          = "gp3"

  username                    = "app_admin"
  manage_master_user_password = true

  subnet_ids                         = data.aws_subnets.default.ids
  create_security_group              = true
  vpc_id                             = data.aws_vpc.default.id
  security_group_ingress_cidr_blocks = [data.aws_vpc.default.cidr_block]

  multi_az                = true
  backup_retention_period = 14
  deletion_protection     = true

  create_db_parameter_group = true
  parameter_group_family    = "mysql8.0"
  parameters = [
    {
      name  = "max_connections"
      value = "200"
    },
  ]

  create_db_option_group = true
  major_engine_version   = "8.0"
  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"
    },
  ]

  enable_enhanced_monitoring = true
  monitoring_interval        = 60

  enable_performance_insights           = true
  performance_insights_retention_period = 7

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  read_replicas = {
    replica1 = {
      instance_class = "db.t4g.medium"
    }
  }

  tags = {
    Environment = "example"
  }
}
