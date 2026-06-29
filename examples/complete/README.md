# Complete Site-to-Site VPN Example 🚀

This example wires the VPN wrapper with metadata, optional `vpc_parameter` and `tgw_parameter` inputs (typically from the VPC and TGW wrappers), and sample `vpn_parameters` entries (VGW + TGW) with static routes, `route_table_keys`, nested `vpc_routes` (`{ <vpc_key> = { private/public = { destination_cidr_block } } }`), and tunnel options.

## 🔧 What's Included

### Analysis of Terraform Configuration

#### Main Purpose
The main purpose is to show how to call `module.wrapper_vpn` with the same file split as other Standard Platform examples (main.tf, variables.tf, metadata.tf, locals.tf, providers.tf, data_sources.tf, outputs.tf, conditions.tf) and how `vpc`, `route_table_keys`, and `vpc_routes` line up with `vpc_parameter.route_tables` keys (`<vpc_key>-<suffix>`).

#### Key Features Demonstrated
- **Inputs**: `vpc_parameter` and `tgw_parameter` are passed as variables (defaults empty) so a root module can inject outputs from `wrapper-vpc` and `wrapper-tgw`.
- **VPN entries**: e.g. `vpn-vpc` (VGW + `vpc_routes` nesting) and `vpn-tgw` with `virtual_private_gateway = null`, `customer_gateway`, and `vpn_connection` settings.
- **Static routing**: `static_routes_only`, `static_routes_destinations`, and `route_table_keys` aligned with wrapper-vpc `route_tables` keys for VGW propagation.
- **Tunnels**: Explicit `tunnel1_*` and `tunnel2_*` options (IKE versions, phases, PSK placeholders, CloudWatch log toggles) matching the inner `terraform-aws-vpn-site-to-site` module.
- **Tags**: The wrapper merges `common_tags` from `metadata` with a per-VPN `Name` (see root `metadata.tf`).

## 🚀 Quick Start

```bash
terraform init
terraform plan
terraform apply
```

## 🔒 Security Notes

⚠️ **Production Considerations**: 
- This example may include configurations that are not suitable for production environments
- Review and customize security settings, access controls, and resource configurations
- Ensure compliance with your organization's security policies
- Consider implementing proper monitoring, logging, and backup strategies

## 📖 Documentation

For detailed module documentation and additional examples, see the main [README.md](../../README.md) file. 