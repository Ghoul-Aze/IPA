resource "aws_vpn_gateway" "vgw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.clientSlug}-vgw-tf"
  }
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = var.vpn_bgp_asn
  ip_address = var.cus_public_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.clientSlug}-cgw-tf"
  }
}

resource "aws_vpn_connection" "vpn_conn" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "${var.clientSlug}-vpn-tf"
  }
}

resource "aws_vpn_connection_route" "vpn_route" {
  destination_cidr_block = var.on_prem_subnet
  vpn_connection_id      = aws_vpn_connection.vpn_conn.id
}

resource "aws_route" "vpn_route" {
  route_table_id         = var.rtb_pvt
  destination_cidr_block = var.on_prem_subnet
  gateway_id             = aws_vpn_gateway.vgw.id
}

#vpn_gw