/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- root/locals.tf ---

locals {
  connect_vpc_public_ip_asn = values({ for k, v in var.vpcs : k => v.local_bgp_asn if v.spoke_type == "connect" })[0]
  remote_vpc_public_ip_asn  = values({ for k, v in var.vpcs : k => v.local_bgp_asn if v.spoke_type == "remote" })[0]

  security_groups = {
    spoke_vpc = {
      instance = {
        name        = "instance_sg"
        description = "Security Group used in the instances"
        ingress = {
          icmp = {
            description = "Allowing ICMP traffic"
            from        = -1
            to          = -1
            protocol    = "icmp"
            cidr_blocks = ["0.0.0.0/0"]
          }
          ssh = {
            description = "Allowing SSH traffic"
            from        = 22
            to          = 22
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
        egress = {
          any = {
            description = "Any traffic"
            from        = 0
            to          = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
        tags = {
          Name = "Instance Security Group"
        }
      }
    }
    vpc_endpoints = {
      endpoints = {
        name        = "endpoints_sg"
        description = "Security Group for SSM connection"
        ingress = {
          https = {
            description = "Allowing HTTPS"
            from        = 443
            to          = 443
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
        egress = {
          any = {
            description = "Any traffic"
            from        = 0
            to          = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
        tags = {
          Name = "VPC Endpoint Security Group"
        }
      }
    }
  }

  endpoint_service_names = {
    ssm = {
      name           = "com.amazonaws.${var.aws_region}.ssm"
      type           = "Interface"
      private_dns    = true
      phz_needed     = true
      phz_name       = "ssm.${var.aws_region}.amazonaws.com"
      phz_alias_name = ""
    }
    ssmmessages = {
      name           = "com.amazonaws.${var.aws_region}.ssmmessages"
      type           = "Interface"
      private_dns    = true
      phz_needed     = true
      phz_name       = "ssmmessages.${var.aws_region}.amazonaws.com"
      phz_alias_name = ""
    }
    ec2messages = {
      name           = "com.amazonaws.${var.aws_region}.ec2messages"
      type           = "Interface"
      private_dns    = true
      phz_needed     = true
      phz_name       = "ec2messages.${var.aws_region}.amazonaws.com"
      phz_alias_name = ""
    }
  }
}
