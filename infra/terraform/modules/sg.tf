# ─────────────────────────────
# ALB
# Internet → ALB
# ALB → EC2
# ─────────────────────────────

resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }
}

# ─────────────────────────────
# EC2
# ALB → EC2
# EC2 → RDS
# EC2 → Redis
# ─────────────────────────────

resource "aws_security_group" "ec2" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds.id]
  }

  egress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.redis.id]
  }
}


# ─────────────────────────────
# RDS
# EC2 → PostgreSQL
# ─────────────────────────────

resource "aws_security_group" "rds" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }
}


# ─────────────────────────────
# Redis
# EC2 → Redis
# ─────────────────────────────

resource "aws_security_group" "redis" {
  name   = "redis-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }
}

resource "aws_security_group" "aurora_primary" {
  provider = aws.primary

  name   = "aurora-primary-sg"
  vpc_id = aws_vpc.primary.id

  ingress {
    description     = "PostgreSQL from application"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.app_primary.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "aurora_secondary" {
  provider = aws.secondary

  name   = "aurora-secondary-sg"
  vpc_id = aws_vpc.secondary.id

  ingress {
    description     = "PostgreSQL from DR application"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.app_secondary.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_rds_global_cluster" "main" {
  global_cluster_identifier = "bank-global"

  engine         = "aurora-postgresql"
  engine_version = "16.6"

  deletion_protection = true
}