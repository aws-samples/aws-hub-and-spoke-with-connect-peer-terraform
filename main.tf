/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- root/main.tf ---

module "vpc" {
  for_each   = { for k, v in var.vpcs : k => v if v.spoke_type != "connect" }
  source     = "./modules/vpc"
  identifier = var.project_identifier
  vpc_name   = each.key
  vpc_info   = each.value
}

module "connect_vpc" {
  source                     = "./modules/connect_vpc"
  for_each                   = { for k, v in var.vpcs : k => v if v.spoke_type == "connect" }
  connect_peer_cidr_blocks   = var.connect_peer_cidr_blocks
  identifier                 = var.project_identifier
  key_name                   = module.key_pairs.ssh_key_name
  tgw_cidr_block             = module.transit_gateway.tgw_cidr_block
  tgw_spoke_route_table      = module.transit_gateway.tgw_spoke_route_table
  transit_gateway_id         = module.transit_gateway.tgw_id
  vpc_info                   = each.value
  vpc_name                   = each.key
  remote_tunnel_bgp_asn      = local.remote_vpc_public_ip_asn
  isakmp_secret              = random_password.isakmp_secret.result
  tunnel_cidr_block          = var.tunnel_cidr_block
  my_ip                      = data.external.curlip.result.extip
  eips                       = aws_eip.csr_public_ip
  transit_gateway_cidr_block = var.transit_gateway_cidr_block
  vpcs                       = var.vpcs
}

module "remote_vpc" {
  source                = "./modules/remote_vpc"
  for_each              = { for k, v in var.vpcs : k => v if v.spoke_type == "remote" }
  identifier            = var.project_identifier
  key_name              = module.key_pairs.ssh_key_name
  vpc_info              = each.value
  vpc_name              = each.key
  remote_tunnel_bgp_asn = local.connect_vpc_public_ip_asn
  isakmp_secret         = random_password.isakmp_secret.result
  tunnel_cidr_block     = var.tunnel_cidr_block
  my_ip                 = data.external.curlip.result.extip
  eips                  = aws_eip.csr_public_ip

}

module "transit_gateway" {
  source                     = "./modules/transit_gateway"
  identifier                 = var.project_identifier
  vpcs                       = merge(module.vpc, module.connect_vpc)
  amazon_side_asn            = var.amazon_side_asn
  transit_gateway_cidr_block = var.transit_gateway_cidr_block
}

module "key_pairs" {
  source     = "./modules/key_pairs"
  identifier = var.project_identifier
  aws_region = var.aws_region
}

module "compute" {
  for_each                 = { for k, v in module.vpc : k => v if length(regexall("spoke", k)) > 0 }
  source                   = "./modules/compute"
  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_info                 = each.value
  instance_type            = var.vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam_kms.ec2_iam_instance_profile
  ec2_security_group       = local.security_groups.spoke_vpc.instance
  key_name                 = module.key_pairs.ssh_key_name
}

module "vpc_endpoints" {
  for_each                 = { for k, v in merge(module.vpc, module.connect_vpc, module.remote_vpc) : k => v }
  source                   = "./modules/vpc_endpoints"
  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_info                 = each.value
  endpoints_security_group = local.security_groups.vpc_endpoints.endpoints
  endpoint_service_names   = local.endpoint_service_names
}


module "iam_kms" {
  source     = "./modules/iam_kms"
  identifier = var.project_identifier
  aws_region = var.aws_region
}

resource "random_password" "isakmp_secret" {
  length           = 8
  special          = true
  override_special = "_%@"
}

resource "aws_eip" "csr_public_ip" {
  for_each = { for k, v in var.eips : k => v }
  vpc      = true

  tags = merge(each.value.tags)
}
