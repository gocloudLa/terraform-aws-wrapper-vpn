## VPN
locals {

  create_vpn_connection_tmp = [
    for vpn_key, vpn_config in var.vpn_parameters :
    {
      "${vpn_key}" = {
        vpc_id                      = try(var.vpc_parameter.vpcs[vpn_config.vpc].vpc_id, vpn_config.vpc_id, null)
        vpn_gateway_amazon_side_asn = try(vpn_config.virtual_private_gateway.amazon_side_asn, 64512)
        virtual_private_gateway_id  = try(vpn_config.virtual_private_gateway.virtual_private_gateway_id, null)

        transit_gateway_id = try(
          vpn_config.transit_gateway_id,
          var.tgw_parameter.transit_gateway[vpn_config.tgw].ec2_transit_gateway_id,
          null
        )
        transit_gateway_route_table_id = try(
          vpn_config.transit_gateway_route_table_id,
          var.tgw_parameter.transit_gateway[vpn_config.tgw].ec2_transit_gateway_association_default_route_table_id,
          var.tgw_parameter.transit_gateway[vpn_config.tgw].ec2_transit_gateway_route_table_id,
          null
        )
        transit_gateway_routes = try(vpn_config.transit_gateway_routes, {})
        route_table_ids = [
          for route_table_key in vpn_config.vpn_connection.route_table_keys :
          var.vpc_parameter.route_tables[route_table_key].id
        ]

        customer_gateway_ip_address       = try(vpn_config.customer_gateway.ip_address, null)
        customer_gateway_device_name      = try(vpn_config.customer_gateway.device_name, null)
        customer_gateway_bgp_asn          = try(vpn_config.customer_gateway.bgp_asn, 65000)
        customer_gateway_bgp_asn_extended = try(vpn_config.customer_gateway.bgp_asn_extended, null)
        customer_gateway_certificate_arn  = try(vpn_config.customer_gateway.certificate_arn, null)

        ## VPN Connection
        create_vpn_connection                               = try(vpn_config.create_vpn_connection, true)
        vpn_connection_static_routes_only                   = try(vpn_config.vpn_connection.static_routes_only, false)
        vpn_connection_static_routes_destinations           = try(vpn_config.vpn_connection.static_routes_destinations, [])
        vpn_connection_local_ipv4_network_cidr              = try(vpn_config.vpn_connection.local_ipv4_network_cidr, "0.0.0.0/0")
        vpn_connection_remote_ipv4_network_cidr             = try(vpn_config.vpn_connection.remote_ipv4_network_cidr, "0.0.0.0/0")
        vpn_connection_log_retention_in_days                = try(vpn_config.vpn_connection.log_retention_in_days, 30)
        vpn_connection_tunnel1_dpd_timeout_action           = try(vpn_config.vpn_connection.tunnel1_dpd_timeout_action, "clear")
        vpn_connection_tunnel1_ike_versions                 = try(vpn_config.vpn_connection.tunnel1_ike_versions, [])
        vpn_connection_tunnel1_inside_cidr                  = try(vpn_config.vpn_connection.tunnel1_inside_cidr, null)
        vpn_connection_tunnel1_phase1_encryption_algorithms = try(vpn_config.vpn_connection.tunnel1_phase1_encryption_algorithms, [])
        vpn_connection_tunnel1_phase2_encryption_algorithms = try(vpn_config.vpn_connection.tunnel1_phase2_encryption_algorithms, [])
        vpn_connection_tunnel1_phase1_integrity_algorithms  = try(vpn_config.vpn_connection.tunnel1_phase1_integrity_algorithms, [])
        vpn_connection_tunnel1_phase2_integrity_algorithms  = try(vpn_config.vpn_connection.tunnel1_phase2_integrity_algorithms, [])
        vpn_connection_tunnel1_phase1_dh_group_numbers      = try(vpn_config.vpn_connection.tunnel1_phase1_dh_group_numbers, [])
        vpn_connection_tunnel1_phase2_dh_group_numbers      = try(vpn_config.vpn_connection.tunnel1_phase2_dh_group_numbers, [])
        vpn_connection_tunnel1_phase1_lifetime_seconds      = try(vpn_config.vpn_connection.tunnel1_phase1_lifetime_seconds, "28800")
        vpn_connection_tunnel1_phase2_lifetime_seconds      = try(vpn_config.vpn_connection.tunnel1_phase2_lifetime_seconds, "3600")
        vpn_connection_tunnel1_preshared_key                = try(vpn_config.vpn_connection.tunnel1_preshared_key, null)
        vpn_connection_tunnel1_startup_action               = try(vpn_config.vpn_connection.tunnel1_startup_action, "add")
        vpn_connection_tunnel1_cloudwatch_log_enabled       = try(vpn_config.vpn_connection.tunnel1_cloudwatch_log_enabled, false)
        vpn_connection_tunnel1_cloudwatch_log_output_format = try(vpn_config.vpn_connection.tunnel1_cloudwatch_log_output_format, "json")
        vpn_connection_tunnel2_dpd_timeout_action           = try(vpn_config.vpn_connection.tunnel2_dpd_timeout_action, "clear")
        vpn_connection_tunnel2_ike_versions                 = try(vpn_config.vpn_connection.tunnel2_ike_versions, [])
        vpn_connection_tunnel2_inside_cidr                  = try(vpn_config.vpn_connection.tunnel2_inside_cidr, null)
        vpn_connection_tunnel2_phase1_encryption_algorithms = try(vpn_config.vpn_connection.tunnel2_phase1_encryption_algorithms, [])
        vpn_connection_tunnel2_phase2_encryption_algorithms = try(vpn_config.vpn_connection.tunnel2_phase2_encryption_algorithms, [])
        vpn_connection_tunnel2_phase1_integrity_algorithms  = try(vpn_config.vpn_connection.tunnel2_phase1_integrity_algorithms, [])
        vpn_connection_tunnel2_phase2_integrity_algorithms  = try(vpn_config.vpn_connection.tunnel2_phase2_integrity_algorithms, [])
        vpn_connection_tunnel2_phase1_dh_group_numbers      = try(vpn_config.vpn_connection.tunnel2_phase1_dh_group_numbers, [])
        vpn_connection_tunnel2_phase2_dh_group_numbers      = try(vpn_config.vpn_connection.tunnel2_phase2_dh_group_numbers, [])
        vpn_connection_tunnel2_phase1_lifetime_seconds      = try(vpn_config.vpn_connection.tunnel2_phase1_lifetime_seconds, "28800")
        vpn_connection_tunnel2_phase2_lifetime_seconds      = try(vpn_config.vpn_connection.tunnel2_phase2_lifetime_seconds, "3600")
        vpn_connection_tunnel2_preshared_key                = try(vpn_config.vpn_connection.tunnel2_preshared_key, null)
        vpn_connection_tunnel2_startup_action               = try(vpn_config.vpn_connection.tunnel2_startup_action, "add")
        vpn_connection_tunnel2_cloudwatch_log_enabled       = try(vpn_config.vpn_connection.tunnel2_cloudwatch_log_enabled, false)
        vpn_connection_tunnel2_cloudwatch_log_output_format = try(vpn_config.vpn_connection.tunnel2_cloudwatch_log_output_format, "json")

        tags = merge(local.common_tags, { Name = "${local.common_name}-${vpn_key}" })
      }
    } if((length(try(vpn_config, {})) > 0))
  ]
  create_vpn_connection = merge(flatten(local.create_vpn_connection_tmp)...)
}

