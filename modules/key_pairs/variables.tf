/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- modules/key_pairs/variables.tf ---
variable "aws_region" {
  type        = string
  description = "value of the AWS region"
}

variable "identifier" {
  type        = string
  description = "value of the identifier"
}
