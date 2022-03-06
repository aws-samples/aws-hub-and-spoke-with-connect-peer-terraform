/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- modules/connect_vpc/csr_sg.tf ---

resource "aws_security_group" "csr_public_interface_security_group" {
  for_each    = local.csr_public_interface_security_group
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id


  #public Security Group
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from
      to_port     = egress.value.to
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${var.vpc_name} CSR Public Interface Security Group"
  }
}

resource "aws_security_group" "internal" {
  name        = "internal_traffic_security_group"
  description = "Traffic Allowed from instance back internally"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "Allow all egress traffic from AWS VPCs and Transit Gateway Peer CIDR"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.cidr_blocks
  }
  egress {
    description = "Allow all egress traffic to AWS VPCs and Transit Gateway Peer CIDR"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.cidr_blocks
  }
  tags = {
    Name = "${var.vpc_name} Internal Traffic Security Group"
  }
}
