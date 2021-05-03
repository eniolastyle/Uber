#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "demo" {
  cidr_block = var.vpc_cidr

  tags = map(
      "Name", "terraform-eks-demo-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
}

resource "aws_subnet" "demo" {
  count = 4

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_cidrs[count.index]
  vpc_id            = aws_vpc.demo.id

  tags = map(
      "Name", "terraform-eks-demo-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
}

resource "aws_route_table_association" "demo" {
  count = 4

  subnet_id      = aws_subnet.demo.*.id[count.index]
  route_table_id = aws_route_table.demo.id
}
