output "vpc_id" {
  value = aws_vpc.default_vpc.id
}

output "pub_sbn_id" {
  value = aws_subnet.pub_sbn.id
}

output "pvt_sbn_id" {
  value = aws_subnet.pvt_sbn.id
}

output "rtb_pvt" {
  value = aws_route_table.rtb_pvt.id
}