locals {

  logs_enabled            = (var.vpn_connection_tunnel1_cloudwatch_log_enabled || var.vpn_connection_tunnel2_cloudwatch_log_enabled)
  transit_gateway_enabled = var.transit_gateway_id != null ? true : false
}