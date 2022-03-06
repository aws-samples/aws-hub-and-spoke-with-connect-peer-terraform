/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- modules/vpc/outputs.tf ---

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "ID of the VPC created"
}

output "private_subnets" {
  value       = aws_subnet.vpc_private_subnets[*].id
  description = "List of private subnets created - to place the EC2 instance(s) or VPC endpoints."
}

output "tgw_subnets" {
  value       = aws_subnet.vpc_tgw_subnets[*].id
  description = "List of TGW subnets - to place the TGW ENIs."
}

output "private_subnet_rts" {
  value       = aws_route_table.vpc_private_subnet_rt[*].id
  description = "List of route tables of the private subnets."
}