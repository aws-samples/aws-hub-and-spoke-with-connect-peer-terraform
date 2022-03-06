/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- root/data.tf ---

data "external" "curlip" {
  program = ["sh", "-c", "echo '{ \"extip\": \"'$(curl -s https://ifconfig.me)'\" }'"]
}