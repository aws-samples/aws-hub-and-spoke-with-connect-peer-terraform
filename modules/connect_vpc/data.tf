/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- moudles/connect_peer/data.tf ---

data "aws_ami" "csr" {
  most_recent = true

  filter {
    name   = "name"
    values = ["cisco-CSR-.16.12.01a-BYOL*"]
  }

  owners = ["679593333241"] # Cisco Systems
}

# data "aws_eip" "peer_csr_eip" {
#   filter {
#     name   = "tag:Type"
#     values = ["RemoteCSR"]
#   }
# }
