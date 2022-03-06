/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- moudles/connect_peer/locals.tf ---

locals {
  hostname               = "${var.vpc_name}-csr01"
  aws_asn                = var.vpc_info.remote_bgp_asn
  aws_tunnel_ip_1        = cidrhost(one(aws_ec2_transit_gateway_connect_peer.tgw_connect_peer.inside_cidr_blocks), 2)
  aws_tunnel_ip_2        = cidrhost(one(aws_ec2_transit_gateway_connect_peer.tgw_connect_peer.inside_cidr_blocks), 3)
  cgw_asn                = aws_ec2_transit_gateway_connect_peer.tgw_connect_peer.bgp_asn
  cgw_tunnel_destination = aws_ec2_transit_gateway_connect_peer.tgw_connect_peer.transit_gateway_address
  cgw_tunnel_interface   = 1
  cgw_tunnel_ip_address  = cidrhost(one(aws_ec2_transit_gateway_connect_peer.tgw_connect_peer.inside_cidr_blocks), 1)
  cgw_tunnel_source      = aws_network_interface.g2.private_ip
  internal_route         = join(" ", [split("/", aws_subnet.vpc_private_subnets[0].cidr_block)[0], cidrnetmask(aws_subnet.vpc_private_subnets[0].cidr_block)])
  vpc_router             = cidrhost(aws_subnet.vpc_private_subnets[0].cidr_block, 1)
  network_cidr           = split("/", var.vpc_info.cidr_block)[0]
  network_mask           = cidrnetmask(var.vpc_info.cidr_block)
  remote_peer_tunnel_ip  = local.remote_csr_eip_ip
  local_bgp_asn          = var.vpc_info.local_bgp_asn
  remote_tunnel_bgp_asn  = var.remote_tunnel_bgp_asn
  tunnel_number          = 11
  isakmp_secret          = var.isakmp_secret
  tunnel_source_ip       = cidrhost(var.tunnel_cidr_block, 1)
  tunnel_source_mask     = cidrnetmask(var.tunnel_cidr_block)
  tunnel_destination_ip  = cidrhost(var.tunnel_cidr_block, 2)
  tunnel_cidr_block      = split("/", var.transit_gateway_cidr_block)[0]
  tunnnel_cidr_mask      = cidrnetmask(var.transit_gateway_cidr_block)

  local_csr_eip_id  = { for k, v in var.eips : k => v.id if length(regexall("connect", k)) > 0 }.connect_csr_eip
  local_csr_eip_ip  = { for k, v in var.eips : k => v.public_ip if length(regexall("connect", k)) > 0 }.connect_csr_eip
  remote_csr_eip_ip = { for k, v in var.eips : k => v.public_ip if length(regexall("remote", k)) > 0 }.remote_csr_eip

  spoke_cidr_blocks = values({ for k, v in var.vpcs : k => v.cidr_block if v.spoke_type == "spoke" || v.spoke_type == "connect" })
  cidr_blocks       = concat([var.tgw_cidr_block[0], var.tunnel_cidr_block], local.spoke_cidr_blocks)

  csr_public_interface_security_group = {
    public = {
      name        = "cs_public_sg"
      description = "Security Group for Cisco CSR instances"
      ingress = {
        ssh = {
          description = "Allow SSH access from the executing instance IP address"
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = ["${var.my_ip}/32"]
        }
        ipsec = {
          description = "Allow IPSec access from the peer CSR public IP address"
          from        = 500
          to          = 500
          protocol    = "udp"
          cidr_blocks = ["${local.remote_csr_eip_ip}/32"]
        }
        esp = {
          description = "Allow ESP access from the peer CSR public IP address"
          from        = 0
          to          = 0
          protocol    = 50
          cidr_blocks = ["${local.remote_csr_eip_ip}/32"]
        }
        nat-t = {
          description = "Allow NAT-T access from the peer CSR public IP address"
          from        = 4500
          to          = 4500
          protocol    = "udp"
          cidr_blocks = ["${local.remote_csr_eip_ip}/32"]
        }
        icmp = {
          description = "Allow NAT-T access from the peer CSR public IP address"
          from        = -1
          to          = -1
          protocol    = "icmp"
          cidr_blocks = ["${local.remote_csr_eip_ip}/32"]
        }
      }
      egress = {
        ipsec = {
          description = "Allow IPSec access from the peer CSR public IP address"
          from        = 500
          to          = 500
          protocol    = "udp"
          cidr_blocks = ["${local.local_csr_eip_ip}/32"]
        }
        esp = {
          description = "Allow ESP access from the peer CSR public IP address"
          from        = 0
          to          = 0
          protocol    = 50
          cidr_blocks = ["${local.local_csr_eip_ip}/32"]
        }
        nat-t = {
          description = "Allow NAT-T access from the peer CSR public IP address"
          from        = 4500
          to          = 4500
          protocol    = "udp"
          cidr_blocks = ["${local.local_csr_eip_ip}/32"]
        }
      }
    }
  }
}
