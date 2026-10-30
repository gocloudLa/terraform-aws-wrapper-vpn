/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

variable "vpc_parameter" {
  type        = any
  description = "VPC wrapper outputs to configure the VPN module"
  default     = {}
}

variable "tgw_parameter" {
  type        = any
  description = "TGW wrapper outputs to configure the VPN module"
  default     = {}
}

/*----------------------------------------------------------------------*/
/* VPN | Variable Definition                                            */
/*----------------------------------------------------------------------*/
variable "vpn_parameters" {
  type        = any
  description = "VPN parameteres to configure VPN module"
  default     = {}

  # customer_gateway.key must name another entry that owns its gateway (ip_address or customer_gateway_id), with no chaining.
  validation {
    condition = alltrue([
      for k, v in var.vpn_parameters : try(v.customer_gateway.key, null) == null ? true : (
        try(v.customer_gateway.customer_gateway_id, null) == null &&
        v.customer_gateway.key != k &&
        try(var.vpn_parameters[v.customer_gateway.key].customer_gateway.key, null) == null &&
        (
          try(var.vpn_parameters[v.customer_gateway.key].customer_gateway.ip_address, null) != null ||
          try(var.vpn_parameters[v.customer_gateway.key].customer_gateway.customer_gateway_id, null) != null
        )
      )
    ])
    error_message = "customer_gateway.key must name another vpn_parameters entry that sets customer_gateway.ip_address or customer_gateway.customer_gateway_id and does not use key itself; do not combine key with customer_gateway_id. Invalid entries: ${join(", ", [
      for k, v in var.vpn_parameters : k if try(v.customer_gateway.key, null) == null ? false : !(
        try(v.customer_gateway.customer_gateway_id, null) == null &&
        v.customer_gateway.key != k &&
        try(var.vpn_parameters[v.customer_gateway.key].customer_gateway.key, null) == null &&
        (
          try(var.vpn_parameters[v.customer_gateway.key].customer_gateway.ip_address, null) != null ||
          try(var.vpn_parameters[v.customer_gateway.key].customer_gateway.customer_gateway_id, null) != null
        )
      )
    ])}."
  }
}

variable "vpn_defaults" {
  type        = any
  description = "VPN defaults parameteres to configure VPN module"
  default     = {}
}

# /*----------------------------------------------------------------------*/
# /* CLIENT VPN | Variable Definition                                     */
# /*----------------------------------------------------------------------*/
# variable "client_vpn_parameters" {
#   type        = any
#   description = "Cient VPN parameteres to configure Cient VPN module"
#   default     = {}
# }

# variable "client_vpn_defaults" {
#   type        = any
#   description = "Cient VPN defaults parameteres to configure Cient VPN module"
#   default     = {}
# }