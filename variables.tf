/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- root/variables.tf ---

# AWS REGION
variable "aws_region" {
  type        = string
  description = "AWS Region to create the environment."
  default     = "eu-west-1"
}

variable "amazon_side_asn" {
  type        = number
  description = "BGP ASN for the TGW."
  default     = 64512
}


variable "connect_peer_cidr_blocks" {
  description = "cidr blocks for connect peer"
  default     = ["169.254.200.0/29"]
  type        = list(string)
}

variable "tunnel_cidr_block" {
  description = "cidr blocks for connect peer"
  default     = "169.254.201.0/29"
  type        = string
}

variable "transit_gateway_cidr_block" {
  description = "cidr blocks for connect peer"
  default     = "192.168.100.0/24"
}

# PROJECT IDENTIFIER
variable "project_identifier" {
  type        = string
  description = "Project Name, used as identifer when creating resources."
  default     = "hub-spoke-connect"
}

# INFORMATION ABOUT THE VPCs TO CREATE
variable "vpcs" {
  type        = map(any)
  description = "VPCs to create."
  default = {
    "spoke-vpc-1" = {
      spoke_type    = "spoke"
      cidr_block    = "10.11.0.0/16"
      number_azs    = 1
      instance_type = "t2.micro"
    }
    "spoke-vpc-2" = {
      spoke_type    = "spoke"
      cidr_block    = "10.12.0.0/16"
      number_azs    = 1
      instance_type = "t2.micro"
    }
    "connect-vpc-1" = {
      spoke_type          = "connect"
      cidr_block          = "10.132.0.0/16"
      number_azs          = 2
      instance_count      = 1
      remote_bgp_asn      = 64512
      local_bgp_asn       = 64515
      csr_hostname_prefix = "csr"
      csr_instance_size   = "c5.large"
    }
    "remote-vpc-1" = {
      spoke_type          = "remote"
      cidr_block          = "10.251.0.0/16"
      number_azs          = 2
      instance_count      = 1
      remote_bpg_asn      = 64515
      local_bgp_asn       = 64516
      csr_hostname_prefix = "csr"
      csr_instance_size   = "c5.large"
    }
  }
}

variable "on_premises_cidr" {
  type        = string
  description = "On-premises CIDR block."
  default     = "192.168.0.0/16"
}

variable "eips" {
  type = map(any)
  default = {
    connect_csr_eip = {
      tags = {
        Name = "connect-csr-eip"
        Type = "ConnectCSR"
      }
    }
    remote_csr_eip = {
      tags = {
        Name = "remote-csr-eip"
        Type = "RemoteSR"
      }
    }
  }
}
