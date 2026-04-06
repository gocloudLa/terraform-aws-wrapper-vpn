module "wrapper_vpn" {
  source = "../../"

  metadata      = local.metadata
  vpc_parameter = local.vpc_parameter
  tgw_parameter = local.tgw_parameter
  vpn_defaults  = var.vpn_defaults

  # Example scenario:
  # - AWS (this account): VPC 10.20.0.0/16 — traffic of interest toward the customer over both VPNs.
  # - vpn-vpc (VGW): that VPC only; simulated customer side 10.50.0.0/16.
  # - vpn-tgw (TGW): same VPC + another VPC 10.30.0.0/16 (other account, attached to the TGW); customer side 10.60.0.0/16.
  #   aws_vpn_connection allows only one remote_ipv4_network_cidr; 10.16.0.0/12 is used as an aggregate covering 10.20/16 and 10.30/16.
  vpn_parameters = {
    "vpn-vpc" = {

      vpc = "networking" # Key into vpc_parameter (not vpc_name)
      # tgw = "tgw-01" # Key into tgw_parameter.transit_gateway (not tgw_name)

      # Can be alternated between them if necessary
      # vpc_id = null
      # tgw_id = null

      # If resources already exist you can pass their ID; otherwise leave null and fill the rest for a custom configuration; if the object is null defaults apply
      virtual_private_gateway = {
        # amazon_side_asn = 64512
        # availability_zone = null
        # virtual_private_gateway_id = null
      }
      customer_gateway = {
        ip_address = "111.111.111.111" // Required, Public IP of client VPN 
        # device_name = null
        # bgp_asn = 65000
        # bgp_asn_extended = null
        # certificate_arn = null
        # customer_gateway_id = null
      }

      # Tunnel resource settings; if omitted, null/default values apply
      vpn_connection = {
        local_ipv4_network_cidr  = "10.50.0.0/16" # External site cidr block
        remote_ipv4_network_cidr = "10.20.0.0/16" # AWS cidr block

        # On-prem prefixes AWS routes toward the tunnel (VGW + propagation into the RTs listed in route_table_keys).
        static_routes_only         = true
        static_routes_destinations = ["10.50.0.0/16"]

        # Prefer keys from vpc_parameter.route_tables (same as wrapper-vpc output keys, e.g. "{vpc_key}-private").
        route_table_keys = ["networking-private", "networking-public"]

        tunnel1_preshared_key                = "12345678" # local.secrets.vpn_preshared_key //if the preshared key is stored in a parameter or secret
        tunnel1_ike_versions                 = ["ikev2"]
        tunnel1_startup_action               = "start"
        tunnel1_dpd_timeout_action           = "none"
        tunnel1_phase1_dh_group_numbers      = ["14"]
        tunnel1_phase1_encryption_algorithms = ["AES128"]
        tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
        tunnel1_phase2_dh_group_numbers      = ["14"]
        tunnel1_phase2_encryption_algorithms = ["AES256"]
        tunnel1_phase2_integrity_algorithms  = ["SHA2-256"]
        tunnel1_cloudwatch_log_enabled       = true

        tunnel2_preshared_key                = "12345678" # local.secrets.vpn_preshared_key
        tunnel2_ike_versions                 = ["ikev2"]
        tunnel2_startup_action               = "start"
        tunnel2_dpd_timeout_action           = "none"
        tunnel2_phase1_dh_group_numbers      = ["14"]
        tunnel2_phase1_encryption_algorithms = ["AES128"]
        tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
        tunnel2_phase2_dh_group_numbers      = ["14"]
        tunnel2_phase2_encryption_algorithms = ["AES256"]
        tunnel2_phase2_integrity_algorithms  = ["SHA2-256"]
        tunnel2_cloudwatch_log_enabled       = true
      }

      vpc_routes = {
        "networking-private" = {
          destination_cidr_block = ["10.50.10.0/24", "10.50.11.0/24"]
        }
        "networking-public" = {
          destination_cidr_block = ["10.50.10.0/24", "10.50.11.0/24"]
        }
      }
    }
    "vpn-tgw" = {
      # vpc = "networking" # Key into vpc_parameter (not vpc_name)
      tgw = "tgw-01"
      # transit_gateway_id             = "tgw-00cd4aadd925dc3c0"
      # transit_gateway_route_table_id = "tgw-rtb-025d697f9ca4f6cf0"
      virtual_private_gateway = null
      customer_gateway = {
        ip_address = "222.222.222.222" // Required, Public IP of client VPN 
      }
      # Tunnel resource settings; if omitted, null/default values apply
      vpn_connection = {
        # Customer side (this TGW VPN): 10.60.0.0/16. AWS side: 10.20.0.0/16 + 10.30.0.0/16 via TGW.
        # aws_vpn_connection allows only one remote_ipv4_network_cidr → aggregate 10.16.0.0/12 (covers 10.16–10.31).
        local_ipv4_network_cidr  = "10.60.0.0/16"
        remote_ipv4_network_cidr = "10.16.0.0/12"

        # On-prem prefix toward the VPN attachment in the TGW route table (one entry per CIDR).
        static_routes_only = true
        static_routes_destinations     = ["10.60.0.0/16"]

        tunnel1_preshared_key          = "12345678" # local.secrets.vpn_preshared_key
        tunnel1_cloudwatch_log_enabled = true
        tunnel2_preshared_key          = "12345678" # local.secrets.vpn_preshared_key
        tunnel2_cloudwatch_log_enabled = true
      }
    }
  }
}