
resource "aws_vpc" "platinum_aws" {
  cidr_block = var.vpc_cidr

  tags = merge(
    local.comman_tags,
    {
      Name = var.vpc_name
    }
  )
}
resource "aws_internet_gateway" "platinum_igw" {
  vpc_id = aws_vpc.platinum_aws.id

  tags = merge(
    local.comman_tags,
    {
      Name = var.platinum-aws-igw-name
    }
  )
}
resource "aws_subnet" "pb_subnet_platinum_aws" {
  count             = length(var.pub_subnet_cidr)
  vpc_id            = aws_vpc.platinum_aws.id
  cidr_block        = element(var.pub_subnet_cidr, count.index)
  availability_zone = element(var.az, count.index)
  tags = merge(
    local.comman_tags,
    {
      Name = "${var.pub_subnet_name}_${count.index + 1}"
    }
  )
}


resource "aws_subnet" "pvt_subnet_platinum_aws" {
  count             = length(var.pvt_subent_cidr)
  vpc_id            = aws_vpc.platinum_aws.id
  cidr_block        = element(var.pvt_subent_cidr, count.index)
  availability_zone = element(var.az, count.index)
  tags = merge(
    local.comman_tags,
    {
      Name = "${var.pvt_subnet_name}_${count.index + 1}"
    }
  )
}
