/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- root/data.tf ---

data "external" "curlip" {
  program = ["sh", "-c", "echo '{ \"extip\": \"'$(curl -s https://ifconfig.me)'\" }'"]
}

# data "aws_eip" "connect_peer_csr_eip" {
#   filter {
#     name   = "tag:Type"
#     values = ["ConnectCSR"]
#   }
# }

# data "aws_eip" "remote_peer_csr_eip" {
#   filter {
#     name   = "tag:Type"
#     values = ["RemoteCSR"]
#   }
# }