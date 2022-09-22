/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
  SPDX-License-Identifier: MIT-0 */

# --- modules/rempote_vpc/csr.tf ---

locals {
  csr_userdata = templatefile("${path.root}/templates/remote_csr_boot_strap_1.tpl", {
    hostname              = local.hostname
    isakmp_secret         = local.isakmp_secret
    remote_peer_tunnel_ip = local.remote_peer_tunnel_ip
    tunnel_number         = local.tunnel_number
    network_cidr          = local.network_cidr
    network_mask          = local.network_mask
    remote_tunnel_bgp_asn = local.remote_tunnel_bgp_asn
    local_bgp_asn         = local.local_bgp_asn
    tunnel_source_ip      = local.tunnel_source_ip
    tunnel_source_mask    = local.tunnel_source_mask
    tunnel_destination_ip = local.tunnel_destination_ip
  })
}

resource "aws_network_interface" "g1" {
  subnet_id         = aws_subnet.vpc_public_subnets[0].id
  security_groups   = [for i in aws_security_group.csr_public_interface_security_group : i.id]
  source_dest_check = false

  tags = {
    "Name" = "${var.vpc_info.csr_hostname_prefix}-public-interface"
  }
}


resource "aws_network_interface" "g2" {
  subnet_id         = aws_subnet.vpc_private_subnets[0].id
  security_groups   = [aws_security_group.internal.id]
  source_dest_check = false

  tags = {
    "Name" = "${var.vpc_info.csr_hostname_prefix}-private-interface"
  }
}

resource "aws_eip_association" "eip_assoc" {
  allocation_id        = local.local_csr_eip_id
  network_interface_id = aws_network_interface.g1.id
}


resource "aws_instance" "csr" {
  count         = var.vpc_info.instance_count
  ami           = data.aws_ami.csr.id
  instance_type = var.vpc_info.csr_instance_size
  key_name      = var.key_name
  user_data     = local.csr_userdata

  network_interface {
    network_interface_id = aws_network_interface.g1.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.g2.id
    device_index         = 1
  }

  tags = {
    Name = "${var.vpc_name}-csr-${count.index + 1}"
  }
  lifecycle {
    ignore_changes = [
      iam_instance_profile
    ]
  }
}