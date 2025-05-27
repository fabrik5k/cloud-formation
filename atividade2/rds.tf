# rds.tf

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnets"
  subnet_ids = module.vpc.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.environment}-db-subnets" })
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Acesso MySQL apenas do SG Web"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.environment}-rds-sg" })
}

resource "aws_db_instance" "main" {
  identifier             = "${var.environment}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false

  tags = merge(var.tags, { Name = "${var.environment}-mysql" })
}

