/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- modules/key_pairs/main.tf ---

# Use the random pet name as the EC2 instance name
resource "random_pet" "key_name" {
  length = 2
}

# Create an AWS SSH keypair for the EC2 instance
resource "aws_key_pair" "key_pair" {
  key_name   = random_pet.key_name.id
  public_key = file(local.rsa_id_file)
  tags = {
    Provisioner = "Terraform-Created_Key_Pair"
  }
}
