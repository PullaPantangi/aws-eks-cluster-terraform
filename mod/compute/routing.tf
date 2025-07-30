resource "aws_route_table" "platinum_pub_RT" {
  vpc_id = aws_vpc.platinum_aws.id

  route {
    cidr_block = var.igw_route
    gateway_id = aws_internet_gateway.platinum_igw.id
  }
  tags = merge(
    local.comman_tags,
    {
      Name = "${var.pub_RT_name}-${var.vpc_name}"
    }
  )
}

resource "aws_route_table_association" "public-associan" {
  count          = length(var.pub_subnet_cidr)
  subnet_id      = element(aws_subnet.pb_subnet_platinum_aws[*].id, count.index)
  route_table_id = aws_route_table.platinum_pub_RT.id
}

resource "aws_route_table" "platinum_pvt_RT" {
  vpc_id = aws_vpc.platinum_aws.id
  tags = merge(
    local.comman_tags,
    {
      Name = "${var.pvt_RT_name}-${var.vpc_name}"
    }
  )
}
resource "aws_route_table_association" "pvt-associan" {
  count          = length(var.pvt_subent_cidr)
  subnet_id      = element(aws_subnet.pvt_subnet_platinum_aws[*].id, count.index)
  route_table_id = aws_route_table.platinum_pvt_RT.id
}
