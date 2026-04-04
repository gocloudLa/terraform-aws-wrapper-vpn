module "wrapper_vpn" {
  source = "../../"

  metadata      = local.metadata
  vpc_parameter = var.vpc_parameter
  tgw_parameter = var.tgw_parameter
  vpn_defaults  = var.vpn_defaults

  vpn_parameters = {
    "vpn-01" = {

      vpc = "test1" # Key into vpc_parameter (not vpc_name)
      # tgw = "tgw-01" # Key into tgw_parameter (not tgw_name)

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
        ip_address = "190.210.45.46" // Required, Public IP of client VPN 
        # device_name = null
        # bgp_asn = 65000
        # bgp_asn_extended = null
        # certificate_arn = null

        # customer_gateway_id = null
      }

      # Tunnel resource settings; if omitted, null/default values apply
      vpn_connection = {
        remote_ipv4_network_cidr = "10.22.0.0/16" // CIDR block shared from our VPC

        # If using static routing for specific machines, use
        static_routes_only         = true
        static_routes_destinations = ["10.1.8.30/32", "10.1.7.140/32"]
        route_table_names          = ["gcl-lab-00-private", "gcl-lab-00-public"]

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

      # # Route propagation and route configuration when not using static routing only
      # vpc_routes = {
      #   "private" = {
      #     destination_cidr = ["172.0.10.1/24", "172.0.10.2/24"]
      #   }
      #   "public" = {
      #     destination_cidr = ["172.0.10.1/24", "172.0.10.2/24"]
      #   }
      # }

      tags = local.custom_tags
    }
    "vpn-tgw-01" = {
      # vpc = "networking" # Key into vpc_parameter (not vpc_name)
      transit_gateway_id             = "tgw-0882eb490f1000e15"
      transit_gateway_route_table_id = "tgw-rtb-0aa86b7268ab0aa9e"
      virtual_private_gateway        = null
      customer_gateway = {
        ip_address = "111.111.111.111" // Required, Public IP of client VPN 
      }
      # Tunnel resource settings; if omitted, null/default values apply
      vpn_connection = {
        remote_ipv4_network_cidr = "10.40.0.0/16" // CIDR block shared from our VPC
        # If using static routing for specific machines, use
        static_routes_only         = true
        static_routes_destinations = ["10.40.0.0/16"]
        # static_routes_destinations = ["10.50.0.0/16", "10.51.0.0/16"]
        # route_table_names          = ["dmc-lv1-private", "dmc-lv1-public"]
        tunnel1_preshared_key          = "12345678" # local.secrets.vpn_preshared_key
        tunnel1_cloudwatch_log_enabled = true
        tunnel2_preshared_key          = "12345678" # local.secrets.vpn_preshared_key
        tunnel2_cloudwatch_log_enabled = true
      }
    }
  }
}