# Create a VPC
resource "aws_vpc" "fluent_bit_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "Fluent Bit VPC"
  }
}

# Create a public subnet
resource "aws_subnet" "fluent_bit_public_subnet" {
  count             = 2
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.fluent_bit_vpc.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index)

  tags = {
    Name = "Fluent Bit Public Subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "fluent_bit_private_subnet" {
  count             = 2
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.fluent_bit_vpc.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, length(aws_subnet.fluent_bit_public_subnet[*]) + count.index)

  tags = {
    Name = "Fluent Bit Private Subnet"
  }
}

# Create an internet gateway for the VPC
resource "aws_internet_gateway" "fluent_bit_igw" {
  vpc_id = aws_vpc.fluent_bit_vpc.id

  tags = {
    Name = "Fluent Bit Internet Gateway"
  }
}

# Create a NAT gateway for the private subnet and place it into the public subnet
resource "aws_nat_gateway" "fluent_bit_ngw" {
  allocation_id = aws_eip.fluent_bit_ngw_eip.allocation_id
  subnet_id     = aws_subnet.fluent_bit_public_subnet[0].id

  tags = {
    Name = "Fluent Bit NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.fluent_bit_igw]
}

# Public IP for the NAT gateway
resource "aws_eip" "fluent_bit_ngw_eip" {
  tags = {
    "Name" = "Fluent Bit NAT Gateway IP"
  }
}

# Route traffic from the public subnet to the internet gateway
resource "aws_route_table" "fluent_bit_public_rt" {
  count  = 2
  vpc_id = aws_vpc.fluent_bit_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fluent_bit_igw.id
  }

  tags = {
    Name = "Fluent Bit Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "fluent_bit_public_rta" {
  count          = 2
  subnet_id      = aws_subnet.fluent_bit_public_subnet[count.index].id
  route_table_id = aws_route_table.fluent_bit_public_rt[count.index].id
}

# Route traffic from the private subnet to the NAT gateway
resource "aws_route_table" "fluent_bit_private_rt" {
  count  = 2
  vpc_id = aws_vpc.fluent_bit_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.fluent_bit_ngw.id
  }

  tags = {
    Name = "Fluent Bit Private Subnet Route Table"
  }
}

resource "aws_route_table_association" "fluent_bit_private_rta" {
  count          = 2
  subnet_id      = aws_subnet.fluent_bit_private_subnet[count.index].id
  route_table_id = aws_route_table.fluent_bit_private_rt[count.index].id
}