module "vpn" {

  source = "./modules/aws/terraform-aws-vpn-site-to-site"

  for_each = local.create_vpn_connection

  create_vpn_connection = each.value.create_vpn_connection

  vpc_id                       = each.value.vpc_id
  vpn_gateway_amazon_side_asn  = each.value.vpn_gateway_amazon_side_asn
  virtual_private_gateway_id   = each.value.virtual_private_gateway_id
  customer_gateway_device_name = each.value.customer_gateway_device_name
  customer_gateway_bgp_asn     = each.value.customer_gateway_bgp_asn
  customer_gateway_ip_address  = each.value.customer_gateway_ip_address
  route_table_ids              = each.value.route_table_ids

  transit_gateway_id             = each.value.transit_gateway_id
  transit_gateway_route_table_id = each.value.transit_gateway_route_table_id
  transit_gateway_routes         = each.value.transit_gateway_routes

  vpn_connection_static_routes_only         = each.value.vpn_connection_static_routes_only
  vpn_connection_static_routes_destinations = each.value.vpn_connection_static_routes_destinations
  vpn_connection_local_ipv4_network_cidr    = each.value.vpn_connection_local_ipv4_network_cidr
  vpn_connection_remote_ipv4_network_cidr   = each.value.vpn_connection_remote_ipv4_network_cidr
  vpn_connection_log_retention_in_days      = each.value.vpn_connection_log_retention_in_days

