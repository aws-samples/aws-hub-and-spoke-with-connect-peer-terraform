<<<<<<< HEAD
## My Project

TODO: Fill this README out!

Be sure to:

* Change the title in this README
* Edit your repository description on GitHub

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

=======
---

---

# AWS Hub and Spoke Architecture with Shared Services and Transit Gateway Connect VPCs - Terraform Sample

This repository contains terraform code to deploy a sample AWS Hub and Spoke architecture with Shared Services and Transit Gateway Connect VPC, with the following centralized services:

- Managing EC2 instances using AWS Sytems Manager - ssm, ssmmessages and ec2messages VPC Endpoints.
- Deploy a Cisco CSR1000v iinto the Transit Gateway Connect VPC
  - Configure the Cisco CSR1000v using a templated user_data boot strap:
    - Connect to the Transit Gateway Connect Peer using a GRE Tunnel
    - Peer with the Transit Gateway Connect Peer BGP address using BGP
- Deploy a Cisco CSR1000v into a Remote Spoke VPC
  - Configure IPsec from the Remote Spoke VPC to the CSR1000v in the Connect VPC
  - BGP neighbourship between the Remote Spoke CSR1000v with the CSR1000v in the Connect VPC over the IPSec tunnel



The resources deployed and the architectural pattern they follow is purely for demonstration/testing purposes.

## Prerequisites

- An AWS account with an IAM user with the appropriate permissions
- Have a local RSA key (~/.ssh/id_rsa and ~/.ssh/id_rsa.pub). If none exists, use 'ssh-keygen' to generate
- Have an AWS Marketplace subscription for Cisco Cloud Services Router (CSR) 1000v - Transit Network VPC - BYOL software
- Terraform installed

## Code Principles:

- Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Usage

- Clone the repository
- Edit the *variables.tf* file in the project root directory. This file contains the variables that are used to configure the VPCs to create, and Hybrid DNS configuration needed to work with your environment.
- To change the configuration about the Security Groups and VPC endpoints to create, edit the *locals.tf* file in the project root directory
- Initialize Terraform using `terraform init`
- Deploy the template using `terraform apply`

## Terraform Output:

After the 'terraform apply' has completed, the output will provide all the information required to connect to the CSR 1000v as well as the AWS CLI command to query the relevant AWS Transit Gateway Route Table for propogated routes once BGP neighbours have formed between the AWS Transit Gateway and the Cisco CSR1000v.

------

## Target Architecture

<img src="./images/architecture_diagram.png" alt="Architecture diagram"  />

------

### References

- AWS SD-WAN Connectivity Reference Architecture - [SD-WAN Connectivity with AWS Transit Gateway Connect](https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/sd-wan-deployment-models-ra.pdf?did=wp_card&trk=wp_card)
- AWS Whitepaper - [Building a Scalable and Secure Multi-VPC AWS Network Infrastructure](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/welcome.html)

### Cleanup

Remember to clean up after your work is complete. You can do that by doing `terraform destroy`.

Note that this command will delete all the resources previously created by Terraform.

