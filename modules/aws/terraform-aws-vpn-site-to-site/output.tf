output "virtual_private_gateway_id" {
  value = length(aws_vpn_gateway.this) > 0 ? aws_vpn_gateway.this[0].id : null
}



# output "vpn_connection_id" {
#   description = "A list with the VPN Connection ID if `create_vpn_connection = true`, or empty otherwise"
#   value = try(
#     aws_vpn_connection.this.id,
#     aws_vpn_connection.tunnel.id,
#     aws_vpn_connection.preshared.id,
#     aws_vpn_connection.tunnel_preshared.id,
#   "")
# }

# output "vpn_connection_tunnel1_address" {
#   description = "A list with the the public IP address of the first VPN tunnel if `create_vpn_connection = true`, or empty otherwise"
#   value = try(
#     aws_vpn_connection.this.tunnel1_address,
#     aws_vpn_connection.tunnel.tunnel1_address,
#     aws_vpn_connection.preshared.tunnel1_address,
#     aws_vpn_connection.tunnel_preshared.tunnel1_address,
#   "")
# }

# output "vpn_connection_tunnel1_cgw_inside_address" {
#   description = "A list with the the RFC 6890 link-local address of the first VPN tunnel (Customer Gateway Side) if `create_vpn_connection = true`, or empty otherwise"
#   value = try(
#     aws_vpn_connection.this.tunnel1_cgw_inside_address,
#     aws_vpn_connection.tunnel.tunnel1_cgw_inside_address,
#     aws_vpn_connection.preshared.tunnel1_cgw_inside_address,
#     aws_vpn_connection.tunnel_preshared.tunnel1_cgw_inside_address,
#   "")
# }

# output "vpn_connection_tunnel1_vgw_inside_address" {
#   description = "A list with the the RFC 6890 link-local address of the first VPN tunnel (VPN Gateway Side) if `create_vpn_connection = true`, or empty otherwise"
#   value = try(
#     aws_vpn_connection.this.tunnel1_vgw_inside_address,
#     aws_vpn_connection.tunnel.tunnel1_vgw_inside_address,
#     aws_vpn_connection.preshared.tunnel1_vgw_inside_address,
#     aws_vpn_connection.tunnel_preshared.tunnel1_vgw_inside_address,
#   "")
# }

# output "vpn_connection_tunnel2_address" {
#   description = "A list with the the public IP address of the second VPN tunnel if `create_vpn_connection = true`, or empty otherwise"
#   value = try(
#     aws_vpn_connection.this.tunnel2_address,
#     aws_vpn_connection.tunnel.tunnel2_address,
#     aws_vpn_connection.preshared.tunnel2_address,
#     aws_vpn_connection.tunnel_preshared.tunnel2_address,
#   "")
# }

# output "vpn_connection_tunnel2_cgw_inside_address" {
#   description = "A list with the the RFC 6890 link-local address of the second VPN tunnel (Customer Gateway Side) if `create_vpn_connection = true`, or empty otherwise"
#   value = try(
#     aws_vpn_connection.this.tunnel2_cgw_inside_address,
#     aws_vpn_connection.tunnel.tunnel2_cgw_inside_address,
#     aws_vpn_connection.preshared.tunnel2_cgw_inside_address,
#     aws_vpn_connection.tunnel_preshared.tunnel2_cgw_inside_address,
#   "")
# }

# output "vpn_connection_tunnel2_vgw_inside_address" {
#   description = "A list with the the RFC 6890 link-local address of the second VPN tunnel (VPN Gateway Side) if `create_vpn_connection = true`, or empty otherwise"
#   value = try(
#     aws_vpn_connection.this.tunnel2_vgw_inside_address,
#     aws_vpn_connection.tunnel.tunnel2_vgw_inside_address,
#     aws_vpn_connection.preshared.tunnel2_vgw_inside_address,
#     aws_vpn_connection.tunnel_preshared.tunnel2_vgw_inside_address,
#   "")
# }

# output "vpn_connection_transit_gateway_attachment_id" {
#   description = "The transit gateway attachment ID that was generated when attaching this VPN connection."
#   value = try(
#     aws_vpn_connection.this.transit_gateway_attachment_id,
#     aws_vpn_connection.tunnel.transit_gateway_attachment_id,
#     aws_vpn_connection.preshared.transit_gateway_attachment_id,
#     aws_vpn_connection.tunnel_preshared.transit_gateway_attachment_id,
#   "")
# }

# output "vpn_connection_customer_gateway_configuration" {
#   description = "The configuration information for the VPN connection's customer gateway (in the native XML format) if `create_vpn_connection = true`, or empty otherwise"
#   value = try(
#     aws_vpn_connection.this.customer_gateway_configuration,
#     aws_vpn_connection.tunnel.customer_gateway_configuration,
#     aws_vpn_connection.preshared.customer_gateway_configuration,
#     aws_vpn_connection.tunnel_preshared.customer_gateway_configuration,
#   "")
#   sensitive = true
# }

# output "tunnel1_preshared_key" {
#   description = "The preshared key of the first VPN tunnel."
#   value = try(
#     aws_vpn_connection.this.tunnel1_preshared_key,
#     aws_vpn_connection.preshared.tunnel1_preshared_key,
#     aws_vpn_connection.tunnel.tunnel1_preshared_key,
#     aws_vpn_connection.tunnel_preshared.tunnel1_preshared_key,
#   "")
#   sensitive = true
# }

# output "tunnel2_preshared_key" {
#   description = "The preshared key of the second VPN tunnel."
#   value = try(
#     aws_vpn_connection.this.tunnel2_preshared_key,
#     aws_vpn_connection.preshared.tunnel2_preshared_key,
#     aws_vpn_connection.tunnel.tunnel2_preshared_key,
#     aws_vpn_connection.tunnel_preshared.tunnel2_preshared_key,
#   "")
#   sensitive = true
# }