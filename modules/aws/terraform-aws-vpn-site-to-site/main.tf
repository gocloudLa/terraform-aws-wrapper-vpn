# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway
resource "aws_customer_gateway" "this" {
  count = var.customer_gateway_id == null ? 1 : 0

  device_name      = var.customer_gateway_device_name == "" ? "${var.tags.Name}" : var.customer_gateway_device_name
  bgp_asn          = var.customer_gateway_bgp_asn <= 2147483647 ? var.customer_gateway_bgp_asn : null
  bgp_asn_extended = var.customer_gateway_bgp_asn > 2147483647 ? var.customer_gateway_bgp_asn : null
  ip_address       = var.customer_gateway_ip_address
  certificate_arn  = var.customer_gateway_certificate_arn
  type             = "ipsec.1"
  tags             = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

### Log Group
resource "aws_cloudwatch_log_group" "this" {
  count = local.logs_enabled ? 1 : 0

  name              = var.tags.Name
  retention_in_days = var.vpn_connection_log_retention_in_days

  tags = var.tags
}

### VPC
resource "aws_vpn_gateway" "this" {
  count = local.transit_gateway_enabled || var.virtual_private_gateway_id != null ? 0 : 1

  vpc_id          = var.vpc_id
  amazon_side_asn = var.vpn_gateway_amazon_side_asn
  tags            = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection
resource "aws_vpn_connection" "this" {
  count = var.create_vpn_connection ? 1 : 0

  vpn_gateway_id     = try(aws_vpn_gateway.this[0].id, var.virtual_private_gateway_id, null)
  transit_gateway_id = local.transit_gateway_enabled ? var.transit_gateway_id : null

  customer_gateway_id      = var.customer_gateway_id != null ? var.customer_gateway_id : aws_customer_gateway.this[0].id
  type                     = "ipsec.1"
  static_routes_only       = var.vpn_connection_static_routes_only
  local_ipv4_network_cidr  = var.vpn_connection_local_ipv4_network_cidr
  remote_ipv4_network_cidr = var.vpn_connection_remote_ipv4_network_cidr

  tunnel1_dpd_timeout_action = var.vpn_connection_tunnel1_dpd_timeout_action
  tunnel1_ike_versions       = var.vpn_connection_tunnel1_ike_versions
  tunnel1_inside_cidr        = var.vpn_connection_tunnel1_inside_cidr
  tunnel1_preshared_key      = var.vpn_connection_tunnel1_preshared_key
  tunnel1_startup_action     = var.vpn_connection_tunnel1_startup_action

  tunnel1_phase1_dh_group_numbers      = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  tunnel1_phase2_dh_group_numbers      = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  tunnel1_phase1_encryption_algorithms = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  tunnel1_phase2_encryption_algorithms = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  tunnel1_phase2_integrity_algorithms  = var.vpn_connection_tunnel1_phase2_integrity_algorithms
  tunnel1_phase1_lifetime_seconds      = var.vpn_connection_tunnel1_phase1_lifetime_seconds
  tunnel1_phase2_lifetime_seconds      = var.vpn_connection_tunnel1_phase2_lifetime_seconds

  tunnel1_log_options {
    cloudwatch_log_options {
      log_enabled       = var.vpn_connection_tunnel1_cloudwatch_log_enabled
      log_output_format = var.vpn_connection_tunnel1_cloudwatch_log_enabled ? var.vpn_connection_tunnel1_cloudwatch_log_output_format : null
      log_group_arn     = var.vpn_connection_tunnel1_cloudwatch_log_enabled ? aws_cloudwatch_log_group.this[0].arn : null
    }
  }

  tunnel2_dpd_timeout_action = var.vpn_connection_tunnel2_dpd_timeout_action
  tunnel2_ike_versions       = var.vpn_connection_tunnel2_ike_versions
  tunnel2_inside_cidr        = var.vpn_connection_tunnel2_inside_cidr
  tunnel2_preshared_key      = var.vpn_connection_tunnel2_preshared_key
  tunnel2_startup_action     = var.vpn_connection_tunnel2_startup_action

  tunnel2_phase1_dh_group_numbers      = var.vpn_connection_tunnel2_phase1_dh_group_numbers
  tunnel2_phase2_dh_group_numbers      = var.vpn_connection_tunnel2_phase2_dh_group_numbers
  tunnel2_phase1_encryption_algorithms = var.vpn_connection_tunnel2_phase1_encryption_algorithms
  tunnel2_phase2_encryption_algorithms = var.vpn_connection_tunnel2_phase2_encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = var.vpn_connection_tunnel2_phase1_integrity_algorithms
  tunnel2_phase2_integrity_algorithms  = var.vpn_connection_tunnel2_phase2_integrity_algorithms
  tunnel2_phase1_lifetime_seconds      = var.vpn_connection_tunnel2_phase1_lifetime_seconds
  tunnel2_phase2_lifetime_seconds      = var.vpn_connection_tunnel2_phase2_lifetime_seconds

  tunnel2_log_options {
    cloudwatch_log_options {
      log_enabled       = var.vpn_connection_tunnel2_cloudwatch_log_enabled
      log_group_arn     = var.vpn_connection_tunnel2_cloudwatch_log_enabled ? aws_cloudwatch_log_group.this[0].arn : null
      log_output_format = var.vpn_connection_tunnel2_cloudwatch_log_enabled ? var.vpn_connection_tunnel2_cloudwatch_log_output_format : null
    }
  }

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation
resource "aws_vpn_gateway_route_propagation" "this" {
  count = !local.transit_gateway_enabled && length(var.route_table_ids) > 0 ? length(var.route_table_ids) : 0

  vpn_gateway_id = try(aws_vpn_gateway.this[0].id, var.virtual_private_gateway_id, null)
  route_table_id = var.route_table_ids[count.index]
}

# VGW-only. TGW-attached VPN static routes must use EC2 Transit Gateway routes (see aws_ec2_transit_gateway_route.vpn_static).
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection_route
resource "aws_vpn_connection_route" "this" {
  count = var.create_vpn_connection && var.vpn_connection_static_routes_only && !local.transit_gateway_enabled ? length(var.vpn_connection_static_routes_destinations) : 0

  vpn_connection_id      = aws_vpn_connection.this[0].id
  destination_cidr_block = var.vpn_connection_static_routes_destinations[count.index]
}

# TGW-attached VPN + static_routes_only: AWS rejects CreateVpnConnectionRoute; install prefixes on the TGW route table instead.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route
resource "aws_ec2_transit_gateway_route" "vpn_static" {
  for_each = var.create_vpn_connection && local.transit_gateway_enabled && local.transit_gateway_route_table_configured && var.vpn_connection_static_routes_only ? toset(var.vpn_connection_static_routes_destinations) : toset([])

  destination_cidr_block         = each.value
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = aws_vpn_connection.this[0].transit_gateway_attachment_id
}

# Transit Gateway: attachment is created with the VPN connection; tags apply to the attachment. Route table association/propagation are owned by the TGW (outside this module).

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag
resource "aws_ec2_tag" "transit_gateway_attachment" {
  for_each = var.create_vpn_connection && local.transit_gateway_enabled ? var.tags : {}

  resource_id = aws_vpn_connection.this[0].transit_gateway_attachment_id
  key         = each.key
  value       = each.value
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route
resource "aws_ec2_transit_gateway_route" "this" {
  for_each = var.create_vpn_connection && local.transit_gateway_enabled && local.transit_gateway_route_table_configured ? var.transit_gateway_routes : {}

  blackhole                      = try(each.value.blackhole, false)
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = try(each.value.blackhole, false) ? null : aws_vpn_connection.this[0].transit_gateway_attachment_id
}

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association
# resource "aws_ec2_transit_gateway_route_table_association" "this" {
#   count = var.create_vpn_connection && local.transit_gateway_enabled && local.transit_gateway_route_table_configured ? 1 : 0

#   transit_gateway_attachment_id  = aws_vpn_connection.this[0].transit_gateway_attachment_id
#   transit_gateway_route_table_id = var.transit_gateway_route_table_id
# }

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation
# resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
#   count = var.create_vpn_connection && local.transit_gateway_enabled && local.transit_gateway_route_table_configured ? 1 : 0

#   transit_gateway_attachment_id  = aws_vpn_connection.this[0].transit_gateway_attachment_id
#   transit_gateway_route_table_id = var.transit_gateway_route_table_id
# }