------

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.4.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_connect_vpc"></a> [connect\_vpc](#module\_connect\_vpc) | ./modules/connect_vpc | n/a |
| <a name="module_iam_kms"></a> [iam\_kms](#module\_iam\_kms) | ./modules/iam_kms | n/a |
| <a name="module_key_pairs"></a> [key\_pairs](#module\_key\_pairs) | ./modules/key_pairs | n/a |
| <a name="module_remote_vpc"></a> [remote\_vpc](#module\_remote\_vpc) | ./modules/remote_vpc | n/a |
| <a name="module_transit_gateway"></a> [transit\_gateway](#module\_transit\_gateway) | ./modules/transit_gateway | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ./modules/vpc_endpoints | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.csr_public_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [random_password.isakmp_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [external_external.curlip](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | BGP ASN for the TGW. | `number` | `64512` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to create the environment. | `string` | `"eu-west-1"` | no |
| <a name="input_connect_peer_cidr_blocks"></a> [connect\_peer\_cidr\_blocks](#input\_connect\_peer\_cidr\_blocks) | cidr blocks for connect peer | `list(string)` | <pre>[<br>  "169.254.200.0/29"<br>]</pre> | no |
| <a name="input_eips"></a> [eips](#input\_eips) | n/a | `map(any)` | <pre>{<br>  "connect_csr_eip": {<br>    "tags": {<br>      "Name": "connect-csr-eip",<br>      "Type": "ConnectCSR"<br>    }<br>  },<br>  "remote_csr_eip": {<br>    "tags": {<br>      "Name": "remote-csr-eip",<br>      "Type": "RemoteSR"<br>    }<br>  }<br>}</pre> | no |
| <a name="input_on_premises_cidr"></a> [on\_premises\_cidr](#input\_on\_premises\_cidr) | On-premises CIDR block. | `string` | `"192.168.0.0/16"` | no |
| <a name="input_project_identifier"></a> [project\_identifier](#input\_project\_identifier) | Project Name, used as identifer when creating resources. | `string` | `"hub-spoke-connect"` | no |
| <a name="input_transit_gateway_cidr_block"></a> [transit\_gateway\_cidr\_block](#input\_transit\_gateway\_cidr\_block) | cidr blocks for connect peer | `string` | `"192.168.100.0/24"` | no |
| <a name="input_tunnel_cidr_block"></a> [tunnel\_cidr\_block](#input\_tunnel\_cidr\_block) | cidr blocks for connect peer | `string` | `"169.254.201.0/29"` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPCs to create. | `map(any)` | <pre>{<br>  "connect-vpc-1": {<br>    "cidr_block": "10.132.0.0/16",<br>    "csr_hostname_prefix": "csr",<br>    "csr_instance_size": "c5.large",<br>    "instance_count": 1,<br>    "local_bgp_asn": 64515,<br>    "number_azs": 2,<br>    "remote_bgp_asn": 64512,<br>    "spoke_type": "connect"<br>  },<br>  "remote-vpc-1": {<br>    "cidr_block": "10.251.0.0/16",<br>    "csr_hostname_prefix": "csr",<br>    "csr_instance_size": "c5.large",<br>    "instance_count": 1,<br>    "local_bgp_asn": 64516,<br>    "number_azs": 2,<br>    "remote_bpg_asn": 64515,<br>    "spoke_type": "remote"<br>  },<br>  "spoke-vpc-1": {<br>    "cidr_block": "10.11.0.0/16",<br>    "instance_type": "t2.micro",<br>    "number_azs": 1,<br>    "spoke_type": "spoke"<br>  },<br>  "spoke-vpc-2": {<br>    "cidr_block": "10.12.0.0/16",<br>    "instance_type": "t2.micro",<br>    "number_azs": 1,<br>    "spoke_type": "spoke"<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connect_aws_eip_csr_public_ip"></a> [connect\_aws\_eip\_csr\_public\_ip](#output\_connect\_aws\_eip\_csr\_public\_ip) | Public IP of the AWS EIP Connect CSR instance |
| <a name="output_connect_csr_instance_id"></a> [connect\_csr\_instance\_id](#output\_connect\_csr\_instance\_id) | Instance ID of the CSR instance created |
| <a name="output_instances_created"></a> [instances\_created](#output\_instances\_created) | Instances created in each VPC |
| <a name="output_isakmp_secret"></a> [isakmp\_secret](#output\_isakmp\_secret) | ISAKMP secret key |
| <a name="output_remote_aws_eip_csr_public_ip"></a> [remote\_aws\_eip\_csr\_public\_ip](#output\_remote\_aws\_eip\_csr\_public\_ip) | Public IP of the AWS EIP remote CSR instance |
| <a name="output_tgw_route_table_id"></a> [tgw\_route\_table\_id](#output\_tgw\_route\_table\_id) | Transit Gateway Route Table ID |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | Transit Gateway ID |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | DNS name (regional) of the VPC endpoints created. |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | List of VPCs created |
| <a name="output_z_output_user_message"></a> [z\_output\_user\_message](#output\_z\_output\_user\_message) | Route table search command |
<!-- END_TF_DOCS -->                                         |                                                   |

------

## Security

See [CONTRIBUTING](CONTRIBUTING.md) for more information.

------

## License

This library is licensed under the MIT-0 License. See the [LICENSE](LICENSE) file.
