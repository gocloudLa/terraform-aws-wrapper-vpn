data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

/*----------------------------------------------------------------------*/
/* Network | datasources                                                */
/*----------------------------------------------------------------------*/
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route_tables" "route_tables" {
  for_each = {
    for k, v in var.vpn_parameters :
    k => v
    if try(v.vpn_connection.route_table_names, null) != null && length(try(v.vpn_connection.route_table_names, 0)) > 0
  }

  filter {
    name   = "tag:Name"
    values = each.value.vpn_connection.route_table_names
  }
}