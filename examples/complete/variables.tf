/*----------------------------------------------------------------------*/
/* Wiring from VPC / TGW wrappers (or tfvars)                           */
/*----------------------------------------------------------------------*/
variable "vpc_parameter" {
  type        = any
  description = "Outputs from wrapper VPC: vpcs, subnets, route_tables."
  default     = {}
}

variable "tgw_parameter" {
  type        = any
  description = "Map with transit_gateway output map from wrapper TGW (if using TGW attachment)."
  default     = {}
}

variable "vpn_defaults" {
  type        = any
  description = "Optional defaults merged across vpn_parameters (not used by root module until extended)."
  default     = {}
}
