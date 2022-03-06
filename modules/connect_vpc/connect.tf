/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- modules/connect_vpc/connect.tf ---

# Create a VPC attchemnt to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachments" {
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.vpc.id
  subnet_ids                                      = [for i in aws_subnet.vpc_tgw_subnets : i.id]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "connect-vpc/connect-vpc-tgw-attachments"
  }
}

# Create a Transit Gateway Connect Attachment
resource "aws_ec2_transit_gateway_connect" "tgw_connect" {
  transit_gateway_id                              = var.transit_gateway_id
  transport_attachment_id                         = aws_ec2_transit_gateway_vpc_attachment.tgw_attachments.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "connect-vpc/connect-vpc-tgw-connect"
  }
}

# Create a Transit Gateway Connect Peer
resource "aws_ec2_transit_gateway_connect_peer" "tgw_connect_peer" {
  inside_cidr_blocks            = [var.connect_peer_cidr_blocks[0]]
  peer_address                  = aws_network_interface.g2.private_ip
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.tgw_connect.id
  bgp_asn                       = var.vpc_info.local_bgp_asn

  tags = {
    Name = "${var.identifier}-tgw-connect-peer-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "connect_vpc_tgw_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachments.id
  transit_gateway_route_table_id = var.tgw_spoke_route_table.id
}
resource "aws_ec2_transit_gateway_route_table_association" "connect_peer_vpc_tgw_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect_peer.tgw_connect_peer.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_spoke_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "connect_vpc_tgw_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachments.id
  transit_gateway_route_table_id = var.tgw_spoke_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "connect_peer_vpc_tgw_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect_peer.tgw_connect_peer.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_spoke_route_table.id
}