  vpn_connection_tunnel1_dpd_timeout_action           = each.value.vpn_connection_tunnel1_dpd_timeout_action
  vpn_connection_tunnel1_ike_versions                 = each.value.vpn_connection_tunnel1_ike_versions
  vpn_connection_tunnel1_inside_cidr                  = each.value.vpn_connection_tunnel1_inside_cidr
  vpn_connection_tunnel1_phase1_encryption_algorithms = each.value.vpn_connection_tunnel1_phase1_encryption_algorithms
  vpn_connection_tunnel1_phase2_encryption_algorithms = each.value.vpn_connection_tunnel1_phase2_encryption_algorithms
  vpn_connection_tunnel1_phase1_integrity_algorithms  = each.value.vpn_connection_tunnel1_phase1_integrity_algorithms
  vpn_connection_tunnel1_phase2_integrity_algorithms  = each.value.vpn_connection_tunnel1_phase2_integrity_algorithms
  vpn_connection_tunnel1_phase1_dh_group_numbers      = each.value.vpn_connection_tunnel1_phase1_dh_group_numbers
  vpn_connection_tunnel1_phase2_dh_group_numbers      = each.value.vpn_connection_tunnel1_phase2_dh_group_numbers
  vpn_connection_tunnel1_phase1_lifetime_seconds      = each.value.vpn_connection_tunnel1_phase1_lifetime_seconds
  vpn_connection_tunnel1_phase2_lifetime_seconds      = each.value.vpn_connection_tunnel1_phase2_lifetime_seconds
  vpn_connection_tunnel1_preshared_key                = each.value.vpn_connection_tunnel1_preshared_key
  vpn_connection_tunnel1_startup_action               = each.value.vpn_connection_tunnel1_startup_action
  vpn_connection_tunnel1_cloudwatch_log_enabled       = each.value.vpn_connection_tunnel1_cloudwatch_log_enabled
  vpn_connection_tunnel1_cloudwatch_log_output_format = each.value.vpn_connection_tunnel1_cloudwatch_log_output_format

  vpn_connection_tunnel2_dpd_timeout_action           = each.value.vpn_connection_tunnel2_dpd_timeout_action
  vpn_connection_tunnel2_ike_versions                 = each.value.vpn_connection_tunnel2_ike_versions
  vpn_connection_tunnel2_inside_cidr                  = each.value.vpn_connection_tunnel2_inside_cidr
  vpn_connection_tunnel2_phase1_encryption_algorithms = each.value.vpn_connection_tunnel2_phase1_encryption_algorithms
  vpn_connection_tunnel2_phase2_encryption_algorithms = each.value.vpn_connection_tunnel2_phase2_encryption_algorithms
  vpn_connection_tunnel2_phase1_integrity_algorithms  = each.value.vpn_connection_tunnel2_phase1_integrity_algorithms
  vpn_connection_tunnel2_phase2_integrity_algorithms  = each.value.vpn_connection_tunnel2_phase2_integrity_algorithms
  vpn_connection_tunnel2_phase1_dh_group_numbers      = each.value.vpn_connection_tunnel2_phase1_dh_group_numbers
  vpn_connection_tunnel2_phase2_dh_group_numbers      = each.value.vpn_connection_tunnel2_phase2_dh_group_numbers
  vpn_connection_tunnel2_phase1_lifetime_seconds      = each.value.vpn_connection_tunnel2_phase1_lifetime_seconds
  vpn_connection_tunnel2_phase2_lifetime_seconds      = each.value.vpn_connection_tunnel2_phase2_lifetime_seconds
  vpn_connection_tunnel2_preshared_key                = each.value.vpn_connection_tunnel2_preshared_key
  vpn_connection_tunnel2_startup_action               = each.value.vpn_connection_tunnel2_startup_action
  vpn_connection_tunnel2_cloudwatch_log_enabled       = each.value.vpn_connection_tunnel2_cloudwatch_log_enabled
  vpn_connection_tunnel2_cloudwatch_log_output_format = each.value.vpn_connection_tunnel2_cloudwatch_log_output_format

  tags = merge(lookup(each.value, "tags", local.common_tags), { Name = "${local.common_name}-${each.key}" })

}


locals {
  create_routes_tmp = [
    for vpn_key, vpn_config in var.vpn_parameters :
    [
      for vpc_name, vpc_values in try(vpn_config.vpc_routes, {}) : [
        for vpc_route_table_name, vpc_route_table_values in try(vpc_values, {}) : [
          for key in distinct(concat(
            try(vpc_route_table_values.destination_cidr_block, []),
            try(vpc_route_table_values.destination_cidr, [])
          )) :
          {
            "${vpn_key}-${vpc_name}-${vpc_route_table_name}-${key}" = {
              route_table_id              = var.vpc_parameter.route_tables["${vpc_name}-${vpc_route_table_name}"].id
              destination_cidr_block      = key
              destination_ipv6_cidr_block = null // to be supported with IPv6
              transit_gateway_id          = null
              gateway_id                  = module.vpn[vpn_key].virtual_private_gateway_id
            }
          } if((length(lookup(vpn_config, "vpc_routes", {})) > 0))
        ]
      ]
    ]
  ]
  create_routes = merge(flatten(local.create_routes_tmp)...)
}

resource "aws_route" "vpn" {
  for_each = local.create_routes

  route_table_id = each.value.route_table_id

  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  transit_gateway_id = each.value.transit_gateway_id
  gateway_id         = each.value.gateway_id
}
