resource "aws_db_subnet_group" "scdb-subnet-group" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  tags = merge(
           local.common_tags,
           {
             Name = "scdb-subnet-group"
           }
  )
}

locals{
    plaintext_pw = substr(sha256("${var.name_prefix}:crowley"),-32,-1)
    username = "scadmin"
}

resource "aws_db_parameter_group" "sc-saas-parameter-group" {
  name = "${var.name_prefix}-sc-saas-parameter-group"
  family = "mysql5.7"

  parameter {
    name = "max_connections"
    value = "10000"
  }
  parameter {
    name = "character_set_client"
    value = "utf8"
  }
  parameter {
    name = "character_set_connection"
    value = "utf8"
  }
  parameter {
    name = "character_set_database"
    value = "utf8"
  }
  parameter {
    name = "character_set_results"
    value = "utf8"
  }
  parameter {
    name = "character_set_server"
    value = "utf8"
  }
  parameter {
    name = "collation_connection"
    value = "utf8_unicode_ci"
  }
  parameter {
    name = "collation_server"
    value = "utf8_unicode_ci"
  }
}


resource "aws_db_instance" "scdb" {
  allocated_storage    = 32
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "securecircle"
  deletion_protection  = true
  identifier           = "${var.name_prefix}-saas-db"
  storage_type         = "standard"
  apply_immediately    = true
  username             = local.username
  password             = local.plaintext_pw
  db_subnet_group_name = aws_db_subnet_group.scdb-subnet-group.id
  vpc_security_group_ids = [aws_security_group.mumbai-rds-sg.id]
  publicly_accessible = false
  delete_automated_backups = false
  final_snapshot_identifier = "${var.name_prefix}-saas-db-final-snapshot"
  multi_az             = true
  storage_encrypted = var.encrypt_db
  kms_key_id = var.encrypt_db == true ? length(var.kms_key_id) > 0 ? var.kms_key_id : aws_kms_key.rds-key.arn : ""
  parameter_group_name = aws_db_parameter_group.sc-saas-parameter-group.name
  backup_window = "04:00-05:00"
  maintenance_window = "Sat:06:00-Sat:10:00"
  backup_retention_period = "14"
  iam_database_authentication_enabled = true
  tags = local.common_tags
}

resource "aws_db_event_subscription" "scdb-backup-events" {
  name = "${var.name_prefix}-db-backup-events"
  sns_topic = aws_sns_topic.saas_alerts.arn
  source_type = "db-instance"
  source_ids = [
    aws_db_instance.scdb.id
  ]
  event_categories = [
    "backup"
  ]
}
