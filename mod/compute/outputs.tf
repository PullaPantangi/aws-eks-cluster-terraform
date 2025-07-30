output vpc_id {
    value = aws_vpc.platinum_aws.id
} 
output igw_route {
    value = var.igw_route
}
output pub_subnet_cidr {
    value = var.pub_subnet_cidr
}
output "pub_sub" {
    value = aws_subnet.pb_subnet_platinum_aws[*].id
}
output "a_zone" {
    value = var.az
}
output "local_tags" {
    value = local.comman_tags
}   