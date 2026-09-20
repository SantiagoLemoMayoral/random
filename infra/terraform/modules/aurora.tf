resource "aws_subnet" "primary_db_a" {
  provider = aws.primary

  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "primary_db_b" {
  provider = aws.primary

  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "primary_db_c" {
  provider = aws.primary

  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_subnet" "secondary_db_a" {
  provider = aws.secondary

  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "secondary_db_b" {
  provider = aws.secondary

  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.1.11.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_subnet" "secondary_db_c" {
  provider = aws.secondary

  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.1.12.0/24"
  availability_zone = "us-west-2c"
}

resource "aws_db_subnet_group" "primary" {
  provider = aws.primary

  name = "aurora-primary-db-subnets"

  subnet_ids = [
    aws_subnet.primary_db_a.id,
    aws_subnet.primary_db_b.id,
    aws_subnet.primary_db_c.id
  ]
}

resource "aws_db_subnet_group" "secondary" {
  provider = aws.secondary

  name = "aurora-secondary-db-subnets"

  subnet_ids = [
    aws_subnet.secondary_db_a.id,
    aws_subnet.secondary_db_b.id,
    aws_subnet.secondary_db_c.id
  ]
}


resource "aws_rds_global_cluster" "main" {
  global_cluster_identifier = "bank-global"

  engine         = "aurora-postgresql"
  engine_version = "16.4"

  storage_encrypted = true

  deletion_protection = true
}

resource "aws_rds_cluster" "primary" {
  provider = aws.primary

  cluster_identifier = "bank-primary"

  engine         = aws_rds_global_cluster.main.engine
  engine_version = aws_rds_global_cluster.main.engine_version

  global_cluster_identifier = aws_rds_global_cluster.main.id

  db_subnet_group_name = aws_db_subnet_group.primary.name

  vpc_security_group_ids = [
    aws_security_group.aurora_primary.id
  ]

  database_name = "bank"

  master_username            = "dbadmin"
  manage_master_user_password = true

  storage_encrypted   = true
  skip_final_snapshot = true
}

resource "aws_rds_cluster" "secondary" {
  provider = aws.secondary

  cluster_identifier = "bank-secondary"

  engine         = aws_rds_global_cluster.main.engine
  engine_version = aws_rds_global_cluster.main.engine_version

  global_cluster_identifier = aws_rds_global_cluster.main.id

  db_subnet_group_name = aws_db_subnet_group.secondary.name

  vpc_security_group_ids = [
    aws_security_group.aurora_secondary.id
  ]

  storage_encrypted   = true
  skip_final_snapshot = true

  depends_on = [
    aws_rds_cluster_instance.primary_a,
    aws_rds_cluster_instance.primary_b,
    aws_rds_cluster_instance.primary_c
  ]
}

resource "aws_rds_cluster_instance" "primary_a" {
  provider = aws.primary

  identifier         = "bank-primary-a"
  cluster_identifier = aws_rds_cluster.primary.id

  instance_class = "db.r7g.large"

  engine         = aws_rds_cluster.primary.engine
  engine_version = aws_rds_cluster.primary.engine_version

  availability_zone = "us-east-1a"
}

resource "aws_rds_cluster_instance" "primary_b" {
  provider = aws.primary

  identifier         = "bank-primary-b"
  cluster_identifier = aws_rds_cluster.primary.id

  instance_class = "db.r7g.large"

  engine         = aws_rds_cluster.primary.engine
  engine_version = aws_rds_cluster.primary.engine_version

  availability_zone = "us-east-1b"
}

resource "aws_rds_cluster_instance" "primary_c" {
  provider = aws.primary

  identifier         = "bank-primary-c"
  cluster_identifier = aws_rds_cluster.primary.id

  instance_class = "db.r7g.large"

  engine         = aws_rds_cluster.primary.engine
  engine_version = aws_rds_cluster.primary.engine_version

  availability_zone = "us-east-1c"
}

resource "aws_rds_cluster_instance" "secondary_a" {
  provider = aws.secondary

  identifier         = "bank-secondary-a"
  cluster_identifier = aws_rds_cluster.secondary.id

  instance_class = "db.r7g.large"

  engine         = aws_rds_cluster.secondary.engine
  engine_version = aws_rds_cluster.secondary.engine_version

  availability_zone = "us-west-2a"
}

resource "aws_rds_cluster_instance" "secondary_b" {
  provider = aws.secondary

  identifier         = "bank-secondary-b"
  cluster_identifier = aws_rds_cluster.secondary.id

  instance_class = "db.r7g.large"

  engine         = aws_rds_cluster.secondary.engine
  engine_version = aws_rds_cluster.secondary.engine_version

  availability_zone = "us-west-2b"
}