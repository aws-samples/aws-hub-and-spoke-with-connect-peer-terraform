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

