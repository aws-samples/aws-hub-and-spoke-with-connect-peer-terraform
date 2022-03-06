/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- modules/connect_vpc/variables.tf ---
variable "identifier" {
  type        = string
  description = "Project identifier."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC where the EC2 instance(s) are created."
}

variable "vpc_info" {
  type        = any
  description = "Information about the VPC where the EC2 instance(s) are created."
}

variable "key_name" {
  type        = string
  description = "ssh key pair name"
}

variable "transit_gateway_id" {
  type        = string
  description = "transit gateway id"
}

variable "tgw_spoke_route_table" {
  type        = any
  description = "spoke vpc tgw route table"
}

variable "tgw_cidr_block" {
  type        = list(string)
  description = "cidr block for tgw"
}

variable "connect_peer_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for connect peer"
}

variable "remote_tunnel_bgp_asn" {
  type        = string
  description = "ASN of the remote CSR"
}

variable "isakmp_secret" {
  type        = string
  description = "ISAKMP secret for the VPN."
}

variable "tunnel_cidr_block" {
  type        = string
  description = "CIDR block for the VPN tunnel."
}

variable "my_ip" {
  type        = string
  description = "Public IP address of the executing instance."
}

variable "eips" {
  type        = any
  description = "List of Elastic IPs to be used for the CSR instances."
}

variable "transit_gateway_cidr_block" {
  type        = string
  description = "CIDR block for the transit gateway."
}

variable "vpcs" {
  type        = any
  description = "All VPC information used to create VPCS"
}
