resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "name" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.primary_db_a.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route{
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
    cidr_block = "0.0.0.0/0"
  }
  
}

resource "aws_route_table_association" "name" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.primary_db_a.id
}

resource "aws_route_table_association" "name" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.primary_db_b.id
}


