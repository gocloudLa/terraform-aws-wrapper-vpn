locals {

  # A computed customer_gateway_id is unknown at plan time, so count cannot depend on `== null`.
  create_customer_gateway = coalesce(var.create_customer_gateway, var.customer_gateway_id == null)

  logs_enabled = (
    var.vpn_connection_tunnel1_cloudwatch_log_enabled ||
    var.vpn_connection_tunnel2_cloudwatch_log_enabled ||
    var.vpn_connection_tunnel1_bgp_log_enabled ||
    var.vpn_connection_tunnel2_bgp_log_enabled
  )
  # A transit_gateway_id created in the same apply is unknown at plan time, so count cannot depend on it.
  transit_gateway_enabled = coalesce(var.attach_to_transit_gateway, var.transit_gateway_id != null && var.transit_gateway_id != "")

  # Same for a transit_gateway_route_table_id that belongs to a transit gateway created in the same apply.
  transit_gateway_route_table_configured = coalesce(var.create_transit_gateway_routes, var.transit_gateway_route_table_id != null && var.transit_gateway_route_table_id != "")
}