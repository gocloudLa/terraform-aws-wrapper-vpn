# Association, propagation and static routes for a TGW-attached VPN in the named route tables of
# wrapper-tgw (tgw_parameter.route_table_ids). Keys come from vpn_parameters, so this plans when the
# TGW, its route tables and the VPN are all created in the same apply.
locals {
  tgw_route_table_associations = {
    for vpn_key, vpn_config in var.vpn_parameters : vpn_key => {
      route_table_id = var.tgw_parameter.route_table_ids[vpn_config.tgw][vpn_config.transit_gateway_route_table]
    } if try(vpn_config.transit_gateway_route_table, null) != null
  }

  tgw_route_table_propagations = merge([
    for vpn_key, vpn_config in var.vpn_parameters : {
      for rt_key in try(vpn_config.transit_gateway_propagations, []) :
      "${vpn_key}:${rt_key}" => {
        vpn_key        = vpn_key
        route_table_id = var.tgw_parameter.route_table_ids[vpn_config.tgw][rt_key]
      }
    }
  ]...)

  tgw_static_routes = merge(flatten([
    for vpn_key, vpn_config in var.vpn_parameters : [
      for rt_key in try(vpn_config.transit_gateway_static_route_tables, []) : {
        for cidr in try(vpn_config.vpn_connection.static_routes_destinations, []) :
        "${vpn_key}:${rt_key}:${cidr}" => {
          vpn_key                = vpn_key
          route_table_id         = var.tgw_parameter.route_table_ids[vpn_config.tgw][rt_key]
          destination_cidr_block = cidr
        }
      }
    ]
  ])...)
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = local.tgw_route_table_associations

  transit_gateway_attachment_id  = local.vpns[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.route_table_id
  replace_existing_association   = true
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.tgw_route_table_propagations

  transit_gateway_attachment_id  = local.vpns[each.value.vpn_key].transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.route_table_id
}

resource "aws_ec2_transit_gateway_route" "this" {
  for_each = local.tgw_static_routes

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = local.vpns[each.value.vpn_key].transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.route_table_id
}
