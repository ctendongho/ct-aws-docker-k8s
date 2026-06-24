resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage       = 20
  multi_az                = true
  storage_encrypted       = true
  backup_retention_period = 0
  deletion_protection     = false

  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]

  publicly_accessible = false

  skip_final_snapshot      = false
  final_snapshot_identifier = "${var.project_name}-mysql-final-snapshot"

  tags = {
    Name = "${var.project_name}-mysql"
  }
}
