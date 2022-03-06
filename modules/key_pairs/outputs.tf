/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- modules/key_pairs/outputs.tf ---

output "ssh_key_name" {
  description = "value of ssh_key_name"
  value       = aws_key_pair.key_pair.key_name
}

output "key_pair_file" {
  description = "value of key_pair_file"
  value       = local.rsa_id_file
}
