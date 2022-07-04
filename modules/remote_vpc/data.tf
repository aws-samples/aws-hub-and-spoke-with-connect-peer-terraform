/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- moudles/connect_peer/data.tf ---

data "aws_ami" "csr" {
  most_recent = true

  filter {
    name   = "name"
    values = ["cisco_CSR-16.09.08-BYOL*"]
  }

  owners = ["679593333241"] # Cisco Systems
}
