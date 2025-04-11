output "vpn_connection_id" {
  value = aws_vpn_connection.vpn_conn.id
}

output "customer_gateway_ip" {
  value = aws_customer_gateway.cgw.ip_address
}
