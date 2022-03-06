/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- root/outputs.tf ---

output "instances_created" {
  value       = module.compute
  description = "Instances created in each VPC"
}

output "transit_gateway" {
  value       = module.transit_gateway.tgw_id
  description = "Transit Gateway ID"
}

output "tgw_route_table_id" {
  value       = module.transit_gateway.tgw_spoke_route_table.id
  description = "Transit Gateway Route Table ID"
}

output "vpcs" {
  value       = { for key, value in module.vpc : key => value.vpc_id }
  description = "List of VPCs created"
}

locals {
  vpc_endpoints        = [for i in module.vpc_endpoints : { for k, v in i : k => v if length(regexall("endpoints", k)) > 0 }]
  endpoint_info        = [for i in local.vpc_endpoints : i.endpoints_info]
  connect_instances    = [for i in module.connect_vpc : { for k, v in i : k => v if length(regexall("csr", k)) > 0 }]
  connect_csr_instance = [for i in { for k, v in local.connect_instances[0]["csr_instance"] : k => v } : i.id]
}

output "vpc_endpoints" {
  value       = { for k, v in local.endpoint_info[0] : k => v.dns_name }
  description = "DNS name (regional) of the VPC endpoints created."
}

output "connect_csr_instance_id" {
  value       = [for i in { for k, v in local.connect_instances[0]["csr_instance"] : k => v } : i.id]
  description = "Instance ID of the CSR instance created"
}

output "isakmp_secret" {
  value       = random_password.isakmp_secret
  description = "ISAKMP secret key"
  sensitive   = true
}

output "z_output_user_message" {
  value       = <<-EOF
Wait a few seconds then run the following command to search the route table for the transit gateway routes:

aws ec2 search-transit-gateway-routes --transit-gateway-route-table-id ${module.transit_gateway.tgw_spoke_route_table.id} --filters "Name=state,Values=active" --region ${var.aws_region} | jq '.Routes[] | .DestinationCidrBlock,.Type' | paste - -

To connect to the Connect VPC CSR console using ssm, run:
aws ec2-instance-connect send-serial-console-ssh-public-key \
  --instance-id  ${local.connect_csr_instance[0]} \
  --serial-port 0 \
  --ssh-public-key file://${module.key_pairs.key_pair_file} \
  --region ${var.aws_region}

  To connect to the CSM:

  ssh -i ${module.key_pairs.key_pair_file} ${local.connect_csr_instance[0]}.port0@serial-console.ec2-instance-connect.${var.aws_region}.aws

EOF
  description = "Route table search command"
}

output "connect_aws_eip_csr_public_ip" {
  value       = { for k, v in aws_eip.csr_public_ip : k => v.public_ip if length(regexall("connect", k)) > 0 }.connect_csr_eip
  description = "Public IP of the AWS EIP Connect CSR instance"
}

output "remote_aws_eip_csr_public_ip" {
  value       = { for k, v in aws_eip.csr_public_ip : k => v.public_ip if length(regexall("remote", k)) > 0 }.remote_csr_eip
  description = "Public IP of the AWS EIP remote CSR instance"
}