data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# A for_each module cannot read another instance of itself. Match the gateway
# the referenced vpn_parameters entry creates (public IP + BGP ASN).
data "aws_customer_gateway" "referenced" {
  for_each = local.referenced_customer_gateways

  filter {
    name   = "ip-address"
    values = [each.value.ip_address]
  }

  filter {
    name   = each.value.bgp_asn > 2147483647 ? "bgp-asn-extended" : "bgp-asn"
    values = [tostring(each.value.bgp_asn)]
  }

  filter {
    name   = "type"
    values = ["ipsec.1"]
  }
}