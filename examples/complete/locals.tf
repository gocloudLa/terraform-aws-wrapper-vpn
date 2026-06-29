locals {

  # Simulated outputs from wrapper-vpc (replace with actual remote_state / module outputs)
  vpc_parameter = {
    vpcs = {
      "networking" = {
        vpc_id = "vpc-01xxxxxxxxxxxxx"
      }
    }
    route_tables = {
      "networking-private" = { id = "rtb-01xxxxxxxxxxxxx" }
      "networking-public"  = { id = "rtb-02xxxxxxxxxxxxx" }
    }
  }

  # Simulated outputs from wrapper-tgw (replace with actual remote_state / module outputs)
  tgw_parameter = {
    transit_gateway = {
      "tgw-01" = {
        ec2_transit_gateway_id                                 = "tgw-01xxxxxxxxxxxxx"
        ec2_transit_gateway_association_default_route_table_id = "tgw-rtb-01xxxxxxxxxxxxx"
        ec2_transit_gateway_route_table_id                     = "tgw-rtb-01xxxxxxxxxxxxx"
      }
    }
  }

}
