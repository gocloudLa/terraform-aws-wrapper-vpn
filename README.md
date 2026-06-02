# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform VPN Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-vpn/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-vpn.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-vpn.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-vpn/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for Site-to-Site VPN simplifies AWS networking integration (Customer Gateway / Virtual Private Gateway or Transit Gateway attachment / VPN connection / static routes / optional TGW static routes / VPC route propagation where VGW is used / tunnel options / etc.) alongside the VPC and TGW wrappers.

### ✨ Features

- 🛣️ [VPC attachment and route table updates (VGW mode)](#vpc-attachment-and-route-table-updates-(vgw-mode)) - VGW in the VPC, propagation into selected route tables, optional explicit `aws_route` via `vpc_routes`

- 🌐 [Transit Gateway attachment (TGW mode)](#transit-gateway-attachment-(tgw-mode)) - VPN terminates on the TGW; set `tgw`, `virtual_private_gateway = null`, and `route_table_keys = []`




## 🚀 Quick Start
```hcl
vpn_parameters = {
    # VGW in VPC: propagation into listed route tables + optional explicit vpc_routes to the VGW
    "vpn-vpc" = {
      vpc                     = "networking" # key in vpc_parameter.vpcs
      virtual_private_gateway = {}             # create VGW; or pass virtual_private_gateway_id to reuse
      customer_gateway = {
        ip_address = "203.0.113.10"
      }
      vpn_connection = {
        local_ipv4_network_cidr    = "10.50.0.0/16"
        remote_ipv4_network_cidr   = "10.20.0.0/16"
        static_routes_only         = true
        static_routes_destinations = ["10.50.0.0/16"]
        route_table_keys           = ["networking-private", "networking-public"]
        tunnel1_preshared_key      = var.vpn_psk_tunnel1 # min 8 chars; never commit real keys
        tunnel2_preshared_key      = var.vpn_psk_tunnel2
        tunnel1_ike_versions       = ["ikev2"]
        tunnel1_startup_action     = "start"
        tunnel1_dpd_timeout_action = "none"
        tunnel1_phase1_dh_group_numbers      = ["14"]
        tunnel1_phase1_encryption_algorithms = ["AES128"]
        tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
        tunnel1_phase2_dh_group_numbers      = ["14"]
        tunnel1_phase2_encryption_algorithms = ["AES256"]
        tunnel1_phase2_integrity_algorithms  = ["SHA2-256"]
        tunnel1_cloudwatch_log_enabled       = true
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
        "networking" = {
          "private" = {
            destination_cidr_block = ["10.50.10.0/24", "10.50.11.0/24"]
          }
          "public" = {
            destination_cidr_block = ["10.50.10.0/24", "10.50.11.0/24"]
          }
        }
      }
    }

    # TGW attachment: no VGW; route_table_keys = []; static routes target the TGW VPN attachment
    "vpn-tgw" = {
      tgw                     = "tgw-01" # key in tgw_parameter.transit_gateway
      virtual_private_gateway = null
      customer_gateway = {
        ip_address = "198.51.100.20"
      }
      vpn_connection = {
        local_ipv4_network_cidr    = "10.60.0.0/16"
        remote_ipv4_network_cidr   = "10.16.0.0/12" # single CIDR on connection; use aggregate if multiple VPC CIDRs behind TGW
        static_routes_only         = true
        static_routes_destinations = ["10.60.0.0/16"]
        route_table_keys           = []
        tunnel1_preshared_key      = var.vpn_psk_tunnel1
        tunnel2_preshared_key      = var.vpn_psk_tunnel2
        tunnel1_cloudwatch_log_enabled = true
        tunnel2_cloudwatch_log_enabled = true
      }
    }
}
```


## 🔧 Additional Features Usage

### VPC attachment and route table updates (VGW mode)
Point the VPN entry at a `vpc` key (or `vpc_id`). The wrapper creates or reuses a Virtual Private Gateway, attaches it to that VPC, and wires the Site-to-Site connection to the VGW. Set `vpn_connection.route_table_keys` to route-table keys from `vpc_parameter.route_tables` so AWS installs VPN routes into those tables (`aws_vpn_gateway_route_propagation`). Optionally add **`vpc_routes`**: nested map `{ <vpc_key> = { <route_table_suffix> = { destination_cidr_block = [...] } } }` (e.g. `private` / `public` → keys `"<vpc_key>-private"` in `vpc_parameter.route_tables`) for explicit `aws_route` toward the VGW; avoid duplicating CIDRs already learned via propagation.


<details><summary>Configuration Code</summary>

```hcl
vpn_parameters = {
  "vpn-vpc" = {
    vpc                     = "networking"
    virtual_private_gateway = {}
    customer_gateway = {
      ip_address = "203.0.113.10"
    }
    vpn_connection = {
      remote_ipv4_network_cidr   = "10.20.0.0/16"
      static_routes_only         = true
      static_routes_destinations = ["10.50.0.0/16"]
      route_table_keys           = ["networking-private", "networking-public"]
      tunnel1_preshared_key      = var.vpn_psk_tunnel1
      tunnel2_preshared_key      = var.vpn_psk_tunnel2
    }
    vpc_routes = {
      "networking" = {
        "private" = {
          destination_cidr_block = ["10.50.10.0/24", "10.50.11.0/24"]
        }
        "public" = {
          destination_cidr_block = ["10.50.10.0/24", "10.50.11.0/24"]
        }
      }
    }
  }
}
```


</details>


### Transit Gateway attachment (TGW mode)
Use **`tgw`** (key into `tgw_parameter.transit_gateway`, same shape as `wrapper-tgw` outputs) so the connection attaches to the Transit Gateway instead of a VGW. Set **`virtual_private_gateway = null`** and **`vpn_connection.route_table_keys = []`** (VPC route propagation does not apply). `static_routes_destinations` drive static routes toward the VPN attachment in the resolved TGW route table. `remote_ipv4_network_cidr` on `aws_vpn_connection` is still a single value—if several VPC CIDRs sit behind the TGW, use an aggregate that covers them (as in `examples/complete`). Override IDs with `transit_gateway_id` / `transit_gateway_route_table_id` when not using the wrapper map.


<details><summary>Configuration Code</summary>

```hcl
vpn_parameters = {
  "vpn-tgw" = {
    tgw                     = "tgw-01"
    virtual_private_gateway = null
    customer_gateway = {
      ip_address = "198.51.100.20"
    }
    vpn_connection = {
      local_ipv4_network_cidr    = "10.60.0.0/16"
      remote_ipv4_network_cidr   = "10.16.0.0/12"
      static_routes_only         = true
      static_routes_destinations = ["10.60.0.0/16"]
      route_table_keys           = []
      tunnel1_preshared_key      = var.vpn_psk_tunnel1
      tunnel2_preshared_key      = var.vpn_psk_tunnel2
    }
  }
}
```


</details>




## 📑 Inputs
| Name                                                | Description                                                                                                                                                                     | Type           | Default       | Required |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------- | -------- |
| create_vpn_connection                               | If set to `true`, the VPN connection will be created.                                                                                                                           | `bool`         | `true`        | no       |
| vpc_id                                              | The ID of the VPC to which the Virtual Private Gateway will be attached.                                                                                                        | `string`       | `null`        | no       |
| vpn_gateway_amazon_side_asn                         | ASN for the Amazon side of the VPN gateway.                                                                                                                                     | `number`       | `64512`       | no       |
| virtual_private_gateway_id                          | ID of an existing VGW; if null the submodule creates one when using VPC mode.                                                                                                   | `string`       | `null`        | no       |
| customer_gateway_device_name                        | Device name of the Customer Gateway.                                                                                                                                            | `string`       | `null`        | no       |
| customer_gateway_bgp_asn                            | BGP ASN for the Customer Gateway.                                                                                                                                               | `number`       | `65000`       | no       |
| customer_gateway_ip_address                         | Public IP of the customer gateway (Internet-routable).                                                                                                                          | `string`       | `null`        | no       |
| route_table_ids                                     | Route table IDs for VGW route propagation.                                                                                                                                      | `list(string)` | `[]`          | no       |
| transit_gateway_id                                  | Transit Gateway ID when the VPN attaches to a TGW instead of a VGW.                                                                                                             | `string`       | `null`        | no       |
| transit_gateway_route_table_id                      | TGW route table for static routes / optional TGW routes.                                                                                                                        | `string`       | `null`        | no       |
| transit_gateway_routes                              | Map of extra TGW routes (`destination_cidr_block`, optional `blackhole`).                                                                                                       | `map`          | `{}`          | no       |
| vpn_connection_static_routes_only                   | Use static routes only (no BGP).                                                                                                                                                | `bool`         | `false`       | no       |
| vpn_connection_static_routes_destinations           | On-prem CIDRs for static routing (VGW or TGW).                                                                                                                                  | `list(string)` | `[]`          | no       |
| vpn_connection_local_ipv4_network_cidr              | IPv4 CIDR on the customer (on-premises) side.                                                                                                                                   | `string`       | `"0.0.0.0/0"` | no       |
| vpn_connection_remote_ipv4_network_cidr             | IPv4 CIDR on the AWS side of the connection.                                                                                                                                    | `string`       | `"0.0.0.0/0"` | no       |
| vpn_connection_log_retention_in_days                | CloudWatch log retention for VPN logs.                                                                                                                                          | `number`       | `30`          | no       |
| vpn_connection_tunnel1_dpd_timeout_action           | DPD timeout action for tunnel 1 (`clear`, `none`, `restart`).                                                                                                                   | `string`       | `"clear"`     | no       |
| vpn_connection_tunnel1_ike_versions                 | Permitted IKE versions for tunnel 1.                                                                                                                                            | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel1_inside_cidr                  | Inside CIDR for tunnel 1.                                                                                                                                                       | `string`       | `null`        | no       |
| vpn_connection_tunnel1_phase1_encryption_algorithms | Phase 1 encryption algorithms for tunnel 1.                                                                                                                                     | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel1_phase2_encryption_algorithms | Phase 2 encryption algorithms for tunnel 1.                                                                                                                                     | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel1_phase1_integrity_algorithms  | Phase 1 integrity algorithms for tunnel 1.                                                                                                                                      | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel1_phase2_integrity_algorithms  | Phase 2 integrity algorithms for tunnel 1.                                                                                                                                      | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel1_phase1_dh_group_numbers      | Phase 1 DH groups for tunnel 1.                                                                                                                                                 | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel1_phase2_dh_group_numbers      | Phase 2 DH groups for tunnel 1.                                                                                                                                                 | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel1_phase1_lifetime_seconds      | Phase 1 IKE lifetime (seconds) for tunnel 1.                                                                                                                                    | `string`       | `"28800"`     | no       |
| vpn_connection_tunnel1_phase2_lifetime_seconds      | Phase 2 lifetime (seconds) for tunnel 1.                                                                                                                                        | `string`       | `"3600"`      | no       |
| vpn_connection_tunnel1_preshared_key                | Preshared key for tunnel 1.                                                                                                                                                     | `string`       | `null`        | no       |
| vpn_connection_tunnel1_startup_action               | Tunnel 1 startup action (`add` or `start`).                                                                                                                                     | `string`       | `"add"`       | no       |
| vpn_connection_tunnel1_cloudwatch_log_enabled       | Enable CloudWatch logging for tunnel 1.                                                                                                                                         | `bool`         | `false`       | no       |
| vpn_connection_tunnel1_cloudwatch_log_output_format | Log format for tunnel 1 (`json` or `text`).                                                                                                                                     | `string`       | `"json"`      | no       |
| vpn_connection_tunnel2_dpd_timeout_action           | DPD timeout action for tunnel 2.                                                                                                                                                | `string`       | `"clear"`     | no       |
| vpn_connection_tunnel2_ike_versions                 | Permitted IKE versions for tunnel 2.                                                                                                                                            | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel2_inside_cidr                  | Inside CIDR for tunnel 2.                                                                                                                                                       | `string`       | `null`        | no       |
| vpn_connection_tunnel2_phase1_encryption_algorithms | Phase 1 encryption algorithms for tunnel 2.                                                                                                                                     | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel2_phase2_encryption_algorithms | Phase 2 encryption algorithms for tunnel 2.                                                                                                                                     | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel2_phase1_integrity_algorithms  | Phase 1 integrity algorithms for tunnel 2.                                                                                                                                      | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel2_phase2_integrity_algorithms  | Phase 2 integrity algorithms for tunnel 2.                                                                                                                                      | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel2_phase1_dh_group_numbers      | Phase 1 DH groups for tunnel 2.                                                                                                                                                 | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel2_phase2_dh_group_numbers      | Phase 2 DH groups for tunnel 2.                                                                                                                                                 | `list(string)` | `[]`          | no       |
| vpn_connection_tunnel2_phase1_lifetime_seconds      | Phase 1 IKE lifetime (seconds) for tunnel 2.                                                                                                                                    | `string`       | `"28800"`     | no       |
| vpn_connection_tunnel2_phase2_lifetime_seconds      | Phase 2 lifetime (seconds) for tunnel 2.                                                                                                                                        | `string`       | `"3600"`      | no       |
| vpn_connection_tunnel2_preshared_key                | Preshared key for tunnel 2.                                                                                                                                                     | `string`       | `null`        | no       |
| vpn_connection_tunnel2_startup_action               | Tunnel 2 startup action (`add` or `start`).                                                                                                                                     | `string`       | `"add"`       | no       |
| vpn_connection_tunnel2_cloudwatch_log_enabled       | Enable CloudWatch logging for tunnel 2.                                                                                                                                         | `bool`         | `false`       | no       |
| vpn_connection_tunnel2_cloudwatch_log_output_format | Log format for tunnel 2 (`json` or `text`).                                                                                                                                     | `string`       | `"json"`      | no       |
| vpc_routes                                          | Wrapper-only: `{ <vpc_key> = { <suffix> = { destination_cidr_block / destination_cidr } } }` → `vpc_parameter.route_tables["<vpc_key>-<suffix>"]`; root `aws_route.vpn` to VGW. | `map`          | `{}`          | no       |
| tags                                                | Tags for this VPC and its resources.                                                                                                                                            | `map`          | `{}`          | no       |







## ⚠️ Important Notes
- **Secrets**: Preshared keys and sensitive tunnel settings end up in Terraform state; prefer `variable` + external secrets (SSM, Secrets Manager) or `-var` / CI secrets.
- **VPC key**: Use `vpc` (string) matching a key in `vpc_parameter.vpcs`, or supply `vpc_id` when not using the VPC wrapper map.
- **TGW key**: Use `tgw` matching a key in `tgw_parameter.transit_gateway` (same shape as `examples/complete/locals.tf`). Resolves `ec2_transit_gateway_id` and (unless overridden) route table from `ec2_transit_gateway_association_default_route_table_id` then `ec2_transit_gateway_route_table_id`. Override with `transit_gateway_id` / `transit_gateway_route_table_id` when needed.
- **Route tables (VGW)**: `vpn_connection.route_table_keys` is required (list; use `[]` for TGW-only VPNs). Each key must exist in `vpc_parameter.route_tables` or the plan fails. Enables `aws_vpn_gateway_route_propagation`. Optional **`vpc_routes`** is `{ <vpc_key> = { <suffix> = { destination_cidr_block / destination_cidr } } }` and resolves route tables as `"<vpc_key>-<suffix>"` in `vpc_parameter.route_tables`; avoid duplicating CIDRs already installed via propagation.
- **Submodule reference**: Behaviour and resource wiring are implemented in `modules/aws/terraform-aws-vpn-site-to-site` (variables mirror AWS resources).
- **Client VPN**: Placeholder sections in `main.tf` / `variables.tf` are not implemented yet.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 