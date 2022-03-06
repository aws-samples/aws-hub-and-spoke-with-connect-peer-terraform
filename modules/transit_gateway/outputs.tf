/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- modules/transit_gateway/outputs.tf ---

output "tgw_id" {
  value       = aws_ec2_transit_gateway.tgw.id
  description = "Transit Gateway ID"
}

output "tgw_spoke_route_table" {
  value       = aws_ec2_transit_gateway_route_table.spoke_vpc_tgw_rt
  description = "Transit Gateway Spoke Route Table"
}

output "tgw_cidr_block" {
  value       = aws_ec2_transit_gateway.tgw.transit_gateway_cidr_blocks
  description = "Transit Gateway Peer CIDR Block"
}

output "amazon_side_asn" {
  value       = aws_ec2_transit_gateway.tgw.amazon_side_asn
  description = "Transit Gateway Amazon Side ASN"
}