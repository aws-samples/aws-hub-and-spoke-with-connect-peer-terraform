/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- modules/transit_gateway/main.tf ---

# TRANSIT GATEWAY
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit-Gateway-${var.identifier}"
  transit_gateway_cidr_blocks     = [var.transit_gateway_cidr_block]
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation

  tags = {
    Name = "transit-gateway-${var.identifier}"
  }
}

# TRANSIT GATEWAY ATTACHMENTS
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachments" {
  for_each                                        = { for k, v in var.vpcs : k => v if length(regexall("spoke", k)) > 0 }
  subnet_ids                                      = each.value.tgw_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = each.value.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${each.key}-tgw-attachment-${var.identifier}"
  }
}

# VPC ROUTES TO TGW 
module "tgw_vpc_route" {
  for_each           = { for k, v in var.vpcs : k => v if length(regexall("spoke", k)) > 0 }
  source             = "../tgw_vpc_route"
  tgw_id             = aws_ec2_transit_gateway.tgw.id
  private_subnet_rts = each.value.private_subnet_rts
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attachments
  ]
}

# TRANSIT GATEWAY ROUTE TABLES
# Spoke VPC
resource "aws_ec2_transit_gateway_route_table" "spoke_vpc_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "spoke-vpc-rt-${var.identifier}"
  }
}

# TRANSIT GATEWAY RT ASSOCIATIONS
# Spoke VPC Attachments association to Spoke VPC TGW Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_vpc_tgw_association" {
  for_each                       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachments : k => v.id if length(regexall("spoke", k)) > 0 }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_tgw_rt.id
}
