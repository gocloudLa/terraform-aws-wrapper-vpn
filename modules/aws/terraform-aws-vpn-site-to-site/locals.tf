locals {

  # A computed customer_gateway_id is unknown at plan time, so count cannot depend on `== null`.
  create_customer_gateway = coalesce(var.create_customer_gateway, var.customer_gateway_id == null)

  logs_enabled = (
    var.vpn_connection_tunnel1_cloudwatch_log_enabled ||
    var.vpn_connection_tunnel2_cloudwatch_log_enabled ||
    var.vpn_connection_tunnel1_bgp_log_enabled ||
    var.vpn_connection_tunnel2_bgp_log_enabled
  )
  transit_gateway_enabled = var.transit_gateway_id != null && var.transit_gateway_id != ""

  transit_gateway_route_table_configured = var.transit_gateway_route_table_id != null && var.transit_gateway_route_table_id != ""
}