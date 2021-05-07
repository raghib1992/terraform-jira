locals {
  vpn_customer_gw_remote_gateway_id_to_ip_map = length(var.ipsec_vpn_map) > 0 ? {
    for vpn_customer_gw in aws_customer_gateway.vpn_customer_gw:
       vpn_customer_gw.id => vpn_customer_gw.ip_address
  } : {}
  vpn_customer_gw_remote_gateway_ip_to_vpn_connection_id_map = length(var.ipsec_vpn_map) > 0 ? {
    for vpn_connection in aws_vpn_connection.vpn_connection:
      local.vpn_customer_gw_remote_gateway_id_to_ip_map[vpn_connection.customer_gateway_id] => vpn_connection.id
  } : {}
  ipsec_vpn_static_routes_to_vpn_connection_id_list = length(var.ipsec_vpn_map) > 0 ? flatten([
    for ipsec_vpn_remote_gateway_ip in keys(var.ipsec_vpn_map): [
      for remote_cidr in var.ipsec_vpn_map[ipsec_vpn_remote_gateway_ip].remote_private_subnet_cidrs:
        {
          vpn_connection_id=local.vpn_customer_gw_remote_gateway_ip_to_vpn_connection_id_map[ipsec_vpn_remote_gateway_ip],
          remote_cidr=remote_cidr
        }
      if !var.ipsec_vpn_map[ipsec_vpn_remote_gateway_ip].dynamic
    ]
  ]) : []
}

resource "aws_vpn_gateway" "vpn_gw" {
  count = length(var.ipsec_vpn_map) > 0 ? 1 : 0

  vpc_id = aws_vpc.mumbai-vpc.id

  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-vpn"
           }
  )
}

resource "aws_customer_gateway" "vpn_customer_gw" {
  count = length(var.ipsec_vpn_map)

  bgp_asn    = 65000
  ip_address = keys(var.ipsec_vpn_map)[count.index]
  type       = "ipsec.1"

  tags = merge(
           local.common_tags,
           {
             Name = length(var.ipsec_vpn_map) > 1 ? "${var.name_prefix}-vpn-${count.index + 1}" : "${var.name_prefix}-vpn"
           }
  )
}

resource "aws_vpn_connection" "vpn_connection" {
  count = length(var.ipsec_vpn_map) > 0 ? length(aws_customer_gateway.vpn_customer_gw) : 0

  vpn_gateway_id      = aws_vpn_gateway.vpn_gw[0].id
  customer_gateway_id = aws_customer_gateway.vpn_customer_gw[count.index].id
  type                = aws_customer_gateway.vpn_customer_gw[count.index].type
  static_routes_only  = !var.ipsec_vpn_map[aws_customer_gateway.vpn_customer_gw[count.index].ip_address].dynamic

  tags = merge(
           local.common_tags,
           {
             Name = length(var.ipsec_vpn_map) > 1 ? "${var.name_prefix}-ipsec-vpn-connection-${count.index + 1}" : "${var.name_prefix}-ipsec-vpn-connection"
           }
  )
}

resource "aws_vpn_connection_route" "vpn_connect_route" {
  count = length(var.ipsec_vpn_map) > 0 ? length(local.ipsec_vpn_static_routes_to_vpn_connection_id_list) : 0

  destination_cidr_block = local.ipsec_vpn_static_routes_to_vpn_connection_id_list[count.index].remote_cidr
  vpn_connection_id      = local.ipsec_vpn_static_routes_to_vpn_connection_id_list[count.index].vpn_connection_id
}
