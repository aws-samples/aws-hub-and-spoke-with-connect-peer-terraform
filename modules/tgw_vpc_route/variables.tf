/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- modules/transit_gateway/tgw_vpc_route/variables.tf ---

variable "tgw_id" {
  type        = string
  description = "Transit Gateway ID"
}

variable "private_subnet_rts" {
  type        = any
  description = "List of private subnets to add the default route to the TGW."
}
